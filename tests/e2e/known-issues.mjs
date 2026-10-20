// Known, ACCEPTED findings: real bugs that are understood but not fixed yet.
//
// A finding listed here is reported on every run but does not fail it, so one
// open bug cannot hold every other fix hostage at the pre-push gate. Each
// entry must say what is wrong and what fixing it involves.
//
// Entries are self-cleaning: if a listed finding stops occurring, the run
// FAILS with "known issue no longer occurs - remove it". A stale entry would
// otherwise hide the bug if it ever came back.

export const KNOWN_ISSUES = [
  {
    id: 'billing-contacts-fragment',
    match: /paymentmethods-billing-contacts.*empty <h1>/,
    seenBy: 'crawl as full',   // the one test that reaches it, for the staleness check
    since: '2026-10-21',
    what:
      'account-paymentmethods-billing-contacts.tpl is built as a full "billing contacts" page over $contacts. ' +
      'In WHMCS it is an AJAX FRAGMENT: <div id="innerBillingContactsContainer"> with a name="billingcontact" ' +
      'radio list (the client + each contact, from $client / $payMethod / $selectedContactId) that the ' +
      'add/edit payment-method form {include}s and reloads. Hadrian links to it as a separate page instead, so ' +
      'that link opens an unstyled fragment with an empty heading, and the payment-method form has no ' +
      'billing-contact chooser.',
    fix:
      'Rebuild the fragment to the WHMCS contract (see templates/twenty-one/account-paymentmethods-billing-contacts.tpl) ' +
      'and include it inside account-paymentmethods-manage\'s form, with the reload after "add contact".',
  },
];

/** Split findings into new problems and known ones; report stale entries. */
export function triage(findings, testInfo) {
  const fresh = [], known = [];
  const hit = new Set();
  for (const f of findings) {
    const k = KNOWN_ISSUES.find(k => k.match.test(f));
    if (k) { known.push(f); hit.add(k.id); } else fresh.push(f);
  }
  for (const f of known) testInfo.annotations.push({ type: 'known issue', description: f });
  // Only the test that is SUPPOSED to see an issue may declare it gone.
  const stale = KNOWN_ISSUES
    .filter(k => k.seenBy === testInfo.title && !hit.has(k.id))
    .map(k => `known issue "${k.id}" no longer occurs - remove it from tests/e2e/known-issues.mjs`);
  return { fresh: [...fresh, ...stale], known };
}
