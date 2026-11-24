<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The merge fields the builder offers in its "insert field" menu.
 *
 * This is a convenience list, not a gate: any field can be typed by hand and
 * WHMCS decides at send time whether it exists. Each name here was read off a
 * real EmailPreSend payload on WHMCS 9.0.8, or (users and invitations, which
 * cannot be triggered through the API) off the stock template that uses it.
 */
final class MergeFields
{
    private const ALWAYS = [
        'Client' => ['client_first_name', 'client_last_name', 'client_name', 'client_company_name', 'client_email', 'client_id'],
        'Company' => ['companyname', 'company_domain', 'whmcs_url', 'whmcs_link', 'signature', 'date', 'unsubscribe_url'],
    ];

    private const BY_TYPE = [
        'invoice' => ['Invoice' => [
            'invoice_num', 'invoice_date_created', 'invoice_date_due', 'invoice_total', 'invoice_balance',
            'invoice_amount_paid', 'invoice_status', 'invoice_payment_method', 'invoice_url', 'invoice_link',
            'invoice_html_contents', 'invoice_last_payment_amount', 'invoice_last_payment_transid',
        ]],
        'support' => ['Ticket' => [
            'ticket_id', 'ticket_subject', 'ticket_message', 'ticket_status', 'ticket_priority',
            'ticket_department', 'ticket_date_opened', 'ticket_url', 'ticket_link',
        ]],
        'product' => ['Service' => [
            'service_product_name', 'service_domain', 'service_username', 'service_password', 'service_server_name',
            'service_server_ip', 'service_dedicated_ip', 'service_next_due_date', 'service_recurring_amount',
            'service_billing_cycle', 'service_reg_date', 'service_status',
        ]],
        'domain' => ['Domain' => [
            'domain_name', 'domain_reg_date', 'domain_expiry_date', 'domain_next_due_date', 'domain_days_until_expiry',
            'domain_recurring_amount', 'domain_registrar', 'domain_status', 'domain_renewal_url',
        ]],
        'general' => ['Order and quote' => [
            'order_number', 'order_details', 'quote_number', 'quote_subject', 'quote_link',
        ]],
        'user' => ['User' => ['reset_password_url', 'verification_url', 'user_first_name', 'user_email']],
        'invite' => ['Invitation' => ['invite_sender_name', 'invite_account_name', 'invite_accept_url']],
        'affiliate' => ['Affiliate' => [
            'affiliate_total_visits', 'affiliate_balance', 'affiliate_withdrawn', 'affiliate_referrals_table', 'affiliate_referral_url',
        ]],
    ];

    /**
     * @param string $type  a tblemailtemplates.type, or '' for the layout
     * @return array<string, list<string>>
     */
    public static function forType(string $type): array
    {
        if ($type === '') {
            // The layout wraps every email, so only fields every email has.
            return self::ALWAYS;
        }
        return (self::BY_TYPE[$type] ?? []) + self::ALWAYS;
    }
}
