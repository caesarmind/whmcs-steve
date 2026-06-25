# B14a — Account (details, contacts, users, permissions, email history)

## Summary
- **Total strings (table rows):** 177 (incl. dedupes — the 5-item `subnav-card` aside repeats verbatim across details/contacts/new/management/permissions/emails, and `clientareafirstname`…`clientareacountry` repeat across the 3 contact forms + details; 4 of the 177 are in-table SKIP `—` rows)
- **WHMCS:** 141
- **CUSTOM:** 32
- **#SKIP-worth-noting:** 4 in-table `—` rows (`$taxIdLabel`×2, the `{lang key="emailPreferences."|cat:$emailType}` dynamic-prefix label ×2) + per-file Notes; also the 2 `{include}`-only forwarders (`clientareacontacts`, `clientareausers`); `name@example.com` sample placeholder; `user@example.com`/`Hostnodes`/demo-data assignment literals under `?preview=1`; all `data-*`/`<script>` `data-data`/`data-subnav` attr values, SVG path data, `$var` output
- **#js-string:** 7 (3 `confirm()` dialogs — contacts-manage delete, user-management remove + cancel-invite, all 3 mapping to real WHMCS modal keys; 4 DataTables-fallback `L = {…}` label literals in clientareaemails)
- **Legacy `$rslang`:** none of these `$LANG.*` keys live in `core/lang/english.php` (it only defines `footer/error/license/admin`), so every `{$LANG.key|default}` here is a genuine `$_LANG` lookup, never a pre-tokenized Hadrian string — confirmed by grep

### Evidence pattern (same as prior batches)
- hadrian uses `{$LANG.x|default:'…'}` **everywhere** (never bare `{$LANG.x}` — grep confirmed), so hadrian's own usage can't validate a key; classification rests on the references.
- **nexus** = `{lang key='x'}`, **lagom** = `{$LANG.x}` (or `{lang key=…}`). Same string seen so in either ref for the same element ⇒ real WHMCS key ⇒ **WHMCS**, strip default.
- The account/contacts/users reference pages map almost 1:1 onto these hadrian pages, so most keys are **high-confidence WHMCS**.
- **Core-resolved nav/section keys** (`accounttab`, `accountdetails`, `usermanagement`, `contacts`, `emailstitle`, `paymentmethods`, `security`) are genuine WHMCS `$_LANG` keys but WHMCS resolves them inside its navbar/Menu PHP (`$item->getLabel()`), so they have no citable template line. Per the "prefer real keys" policy they are kept **WHMCS / med** with note "core-resolved nav key — verify in server lang/english.php; strip default" — same treatment as B08. (`paymentmethods` flat → real nested `paymentMethods.title`, per B08.)

---

### core/pages/clientareadetails/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Account Details | WHMCS | {$LANG.accountdetails} | core-resolved account key (cf. real `clientareanavdetails`, nexus clientareadetails.tpl:21); page title; strip default | med |
| 31 | text | Your personal information, billing address and email preferences. | CUSTOM | {$hadrianLang.account.accountDetailsSub} | `accountdetailssub` not in nexus/lagom; bespoke subtitle | high |
| 38 | text | Account | WHMCS | {$LANG.accounttab} | core-resolved section key; subnav heading; strip default | med |
| 41 | text | Account Details | WHMCS | {$LANG.accountdetails} | dedupe (line 30); subnav item | med |
| 45 | text | User Management | WHMCS | {$LANG.usermanagement} | core-resolved (real variant `navUserManagement`); strip default | med |
| 49 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat `paymentmethods` → real nested key (nexus account-paymentmethods.tpl:22); strip default | high |
| 53 | text | Contacts | WHMCS | {$LANG.contacts} | core-resolved account key; strip default | med |
| 57 | text | Email History | WHMCS | {$LANG.emailstitle} | core-resolved account key; strip default | med |
| 68 | text | Personal information | WHMCS | {$LANG.orderForm.personalInformation} | `personalinformation` invented; ref section title is `orderForm.personalInformation` (lagom clientareadetails.tpl:23, nexus clientregister.tpl:38); strip default | high |
| 72 | text | First name | WHMCS | {$LANG.clientareafirstname} | real key — nexus clientareadetails.tpl:27, lagom:31; strip default | high |
| 76 | text | Last name | WHMCS | {$LANG.clientarealastname} | real key — nexus clientareadetails.tpl:32, lagom:37; strip default | high |
| 82 | text | Email address | WHMCS | {$LANG.clientareaemail} | real key — nexus clientareadetails.tpl:42, lagom:45; strip default | high |
| 86 | text | Phone number | WHMCS | {$LANG.clientareaphonenumber} | real key — nexus clientareadetails.tpl:80, lagom:51; strip default | high |
| 92 | text | Language | WHMCS | {$LANG.clientarealanguage} | real key — nexus clientareadetails.tpl:108, lagom:57; strip default | high |
| 105 | text | Billing address | WHMCS | {$LANG.orderForm.billingAddress} | `billingaddress` invented; ref section title is `orderForm.billingAddress` (lagom clientareadetails.tpl:76); strip default | high |
| 109 | text | Company name | WHMCS | {$LANG.clientareacompanyname} | real key — nexus clientareadetails.tpl:37, lagom:84; strip default | high |
| 109 | text | optional | WHMCS | {$LANG.orderForm.optional} | `optional` invented; ref key `orderForm.optional` (lagom register-form.tpl:59); dedupe across batch; strip default | high |
| 113 | text | Address line 1 | WHMCS | {$LANG.clientareaaddress1} | real key — nexus clientareadetails.tpl:50, lagom:98; strip default | high |
| 119 | text | Address line 2 | WHMCS | {$LANG.clientareaaddress2} | real key — nexus clientareadetails.tpl:55, lagom:104; strip default | high |
| 119 | text | optional | WHMCS | {$LANG.orderForm.optional} | dedupe (line 109) | high |
| 123 | text | City | WHMCS | {$LANG.clientareacity} | real key — nexus clientareadetails.tpl:60, lagom:111; strip default | high |
| 129 | text | Country | WHMCS | {$LANG.clientareacountry} | real key — nexus clientareadetails.tpl:75, lagom:117; strip default | high |
| 141 | text | State / Region | WHMCS | {$LANG.clientareastate} | real key — nexus clientareadetails.tpl:65, lagom:125; strip default | high |
| 147 | text | Zip / Postal code | WHMCS | {$LANG.clientareapostcode} | real key — nexus clientareadetails.tpl:70, lagom:131; strip default | high |
| 157 | text | Email preferences | WHMCS | {$LANG.clientareacontactsemails} | `emailpreferences` invented; ref section title is `clientareacontactsemails` (nexus clientareadetails.tpl:167, lagom:206; hadrian already uses it correctly on contacts page); strip default | high |
| 161 | text | General emails | CUSTOM | {$hadrianLang.account.generalEmails} | `generalemails` not in refs; WHMCS renders pref labels dynamically via `{lang key="emailPreferences."|cat:$emailType}` (lagom clientareadetails.tpl:216) — hadrian hardcodes a static 6-row group → invented | high |
| 161 | text | All account-related emails and password reminders | CUSTOM | {$hadrianLang.account.generalEmailsSub} | `generalemailssub` not in refs; bespoke description (WHMCS has no per-pref sub-text) | high |
| 165 | text | Invoice emails | CUSTOM | {$hadrianLang.account.invoiceEmails} | `invoiceemails` not in refs; see line 161 note | high |
| 165 | text | New invoices, reminders, and overdue notices | CUSTOM | {$hadrianLang.account.invoiceEmailsSub} | `invoiceemailssub` not in refs; bespoke | high |
| 169 | text | Support emails | CUSTOM | {$hadrianLang.account.supportEmails} | `supportemails` not in refs; see line 161 note | high |
| 169 | text | Receive a CC of all support ticket communications | CUSTOM | {$hadrianLang.account.supportEmailsSub} | `supportemailssub` not in refs; bespoke | high |
| 173 | text | Product emails | CUSTOM | {$hadrianLang.account.productEmails} | `productemails` not in refs; see line 161 note | high |
| 173 | text | Welcome emails, suspensions and other lifecycle notifications | CUSTOM | {$hadrianLang.account.productEmailsSub} | `productemailssub` not in refs; bespoke | high |
| 177 | text | Domain emails | CUSTOM | {$hadrianLang.account.domainEmails} | `domainemails` not in refs; see line 161 note | high |
| 177 | text | Registration, transfer confirmations and renewal notices | CUSTOM | {$hadrianLang.account.domainEmailsSub} | `domainemailssub` not in refs; bespoke | high |
| 181 | text | Affiliate emails | CUSTOM | {$hadrianLang.account.affiliateEmails} | `affiliateemails` not in refs; see line 161 note | high |
| 181 | text | Notifications about your affiliate account and payouts | CUSTOM | {$hadrianLang.account.affiliateEmailsSub} | `affiliateemailssub` not in refs; bespoke | high |
| 188 | text | Cancel changes | WHMCS | {$LANG.cancel} | `cancelchanges` invented; ref reset/cancel is `cancel` (nexus clientareadetails.tpl:194); wording shifts "Cancel changes"→"Cancel"; strip default | med |
| 189 | value/text | Save changes | WHMCS | {$LANG.clientareasavechanges} | `savechanges` invented; ref submit is `clientareasavechanges` (nexus clientareadetails.tpl:193, lagom:249); strip default | high |
| 200 | text | Profile not yet set up | CUSTOM | {$hadrianLang.account.profileNotSetup} | `profilenotsetup` not in refs (empty state is hadrian-only); invented | high |
| 201 | text | Complete your account profile to keep your billing and contact info up to date. | CUSTOM | {$hadrianLang.account.profileNotSetupSub} | `profilenotsetupsub` not in refs; bespoke | high |
| 202 | text | Set up profile | CUSTOM | {$hadrianLang.account.setupProfile} | `setupprofile` not in refs; bespoke CTA | high |

_Notes: line 25 `'{$dashIsEmpty}'` is a `data-*` value, SKIP. All `value="{$clientsdetails.*|default:''|escape}"` are empty sticky-value defaults, SKIP. The `<option>` labels are `{$lang|capitalize}` / `{$name}` dynamic, SKIP._

---

### core/pages/clientareacontacts/default/default.tpl
_None found._ (1-line `{include}` forwarder → `account-contacts-manage/default/default.tpl`; no own strings.)

---

### core/pages/account-contacts-manage/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 33 | text | Contacts | WHMCS | {$LANG.contacts} | core-resolved account key; page title; strip default | med |
| 34 | text | Additional people authorised to manage parts of this account. | CUSTOM | {$hadrianLang.account.contactsSub} | `contactsSub` not in refs; bespoke subtitle | high |
| 52 | text | Choose a contact | WHMCS | {$LANG.clientareachoosecontact} | real key — nexus account-contacts-manage.tpl:6, lagom:12; strip default | high |
| 60 | text | Add new contact | WHMCS | {$LANG.clientareanavaddcontact} | real key — nexus account-contacts-manage.tpl:12, lagom:24; strip default | high |
| 62 | text | Go | WHMCS | {$LANG.go} | real key — nexus account-contacts-manage.tpl:16; strip default | high |
| 72 | text | Contact details | WHMCS | {$LANG.contactDetails} | real key — nexus account-contacts-manage.tpl:25 `{lang key="contactDetails"}`; strip default | high |
| 78 | text | First name | WHMCS | {$LANG.clientareafirstname} | real key — nexus account-contacts-manage.tpl:39, lagom:47; strip default | high |
| 82 | text | Last name | WHMCS | {$LANG.clientarealastname} | real key — nexus account-contacts-manage.tpl:44, lagom:53; strip default | high |
| 86 | text | Company | WHMCS | {$LANG.clientareacompanyname} | real key — nexus account-contacts-manage.tpl:49, lagom:71; strip default | high |
| 90 | text | Email address | WHMCS | {$LANG.clientareaemail} | real key — nexus account-contacts-manage.tpl:54, lagom:59; strip default | high |
| 94 | text | Phone number | WHMCS | {$LANG.clientareaphonenumber} | real key — nexus account-contacts-manage.tpl:59, lagom:65; strip default | high |
| 99 | text | Tax ID | — | — | `{$LANG[$taxIdLabel]|default:'Tax ID'}` — server-provided VAT label var (refs: `{lang key=$taxIdLabel}` nexus:64); SKIP (admin-set value, not a literal) | high |
| 107 | text | Address 1 | WHMCS | {$LANG.clientareaaddress1} | real key — nexus account-contacts-manage.tpl:72, lagom:83; strip default | high |
| 111 | text | Address 2 | WHMCS | {$LANG.clientareaaddress2} | real key — nexus account-contacts-manage.tpl:77, lagom:89; strip default | high |
| 115 | text | City | WHMCS | {$LANG.clientareacity} | real key — nexus account-contacts-manage.tpl:82, lagom:95; strip default | high |
| 119 | text | State / region | WHMCS | {$LANG.clientareastate} | real key — nexus account-contacts-manage.tpl:87, lagom:109; strip default | high |
| 123 | text | ZIP / postal code | WHMCS | {$LANG.clientareapostcode} | real key — nexus account-contacts-manage.tpl:92, lagom:115; strip default | high |
| 127 | text | Country | WHMCS | {$LANG.clientareacountry} | real key — nexus account-contacts-manage.tpl:97, lagom:101; strip default | high |
| 137 | text | Email preferences | WHMCS | {$LANG.clientareacontactsemails} | real key — nexus account-contacts-manage.tpl:110, lagom:128; strip default | high |
| 144 | text | (dynamic pref label) | — | — | `{lang key="emailPreferences."|cat:$emailType}` — dynamic key-prefix concat (refs do same); SKIP (not a literal) | high |
| 154 | text | Delete contact | WHMCS | {$LANG.clientareadeletecontact} | real key — nexus account-contacts-manage.tpl:127, lagom:149; strip default | high |
| 157 | text | Cancel | WHMCS | {$LANG.cancel} | real key — nexus account-contacts-manage.tpl:126 (reset btn); strip default | high |
| 158 | value/text | Save changes | WHMCS | {$LANG.clientareasavechanges} | real key — nexus account-contacts-manage.tpl:125, lagom:147; strip default | high |
| 38 | text | Account | WHMCS | {$LANG.accounttab} | core-resolved; subnav heading; strip default | med |
| 41 | text | Account Details | WHMCS | {$LANG.accountdetails} | core-resolved; subnav item; strip default | med |
| 45 | text | User Management | WHMCS | {$LANG.usermanagement} | core-resolved; subnav; strip default | med |
| 49 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat→nested; subnav; strip default | high |
| 53 | text | Contacts | WHMCS | {$LANG.contacts} | dedupe (line 33); subnav active | med |
| 57 | text | Email History | WHMCS | {$LANG.emailstitle} | core-resolved; subnav; strip default | med |
| 203 | js-string | Delete this contact? This cannot be undone. | WHMCS | {$LANG.clientareadeletecontactareyousure} | `confirm()` text; real key — nexus account-contacts-manage.tpl:144 `{lang key="clientareadeletecontactareyousure"}` (modal body). Seed into a JS lang object; wording shifts | med |

_Notes: subnav rows 38–57 are line-ordered out of sequence above to keep them grouped (they sit at file lines 167–186); both share the page's other subnav copy. `value="{$formdata.*|default:''|escape}"` sticky defaults, `name="email_preferences[…]"` and all intl-tel-input `<script>` (country codes, `'phonenumber'`, selectors) — SKIP (logic, no UI strings)._

---

### core/pages/account-contacts-new/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Add new contact | WHMCS | {$LANG.clientareanavaddcontact} | real key — nexus account-contacts-new.tpl (uses same key family), nexus account-contacts-manage.tpl:12; page title; strip default | high |
| 31 | text | Add another person who can manage parts of this account. | CUSTOM | {$hadrianLang.account.contactsNewSub} | `contactsnewsub` not in refs; bespoke subtitle | high |
| 49 | text | Choose a contact | WHMCS | {$LANG.clientareachoosecontact} | real key — nexus account-contacts-manage.tpl:6; dedupe; strip default | high |
| 57 | text | Add new contact | WHMCS | {$LANG.clientareanavaddcontact} | dedupe (line 30); picker option | high |
| 59 | text | Go | WHMCS | {$LANG.go} | dedupe; strip default | high |
| 68 | text | Contact details | WHMCS | {$LANG.contactDetails} | dedupe (contacts-manage:72); strip default | high |
| 73 | text | First name | WHMCS | {$LANG.clientareafirstname} | real key — dedupe; strip default | high |
| 77 | text | Last name | WHMCS | {$LANG.clientarealastname} | real key — dedupe; strip default | high |
| 81 | text | Company | WHMCS | {$LANG.clientareacompanyname} | real key — dedupe; strip default | high |
| 85 | text | Email address | WHMCS | {$LANG.clientareaemail} | real key — dedupe; strip default | high |
| 89 | text | Phone number | WHMCS | {$LANG.clientareaphonenumber} | real key — dedupe; strip default | high |
| 94 | text | Tax ID | — | — | `{$LANG[$taxIdLabel]|default:'Tax ID'}` — server VAT var; SKIP | high |
| 101 | text | Address 1 | WHMCS | {$LANG.clientareaaddress1} | real key — dedupe; strip default | high |
| 105 | text | Address 2 | WHMCS | {$LANG.clientareaaddress2} | real key — dedupe; strip default | high |
| 109 | text | City | WHMCS | {$LANG.clientareacity} | real key — dedupe; strip default | high |
| 113 | text | State / region | WHMCS | {$LANG.clientareastate} | real key — dedupe; strip default | high |
| 117 | text | ZIP / postal code | WHMCS | {$LANG.clientareapostcode} | real key — dedupe; strip default | high |
| 121 | text | Country | WHMCS | {$LANG.clientareacountry} | real key — dedupe; strip default | high |
| 131 | text | Email preferences | WHMCS | {$LANG.clientareacontactsemails} | real key — dedupe; strip default | high |
| 138 | text | (dynamic pref label) | — | — | `{lang key="emailPreferences."|cat:$emailType}` — dynamic; SKIP | high |
| 148 | text | Cancel | WHMCS | {$LANG.cancel} | real key — dedupe; strip default | high |
| 149 | value/text | Add contact | WHMCS | {$LANG.clientareanavaddcontact} | submit btn; `clientareanavaddcontact` ("Add new contact") is the real add-contact key; wording shifts "Add contact"→"Add new contact"; strip default | med |
| 158 | text | Account | WHMCS | {$LANG.accounttab} | core-resolved; subnav heading | med |
| 161 | text | Account Details | WHMCS | {$LANG.accountdetails} | core-resolved; subnav | med |
| 165 | text | User Management | WHMCS | {$LANG.usermanagement} | core-resolved; subnav | med |
| 169 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat→nested; subnav | high |
| 173 | text | Contacts | WHMCS | {$LANG.contacts} | core-resolved; subnav active | med |
| 177 | text | Email History | WHMCS | {$LANG.emailstitle} | core-resolved; subnav | med |

_Notes: identical intl-tel-input `<script>` to contacts-manage — no js-string. `value=""` sticky defaults SKIP._

---

### core/pages/account-user-management/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 42 | text | User Management | WHMCS | {$LANG.usermanagement} | core-resolved (real `navUserManagement`, nexus account-user-management.tpl:5 `{lang key="navUserManagement"}`); page title; strip default | med |
| 43 | text | Invite people to access this account and choose what they can do. | CUSTOM | {$hadrianLang.account.userManagementSub} | `usermanagementsub` not in refs; bespoke subtitle | high |
| 47 | text | Invite new user | WHMCS | {$LANG.userManagement.inviteNewUser} | real key — nexus account-user-management.tpl:85, lagom:8; strip default | high |
| 78 | text | Owner | WHMCS | {$LANG.clientOwner} | real key — nexus account-user-management.tpl:19, lagom:43; strip default | high |
| 83 | title | Two-factor enabled | WHMCS | {$LANG.twoFactor.enabled} | real key — nexus account-user-management.tpl:22, lagom:24; strip default | high |
| 90 | text | Last login | WHMCS | {$LANG.userManagement.lastLogin} | real key — nexus account-user-management.tpl:28, lagom:32; strip default | high |
| 91 | text | Never | WHMCS | {$LANG.never} | real key — nexus account-user-management.tpl:32 `{lang key='never'}`, lagom:36; strip default | high |
| 97 | text | Permissions | WHMCS | {$LANG.userManagement.managePermissions} | real key — nexus account-user-management.tpl:38, lagom:45; wording "Permissions" vs "Manage permissions"; strip default | high |
| 100 | text | Remove | WHMCS | {$LANG.userManagement.removeAccess} | real key — nexus account-user-management.tpl:41, lagom:48; strip default | high |
| 110 | text | Pending invites | WHMCS | {$LANG.userManagement.pendingInvites} | real key — nexus account-user-management.tpl:49, lagom:64; strip default | high |
| 117 | text | Pending | CUSTOM | {$hadrianLang.account.invitePending} | `userManagement.pending` not in refs (refs have no per-row "Pending" badge); invented tag | high |
| 119 | text | Invited | WHMCS | {$LANG.userManagement.inviteSent} | real key — nexus account-user-management.tpl:58, lagom:79; strip default | high |
| 127 | text | Resend | WHMCS | {$LANG.userManagement.resendInvite} | real key — nexus account-user-management.tpl:66, lagom:84; strip default | high |
| 129 | text | Cancel | WHMCS | {$LANG.userManagement.cancelInvite} | real key — nexus account-user-management.tpl:69, lagom:87; "Cancel" = invite cancel action; strip default | high |
| 136 | text | The account owner always has full permissions and cannot be removed. | WHMCS | {$LANG.userManagement.accountOwnerPermissionsInfo} | real key — nexus account-user-management.tpl:78, lagom:58; strip default | high |
| 174 | text | Invite a new user | WHMCS | {$LANG.userManagement.inviteNewUser} | dedupe (line 47); modal title default differs ("Invite a new user" vs "Invite new user") — same real key; strip default | high |
| 175 | aria-label | Close | WHMCS | {$LANG.close} | real key (nexus footer.tpl:70 `{lang key='close'}`); strip default | high |
| 185 | text | Send an invitation email. They can accept by signing in to — or creating — their WHMCS account. | WHMCS | {$LANG.userManagement.inviteNewUserDescription} | real key — nexus account-user-management.tpl:87, lagom:110; wording shifts; strip default | med |
| 187 | text | Email address | WHMCS | {$LANG.userManagement.emailAddress} | `emailaddress` (flat) invented; real key `userManagement.emailAddress` (nexus account-user-management.tpl:11); or reuse `clientareaemail`; strip default | med |
| 191 | text | Permissions | WHMCS | {$LANG.userManagement.permissions} | real key — nexus account-user-permissions.tpl:9, lagom:13; strip default | high |
| 194 | text | All permissions | WHMCS | {$LANG.userManagement.allPermissions} | real key — nexus account-user-management.tpl:96, lagom:118; strip default | high |
| 198 | text | Choose individual permissions | WHMCS | {$LANG.userManagement.choosePermissions} | real key — nexus account-user-management.tpl:100, lagom:124; strip default | high |
| 216 | text | Cancel | WHMCS | {$LANG.cancel} | real key — nexus account-user-management.tpl:145 (modal cancel btn); strip default | high |
| 217 | text | Send invitation | WHMCS | {$LANG.userManagement.sendInvite} | real key — nexus account-user-management.tpl:116, lagom:143; strip default | high |
| 142 | text | Account | WHMCS | {$LANG.accounttab} | core-resolved; subnav heading | med |
| 145 | text | Account Details | WHMCS | {$LANG.accountdetails} | core-resolved; subnav | med |
| 149 | text | User Management | WHMCS | {$LANG.usermanagement} | dedupe (line 42); subnav active | med |
| 153 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat→nested; subnav | high |
| 157 | text | Contacts | WHMCS | {$LANG.contacts} | core-resolved; subnav | med |
| 161 | text | Email History | WHMCS | {$LANG.emailstitle} | core-resolved; subnav | med |
| 276 | js-string | Remove this user's access to your account? | WHMCS | {$LANG.userManagement.removeAccessSure} | `confirm()` text; real key — nexus account-user-management.tpl:139 (modal body); wording shifts; seed into JS lang | med |
| 287 | js-string | Cancel this pending invitation? | WHMCS | {$LANG.userManagement.cancelInviteSure} | `confirm()` text; real key — nexus account-user-management.tpl:167 (modal body); wording shifts; seed into JS lang | med |

_Notes: `$perm.title`/`$perm.description`/`$user->email`/`$uName`/`$uInitial`/`$invite->email` all dynamic, SKIP. `placeholder="name@example.com"` (line 188) is a sample-email format, SKIP. `'{if $usCount…}full{else}empty{/if}'`/`'on'` are `data-*` values, SKIP._

---

### core/pages/account-user-permissions/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 50 | text | Account | WHMCS | {$LANG.accounttab} | core-resolved; eyebrow; strip default | med |
| 51 | text | User permissions | WHMCS | {$LANG.userManagement.permissions} | real key — nexus account-user-permissions.tpl:9, lagom:13; page title (default "User permissions" vs "Permissions"); strip default | med |
| 52 | text | Choose what this user can see and do on the account. | WHMCS | {$LANG.userManagement.managePermissions} | `managePermissions` real key (nexus account-user-permissions.tpl:5 = "Manage permissions"); hadrian pipes a *different* literal through it — see ambiguity #4 (the real WHMCS string will win on server) | low |
| 63 | text | Permissions | WHMCS | {$LANG.userManagement.permissions} | real key — dedupe (line 51); user-card sub | high |
| 70 | text | Permissions | WHMCS | {$LANG.userManagement.permissions} | real key — dedupe; card header; strip default | high |
| 101 | text | Save permissions | WHMCS | {$LANG.clientareasavechanges} | `clientareasavechanges` real key (nexus account-user-permissions.tpl:28, lagom:32 = "Save changes"); hadrian default "Save permissions" — different literal via `|default`; strip default (see ambiguity #4) | med |
| 102 | text | Cancel | WHMCS | {$LANG.cancel} | real key (nexus account-contacts-manage.tpl:126); note refs use `clientareacancel` here (nexus account-user-permissions.tpl:31) — either fits; strip default | med |
| 115 | text | No user selected | CUSTOM | {$hadrianLang.account.noUserSelected} | `userManagement.noUserSelected` not in refs (no empty state on permissions page); invented | high |
| 116 | text | Choose a user from user management to edit their permissions. | CUSTOM | {$hadrianLang.account.selectUserSub} | `userManagement.selectUserSub` not in refs; bespoke | high |
| 117 | text | User management | WHMCS | {$LANG.usermanagement} | core-resolved; empty-state CTA; strip default | med |
| 126 | text | Account | WHMCS | {$LANG.accounttab} | dedupe (line 50); subnav heading | med |
| 129 | text | Account Details | WHMCS | {$LANG.accountdetails} | core-resolved; subnav | med |
| 133 | text | User Management | WHMCS | {$LANG.usermanagement} | core-resolved; subnav active | med |
| 137 | text | Payment Methods | WHMCS | {$LANG.paymentMethods.title} | flat→nested; subnav | high |
| 141 | text | Contacts | WHMCS | {$LANG.contacts} | core-resolved; subnav | med |

_Notes: the `permList` demo array (lines 20–28: "View services"/"Manage services"/… + descriptions) renders ONLY under `?preview=1` as placeholder data — these are demo `$perm.title`/`$perm.description` values echoed dynamically, not literal text nodes → SKIP (matches dashboard demo-data convention). `$permEmail`/`user@example.com` fallback (line 35) is sample data, SKIP. `'{$dashIsEmpty}'`/`'on'` `data-*`, SKIP._

---

### core/pages/clientareausers/default/default.tpl
_None found._ (1-line `{include}` forwarder → `account-user-management/default/default.tpl`; no own strings.)

---

### core/pages/clientareaemails/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 49 | text | Account | WHMCS | {$LANG.accounttab} | core-resolved; eyebrow; strip default | med |
| 50 | text | Email history | WHMCS | {$LANG.emailstitle} | core-resolved account key; page title; strip default | med |
| 51 | text | Messages we have sent to your account email address. | CUSTOM | {$hadrianLang.account.emailsIntro} | `emailsintro` not in refs (nexus/lagom clientareaemails are bare DataTables, no intro); bespoke | high |
| 62 | placeholder | Search | WHMCS | {$LANG.search} | real key — nexus downloads.tpl:6, includes/domain-search.tpl:13; strip default | high |
| 62 | aria-label | Search | WHMCS | {$LANG.search} | dedupe; same input; strip default | high |
| 71 | text | Date Sent | WHMCS | {$LANG.clientareaemailsdate} | real key — nexus clientareaemails.tpl:21, lagom:26; strip default | high |
| 72 | text | Message Subject | WHMCS | {$LANG.clientareaemailssubject} | real key — nexus clientareaemails.tpl:22, lagom:27; strip default | high |
| 74 | text | Date Sent | WHMCS | {$LANG.clientareaemailsdate} | dedupe (line 71); ajax-table header | high |
| 75 | text | Message Subject | WHMCS | {$LANG.clientareaemailssubject} | dedupe (line 72); ajax-table header | high |
| 98 | placeholder | Search | WHMCS | {$LANG.search} | dedupe (line 62); ajax footer search; strip default | high |
| 98 | aria-label | Search | WHMCS | {$LANG.search} | dedupe; strip default | high |
| 106 | text | Show | CUSTOM | {$hadrianLang.account.showEntries} | `show` not in refs (DataTables length labels come from JS config, not templates); invented | med |
| 107 | aria-label | Show entries | CUSTOM | {$hadrianLang.account.showEntriesAria} | composed from `show`+`entries` defaults; bespoke a11y label | low |
| 112 | text | entries | CUSTOM | {$hadrianLang.account.entries} | `entries` not in refs; invented (pairs with `show`) | med |
| 129 | text | No emails yet | CUSTOM | {$hadrianLang.account.emailsEmptyTitle} | `clientareaemailsnonetitle` not in refs (no empty state in ref clientareaemails); invented | high |
| 130 | text | Messages we send to your account email will be listed here. | CUSTOM | {$hadrianLang.account.emailsEmptySub} | `clientareaemailsnone` here = bespoke empty-list copy; NOT the WHMCS `clientareaemailsnone` ("no longer available", see viewemail) — see ambiguity #5; invented | high |
| 131 | text | Account details | WHMCS | {$LANG.accountdetails} | core-resolved; empty-state CTA; strip default | med |
| 140 | text | Account | WHMCS | {$LANG.accounttab} | dedupe (line 49); subnav heading | med |
| 143 | text | Account Details | WHMCS | {$LANG.accountdetails} | core-resolved; subnav | med |
| 147 | text | Contacts | WHMCS | {$LANG.contacts} | core-resolved; subnav | med |
| 151 | text | Email History | WHMCS | {$LANG.emailstitle} | dedupe (line 50); subnav active | med |
| 155 | text | Security | WHMCS | {$LANG.security} | core-resolved nav key; subnav; strip default | med |
| 175 | js-string | Showing | CUSTOM | {$hadrianLang.account.dtShowing} | DataTables-fallback `L.showing`; info-bar prefix ("Showing %s–%s of %s"); no ref (refs use real DataTables i18n); invented | low |
| 175 | js-string | of | CUSTOM | {$hadrianLang.account.dtOf} | `L.of`; info-bar connector; invented | low |
| 175 | js-string | No matching emails | CUSTOM | {$hadrianLang.account.dtNoMatch} | `L.none`; empty-filter message; invented | med |
| 175 | js-string | filtered from | CUSTOM | {$hadrianLang.account.dtFiltered} | `L.filtered`; "(filtered from %s)"; invented | low |

_Notes: line 175 `L.to = '–'` is an en-dash glyph (punctuation), SKIP. `$email.date`/`$email.subject`/`$email.id` dynamic, SKIP. All `data-mt-*`/`data-sort`/`data-href`/`data-date` are `data-*` attr values, SKIP. The pager `<svg>` (PREV/NEXT) is markup, SKIP. `'{$dashIsEmpty}'`/`'on'` `data-*`, SKIP. The `<option>10/25/50</option>` are numbers, SKIP. Demo `$emails` array (lines 18–23, `?preview=1`) is sample data echoed dynamically, SKIP._

---

### core/pages/viewemail/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 19 | title | Email | WHMCS | {$LANG.clientareaemails} | `clientareaemails` real key (nexus viewemail.tpl:5 `{lang key='clientareaemails'}`, lagom:8 = "My Emails"); `<title>` text; wording "Email"→"My Emails"; strip default | high |
| 26 | text | Email | WHMCS | {$LANG.clientareaemails} | dedupe (line 19); eyebrow; strip default | high |
| 33 | text | Attachments | WHMCS | {$LANG.supportticketsticketattachments} | real key — nexus viewticket.tpl:82/141, supportticketsubmit-steptwo.tpl:74; lagom viewticket.tpl:43/154; strip default | high |
| 43 | text | This email is no longer available. | WHMCS | {$LANG.clientareaemailsnone} | `clientareaemailsnone` is the real WHMCS "no emails" key; hadrian reuses it here for the missing-message empty state (plausible fit, wording shifts); strip default — but note the same key is used with a *different* literal on clientareaemails:130 (ambiguity #5) | med |

_Notes: `{$companyname|default:'Hostnodes'|escape}` (lines 19/27) — brand fallback, SKIP (proper noun). `{$vemMsg}`/`{$attachedFile}` dynamic, SKIP. `<html lang="en">`/charset/viewport are markup attrs, SKIP. The `?preview=1` demo message HTML (line 13, "Hi Arshile…") is sample data, SKIP._

---

## Proposed custom keys
```
hadrianLang.account.accountDetailsSub = "Your personal information, billing address and email preferences."
hadrianLang.account.generalEmails = "General emails"
hadrianLang.account.generalEmailsSub = "All account-related emails and password reminders"
hadrianLang.account.invoiceEmails = "Invoice emails"
hadrianLang.account.invoiceEmailsSub = "New invoices, reminders, and overdue notices"
hadrianLang.account.supportEmails = "Support emails"
hadrianLang.account.supportEmailsSub = "Receive a CC of all support ticket communications"
hadrianLang.account.productEmails = "Product emails"
hadrianLang.account.productEmailsSub = "Welcome emails, suspensions and other lifecycle notifications"
hadrianLang.account.domainEmails = "Domain emails"
hadrianLang.account.domainEmailsSub = "Registration, transfer confirmations and renewal notices"
hadrianLang.account.affiliateEmails = "Affiliate emails"
hadrianLang.account.affiliateEmailsSub = "Notifications about your affiliate account and payouts"
hadrianLang.account.profileNotSetup = "Profile not yet set up"
hadrianLang.account.profileNotSetupSub = "Complete your account profile to keep your billing and contact info up to date."
hadrianLang.account.setupProfile = "Set up profile"
hadrianLang.account.contactsSub = "Additional people authorised to manage parts of this account."
hadrianLang.account.contactsNewSub = "Add another person who can manage parts of this account."
hadrianLang.account.userManagementSub = "Invite people to access this account and choose what they can do."
hadrianLang.account.invitePending = "Pending"
hadrianLang.account.noUserSelected = "No user selected"
hadrianLang.account.selectUserSub = "Choose a user from user management to edit their permissions."
hadrianLang.account.emailsIntro = "Messages we have sent to your account email address."
hadrianLang.account.showEntries = "Show"
hadrianLang.account.showEntriesAria = "Show entries"
hadrianLang.account.entries = "entries"
hadrianLang.account.emailsEmptyTitle = "No emails yet"
hadrianLang.account.emailsEmptySub = "Messages we send to your account email will be listed here."
hadrianLang.account.dtShowing = "Showing"
hadrianLang.account.dtOf = "of"
hadrianLang.account.dtNoMatch = "No matching emails"
hadrianLang.account.dtFiltered = "filtered from"
```

## Ambiguities / switch-targets (for the fix phase)
1. **Invented flat section-title keys with proven WHMCS targets.** `personalinformation` → `orderForm.personalInformation`; `billingaddress` → `orderForm.billingAddress`; `emailpreferences` → `clientareacontactsemails`. All three are classed WHMCS above (refs use the proven key for the same section heading); listed because the *key name* changes even though the rendered string stays.
2. **Invented "changes" button keys.** `savechanges` → `clientareasavechanges`; `cancelchanges` → `cancel`. Stripping resolves to the WHMCS wording ("Save changes" stays; "Cancel changes" becomes "Cancel").
3. **Two cancel keys coexist.** Refs use `cancel` on contacts (nexus account-contacts-manage:126) but `clientareacancel` on permissions (nexus account-user-permissions:31). Both are real and both = "Cancel"; hadrian uses `cancel` everywhere — fine, but flag if you want to mirror refs exactly.
4. **Reused-key-with-wrong-literal traps (the `|default` is dead on the server).** Two spots pipe a *different* English literal through a real WHMCS key, so the rendered text will be the WHMCS string, not hadrian's copy:
   - account-user-permissions:52 — `userManagement.managePermissions|default:'Choose what this user can see and do on the account.'` → server renders **"Manage permissions"**, not the sentence. If the descriptive subtitle is wanted, mint a custom key instead.
   - account-user-permissions:101 — `clientareasavechanges|default:'Save permissions'` → server renders **"Save changes"**, not "Save permissions". Same for `userManagement.permissions|default:'User permissions'` (line 51) → "Permissions". Decide: accept WHMCS wording or go custom.
5. **`clientareaemailsnone` used with two different literals.** clientareaemails:130 pipes it as an empty-LIST message ("Messages we send … listed here.") while viewemail:43 pipes it as a missing-MESSAGE message ("This email is no longer available."). On the server the real `clientareaemailsnone` string wins in BOTH places, so the two pages will show identical text. I classed viewemail:43 WHMCS (plausible fit) and clientareaemails:130 CUSTOM (the list-empty wording is bespoke and shouldn't collide). Pick one: keep the WHMCS key on viewemail + a custom key for the list-empty state (recommended), or accept identical copy.
6. **`emailaddress` (flat) on the invite modal** → real key is `userManagement.emailAddress` (nexus account-user-management:11) or generic `clientareaemail`. Classed WHMCS; flag the key-name choice.
7. **`userManagement.inviteNewUser` carries two defaults** — "Invite new user" (button, line 47) vs "Invite a new user" (modal title, line 174). Same real key; stripping unifies them to one WHMCS string.
8. **Core-resolved nav/section keys** (`accounttab`, `accountdetails`, `usermanagement`, `contacts`, `emailstitle`, `paymentmethods`→`paymentMethods.title`, `security`, `usermanagement`) can't be cited file:line (WHMCS resolves them in navbar/Menu PHP). Kept WHMCS/med per the prefer-real-keys policy, same as B08. Verify against the server `lang/english.php` before stripping defaults.
9. **Email-preference checkbox group is hand-rolled.** clientareadetails lines 161–181 hardcode 6 static pref rows (label + sub-text). WHMCS's real mechanism is the dynamic `{lang key="emailPreferences."|cat:$emailType}` loop (as hadrian itself does on the contacts pages, lines 144/138). The labels were classed CUSTOM (no WHMCS per-row label+description exists), but the *better* fix is to drive this group from `$emailPreferences` dynamically like the contacts page rather than tokenizing 12 invented strings.
10. **JS `confirm()` strings map to real WHMCS modal-body keys** — contacts-manage:203 → `clientareadeletecontactareyousure`; user-management:276 → `userManagement.removeAccessSure`; user-management:287 → `userManagement.cancelInviteSure`. These pages have no `_localLang` seed yet (unlike cart files), so wiring them needs a small Smarty→JS lang bridge; classed WHMCS (the keys are real) but flagged as needing the seed mechanism.
