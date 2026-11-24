<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Starting points: the default layout, and a starter body for the WHMCS
 * emails clients see most.
 *
 * Every starter is built from the merge fields the stock WHMCS 9 template for
 * that email already uses, so nothing in one refers to a field WHMCS does not
 * supply. A template with no starter is imported instead (see import()).
 */
final class Presets
{
    private const SIGNATURE = '<p>{$signature}</p>';

    /** @return array<string,mixed> a layout document, not yet normalised */
    public static function layout(array $footerLinks = []): array
    {
        return [
            'blocks' => [
                ['type' => 'header'],
                ['type' => 'content'],
                ['type' => 'footer', 'props' => ['links' => $footerLinks]],
            ],
        ];
    }

    /** WHMCS template names that have a starter. */
    public static function names(): array
    {
        return array_keys(self::all());
    }

    /**
     * @return array<string,mixed>|null  a message document, not yet normalised
     */
    public static function message(string $target): ?array
    {
        return self::all()[$target] ?? null;
    }

    /**
     * No starter: carry the email's current body over so nothing is lost.
     *
     * A body made only of simple tags becomes an editable text block. Anything
     * richer (tables, inline styles, images) goes into an HTML block untouched,
     * because the sanitiser would otherwise strip what it does not allow.
     *
     * @return array<string,mixed>
     */
    public static function import(string $body): array
    {
        $body = trim($body);
        if ($body === '') {
            return ['blocks' => [self::text('<p>Write your message here.</p>')]];
        }
        $simple = !preg_match('/<(table|img|div|span|font|center|style|h1|h4|h5|h6|pre|hr)\b|\sstyle=|\salign=/i', $body);
        if ($simple) {
            $clean = Sanitizer::rich($body);
            $plain = static fn(string $s): string => (string)preg_replace('/\s+/', '', html_entity_decode(strip_tags($s), ENT_QUOTES, 'UTF-8'));
            if ($clean !== '' && $plain($clean) === $plain($body)) {
                return ['blocks' => [self::text($clean)]];
            }
        }
        return ['blocks' => [['type' => 'html', 'props' => ['code' => $body]]]];
    }

    // ------------------------------------------------------------- starters

    /** @return array<string, array<string,mixed>> */
    private static function all(): array
    {
        $invoiceItems = self::raw('<div style="margin:0 0 20px;font-size:14px;line-height:1.6;">{$invoice_html_contents}</div>');
        $payDetails   = [
            ['Balance due', '{$invoice_balance}'],
            ['Due date', '{$invoice_date_due}'],
            ['Payment method', '{$invoice_payment_method}'],
        ];
        $overdue = static fn(string $title, string $note): array => [
            'settings' => ['preheader' => '{$invoice_balance} was due on {$invoice_date_due}.'],
            'blocks'   => [
                self::heading($title),
                self::text('<p>Hi {$client_first_name}, invoice #{$invoice_num}, generated on {$invoice_date_created}, has not been paid yet.</p>'),
                self::callout('<p>' . $note . '</p>', 'danger'),
                self::details($payDetails),
                self::button('Pay invoice', '{$invoice_url}'),
                self::text(self::SIGNATURE),
            ],
        ];
        $ticketDetails = [
            ['Ticket', '#{$ticket_id}'],
            ['Subject', '{$ticket_subject}'],
            ['Status', '{$ticket_status}'],
        ];

        return [
            'Client Signup Email' => [
                'settings' => ['preheader' => 'Your {$companyname} account is ready.'],
                'blocks'   => [
                    self::heading('Welcome, {$client_first_name}'),
                    self::text('<p>Thanks for creating a {$companyname} account. Your client area is where you manage services, pay invoices and get help.</p>'),
                    self::button('Open client area', '{$whmcs_url}'),
                    self::text('<p><strong>Signing in</strong></p><p>Use your email address and the password you chose when you signed up.</p>'
                        . '<p><strong>Need a hand?</strong></p><ul>'
                        . '<li><a href="{$whmcs_url}/knowledgebase.php">Browse the knowledgebase</a></li>'
                        . '<li><a href="{$whmcs_url}/submitticket.php">Open a support ticket</a></li></ul>'),
                    self::text(self::SIGNATURE),
                    self::text('<p>You are receiving this email because an account was created with this address. If that was not you, please contact us.</p>', ['size' => 'small', 'muted' => true]),
                ],
            ],

            'Order Confirmation' => [
                'settings' => ['preheader' => 'We have received your order.'],
                'blocks'   => [
                    self::heading('Thanks for your order'),
                    self::text('<p>Hi {$client_first_name}, we have received your order and will start on it shortly.</p>'),
                    self::details([['Order number', '{if isset($order_number)}{$order_number}{/if}']]),
                    self::raw('{if isset($order_details)}<div style="margin:0 0 20px;font-size:14px;line-height:1.6;">{$order_details}</div>{/if}'),
                    self::text('<p>You will get another email as soon as your service is set up. Quote the order number if you contact us about it.</p>'),
                    self::text(self::SIGNATURE),
                ],
            ],

            'Invoice Created' => [
                'settings' => ['preheader' => '{$invoice_total} due on {$invoice_date_due}.'],
                'blocks'   => [
                    self::heading('Invoice #{$invoice_num}'),
                    self::text('<p>Hi {$client_first_name}, a new invoice was generated on {$invoice_date_created}.</p>'),
                    self::details([
                        ['Amount due', '{$invoice_total}'],
                        ['Due date', '{$invoice_date_due}'],
                        ['Payment method', '{$invoice_payment_method}'],
                    ]),
                    self::button('View and pay invoice', '{$invoice_url}'),
                    self::heading('Invoice items', 3),
                    $invoiceItems,
                    self::text(self::SIGNATURE),
                ],
            ],

            'Invoice Payment Confirmation' => [
                'settings' => ['preheader' => 'We received {$invoice_last_payment_amount}. Thank you.'],
                'blocks'   => [
                    self::heading('Payment received'),
                    self::text('<p>Hi {$client_first_name}, thank you. This is your receipt for invoice #{$invoice_num}.</p>'),
                    self::details([
                        ['Amount paid', '{$invoice_last_payment_amount}'],
                        ['Transaction', '{$invoice_last_payment_transid}'],
                        ['Total paid', '{$invoice_amount_paid}'],
                        ['Remaining balance', '{$invoice_balance}'],
                        ['Status', '{$invoice_status}'],
                    ]),
                    self::heading('Invoice items', 3),
                    $invoiceItems,
                    self::button('View invoice', '{$invoice_url}', 'secondary'),
                    self::text(self::SIGNATURE),
                ],
            ],

            'Invoice Payment Reminder' => [
                'settings' => ['preheader' => '{$invoice_balance} is due on {$invoice_date_due}.'],
                'blocks'   => [
                    self::heading('Invoice #{$invoice_num} is due soon'),
                    self::text('<p>Hi {$client_first_name}, this is a reminder that invoice #{$invoice_num}, generated on {$invoice_date_created}, is due on {$invoice_date_due}.</p>'),
                    self::details($payDetails),
                    self::button('Pay invoice', '{$invoice_url}'),
                    self::text(self::SIGNATURE),
                ],
            ],

            'First Invoice Overdue Notice'  => $overdue('Invoice #{$invoice_num} is overdue', 'Please pay it as soon as you can to keep your services running.'),
            'Second Invoice Overdue Notice' => $overdue('Second notice: invoice #{$invoice_num}', 'This invoice is still unpaid. Your services may be suspended if it stays that way.'),
            'Third Invoice Overdue Notice'  => $overdue('Final notice: invoice #{$invoice_num}', 'This is the last reminder before your services are suspended.'),

            'Support Ticket Opened' => [
                'settings' => ['preheader' => 'Ticket #{$ticket_id} is open.'],
                'blocks'   => [
                    self::heading('We have your request'),
                    self::text('<p>Hi {$client_first_name}, your ticket is open and our team will reply by email.</p>'),
                    self::details([
                        ['Ticket', '#{$ticket_id}'],
                        ['Subject', '{$ticket_subject}'],
                        ['Priority', '{$ticket_priority}'],
                        ['Status', '{$ticket_status}'],
                    ]),
                    self::button('View ticket', '{$ticket_url}', 'secondary'),
                    self::text(self::SIGNATURE),
                ],
            ],

            'Support Ticket Reply' => [
                'blocks' => [
                    self::raw('<div style="margin:0 0 20px;">{$ticket_message}</div>'),
                    self::divider(),
                    self::details($ticketDetails),
                    self::button('View ticket', '{$ticket_url}', 'secondary'),
                ],
            ],

            'Password Reset Validation' => [
                'settings' => ['preheader' => 'Use this link to choose a new password.'],
                'blocks'   => [
                    self::heading('Reset your password'),
                    self::text('<p>We received a request to reset the password for your account.</p>'),
                    self::button('Reset password', '{if isset($reset_password_url)}{$reset_password_url}{/if}'),
                    self::text('<p>If the button does not work, copy this address into your browser:<br>{if isset($reset_password_url)}{$reset_password_url}{/if}</p>'
                        . '<p>If you did not ask for this, you can ignore this email. The link expires in 2 hours.</p>', ['size' => 'small', 'muted' => true]),
                    self::text(self::SIGNATURE),
                ],
            ],

            'Email Address Verification' => [
                'settings' => ['preheader' => 'Confirm this address to finish setting up your account.'],
                'blocks'   => [
                    self::heading('Confirm your email address'),
                    self::text('<p>Welcome to {$company_name}. Confirm this address so we know it is yours.</p>'),
                    self::button('Verify email address', '{if isset($verification_url)}{$verification_url}{/if}'),
                    self::text('<p>If the button does not work, copy this address into your browser:<br>{if isset($verification_url)}{$verification_url}{/if}</p>'
                        . '<p>This link is valid for 60 minutes. If it has expired, sign in to the <a href="{$whmcs_url}">client area</a> to request a new one.</p>', ['size' => 'small', 'muted' => true]),
                    self::text(self::SIGNATURE),
                ],
            ],
        ];
    }

    // -------------------------------------------------------------- builders

    /** @return array<string,mixed> */
    private static function heading(string $text, int $level = 1): array
    {
        return ['type' => 'heading', 'props' => ['text' => ['_' => $text], 'level' => (string)$level]];
    }

    /**
     * @param array<string,mixed> $extra
     * @return array<string,mixed>
     */
    private static function text(string $html, array $extra = []): array
    {
        return ['type' => 'text', 'props' => ['html' => ['_' => $html]] + $extra];
    }

    /** @return array<string,mixed> */
    private static function button(string $label, string $url, string $style = 'primary'): array
    {
        return ['type' => 'button', 'props' => ['label' => ['_' => $label], 'url' => $url, 'style' => $style]];
    }

    /**
     * @param list<array{0:string,1:string}> $pairs
     * @return array<string,mixed>
     */
    private static function details(array $pairs): array
    {
        return ['type' => 'details', 'props' => ['rows' => array_map(
            static fn(array $p): array => ['label' => ['_' => $p[0]], 'value' => $p[1]],
            $pairs
        )]];
    }

    /** @return array<string,mixed> */
    private static function callout(string $html, string $tone): array
    {
        return ['type' => 'callout', 'props' => ['html' => ['_' => $html], 'tone' => $tone]];
    }

    /** @return array<string,mixed> */
    private static function divider(): array
    {
        return ['type' => 'divider', 'props' => []];
    }

    /** @return array<string,mixed> */
    private static function raw(string $code): array
    {
        return ['type' => 'html', 'props' => ['code' => $code]];
    }
}
