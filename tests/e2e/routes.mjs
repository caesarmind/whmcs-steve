// Every page the smoke tier visits: which URL, as whom, and which template
// it must render.
//
// `tpl` is the point. A request can return 200 and still be the WRONG page:
// a stale route redirects to the dashboard, an expired session lands on the
// sign-in form. Asserting <body data-tpl> catches both, which is how this
// table was corrected - hadrian/scripts/pages.csv predates WHMCS 9 and about a
// third of its URLs now 404 or redirect (/account/security is /user/security,
// /register is /register.php, payment methods moved under rp=/account/...).
//
// URLs were taken from the theme's own navigation by crawling it as a signed
// in client, not guessed. ids come from tests/.local/fixtures.json.
//
//   personas  guest | full | empty | suspended | subuser (see tests/php/scenarios.php)
//   tpl       expected data-tpl; an array means "any of these" (WHMCS picks
//             the template from data, e.g. contacts list vs new-contact form)

import { fx } from './helpers.mjs';

const id = fx.ids;
const CLIENTS = ['full', 'empty'];
const EVERYONE = ['guest', 'full'];

export const ROUTES = [
  // --- public ---------------------------------------------------------------
  { tpl: 'homepage',          url: '/',                                   personas: EVERYONE },
  { tpl: 'announcements',     url: '/announcements.php',                  personas: EVERYONE },
  { tpl: 'viewannouncement',  url: `/index.php?rp=/announcements/${id.announcementId}/x.html`, personas: ['guest'] },
  { tpl: 'knowledgebase',     url: '/knowledgebase.php',                  personas: EVERYONE },
  { tpl: 'downloads',         url: '/downloads.php',                      personas: EVERYONE },
  { tpl: 'contact',           url: '/contact.php',                        personas: EVERYONE },
  { tpl: 'domain-pricing',    url: '/index.php?rp=/domain/pricing',       personas: EVERYONE },
  { tpl: 'login',             url: '/login',                              personas: ['guest'] },
  { tpl: 'clientregister',    url: '/register.php',                       personas: ['guest'] },
  { tpl: 'password-reset-container', url: '/index.php?rp=/password/reset', personas: ['guest'] },
  { tpl: 'knowledgebasecat',  url: `/index.php?rp=/knowledgebase/${id.kbCategoryId}/x`, personas: EVERYONE },
  { tpl: 'knowledgebasearticle', url: `/index.php?rp=/knowledgebase/${id.kbArticleId}/x.html`, personas: EVERYONE },
  { tpl: 'downloadscat',      url: `/index.php?rp=/download/category/${id.downloadCategoryId}/x.html`, personas: EVERYONE },
  { tpl: 'custom-page',       url: '/custom-page.php',                    personas: EVERYONE },
  { tpl: 'user-invite-accept', url: `/index.php?rp=/invite/${id.inviteToken}`, personas: ['guest'] },
  // Consumes its token; fixtures.php re-arms it on a throwaway user every run.
  { tpl: 'user-verify-email', url: `/index.php?rp=/user/verify/${id.verifyToken}`, personas: ['guest'] },

  // --- order form (hadrian_cart) ---------------------------------------------
  { tpl: 'products',          url: '/cart.php',                           personas: EVERYONE },
  { tpl: 'products',          url: `/index.php?rp=/store/${id.productGroupSlug}`, personas: EVERYONE, name: 'store group' },
  { tpl: ['configureproductdomain', 'configureproduct'], url: `/index.php?rp=/store/${id.productPath}`, personas: ['guest'], name: 'store product' },
  { tpl: 'domainregister',    url: '/cart.php?a=add&domain=register',     personas: EVERYONE },
  { tpl: 'domaintransfer',    url: '/cart.php?a=add&domain=transfer',     personas: ['guest'] },
  { tpl: 'viewcart',          url: '/cart.php?a=view',                    personas: EVERYONE },
  { tpl: 'addons',            url: '/cart.php?gid=addons',                personas: ['full'] },
  { tpl: 'domain-renewals',   url: '/cart.php?gid=renewals',              personas: ['full'] },
  { tpl: 'service-renewals',  url: '/index.php?rp=/service-renewals',     personas: ['full'] },
  { tpl: 'domainregister',    url: '/cart.php?a=add&domain=register&query=hadrian-test.com', personas: ['guest'], name: 'domain search results' },

  // --- client area ------------------------------------------------------------
  { tpl: 'clientareahome',    url: '/clientarea.php',                     personas: [...CLIENTS, 'suspended'] },
  { tpl: 'clientareaproducts', url: '/clientarea.php?action=services',    personas: [...CLIENTS, 'suspended'] },
  { tpl: 'clientareadomains', url: '/clientarea.php?action=domains',      personas: CLIENTS },
  { tpl: 'clientareainvoices', url: '/clientarea.php?action=invoices',    personas: CLIENTS },
  { tpl: 'clientareaquotes',  url: '/clientarea.php?action=quotes',       personas: CLIENTS },
  { tpl: 'clientareadetails', url: '/clientarea.php?action=details',      personas: CLIENTS },
  { tpl: 'clientareasecurity', url: '/clientarea.php?action=security',    personas: ['full'] },
  { tpl: 'clientareaemails',  url: '/clientarea.php?action=emails',       personas: CLIENTS },
  { tpl: 'clientareaaddfunds', url: '/clientarea.php?action=addfunds',    personas: ['full'] },
  { tpl: 'clientareaproductdetails', url: `/clientarea.php?action=productdetails&id=${id.serviceId}`, personas: ['full'] },
  { tpl: 'clientareaproductdetails', url: `/clientarea.php?action=productdetails&id=${id.suspendedServiceId}`, personas: ['suspended'], name: 'suspended service' },
  { tpl: 'clientareacancelrequest', url: `/clientarea.php?action=cancel&id=${id.serviceId}`, personas: ['full'] },
  { tpl: 'clientareadomaindetails', url: `/clientarea.php?action=domaindetails&id=${id.domainId}`, personas: ['full'] },
  { tpl: 'clientareadomaincontactinfo', url: `/clientarea.php?action=domaincontacts&domainid=${id.domainId}`, personas: ['full'] },
  { tpl: 'clientareadomaindns', url: `/clientarea.php?action=domaindns&domainid=${id.domainId}`, personas: ['full'] },
  { tpl: 'clientareadomaingetepp', url: `/clientarea.php?action=domaingetepp&domainid=${id.domainId}`, personas: ['full'] },
  { tpl: 'clientareadomainregisterns', url: `/clientarea.php?action=domainregisterns&domainid=${id.domainId}`, personas: ['full'] },
  { tpl: 'clientareadomainemailforwarding', url: `/clientarea.php?action=domainemailforwarding&domainid=${id.domainId}`, personas: ['full'] },
  { tpl: 'viewinvoice',       url: `/viewinvoice.php?id=${id.invoiceId}`, personas: ['full'] },
  { tpl: 'viewinvoice',       url: `/viewinvoice.php?id=${id.overdueInvoiceId}`, personas: ['full'], name: 'overdue invoice' },
  { tpl: 'viewquote',         url: `/viewquote.php?id=${id.quoteId}`,    personas: ['full'] },
  // viewemail is a standalone popup document: no header, so no data-tpl.
  { tpl: null,                url: `/viewemail.php?id=${id.emailId}`,    personas: ['full'], name: 'viewemail', covers: 'viewemail' },
  // markdown-guide is a JSON-wrapped fragment the ticket editor loads (no data-tpl).
  { tpl: null,                url: '/submitticket.php?action=markdown',   personas: ['full'], name: 'markdown guide', covers: 'markdown-guide' },
  { tpl: 'masspay',           url: '/clientarea.php?action=masspay&all=true', personas: ['full'] },
  { tpl: 'upgrade',           url: `/upgrade.php?type=package&id=${id.serviceId}`, personas: ['full'] },
  { tpl: 'upgrade',           url: `/upgrade.php?type=configoptions&id=${id.serviceId}`, personas: ['full'], name: 'upgrade options' },
  { tpl: 'managessl',         url: '/index.php?rp=/clientarea/ssl-certificates/manage', personas: CLIENTS },
  { tpl: 'downloaddenied',    url: `/dl.php?type=d&id=${id.restrictedDownloadId}`, personas: ['full'] },
  { tpl: 'supportticketslist', url: '/supporttickets.php',                personas: CLIENTS },
  { tpl: 'supportticketsubmit-stepone', url: '/submitticket.php',         personas: CLIENTS },
  { tpl: 'supportticketsubmit-steptwo', url: `/submitticket.php?step=2&deptid=${id.deptId}`, personas: ['full'] },
  { tpl: 'viewticket',        url: `/viewticket.php?tid=${id.ticketTid}&c=${id.ticketC}`, personas: ['full'] },
  // A ticket that does not exist - deleted, merged, or a stale link in an old email.
  { tpl: 'viewticket',        url: '/viewticket.php?tid=NOPE-000000&c=x', personas: ['full'], name: 'missing ticket' },
  { tpl: 'viewticket',        url: `/viewticket.php?tid=${id.closedTicketTid}&c=${id.closedTicketC}`, personas: ['full'], name: 'closed ticket' },
  { tpl: 'ticketfeedback',    url: `/viewticket.php?tid=${id.closedTicketTid}&c=${id.closedTicketC}&feedback=1`, personas: ['full'] },
  { tpl: 'affiliates',        url: '/affiliates.php',                     personas: ['full'], name: 'affiliate dashboard' },
  { tpl: 'affiliatessignup',  url: '/affiliates.php',                     personas: ['empty'], name: 'affiliate signup' },
  { tpl: 'serverstatus',      url: '/serverstatus.php',                   personas: ['full'] },
  { tpl: ['account-contacts-manage', 'account-contacts-new'], url: '/index.php?rp=/account/contacts', personas: CLIENTS },
  { tpl: 'account-user-management', url: '/index.php?rp=/account/users',  personas: CLIENTS },
  { tpl: 'account-paymentmethods', url: '/index.php?rp=/account/paymentmethods', personas: CLIENTS },
  { tpl: 'account-paymentmethods-manage', url: '/index.php?rp=/account/paymentmethods/add', personas: CLIENTS },
  { tpl: 'account-contacts-manage', url: `/index.php?rp=/account/contacts&contactid=${id.contactId}`, personas: ['full'], name: 'edit contact' },
  { tpl: 'account-user-permissions', url: `/index.php?rp=/account/users/${id.subUserId}/permissions`, personas: ['full'] },
  { tpl: 'user-profile',      url: '/index.php?rp=/user/profile',         personas: CLIENTS },
  { tpl: 'user-password',     url: '/index.php?rp=/user/password',        personas: CLIENTS },
  { tpl: 'user-security',     url: '/index.php?rp=/user/security',        personas: CLIENTS },
  { tpl: 'user-switch-account', url: '/index.php?rp=/user/accounts',      personas: ['full'] },

  // --- a sub-user on the full persona's account, without invoice access ------
  { tpl: 'clientareahome',    url: '/clientarea.php',                     personas: ['subuser'], name: 'sub-user dashboard' },
  { tpl: 'access-denied',     url: '/clientarea.php?action=invoices',     personas: ['subuser'] },
];

// Hadrian admin screens: addonmodules.php?module=Hadrian&action=<a>. Read
// views only - the sub= actions that write (delete, seed, reset-defaults,
// remove, generate) are never visited.
export const ADMIN_ACTIONS = [
  'index', 'settings', 'styles', 'layouts', 'pages', 'sitemap', 'menu',
  'branding', 'media', 'extensions', 'tools', 'templates', 'license', 'setup',
];
