<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Stand-in data for the builder preview, so a design shows a name and an
 * amount instead of a row of braces. A field with no sample here is left on
 * the page as typed, which is also how the admin spots a misspelt one.
 */
final class Samples
{
    /** The subject shown in a header's title while previewing the layout on its own. */
    public const SUBJECT = 'Invoice #{$invoice_num} is ready';

    /**
     * @param array<string,mixed> $theme
     * @return array<string,string>
     */
    public static function fields(array $theme): array
    {
        $url     = (string)$theme['systemUrl'];
        $company = (string)$theme['company'];
        $link    = static fn(string $path, string $text = ''): string
            => '<a href="' . htmlspecialchars($url . $path, ENT_QUOTES, 'UTF-8') . '">' . htmlspecialchars($text !== '' ? $text : $url . $path, ENT_QUOTES, 'UTF-8') . '</a>';

        return [
            'companyname'  => $company,
            'company_name' => $company,
            'company_domain' => (string)parse_url($url, PHP_URL_HOST),
            'whmcs_url'    => $url,
            'whmcs_link'   => $link(''),
            'signature'    => htmlspecialchars($company, ENT_QUOTES, 'UTF-8') . '<br>' . htmlspecialchars((string)parse_url($url, PHP_URL_HOST), ENT_QUOTES, 'UTF-8'),
            'date'         => date('l, jS F Y'),
            'time'         => date('g:ia'),
            'unsubscribe_url' => $url . 'unsubscribe.php',

            'client_id'         => '1042',
            'client_name'       => 'Mara Okonkwo',
            'client_first_name' => 'Mara',
            'client_last_name'  => 'Okonkwo',
            'client_company_name' => 'Okonkwo Studio',
            'client_email'      => 'mara@example.com',
            'client_credit'     => '$0.00 USD',
            'client_due_invoices_balance' => '$49.00 USD',

            'invoice_id'           => '3187',
            'invoice_num'          => '3187',
            'invoice_date_created' => date('d/m/Y'),
            'invoice_date_due'     => date('d/m/Y', time() + 7 * 86400),
            'invoice_date_paid'    => date('d/m/Y'),
            'invoice_total'        => '$49.00 USD',
            'invoice_subtotal'     => '$49.00 USD',
            'invoice_balance'      => '$49.00 USD',
            'invoice_amount_paid'  => '$49.00 USD',
            'invoice_status'       => 'Unpaid',
            'invoice_payment_method' => 'Credit Card',
            'invoice_last_payment_amount'  => '$49.00 USD',
            'invoice_last_payment_transid' => 'ch_3PqK2e',
            'invoice_url'          => $url . 'viewinvoice.php?id=3187',
            'invoice_link'         => $link('viewinvoice.php?id=3187'),
            'invoice_payment_link' => $link('viewinvoice.php?id=3187', 'Pay now'),
            'invoice_html_contents' => 'Managed WordPress - Agency (01/12/2026 - 31/12/2026) $45.00 USD<br>Domain privacy - okonkwo.studio $4.00 USD',

            'order_number'  => '8163207459',
            'order_details' => 'Product/Service: Managed WordPress - Agency<br>Domain: okonkwo.studio<br>First payment: $49.00 USD',

            'service_product_name' => 'Managed WordPress - Agency',
            'service_domain'       => 'okonkwo.studio',
            'service_next_due_date' => date('d/m/Y', time() + 30 * 86400),
            'service_username'     => 'okonkwo',
            'service_server_name'  => 'lon-3',
            'service_recurring_amount' => '$45.00 USD',
            'service_billing_cycle' => 'Monthly',

            'domain_name'            => 'okonkwo.studio',
            'domain_reg_date'        => date('d/m/Y'),
            'domain_next_due_date'   => date('d/m/Y', time() + 365 * 86400),
            'domain_days_until_expiry' => '30',

            'ticket_id'       => 'IKI-620974',
            'ticket_subject'  => 'SSL certificate not renewing automatically',
            'ticket_priority' => 'Medium',
            'ticket_status'   => 'Open',
            'ticket_department' => 'Technical Support',
            'ticket_message'  => 'Thanks for getting in touch. We have reissued the certificate and it is now live on your site.',
            'ticket_url'      => $url . 'viewticket.php?tid=IKI-620974',
            'ticket_link'     => $link('viewticket.php?tid=IKI-620974'),

            'reset_password_url' => $url . 'password/reset/redeem/7f3a9c',
            'verification_url'   => $url . 'user/verify/7f3a9c',
            'quote_number'  => '214',
            'quote_subject' => 'Agency hosting bundle',
            'quote_link'    => $link('viewquote.php?id=214'),
        ];
    }

    /** A stock-shaped WHMCS body, for previewing the layout on its own. */
    public static function body(): string
    {
        return '<p>Dear {$client_first_name},</p>'
            . '<p>This is how an email that has no design of its own looks inside your layout. Its text comes from the WHMCS email template; the header, the footer and the colours come from here.</p>'
            . '<p><strong>Invoice #{$invoice_num}</strong><br>Amount due: {$invoice_total}<br>Due date: {$invoice_date_due}</p>'
            . '<p>You can view and pay the invoice at {$invoice_link}</p>'
            . '<p>{$signature}</p>';
    }
}
