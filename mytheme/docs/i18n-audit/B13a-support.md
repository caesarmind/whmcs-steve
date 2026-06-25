# B13a — Support (tickets list, submit flow, view ticket, feedback)

## Summary
- **Total strings (table rows):** 143
- **WHMCS:** 93
- **CUSTOM:** 50
- **#SKIP-worth-noting:** see notes (legacy `$rslang` not used in these files; the lang file `hadrian/.../core/lang/english.php` has NO `support` group; `$reply.*`/`$customfield.*`/`$dept.*`/`$staff*`/`$clientsdetails.*`/`$errormessage`/`$attachment` dynamic output skipped; SVG/`data-*`/URLs/`$WEB_ROOT`/class names skipped; `'Client'`/`'?'` `|default` fallbacks on dynamic vars skipped; `?preview=1` demo `{assign}` seed data on confirm/customfields/kbsuggestions/feedback skipped as non-shipping; the "KB" file-size unit built in attachment JS skipped — see ambiguity #4)
- **#js-string:** 3 (all in the supporttickets DataTables block, lines 275/277: "Showing %s–%s of %s" → CUSTOM, "Previous page" + "Next page" → WHMCS dedupes of the markup `aria-label`s). The split markup tokens "Show"/"entries"/"Showing"/"of" (lines 172–182) are reported as plain `text` rows, not js-string.
- **Distinct strings after dedupe:** ~95. Heavy dedupe drivers: `opennewticket` ("Open a ticket", ×7 across the sub-nav + empty states), `supporttab` ("Support", ×5 eyebrows/headings), `myTickets`/`chooseFile`/`addmore`/`orderForm.remove`/`supportticketsallowedextensions`/`attachmentsAllowedFallback`/`returnclient`/`feedbackthankyou` each repeat. 3 of the 11 files are pure `{include}` forwarders (supportticketslist, submitticket, supportticketsubmit-stepone, supportticketsubmit-steptwo — 4 forwarders, no own strings).

### Evidence legend
- nexus uses `{lang key='x'}` (resolves real WHMCS `$_LANG`) — citing it proves the key is real.
- lagom uses `{$LANG.x}` — same proof.
- This theme uses `{$LANG.x|default:'English'}` **everywhere** (never a bare `{$LANG.x}`), so per spec the `|default` literal is the "Current text"; `|default`-only keys not provable elsewhere are treated as **invented → CUSTOM**.
- The **support filenames are identical** in nexus (`supportticketsubmit-stepone.tpl`, `viewticket.tpl`, `ticketfeedback.tpl`, …) and lagom — these are the highest-value references and most strings map 1:1.
- **Section/nav labels** `supporttab` ("Support") and `supporttickets` are genuine WHMCS keys but WHMCS resolves them inside its core navbar/Menu PHP (cf. B08 batch), so they never appear in a reference *template* and can't be cited file:line. Per "prefer real keys" they are kept **WHMCS / med** with the note "core-resolved — verify in lang/english.php; strip default". Flagged as ambiguity #1.
- **`supporttab` is reused as a page-eyebrow** ("Support") on confirm / customfields / kbsuggestions / ticketfeedback — same key, deduped.

---

### hadrian/templates/hadrian/core/pages/supporttickets/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 64 | text | Tickets | WHMCS | {$LANG.navtickets} | real key — nexus/clientareahome.tpl:45 + lagom2.3/lagom2-theme/clientareahome.tpl:115 use `navtickets` bare (WHMCS "My Support Tickets"); strip default | high |
| 65 | text | Open conversations with our team — filter by status or start a new ticket. | CUSTOM | {$hadrianLang.support.ticketsListSub} | invented `ticketssub`; no WHMCS subtitle key | high |
| 68 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | real key — lagom2.3/lagom2-theme/clientareaquotes.tpl:98 uses `opennewticket` bare; strip default | high |
| 82 | text | ticket | CUSTOM | {$hadrianLang.support.ticketSingular} | invented `ticket`; singular noun used in a count phrase; no bare WHMCS key | med |
| 82 | text | tickets | CUSTOM | {$hadrianLang.support.ticketPlural} | invented `tickets`; plural noun in count phrase | med |
| 82 | text | has a new reply from our team. | CUSTOM | {$hadrianLang.support.newReplyBanner} | invented `ticketnewreply`; bespoke unread-banner copy | high |
| 84 | text | View replies | CUSTOM | {$hadrianLang.support.viewReplies} | invented `viewreplies`; no WHMCS key (nexus/lagom have no unread banner) | high |
| 89 | text | All | WHMCS | {$LANG.all} | `all` is a standard WHMCS filter key; strip default | med |
| 90 | text | Open | WHMCS | {$LANG.supportticketsstatusopen} | real status key (cf. nexus uses `supportticketsstatusclosed` bare, viewticket.tpl:27); strip default | high |
| 91 | text | Answered | WHMCS | {$LANG.supportticketsstatusanswered} | real status key (sibling of the bare-used `supportticketsstatusclosed`); strip default | high |
| 92 | text | Customer-reply | WHMCS | {$LANG.supportticketsstatuscustomerreply} | real status key; strip default (WHMCS "Customer-Reply") | high |
| 93 | text | Closed | WHMCS | {$LANG.supportticketsstatusclosed} | real key — nexus/viewticket.tpl:27 `{lang key='supportticketsstatusclosed'}`; strip default | high |
| 94 | placeholder | Search | WHMCS | {$LANG.search} | real key — lagom downloads.tpl:20 / knowledgebase.tpl:11 use `{$LANG.search}` bare; strip default | high |
| 94 | aria-label | Search | WHMCS | {$LANG.search} | dedupe of line 94 placeholder | high |
| 118 | text | No tickets yet | CUSTOM | {$hadrianLang.support.noTicketsTitle} | invented `notickets`; bespoke empty-state heading | high |
| 119 | text | You haven't opened any support tickets. Need a hand with something? Our team is here to help. | CUSTOM | {$hadrianLang.support.noTicketsSub} | invented `noticketssub`; bespoke empty-state body | high |
| 120 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | dedupe of line 68 | high |
| 133 | text | Subject | WHMCS | {$LANG.supportticketssubject} | real key — nexus/supportticketslist.tpl:25 `{lang key='supportticketssubject'}`; strip default | high |
| 134 | text | Department | WHMCS | {$LANG.supportticketsdepartment} | real key — nexus/supportticketslist.tpl:24 + lagom viewticket.tpl:90; strip default | high |
| 135 | text | Status | WHMCS | {$LANG.supportticketsstatus} | real key — nexus/supportticketslist.tpl:26 `{lang key='supportticketsstatus'}`; strip default | high |
| 136 | text | Last updated | WHMCS | {$LANG.supportticketsticketlastupdated} | real key — nexus/supportticketslist.tpl:27 `{lang key='supportticketsticketlastupdated'}`; default here is `supportticketslastupdated` (variant) → use the real `supportticketsticketlastupdated`; strip default | high |
| 172 | text | Show | CUSTOM | {$hadrianLang.support.tableShow} | split DataTables label; WHMCS ships the composite `tablelength` ("Show _MENU_ entries", nexus/includes/tablelist.tpl:64) — no standalone "Show". Reused across 7 hadrian list pages → likely owned by a table batch; rebadge or wire to `tablelength` | low |
| 173 | aria-label | Rows per page | CUSTOM | {$hadrianLang.support.rowsPerPage} | invented `rowsperpage`; no standalone WHMCS key (composite is `tablelength`); reused across list pages | low |
| 179 | text | entries | CUSTOM | {$hadrianLang.support.tableEntries} | split DataTables token; part of composite `tablelength`; reused across list pages | low |
| 182 | text | Showing | CUSTOM | {$hadrianLang.support.tableShowing} | split token; WHMCS composite is `tableshowing` (nexus/includes/tablelist.tpl:59); reused across list pages | low |
| 182 | text | of | CUSTOM | {$hadrianLang.support.tableOf} | split connector word; reused across list pages | low |
| 184 | aria-label | Previous page | WHMCS | {$LANG.previouspage} | real key — lagom serverstatus.tpl:71 uses `{$LANG.previouspage}` bare; strip default | high |
| 186 | aria-label | Next page | WHMCS | {$LANG.nextpage} | real key — lagom serverstatus.tpl:72 uses `{$LANG.nextpage}` bare; strip default | high |
| 196 | text | Support | WHMCS | {$LANG.supporttab} | section label; core-resolved (see legend); strip default | med |
| 199 | text | My tickets | CUSTOM | {$hadrianLang.support.myTickets} | invented `mytickets`; closest real key is `navtickets` ("My Support Tickets") — consider `{$LANG.navtickets}` if wording shift OK; kept CUSTOM (sub-nav uses a shorter label) | med |
| 204 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | dedupe of line 68 | high |
| 208 | text | Announcements | WHMCS | {$LANG.announcementstitle} | real key — nexus/homepage.tpl:58 `{lang key='announcementstitle'}`; strip default | high |
| 212 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | real key — nexus/homepage.tpl:74 `{lang key='knowledgebasetitle'}`; strip default | high |
| 216 | text | Downloads | WHMCS | {$LANG.downloadstitle} | real key — standard WHMCS `downloadstitle` (downloads section); strip default | med |
| 220 | text | Network status | WHMCS | {$LANG.networkstatus} | real key — standard WHMCS `networkstatus` (serverstatus page); strip default | med |
| 275 | js-string | Showing %s–%s of %s | CUSTOM | {$hadrianLang.support.tableShowingFull} | DataTables `updateControls` sets `infoEl.textContent = 'Showing ' + from + '–' + info.end + ' of ' + …'`; composite of the split tokens; map to WHMCS `tableshowing`; seed from Smarty | low |
| 275 | js-string | Previous page | WHMCS | {$LANG.previouspage} | JS pager `buildPager` `aria-label="Previous page"`; dedupe of line 184 | med |
| 277 | js-string | Next page | WHMCS | {$LANG.nextpage} | JS pager `aria-label="Next page"`; dedupe of line 186 | med |

Notes: `$dashIsEmpty`, `$tkUnreadCount`, `$tkt.*`, `$tkCount`, `$tktStatusClass`, `$tktPriority`, all `data-*`/`data-mt-*` attr values, SVG path data, `$WEB_ROOT`/CDN script URLs, `data-data`/`data-subnav`/`data-svc-layout` body flags skipped. The DataTables JS pager also builds `aria-label="Previous page"/"Next page"` inline (lines 275/277) — flagged as js-string dedupes. `#{$tkt.tid}` is a number+dynamic. `1–{$tkCount} of {$tkCount}` (line 182) is split between the `Showing`/`of` tokens + dynamic counts.

---

### hadrian/templates/hadrian/core/pages/supportticketslist/default/default.tpl
_None found._ (one-line `{include}` forwarding to `supporttickets/default/default.tpl` — audited above.)

---

### hadrian/templates/hadrian/core/pages/submitticket/default/default.tpl
_None found._ (forwards to `supportticketsubmit/default/default.tpl` — audited below.)

---

### hadrian/templates/hadrian/core/pages/supportticketsubmit/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 45 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | dedupe; real key (lagom clientareaquotes.tpl:98); strip default | high |
| 46 | text | Tell us what you need help with — our team will reply by email. | CUSTOM | {$hadrianLang.support.submitSub} | invented `submitticketsub`; bespoke page subtitle (nexus uses `supportticketsheader` for a different subtitle) | high |
| 54 | text | Support | WHMCS | {$LANG.supporttab} | section label; core-resolved; dedupe of supporttickets.tpl:196 | med |
| 57 | text | My tickets | CUSTOM | {$hadrianLang.support.myTickets} | dedupe of supporttickets.tpl:199 | med |
| 61 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | dedupe | high |
| 65 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe of supporttickets.tpl:208 | high |
| 69 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe of supporttickets.tpl:212 | high |
| 73 | text | Network status | WHMCS | {$LANG.networkstatus} | dedupe of supporttickets.tpl:220 | med |
| 92 | text | Step 1 of 2 | CUSTOM | {$hadrianLang.support.step1of2} | invented `step1of2`; no WHMCS stepper key | high |
| 93 | text | Choose a department | CUSTOM | {$hadrianLang.support.chooseDepartment} | invented `choosedepartment`; nexus step-1 heading is `createNewSupportRequest` — consider `{$LANG.createNewSupportRequest}` ("Open New Ticket"); kept CUSTOM (different wording) | med |
| 94 | text | Pick the team best suited to help — your message reaches them directly. | CUSTOM | {$hadrianLang.support.chooseDepartmentSub} | invented `choosedepartmentsub`; closest is `supportticketsheader` (nexus step-1 subtitle) — consider WHMCS; kept CUSTOM | med |
| 127 | text | Cancel | WHMCS | {$LANG.cancel} | real key — nexus/supportticketsubmit-steptwo.tpl:119 `{lang key='cancel'}`; strip default | high |
| 128 | text | Continue | WHMCS | {$LANG.continue} | real key — nexus/supportticketsubmit-confirm.tpl:23 `{lang key='continue'}`; strip default | high |
| 136 | text | Step 2 of 2 | CUSTOM | {$hadrianLang.support.step2of2} | invented `step2of2`; no WHMCS stepper key | high |
| 137 | text | Ticket details | CUSTOM | {$hadrianLang.support.ticketDetails} | invented `ticketdetails`; nexus step-2 heading is `createNewSupportRequest`; kept CUSTOM | med |
| 139 | text | Replying via | CUSTOM | {$hadrianLang.support.replyingVia} | invented `replyingto`; no WHMCS "Replying via" key (department-prefix label) | high |
| 150 | text | Your name | WHMCS | {$LANG.clientareafirstname} | maps to real `clientareafirstname`; nexus uses `supportticketsclientname` ("Name") for this guest field — consider `{$LANG.supportticketsclientname}` (nexus/supportticketsubmit-steptwo.tpl:14); strip default | med |
| 154 | text | Email address | WHMCS | {$LANG.clientareaemail} | real `clientareaemail`; nexus uses `supportticketsclientemail` here (steptwo.tpl:18) — either works; strip default | med |
| 161 | text | Subject | WHMCS | {$LANG.supportticketsticketsubject} | real key — nexus/supportticketsubmit-steptwo.tpl:24 `{lang key='supportticketsticketsubject'}` for this input; default here is the variant `supportticketssubject` → prefer `supportticketsticketsubject`; strip default | high |
| 167 | text | Priority | WHMCS | {$LANG.supportticketspriority} | real key — nexus/supportticketsubmit-steptwo.tpl:53; strip default | high |
| 169 | option | Low | WHMCS | {$LANG.supportticketsticketurgencylow} | real key — nexus steptwo.tpl:61; strip default | high |
| 170 | option | Medium | WHMCS | {$LANG.supportticketsticketurgencymedium} | real key — nexus steptwo.tpl:58; strip default | high |
| 171 | option | High | WHMCS | {$LANG.supportticketsticketurgencyhigh} | real key — nexus steptwo.tpl:56; strip default | high |
| 176 | text | Related service | WHMCS | {$LANG.relatedservice} | real key — nexus/supportticketsubmit-steptwo.tpl:41 `{lang key='relatedservice'}`; strip default | high |
| 176 | text | optional | CUSTOM | {$hadrianLang.support.optional} | invented `optional`; "(optional)" hint; no standalone WHMCS key found in references | med |
| 178 | option | None | WHMCS | {$LANG.none} | real key — nexus/supportticketsubmit-steptwo.tpl:43 `{lang key='none'}`; strip default | high |
| 188 | text | Message | WHMCS | {$LANG.contactmessage} | real key — nexus/supportticketsubmit-steptwo.tpl:69 + lagom viewticket.tpl:38 `contactmessage`; strip default | high |
| 210 | text | Attachments | WHMCS | {$LANG.supportticketsticketattachments} | real key — nexus steptwo.tpl:74 + lagom viewticket.tpl:43; strip default | high |
| 210 | text | optional | CUSTOM | {$hadrianLang.support.optional} | dedupe of line 176 | med |
| 215 | text | Choose a file… | WHMCS | {$LANG.chooseFile} | real key — nexus/supportticketsubmit-steptwo.tpl:78 `{lang key='chooseFile'}` ("Choose file"); strip default | high |
| 218 | aria-label | Remove | WHMCS | {$LANG.orderForm.remove} | real nested key — lagom viewticket.tpl:56 / supportticketsubmit-steptwo.tpl:161 use `{$LANG.orderForm.remove}` bare on this exact button; already correct key, strip default | high |
| 225 | text | Add another file | WHMCS | {$LANG.addmore} | real key — nexus steptwo.tpl:85 `{lang key='addmore'}` ("Add More"); strip default (wording differs, key right) | high |
| 229 | text | Allowed extensions | WHMCS | {$LANG.supportticketsallowedextensions} | real key — nexus steptwo.tpl:101 + lagom viewticket.tpl:61; strip default | high |
| 229 | text | Allowed: .jpg, .gif, .jpeg, .png, .txt, .pdf · Max 64MB | CUSTOM | {$hadrianLang.support.attachmentsAllowedFallback} | invented `attachmentsallowed`; hardcoded ext/size fallback shown only when `$allowedfiletypes` unset — bespoke (WHMCS builds this from `supportticketsallowedextensions` + `maxFileSize`) | med |
| 316 | text | Back | WHMCS | {$LANG.back} | real key — nexus/store/order.tpl:173 + lagom configuressl-stepone.tpl:7 use `back` bare; strip default | high |
| 317 | value | Submit ticket | WHMCS | {$LANG.supportticketsticketsubmit} | real key — nexus steptwo.tpl:117 `{lang key='supportticketsticketsubmit'}` + lagom viewticket.tpl:65; strip default | high |
| 332 | text | No departments available | CUSTOM | {$hadrianLang.support.noDepartmentsTitle} | invented `nodepartments`; nexus shows `nosupportdepartments` ("Sorry, there are no support departments…") for this case — consider `{$LANG.nosupportdepartments}` (nexus stepone.tpl:22); kept CUSTOM (separate title vs body split) | med |
| 333 | text | No support departments have been configured. Please contact the site administrator. | CUSTOM | {$hadrianLang.support.noDepartmentsSub} | invented `nodepartmentssub`; closest real key is `nosupportdepartments` (single combined string) — consider WHMCS; kept CUSTOM | med |
| 334 | text | Contact us | WHMCS | {$LANG.contactus} | real key — nexus/contact.tpl:5 + lagom user-invite.tpl:138 use `contactus` bare; strip default | high |

Notes: `$dept.*`/`$deptName`/`$deptKind`/`$chosenDeptName`/`$relatedservice.*`/`$customfield.*` (incl. `$customfield.input` raw HTML, `$customfield.name`, `$customfield.description`) dynamic → SKIP. `$errormessage` (line 84) is WHMCS-rendered error HTML → SKIP. `{lang key="maxFileSize" fileSize=$uploadMaxFileSize}` (line 229) is already a real `{lang}` call with a param → leave as-is (correct WHMCS usage, not a `|default`). The attachment-row `<script>` (lines 232–306) manipulates DOM only — `f.name + ' (' + kb + ' KB)'` builds a filename+size string from dynamic file data (the "KB" unit is a borderline standalone token, noted in ambiguity #4) → not reported as a row. Captcha include, SVG/`data-*`/`$WEB_ROOT` skipped.

---

### hadrian/templates/hadrian/core/pages/supportticketsubmit-confirm/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 22 | text | Support | WHMCS | {$LANG.supporttab} | page-eyebrow; section label, core-resolved; dedupe | med |
| 23 | text | Ticket created | WHMCS | {$LANG.supportticketsticketcreated} | real key — nexus/supportticketsubmit-confirm.tpl:8 `{lang key='supportticketsticketcreated'}`; strip default | high |
| 31 | text | Ticket created | WHMCS | {$LANG.supportticketsticketcreated} | dedupe of line 23 (notice title) | high |
| 32 | text | Your ticket has been submitted. Our team will reply by email and you can follow the conversation in your client area. | WHMCS | {$LANG.supportticketsticketcreateddesc} | real key — nexus/supportticketsubmit-confirm.tpl:15 `{lang key='supportticketsticketcreateddesc'}`; strip default (WHMCS wording differs) | high |
| 34 | text | View ticket | CUSTOM | {$hadrianLang.support.viewTicketBtn} | invented `viewticket`; nexus confirm CTA is the real `{$LANG.continue}` (confirm.tpl:23) — consider `{$LANG.continue}`; kept CUSTOM (theme uses an explicit "View ticket" label, distinct from the `supportticketsviewticket` "View Ticket #" heading) | med |
| 36 | text | My tickets | CUSTOM | {$hadrianLang.support.myTickets} | dedupe of supporttickets.tpl:199 | med |

Notes: `$tkTid`/`$tid`/`$c`/`$isPreview`/`$dashIsEmpty` dynamic → SKIP. `#{$tkTid}` number+dynamic. SVG/`data-*`/`$WEB_ROOT` skipped.

---

### hadrian/templates/hadrian/core/pages/supportticketsubmit-customfields/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 39 | text | Support | WHMCS | {$LANG.supporttab} | page-eyebrow; section label, core-resolved; dedupe | med |
| 40 | text | Additional details | CUSTOM | {$hadrianLang.support.additionalInfoTitle} | invented `supportticketsadditionalinfo`; nexus customfields fragment has NO heading (just iterates fields) → bespoke standalone-card title | high |
| 41 | text | A few department-specific details to help us route and resolve your ticket faster. | CUSTOM | {$hadrianLang.support.customFieldsIntro} | invented `supportticketscustomfieldsintro`; no WHMCS intro key | high |
| 75 | text | No additional fields | CUSTOM | {$hadrianLang.support.noCustomFieldsTitle} | invented `supportticketsnocustomfields`; bespoke empty-state heading | high |
| 76 | text | This department has no extra fields. Continue with your ticket. | CUSTOM | {$hadrianLang.support.noCustomFieldsSub} | invented `supportticketsnocustomfieldssub`; bespoke empty-state body | high |
| 77 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | dedupe of supporttickets.tpl:68 | high |

Notes: this page is normally a *fragment* of the submit form (nexus includes `supportticketsubmit-customfields.tpl` inside step-2 and it renders only `$customfield.name`/`.input`/`.description`). All `$customfield.*` output (incl. `$customfield.required` rendered as the literal `*`, line 54/57) is dynamic → SKIP. The `?preview=1` demo `{assign}` data (lines 18–21: "Affected service", "Business Cloud Pro", "Order or invoice number", "e.g. #1042", etc.) is **demo seed data inside Smarty arrays, not emitted UI copy** → SKIP (preview-only; cf. spec treats demo seeds as non-shipping). Inline `style=` attrs skipped.

---

### hadrian/templates/hadrian/core/pages/supportticketsubmit-kbsuggestions/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 38 | text | Support | WHMCS | {$LANG.supporttab} | page-eyebrow; section label, core-resolved; dedupe | med |
| 39 | text | Before you submit | CUSTOM | {$hadrianLang.support.kbSuggestionsTitle} | `kbsuggestions` default here is "Before you submit"; the REAL `kbsuggestions` key = "Knowledgebase Suggestions" (nexus/supportticketsubmit-kbsuggestions.tpl:1) → this is a **real key piped a different default** trap. Use `{$LANG.kbsuggestions}` (WHMCS wording) → class WHMCS, OR keep bespoke title as CUSTOM if "Before you submit" must stay. Flagged ambiguity #3 | med |
| 40 | text | These knowledgebase articles match your question and might resolve it instantly. | WHMCS | {$LANG.kbsuggestionsexplanation} | real key — nexus/supportticketsubmit-kbsuggestions.tpl:3 `{lang key='kbsuggestionsexplanation'}`; strip default (WHMCS wording differs) | high |
| 58 | text | None of these helped, continue | CUSTOM | {$hadrianLang.support.kbSuggestionsContinue} | invented `kbsuggestionscontinue`; no WHMCS key (nexus has no continue button on this fragment) | high |
| 70 | text | No matching articles | CUSTOM | {$hadrianLang.support.kbNoSuggestionsTitle} | invented `kbnosuggestions`; bespoke empty-state heading | high |
| 71 | text | We couldn't find a related article. Go ahead and open your ticket. | CUSTOM | {$hadrianLang.support.kbNoSuggestionsSub} | invented `kbnosuggestionssub`; bespoke empty-state body | high |
| 72 | text | Open a ticket | WHMCS | {$LANG.opennewticket} | dedupe of supporttickets.tpl:68 | high |

Notes: `$kbarticle.title`/`$kbarticle.article`/`$kbarticle.id` dynamic → SKIP. The `?preview=1` demo `{assign}` KB articles (lines 16–20: "How to reset your cPanel password", "Pointing your domain to our nameservers", "Setting up email on your device", etc.) are demo seed data, not shipping UI → SKIP. Inline `style=`/SVG/`$WEB_ROOT` skipped.

---

### hadrian/templates/hadrian/core/pages/supportticketsubmit-stepone/default/default.tpl
_None found._ (one-line `{include}` forwarding to `supportticketsubmit/default/default.tpl` — audited above.)

---

### hadrian/templates/hadrian/core/pages/supportticketsubmit-steptwo/default/default.tpl
_None found._ (forwards to `supportticketsubmit/default/default.tpl`.)

---

### hadrian/templates/hadrian/core/pages/viewticket/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 60 | text (js confirm) | Close this ticket? | WHMCS | {$LANG.confirmcloseticket} | inline `onclick="return confirm('…')"`; real WHMCS key `confirmcloseticket` ("Are you sure you want to close this ticket?"); strip default | med |
| 62 | text | Close Ticket | WHMCS | {$LANG.supportticketsclose} | real key — nexus/viewticket.tpl:33 `{lang key='supportticketsclose'}`; strip default | high |
| 76 | text | Conversation | CUSTOM | {$hadrianLang.support.conversation} | invented `conversation`; no WHMCS section-title key (nexus/lagom have no "Conversation" heading) | high |
| 100 | text | Attachments were removed. | WHMCS | {$LANG.support.attachmentsRemoved} | real nested key — nexus/viewticket.tpl:84 + lagom viewticket.tpl:155 `{lang key='support.attachmentsRemoved'}`; default here is flat `attachmentsremoved` → use real nested `support.attachmentsRemoved`; strip default | high |
| 112 | aria-label | Download | WHMCS | {$LANG.download} | standard WHMCS `download` key (downloads section); not citable bare in nexus/lagom support tpls; strip default | med |
| 125 | text | No conversation yet — be the first to reply. | CUSTOM | {$hadrianLang.support.noTicketReplies} | invented `noticketreplies`; no WHMCS key (a ticket always has an opening post in WHMCS) | med |
| 134 | text | Ticket Settings | CUSTOM | {$hadrianLang.support.ticketSettings} | invented `ticketsettings`; no WHMCS section-title key | high |
| 139 | text | Reply | WHMCS | {$LANG.supportticketsreply} | real key — nexus/viewticket.tpl:21/121 + lagom viewticket.tpl:21 `supportticketsreply`; strip default | high |
| 158 | placeholder | Write your reply… | CUSTOM | {$hadrianLang.support.writeYourReply} | invented `writeyourreply`; no WHMCS placeholder key (nexus reply textarea has no placeholder) | high |
| 166 | text | Choose a file… | WHMCS | {$LANG.chooseFile} | real key — nexus/viewticket.tpl:145 `{lang key='chooseFile'}`; dedupe; strip default | high |
| 169 | aria-label | Remove | WHMCS | {$LANG.orderForm.remove} | real nested key — lagom viewticket.tpl:56 uses it bare on this button; dedupe; strip default | high |
| 176 | text | Add another file | WHMCS | {$LANG.addmore} | real key — nexus/viewticket.tpl:152 `{lang key='addmore'}`; dedupe; strip default | high |
| 180 | text | Allowed extensions | WHMCS | {$LANG.supportticketsallowedextensions} | real key — nexus/viewticket.tpl:168 + lagom viewticket.tpl:61; dedupe; strip default | high |
| 180 | text | Allowed extensions: .jpg, .gif, .jpeg, .png, .txt, .pdf · Max file size: 64MB | CUSTOM | {$hadrianLang.support.attachmentsAllowedFallback} | invented `attachmentsallowed`; ext/size fallback (only when `$allowedfiletypes` unset); dedupe of supportticketsubmit.tpl:229 (NOTE divergent default wording — see ambiguity #5) | med |
| 249 | text | Send Message | CUSTOM | {$hadrianLang.support.sendMessage} | invented `sendmessage`; nexus/lagom reply submit uses the real `supportticketsticketsubmit` ("Submit") (nexus viewticket.tpl:173) — consider `{$LANG.supportticketsticketsubmit}`; kept CUSTOM (theme wording "Send Message") | med |
| 250 | text | Cancel | WHMCS | {$LANG.cancel} | real key — nexus/viewticket.tpl:174 `{lang key='cancel'}`; strip default | high |
| 263 | text | Ticket Information | WHMCS | {$LANG.ticketinfo} | maps to real `ticketinfo` ("Ticket Information") — lagom/viewticket.tpl:75 `{$LANG.ticketinfo}`; default here is invented `ticketinformation` → use real `ticketinfo`; strip default | high |
| 268 | text | Status | WHMCS | {$LANG.supportticketsstatus} | real key — dedupe; nexus/supportticketslist.tpl:26; strip default | high |
| 276 | text | Requestor | CUSTOM | {$hadrianLang.support.requestor} | invented `requestor`; WHMCS only has `support.requestor.<type>` (role-type names: Owner/Admin/…), NOT a "Requestor" field label → CUSTOM. Flagged ambiguity #2 | med |
| 292 | text | Department | WHMCS | {$LANG.supportticketsdepartment} | real key — dedupe; lagom viewticket.tpl:90; strip default | high |
| 301 | text | Submitted | WHMCS | {$LANG.supportticketssubmitted} | real status/meta key (sibling of bare-used support* keys); strip default | med |
| 310 | text | Last Updated | WHMCS | {$LANG.supportticketsticketlastupdated} | real key — nexus/supportticketslist.tpl:27; default here is variant `supportticketslastupdated` → use `supportticketsticketlastupdated`; strip default | high |
| 319 | text | Priority | WHMCS | {$LANG.supportticketspriority} | real key — dedupe; lagom viewticket.tpl:87; strip default | high |
| 335 | text | Ticket not available | CUSTOM | {$hadrianLang.support.ticketNotAvailableTitle} | invented `ticketnotavailable`; nexus uses the alert `supportticketinvalid` ("This support ticket was not found…") for this case — consider `{$LANG.supportticketinvalid}`; kept CUSTOM (title/body split) | med |
| 336 | text | This ticket may be closed, archived, or no longer accessible. | CUSTOM | {$hadrianLang.support.ticketNotAvailableSub} | invented `ticketnotavailablesub`; closest is `supportticketinvalid` (single string) — consider WHMCS; kept CUSTOM | med |
| 337 | text | All tickets | CUSTOM | {$hadrianLang.support.allTickets} | invented `alltickets`; closest real key is `navtickets` ("My Support Tickets") — consider `{$LANG.navtickets}`; kept CUSTOM (back-link wording) | med |

Notes: `$tid`/`$ticketid`/`$subject`/`$status`/`$priority`/`$department`/`$date`/`$lastreply`/`$reply.*`/`$attachment`/`$clientsdetails.*`/`$id`/`$c`/`$token` dynamic → SKIP. `$reply.name|default:'Client'` (line 94) — `|default` fallback on a dynamic sender name, not standalone UI copy → SKIP (borderline; if tokenized: `hadrianLang.support.client` = "Client"). `$clientsdetails.firstname|default:'?'` (lines 145/279) → SKIP (avatar initial placeholder). `{lang key="maxFileSize" …}` (line 180) is a correct `{lang}` call → leave. The attachment-row `<script>` (lines 183–246) is DOM-only (same as submit page; "KB" unit borderline, ambiguity #4) → no js-string rows. SVG/`data-*`/inline `style=`/`$WEB_ROOT` skipped.

---

### hadrian/templates/hadrian/core/pages/ticketfeedback/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 49 | text | Support | WHMCS | {$LANG.supporttab} | page-eyebrow; section label, core-resolved; dedupe | med |
| 50 | text | Ticket feedback | CUSTOM | {$hadrianLang.support.feedbackTitle} | invented `feedbacktitle`; nexus/lagom ticketfeedback have no page title (heading comes from layout) → bespoke | med |
| 58 | text | Feedback not available yet | CUSTOM | {$hadrianLang.support.feedbackClosedTitle} | `feedbackclosed` default here is "Feedback not available yet"; REAL `feedbackclosed` key = "This ticket is still marked as Open…" (nexus ticketfeedback.tpl:4) → **real key, different default** trap. The notice TITLE is bespoke; the body (line 59) is the real string. Title → CUSTOM; see ambiguity #6 | med |
| 59 | text | This ticket is still open. You can leave feedback once it has been resolved. | WHMCS | {$LANG.feedbackclosed} | real key — nexus/ticketfeedback.tpl:4 + lagom ticketfeedback.tpl:5 `feedbackclosed`; this is the genuine "still open" message; strip default (WHMCS wording differs) | high |
| 60 | text | Back to dashboard | WHMCS | {$LANG.returnclient} | real key — nexus/ticketfeedback.tpl:7 + lagom:7 `returnclient` ("Return to Client Area"); strip default | high |
| 67 | text | Feedback already submitted | WHMCS | {$LANG.feedbackprovided} | real key — nexus/ticketfeedback.tpl:10 + lagom:14 `feedbackprovided`; strip default | high |
| 67 | text | Thank you for your feedback | WHMCS | {$LANG.feedbackreceived} | real key — nexus/ticketfeedback.tpl:18 + lagom:25 `feedbackreceived`; strip default | high |
| 68 | text | We appreciate you taking the time to help us improve our support. | WHMCS | {$LANG.feedbackthankyou} | real key — nexus/ticketfeedback.tpl:12 + lagom:15 `feedbackthankyou`; strip default | high |
| 69 | text | Back to dashboard | WHMCS | {$LANG.returnclient} | dedupe of line 60 | high |
| 83 | text | Opened | WHMCS | {$LANG.feedbackopenedat} | real key — nexus/ticketfeedback.tpl:39 + lagom:40 `feedbackopenedat`; strip default | high |
| 84 | text | Last reply | WHMCS | {$LANG.feedbacklastreplied} | real key — nexus/ticketfeedback.tpl:43 + lagom:44 `feedbacklastreplied`; strip default | high |
| 85 | text | Staff involved | WHMCS | {$LANG.feedbackstaffinvolved} | real key — nexus/ticketfeedback.tpl:47 + lagom:48 `feedbackstaffinvolved`; strip default | high |
| 85 | text | None | WHMCS | {$LANG.none} | real key — nexus/ticketfeedback.tpl:48 `{lang key='none'}`; strip default | high |
| 86 | text | Total duration | WHMCS | {$LANG.feedbacktotalduration} | real key — nexus/ticketfeedback.tpl:51 + lagom:52 `feedbacktotalduration`; strip default | high |
| 98 | text | How well did | WHMCS | {$LANG.feedbackpleaserate1} | real key — nexus/ticketfeedback.tpl:65 + lagom:68 `feedbackpleaserate1`; strip default | high |
| 98 | text | handle your request? | WHMCS | {$LANG.feedbackhandled} | real key — nexus/ticketfeedback.tpl:65 + lagom:68 `feedbackhandled`; strip default | high |
| 107 | placeholder | Any comments about | WHMCS | {$LANG.feedbackpleasecomment1} | real key — nexus/ticketfeedback.tpl:95 + lagom:76 `feedbackpleasecomment1`; default here trims to a placeholder ("Any comments about %s?") but the key matches; strip default | med |
| 112 | text | Anything else we could improve? | WHMCS | {$LANG.feedbackimprove} | real key — nexus/ticketfeedback.tpl:107 + lagom:81 `feedbackimprove`; strip default | high |
| 113 | placeholder | Your feedback... | CUSTOM | {$hadrianLang.support.feedbackCommentsPlaceholder} | invented `feedbackcommentsplaceholder`; nexus/lagom generic-comment textarea has NO placeholder → bespoke | high |
| 117 | text | Submit feedback | WHMCS | {$LANG.clientareasavechanges} | real key — nexus/ticketfeedback.tpl:118 + lagom:87 use `clientareasavechanges` ("Save Changes") on this submit; default here is invented `feedbacksubmit` → use `clientareasavechanges`; strip default (wording differs, key right) | high |
| 118 | text | Review ticket | WHMCS | {$LANG.feedbackclickreview} | real key — nexus/ticketfeedback.tpl:33 + lagom:56 `feedbackclickreview` ("Click here to review the ticket"); strip default | high |

Notes: `$opened`/`$lastreply`/`$staffinvolvedtext`/`$duration`/`$staffinvolved`/`$staff`/`$staffid`/`$ratings`/`$rating`/`$rate`/`$comments`/`$tid`/`$c`/`$errormessage` dynamic → SKIP. The `?preview=1` demo `{assign}` data (lines 26–31: "Sarah K., Mike R.", "2 days, 7 hours", etc.) is demo seed data → SKIP. `feedbackprovided` vs `feedbackreceived` (line 67) correctly branch on `$fbState` — both real, both reported. Inline `style=`/SVG/`$WEB_ROOT` skipped.

---

## New ambiguities (flag for the user)
1. **Core-resolved section labels can't be cited file:line.** `supporttab` ("Support") and `supporttickets` are genuine WHMCS `$_LANG` keys but WHMCS resolves them inside its navbar/Menu PHP (cf. B08 batch), so they never appear in a reference template. Kept **WHMCS / med** per "prefer real keys". `supporttab` is reused as a page-eyebrow on 4 pages. **Verify against server lang/english.php before stripping defaults.**
2. **`requestor` has no WHMCS field-label key.** WHMCS ships `support.requestor.<type>` (the *role-type* names — Owner, Admin, etc., used inside the posted-by badge), but NOT a standalone "Requestor" label for the info-card row. viewticket.tpl:276 invents `requestor` → CUSTOM. Confirm there's no `support.requestor` parent label on the server.
3. **`kbsuggestions` real-key-with-wrong-default trap.** kbsuggestions.tpl:39 does `{$LANG.kbsuggestions|default:'Before you submit'}` but the REAL `kbsuggestions` = "Knowledgebase Suggestions" (nexus/supportticketsubmit-kbsuggestions.tpl:1). If you strip the default you get WHMCS wording "Knowledgebase Suggestions", NOT "Before you submit". Decide: adopt WHMCS wording (→ class WHMCS, `{$LANG.kbsuggestions}`) or keep the bespoke title (→ CUSTOM under a new key). Reported as CUSTOM to preserve current copy; flagged for your call.
4. **"KB" file-size unit in attachment JS.** Both attachment `<script>` blocks build `f.name + ' (' + kb + ' KB)'`. "KB" is a unit abbreviation (borderline translatable). Not reported as a js-string row; if Phase B tokenizes units, propose `hadrianLang.support.fileSizeKb` = "KB".
5. **Divergent defaults on `attachmentsallowed`.** The ext/size fallback differs between pages: supportticketsubmit.tpl:229 "Allowed: …· Max 64MB" vs viewticket.tpl:180 "Allowed extensions: …· Max file size: 64MB". Same invented key, two English strings — unify on one custom value. (This fallback only shows when WHMCS `$allowedfiletypes` is unset; normally WHMCS supplies the real `supportticketsallowedextensions` + `maxFileSize`.)
6. **`feedbackclosed` real-key-with-wrong-default trap.** ticketfeedback.tpl splits the "still open" notice into a bespoke TITLE ("Feedback not available yet", line 58) + the real `feedbackclosed` BODY (line 59). WHMCS `feedbackclosed` is a single combined string ("This ticket is still marked as Open / open and so cannot be reviewed yet"). Stripping the default on line 58 would surface that whole sentence as the title. Title kept CUSTOM; body mapped to WHMCS. Decide whether to keep the title/body split.
7. **Split DataTables tokens vs WHMCS composites.** supporttickets.tpl uses standalone "Show"/"entries"/"Showing"/"of"/"Rows per page" (lines 172–182) + the JS twin "Showing %s–%s of %s" (line 275). WHMCS ships these only as composite, placeholder-bearing keys: `tablelength` ("Show _MENU_ entries"), `tableshowing` ("Showing _START_ to _END_ of _TOTAL_ entries") — nexus/includes/tablelist.tpl:59-64. These split tokens are reused across **7 hadrian list pages** (clientareaproducts/quotes/invoices/emails/domains/serverstatus + this one) and are almost certainly owned by an earlier *table* batch — reported here as CUSTOM/low so they're not lost, but recommend dedupe with that batch and ideally wire to the WHMCS composites. `previouspage`/`nextpage` ARE real standalone keys (kept WHMCS).
8. **Guest name/email field keys.** supportticketsubmit.tpl:150/154 use `clientareafirstname`/`clientareaemail` ("Your name"/"Email address") for the guest submit fields, but nexus/lagom use the support-specific `supportticketsclientname` ("Name") / `supportticketsclientemail` ("Email Address") on the SAME fields. Both are real WHMCS keys; mapped to the generic ones (matching current defaults) but the support-specific pair is the reference convention — your choice.
9. **"View ticket" vs `supportticketsviewticket`.** WHMCS `supportticketsviewticket` = "View Ticket" (nexus/viewticket.tpl:17, used as the "View Ticket #N" heading). confirm.tpl:34's "View ticket" button could reuse it (→ WHMCS) instead of a new custom key. Reported CUSTOM; consider mapping.

---

## Proposed custom keys
```
hadrianLang.support.ticketsListSub                = "Open conversations with our team — filter by status or start a new ticket."
hadrianLang.support.ticketSingular                = "ticket"
hadrianLang.support.ticketPlural                  = "tickets"
hadrianLang.support.newReplyBanner                = "has a new reply from our team."
hadrianLang.support.viewReplies                   = "View replies"
hadrianLang.support.noTicketsTitle                = "No tickets yet"
hadrianLang.support.noTicketsSub                  = "You haven't opened any support tickets. Need a hand with something? Our team is here to help."
hadrianLang.support.tableShow                     = "Show"
hadrianLang.support.rowsPerPage                   = "Rows per page"
hadrianLang.support.tableEntries                  = "entries"
hadrianLang.support.tableShowing                  = "Showing"
hadrianLang.support.tableOf                       = "of"
hadrianLang.support.tableShowingFull              = "Showing %s–%s of %s"
hadrianLang.support.myTickets                     = "My tickets"
hadrianLang.support.submitSub                     = "Tell us what you need help with — our team will reply by email."
hadrianLang.support.step1of2                      = "Step 1 of 2"
hadrianLang.support.step2of2                      = "Step 2 of 2"
hadrianLang.support.chooseDepartment              = "Choose a department"
hadrianLang.support.chooseDepartmentSub           = "Pick the team best suited to help — your message reaches them directly."
hadrianLang.support.ticketDetails                 = "Ticket details"
hadrianLang.support.replyingVia                   = "Replying via"
hadrianLang.support.optional                      = "optional"
hadrianLang.support.attachmentsAllowedFallback    = "Allowed extensions: .jpg, .gif, .jpeg, .png, .txt, .pdf · Max file size: 64MB"
hadrianLang.support.noDepartmentsTitle            = "No departments available"
hadrianLang.support.noDepartmentsSub              = "No support departments have been configured. Please contact the site administrator."
hadrianLang.support.viewTicketBtn                 = "View ticket"
hadrianLang.support.additionalInfoTitle           = "Additional details"
hadrianLang.support.customFieldsIntro             = "A few department-specific details to help us route and resolve your ticket faster."
hadrianLang.support.noCustomFieldsTitle           = "No additional fields"
hadrianLang.support.noCustomFieldsSub             = "This department has no extra fields. Continue with your ticket."
hadrianLang.support.kbSuggestionsTitle            = "Before you submit"
hadrianLang.support.kbSuggestionsContinue         = "None of these helped, continue"
hadrianLang.support.kbNoSuggestionsTitle          = "No matching articles"
hadrianLang.support.kbNoSuggestionsSub            = "We couldn't find a related article. Go ahead and open your ticket."
hadrianLang.support.conversation                  = "Conversation"
hadrianLang.support.noTicketReplies               = "No conversation yet — be the first to reply."
hadrianLang.support.ticketSettings                = "Ticket Settings"
hadrianLang.support.writeYourReply                = "Write your reply…"
hadrianLang.support.sendMessage                   = "Send Message"
hadrianLang.support.requestor                     = "Requestor"
hadrianLang.support.ticketNotAvailableTitle       = "Ticket not available"
hadrianLang.support.ticketNotAvailableSub         = "This ticket may be closed, archived, or no longer accessible."
hadrianLang.support.allTickets                    = "All tickets"
hadrianLang.support.feedbackTitle                 = "Ticket feedback"
hadrianLang.support.feedbackClosedTitle           = "Feedback not available yet"
hadrianLang.support.feedbackCommentsPlaceholder   = "Your feedback..."
```

### Optional (only if Phase B tokenizes the file-size unit)
```
hadrianLang.support.fileSizeKb = "KB"
```
