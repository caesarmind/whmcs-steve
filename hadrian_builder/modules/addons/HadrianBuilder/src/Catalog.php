<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * What a section can show from WHMCS itself: products and announcements.
 *
 * Prices come from WHMCS's own product model, in the visitor's currency, on
 * every request. Nothing about a price is stored in a page, so a price change
 * in WHMCS shows on the next page view.
 *
 * The Renderer only ever calls products() and announcements(); a test hands
 * it a stand-in with the same two methods.
 *
 * One product, as a template receives it (a product field `x` gives `xData`):
 *
 *   id        int
 *   name      string
 *   tagline   the introduction line of the product description
 *   features  list of strings, the description's list items
 *   free      bool
 *   price     "$3.74"   the first available cycle; '' when there is none
 *   per       "/mo"     '' for a one-time or free product
 *   cycle     "monthly" the cycle `price` is for; '' when there is none
 *   cycles    every available cycle, keyed by its WHMCS name:
 *             monthly, quarterly, semiannually, annually, biennially,
 *             triennially (and onetime). Each is
 *             { price: "$35.88", per: "/yr", monthly: "$2.99" }
 *             where `monthly` is that cycle's cost per month.
 *   orderUrl  link that puts the product in the cart
 */
class Catalog
{
    /** @var array<int, array<string,mixed>|null> */
    private array $memo = [];

    /**
     * @param list<int> $ids
     * @return array<int, array<string,mixed>> id => product data; a missing or retired product is left out
     */
    public function products(array $ids): array
    {
        $out = [];
        foreach (array_unique(array_filter(array_map('intval', $ids))) as $id) {
            if (!array_key_exists($id, $this->memo)) {
                $this->memo[$id] = $this->load($id);
            }
            if ($this->memo[$id] !== null) {
                $out[$id] = $this->memo[$id];
            }
        }
        return $out;
    }

    /** @return array<string,mixed>|null */
    private function load(int $id): ?array
    {
        try {
            $p = \WHMCS\Product\Product::find($id);
            if ($p === null || !empty($p->retired)) {
                return null;
            }
            [$tagline, $features] = self::splitDescription((string)$p->description);

            $data = [
                'id'       => $id,
                'name'     => (string)$p->name,
                'tagline'  => $tagline,
                'features' => $features,
                'free'     => (bool)$p->isFree(),
                'price'    => '',
                'per'      => '',
                'cycle'    => '',
                'cycles'   => [],
                'orderUrl' => 'cart.php?a=add&pid=' . $id,
            ];
            if ($data['free']) {
                return $data;
            }
            $pricing = $p->pricing();
            foreach ((array)$pricing->allAvailableCycles() as $price) {
                $cycle = (string)$price->cycle();
                if ($cycle === '') {
                    continue;
                }
                $monthly = '';
                if ($price->isRecurring() && method_exists($price, 'monthlyPrice')) {
                    // "$2.99 USD/mo": keep the amount, as price() is shown.
                    $monthly = (string)preg_replace('/\s+[A-Z]{3}\b.*$|\/.*$/', '', (string)$price->monthlyPrice());
                }
                $data['cycles'][$cycle] = [
                    'price'   => self::amount($price),
                    'per'     => $price->isRecurring() && method_exists($price, 'getShortCycle') ? '/' . (string)$price->getShortCycle() : '',
                    'monthly' => $monthly,
                ];
            }
            $first = $pricing->first();
            if ($first !== null) {
                $cycle         = (string)$first->cycle();
                $data['cycle'] = $cycle;
                $data['price'] = $data['cycles'][$cycle]['price'] ?? self::amount($first);
                $data['per']   = $data['cycles'][$cycle]['per'] ?? '';
            }
            return $data;
        } catch (\Throwable $e) {
            error_log('Hadrian Page Builder: could not read product ' . $id . ': ' . $e->getMessage());
            return null;
        }
    }

    /** "$3.74": the amount with its currency symbol and no currency code. */
    private static function amount(object $price): string
    {
        $amount = $price->price();
        return is_object($amount) && method_exists($amount, 'toPrefixed') ? (string)$amount->toPrefixed() : (string)$amount;
    }

    /**
     * A WHMCS product description is free text, by convention a line of
     * introduction followed by a list. Split it into the two parts a price
     * card shows: the tagline and the feature lines.
     *
     * @return array{0:string, 1:list<string>}
     */
    public static function splitDescription(string $description): array
    {
        $plain = static fn(string $s): string => Text::line(
            html_entity_decode(strip_tags($s), ENT_QUOTES | ENT_HTML5, 'UTF-8'),
            200
        );
        $features = [];
        $intro    = $description;

        if (preg_match_all('/<li\b[^>]*>(.*?)<\/li>/is', $description, $m)) {
            $intro = (string)preg_split('/<(ul|ol)\b/i', $description, 2)[0];
            foreach ($m[1] as $li) {
                $features[] = $plain($li);
            }
        } else {
            // No list: the first line is the tagline, the rest are features.
            $lines = preg_split('/\r\n|\r|\n|<br\s*\/?>/i', $description) ?: [];
            $intro = (string)array_shift($lines);
            foreach ($lines as $line) {
                $features[] = $plain($line);
            }
        }
        $features = array_slice(array_values(array_filter($features, static fn(string $s): bool => $s !== '')), 0, 12);
        return [$plain($intro), $features];
    }

    /**
     * The newest published WHMCS announcements, in the visitor's language
     * where a translation exists. WHMCS announcements have a title, a date
     * and a body; they have no categories or images.
     *
     * @return list<array{id:int, title:string, date:string, dateIso:string, text:string, url:string}>
     */
    public function announcements(int $limit, string $lang): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table('tblannouncements')
                ->where('published', '1')->where('parentid', 0)
                ->orderBy('date', 'desc')->limit(max(1, min(24, $limit)))
                ->get(['id', 'date', 'title', 'announcement']);
            $translated = [];
            if ($lang !== '' && $lang !== '_' && count($rows) > 0) {
                $ids = [];
                foreach ($rows as $row) {
                    $ids[] = (int)$row->id;
                }
                $children = \WHMCS\Database\Capsule::table('tblannouncements')
                    ->whereIn('parentid', $ids)->where('language', $lang)
                    ->get(['parentid', 'title', 'announcement']);
                foreach ($children as $child) {
                    $translated[(int)$child->parentid] = $child;
                }
            }
        } catch (\Throwable $e) {
            return [];
        }
        $out = [];
        foreach ($rows as $row) {
            $id     = (int)$row->id;
            $source = $translated[$id] ?? $row;
            $title  = trim((string)$source->title) !== '' ? (string)$source->title : (string)$row->title;
            $body   = trim((string)$source->announcement) !== '' ? (string)$source->announcement : (string)$row->announcement;
            $time   = strtotime((string)$row->date) ?: 0;
            $out[]  = [
                'id'      => $id,
                'title'   => Text::line(html_entity_decode(strip_tags($title), ENT_QUOTES | ENT_HTML5, 'UTF-8'), 200),
                'date'    => function_exists('fromMySQLDate') ? (string)fromMySQLDate((string)$row->date) : date('Y-m-d', $time),
                'dateIso' => date('Y-m-d', $time),
                'text'    => self::excerpt($body, 180),
                'url'     => 'announcements.php?id=' . $id,
            ];
        }
        return $out;
    }

    /** The opening of an HTML body as one line of plain text. */
    public static function excerpt(string $html, int $max): string
    {
        $text = Text::line(html_entity_decode(strip_tags((string)preg_replace('/<(br|\/p|\/div|\/li)\b[^>]*>/i', ' ', $html)), ENT_QUOTES | ENT_HTML5, 'UTF-8'), 2000);
        $text = (string)preg_replace('/\s{2,}/', ' ', $text);
        $len  = function_exists('mb_strlen') ? mb_strlen($text) : strlen($text);
        if ($len <= $max) {
            return $text;
        }
        $cut   = Text::cut($text, $max);
        $space = strrpos($cut, ' ');
        return rtrim($space !== false && $space > $max * 0.6 ? substr($cut, 0, $space) : $cut, " ,.;:") . '...';
    }

    /**
     * Every product an admin can put on a page, for the editor's picker.
     *
     * @return list<array{id:int, name:string, group:string}>
     */
    public static function options(): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table('tblproducts as p')
                ->leftJoin('tblproductgroups as g', 'g.id', '=', 'p.gid')
                ->where('p.retired', '!=', 1)
                ->orderBy('g.order')->orderBy('p.order')->orderBy('p.name')
                ->get(['p.id', 'p.name', 'g.name as group']);
        } catch (\Throwable $e) {
            return [];
        }
        $out = [];
        foreach ($rows as $row) {
            $out[] = ['id' => (int)$row->id, 'name' => (string)$row->name, 'group' => (string)($row->group ?? '')];
        }
        return $out;
    }
}
