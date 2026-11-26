<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The section label and status pill the client-area designs (Page, Panel,
 * Notice) put next to an email's title, the way the client area heads an
 * invoice or service page: "BILLING", "Invoice #42", [Unpaid].
 *
 * Both come from facts WHMCS already has, never from guesses about the
 * message's content:
 *   - the section is the email template's own type (invoice, product, ...)
 *   - the status is only given for stock templates whose name says what state
 *     the record is in when that email goes out (an invoice is unpaid when
 *     "Invoice Created" is sent, paid when "Invoice Payment Confirmation" is).
 *     Any other template, including every custom one, gets no pill.
 *
 * The words are WHMCS's own client-area strings ($_LANG), so they are already
 * translated into every language WHMCS ships, and an admin's language
 * override applies here too.
 */
final class Status
{
    /** Template type => WHMCS lang key for the section. */
    private const SECTIONS = [
        'invoice'   => 'navbilling',
        'product'   => 'navservices',
        'domain'    => 'navdomains',
        'support'   => 'navsupport',
        'general'   => 'account',
        'user'      => 'account',
        'affiliate' => 'affiliatestitle',
    ];

    /** Pill tones; each has a colour pair in the Renderer. */
    public const TONES = ['success', 'warning', 'danger', 'info', 'neutral'];

    /** Stock template name => [WHMCS lang key, tone]. */
    private const STATES = [
        'Invoice Created'                   => ['invoicesunpaid', 'warning'],
        'Credit Card Invoice Created'       => ['invoicesunpaid', 'warning'],
        'Invoice Payment Reminder'          => ['invoicesunpaid', 'warning'],
        'Credit Card Payment Due'           => ['invoicesunpaid', 'warning'],
        'First Invoice Overdue Notice'      => ['invoicesunpaid', 'danger'],
        'Second Invoice Overdue Notice'     => ['invoicesunpaid', 'danger'],
        'Third Invoice Overdue Notice'      => ['invoicesunpaid', 'danger'],
        'Credit Card Payment Failed'        => ['invoicesunpaid', 'danger'],
        'Direct Debit Payment Failed'       => ['invoicesunpaid', 'danger'],
        'Credit Card Payment Pending'       => ['clientareapending', 'warning'],
        'Direct Debit Payment Pending'      => ['clientareapending', 'warning'],
        'Invoice Payment Confirmation'      => ['invoicespaid', 'success'],
        'Credit Card Payment Confirmation'  => ['invoicespaid', 'success'],
        'Direct Debit Payment Confirmation' => ['invoicespaid', 'success'],
        'Invoice Refund Confirmation'       => ['invoicesrefunded', 'info'],
        'Service Suspension Notification'   => ['clientareasuspended', 'warning'],
        'Service Unsuspension Notification' => ['clientareaactive', 'success'],
        'Domain Registration Confirmation'  => ['clientareaactive', 'success'],
        'Domain Renewal Confirmation'       => ['clientareaactive', 'success'],
        'Domain Transfer Completed'         => ['clientareaactive', 'success'],
        'Expired Domain Notice'             => ['clientareaexpired', 'danger'],
        'Support Ticket Opened'             => ['supportticketsstatusopen', 'success'],
        'Support Ticket Opened by Admin'    => ['supportticketsstatusopen', 'success'],
        'Support Ticket Reply'              => ['supportticketsstatusanswered', 'info'],
        'Support Ticket Auto Close Notification' => ['supportticketsstatusclosed', 'neutral'],
    ];

    /** Every "... Welcome Email" is sent when the service goes active. */
    private const WELCOME = ['clientareaactive', 'success'];

    /** English, for when the WHMCS language files cannot be read (tests, preview off-install). */
    private const ENGLISH = [
        'navbilling' => 'Billing', 'navservices' => 'Services', 'navdomains' => 'Domains',
        'navsupport' => 'Support', 'account' => 'Account', 'affiliatestitle' => 'Affiliates',
        'invoicesunpaid' => 'Unpaid', 'invoicespaid' => 'Paid', 'invoicesrefunded' => 'Refunded',
        'clientareapending' => 'Pending', 'clientareasuspended' => 'Suspended',
        'clientareaactive' => 'Active', 'clientareaexpired' => 'Expired',
        'supportticketsstatusopen' => 'Open', 'supportticketsstatusanswered' => 'Answered',
        'supportticketsstatusclosed' => 'Closed',
    ];

    /**
     * The merge fields for one email: hx_eyebrow, hx_status and one
     * hx_tone_<tone> set to "1". Empty strings where there is nothing to say.
     *
     * @return array<string,string>
     */
    public static function fields(string $messageName, string $type, string $lang): array
    {
        $out = ['hx_eyebrow' => '', 'hx_status' => ''];
        foreach (self::TONES as $t) {
            $out['hx_tone_' . $t] = '';
        }
        $section = self::SECTIONS[strtolower($type)] ?? null;
        if ($section !== null) {
            $out['hx_eyebrow'] = self::word($section, $lang);
        }
        $state = self::STATES[$messageName] ?? (str_ends_with($messageName, ' Welcome Email') ? self::WELCOME : null);
        if ($state !== null) {
            [$key, $tone] = $state;
            $out['hx_status']          = self::word($key, $lang);
            $out['hx_tone_' . $tone] = $out['hx_status'] !== '' ? '1' : '';
        }
        return $out;
    }

    /** One WHMCS client-area string, escaped for HTML. */
    private static function word(string $key, string $lang): string
    {
        $text = Bridge::whmcsLang($lang, $key) ?? self::ENGLISH[$key] ?? '';
        return htmlspecialchars(trim($text), ENT_QUOTES, 'UTF-8');
    }
}
