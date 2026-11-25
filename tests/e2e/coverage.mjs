// What the suite does NOT render yet, and why.
//
// tests/static/check-coverage.mjs walks every page folder in
// hadrian/templates/hadrian/core/pages, every variant inside them and every
// top-level hadrian_cart template. Each one must be either
//
//   - rendered by a test: a `tpl:` in routes.mjs, or a data-tpl a flow asserts
//     (flows.spec.mjs `tpl(page)).toBe('...')`), or
//   - listed below with a status and a reason.
//
// So a new page, variant or cart template fails the gate until someone decides
// how it gets tested. Entries are self-cleaning, like known-issues.mjs: once a
// listed template is rendered by a test, the checker fails asking for its
// entry to be removed, so this file never claims a gap that is already closed.
//
//   todo      testable locally, needs a fixture, flow or setting first.
//             `step` is the step of the test plan that closes it:
//               4 fixtures   5 settings + variants   6 flows
//   inner     never a page of its own: WHMCS renders it inside another page or
//             returns it to an AJAX call. `in` names where. Its markup is only
//             judged as part of that page. (A page folder that another page
//             folder {include}s - supportticketslist -> supporttickets - is found
//             by the checker itself and needs no entry.)
//   local     cannot be reached on the local stack (needs a third-party
//             service). `stub` says what a test double would have to fake.
//   legacy    WHMCS 9 never renders it: the URL redirects to a newer page.
//             A candidate for deletion. Verified by probes on 2026-11-11 and
//             2026-11-23 (the redirect target is in `why`).

export const PAGES = {
  // --- account and sign-in -------------------------------------------------
  'password-reset-email-prompt':    { status: 'inner', in: 'password-reset-container (the first step of /password/reset)' },
  'password-reset-security-prompt': { status: 'todo', step: 6, needs: 'a reset token for a user with a security question' },
  'password-reset-change-prompt':  { status: 'inner', in: 'password-reset-container, on the emailed redeem link (the password-reset flow sets a new password through it)' },
  'banned':                         { status: 'todo', step: 4, needs: 'a banned IP or email that is NOT 127.0.0.1, set and cleared inside one test' },
  'account-paymentmethods-billing-contacts': { status: 'inner', in: 'account-paymentmethods-manage (AJAX fragment; see known-issues.mjs billing-contacts-fragment)' },

  // --- billing ---------------------------------------------------------------
  'usagebillingpricing':            { status: 'local', stub: 'a server module that reports usage metrics (WHMCS Usage Billing)' },
  '3dsecure':                       { status: 'local', stub: 'a card gateway that answers with a 3-D Secure challenge' },

  // --- services, upgrades, SSL ------------------------------------------------
  'configuressl-stepone':           { status: 'local', stub: 'an SSL provisioning module (MarketConnect / registrar SSL)' },
  'configuressl-steptwo':           { status: 'local', stub: 'an SSL provisioning module' },
  'configuressl-complete':          { status: 'local', stub: 'an SSL provisioning module' },

  // --- support, knowledgebase, downloads, content ------------------------------
  'supportticketsubmit-customfields': { status: 'inner', in: 'supportticketsubmit-steptwo (custom-fields AJAX fragment)' },
  'supportticketsubmit-kbsuggestions': { status: 'inner', in: 'supportticketsubmit-steptwo (KB-suggestions AJAX fragment)' },

  // --- MarketConnect store landing pages ----------------------------------------
  // index.php?rp=/store/<slug> 404s without an active MarketConnect service.
  ...Object.fromEntries([
    'store-codeguard', 'store-marketgoo', 'store-nordvpn', 'store-ox', 'store-sitebuilder', 'store-sitelock',
    'store-socialbee', 'store-spamexperts', 'store-ssl', 'store-threesixtymonitoring', 'store-weebly',
  ].map(p => [p, { status: 'local', stub: 'MarketConnect service rows (tblmarketconnect_services) so the store route resolves' }])),
  'store-not-found':                { status: 'local', stub: 'MarketConnect: an unknown /store/<slug> redirects to the first product group instead' },
  'store-order':                    { status: 'local', stub: 'MarketConnect: /store/order redirects to the first product group without it' },

  // --- probably legacy (to be confirmed by probe) ------------------------------
  'changepassword':                   { status: 'legacy', why: '/clientarea.php?action=changepw renders user-password' },
  'changepw':                         { status: 'legacy', why: '/clientarea.php?action=changepw renders user-password' },
  'clientareacontacts':               { status: 'legacy', why: '/clientarea.php?action=contacts renders account-contacts-new / -manage' },
  'clientareausers':                  { status: 'legacy', why: '/clientarea.php?action=users redirects to the dashboard' },
  'submitticket':                     { status: 'legacy', why: '/submitticket.php renders supportticketsubmit-stepone' },
};

// Page variants other than each page's default. The default variant is covered
// whenever its page is routed; these need the variant switch from step 5
// (write hadrian_pages.variant, render, restore).
export const VARIANTS = {
};

// Top-level hadrian_cart templates.
export const CART = {
  'common':                       { status: 'inner', in: 'every cart page (shared head + scripts)' },
  'sidebar-categories':           { status: 'inner', in: 'products, viewcart' },
  'sidebar-categories-collapsed': { status: 'inner', in: 'cart pages at narrow widths' },
  'sidebar-categories-selector':  { status: 'inner', in: 'cart pages (category select)' },
  'recommendations-modal':        { status: 'inner', in: 'viewcart / configureproduct after adding an item with recommendations' },
  'marketconnect-promo':          { status: 'inner', in: 'viewcart, only with MarketConnect services active' },
  'service-renewal-item':         { status: 'inner', in: 'service-renewals' },
  'ordersummary':                 { status: 'inner', in: 'configureproduct (AJAX order-summary refresh)' },
  'domainoptions':                { status: 'inner', in: 'configureproductdomain / domainregister (AJAX availability result)' },
  'linkedaccounts':               { status: 'inner', in: 'checkout sign-in panel, only with a social-login provider' },
  'checkout':                     { status: 'inner', in: 'viewcart (WHMCS renders cart.php?a=checkout through the $checkout branch of viewcart.tpl; the checkout flows fill #frmCheckout)' },
  'fraudcheck':                   { status: 'local', stub: 'a fraud module that flags the order' },
};
