<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * WHMCS products, as a pricing section needs them.
 *
 * Prices come from WHMCS's own product model, in the visitor's currency, on
 * every request. Nothing about a price is stored in a page, so a price change
 * in WHMCS shows on the next page view.
 *
 * The Renderer only ever calls products(); a test hands it a stand-in with
 * the same method.
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
                'orderUrl' => 'cart.php?a=add&pid=' . $id,
            ];
            if (!$data['free']) {
                $price = $p->pricing()->first();
                if ($price === null) {
                    return $data;       // no price in this currency: the card shows no amount
                }
                $amount        = $price->price();
                $data['price'] = is_object($amount) && method_exists($amount, 'toPrefixed')
                    ? (string)$amount->toPrefixed()
                    : (string)$amount;
                if ($price->isRecurring() && method_exists($price, 'getShortCycle')) {
                    $data['per'] = '/' . (string)$price->getShortCycle();
                }
            }
            return $data;
        } catch (\Throwable $e) {
            error_log('Hadrian Page Builder: could not read product ' . $id . ': ' . $e->getMessage());
            return null;
        }
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
