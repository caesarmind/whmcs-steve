# B13b — KB / announcements / downloads / contact / markdown / server status (support + network)

## Summary
- **Total strings (table rows):** 217 (heavy duplication — the 8-page Support sub-nav repeats ~7 WHMCS rows per page; markdown-guide alone is ~30 rows)
- **WHMCS:** 139
- **CUSTOM:** 78 (66 distinct keys after dedupe — see `## Proposed custom keys`)
- **#SKIP-worth-noting:** see notes per file (all `{$var}` dynamic output — `$cat.name`, `$art.title`, `$ann.title/.text/.date`, `$download.*`, `$issue.*`, `$server.*`, `$dept.name`, `$annTitle/$annText/$annDate`, `$author`, `$noissuesmsg`, `$kbarticle.text`, `$catName`; demo-data array literals under `?preview=1`; `data-data`/`data-subnav` body-script attr values; SVG path data; URLs/hrefs/`routePath()`; brand tokens HTTP/FTP/POP3/PDF/ZIP; `role`/`aria-label="…table…"` landmark/grid roles; the `var example = "hello";` literal Markdown sample). `$rslang.*` — none present in these files.
- **#js-string:** 1 (viewannouncement copy-link "Copied" toast). The downloadscat + serverstatus `{literal}` scripts contain **no** user-facing strings (selectors/dataset/fetch only).

### Evidence legend
- nexus uses `{lang key='x'}` → resolves real WHMCS `$_LANG`; citing it proves a key is real.
- lagom uses `{$LANG.x}` → same proof.
- This theme uses `{$LANG.x|default:'…'}` **everywhere** (never a bare `{$LANG.x}`). Per spec the `|default` literal is the "Current text"; a `|default`-only key not provable elsewhere is treated as invented → CUSTOM.
- **Big win on markdown-guide:** nexus ships `nexus/markdown-guide.tpl` using the exact same nested `markdown.*` keys our template carries (accessed here as `$LANG['markdown.x']`). Almost all are real WHMCS keys → WHMCS, strip default.
- **`|default`-literal traps flagged** (real key, but our `|default` puts a DIFFERENT English than WHMCS ships — stripping the default WILL change the visible label): `networkstatustitle` (we show "Incidents & maintenance", WHMCS = "Network Status"), `viewcart` (we show "Open", WHMCS = "View Cart"), `networkissuesstatusopen` (we show "Active", WHMCS = "Open"), `downloadsfiles` (we show count-word "files", WHMCS section title = "Files"), `kbarticles` (we show count-word "articles"; the real list key is `knowledgebasearticles` = "Articles" / count key is `knowledgebase.numArticles`).

---

### hadrian/templates/hadrian/core/pages/knowledgebase/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 27 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | real key — `nexus/homepage.tpl:74` `{lang key='knowledgebasetitle'}`; strip default | high |
| 28 | text | Setup guides, troubleshooting and answers to frequently asked questions. | CUSTOM | {$hadrianLang.support.kbSubtitle} | `knowledgebasesub` not in nexus/lagom → invented page subtitle → rebadge | high |
| 36 | text | Support | WHMCS | {$LANG.supporttab} | WHMCS section key (cf. `supporttickets` family), core-resolved; strip default | med |
| 39 | text | My support tickets | WHMCS | {$LANG.mytickets} | standard WHMCS key (nav/support); core-resolved; default "My support tickets" vs WHMCS "My Tickets"; strip default | med |
| 43 | text | Announcements | WHMCS | {$LANG.announcementstitle} | real key — `nexus/announcements.tpl:3`; strip default | high |
| 47 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe of line 27 | high |
| 51 | text | Open ticket | WHMCS | {$LANG.opennewticket} | standard WHMCS key "Open New Ticket"; default "Open ticket"; strip default | med |
| 57 | text | Most popular | WHMCS | {$LANG.knowledgebasepopular} | real key — `nexus/knowledgebase.tpl:45`, `lagom2.3/lagom2-theme/knowledgebase.tpl:45`; **NOTE our key is `knowledgebasepop` (invented) — use real `knowledgebasepopular`**, strip default | high |
| 64 | text | views | CUSTOM | {$hadrianLang.support.views} | `views` not found as a WHMCS key in nexus/lagom; count-suffix word; rebadge | med |
| 78 | text | How can we help? | WHMCS | {$LANG.howcanwehelp} | real key — `lagom2.3/lagom2-theme/knowledgebase.tpl:8` placeholder `{$LANG.howcanwehelp}`; our key is `kbherotitle` (invented) → use `howcanwehelp`; strip default | high |
| 79 | text | Search the knowledgebase or browse by category below. | CUSTOM | {$hadrianLang.support.kbHeroSub} | `kbherosub` not in refs → invented hero subtitle → rebadge | high |
| 82 | placeholder | Search guides, troubleshooting, billing… | WHMCS | {$LANG.clientHomeSearchKb} | KB search placeholder; real key — `nexus/knowledgebase.tpl:3` `{lang key='clientHomeSearchKb'}`; our `kbsearchplaceholder` invented; strip default (wording shifts) | high |
| 94 | text | articles | CUSTOM | {$hadrianLang.support.articlesCount} | `kbarticles` here = count-suffix "articles"; the WHMCS list key `knowledgebasearticles` means the *section* "Articles" (nexus/knowledgebasecat.tpl:46) — different semantics; the real count key is nested `knowledgebase.numArticles{s}` (`nexus/knowledgebase.tpl:20`) which needs `num=`. Safer as CUSTOM count word; see ambiguity #2 | med |
| 107 | text | No articles yet | WHMCS | {$LANG.knowledgebasenoarticles} | real key — `nexus/knowledgebase.tpl:37`, `lagom2.3/lagom2-theme/knowledgebase.tpl:37`; default "No articles yet" vs WHMCS "There are currently no Knowledgebase articles…"; strip default (wording shifts) | med |
| 108 | text | When our team publishes setup guides and troubleshooting articles, they will appear here. | CUSTOM | {$hadrianLang.support.kbEmptySub} | `kbemptysub` not in refs → invented empty-state body → rebadge | high |
| 109 | text | Open a ticket instead | WHMCS | {$LANG.opennewticket} | dedupe of line 51; default "Open a ticket instead" — same key; strip default | med |

Notes: `$cat.name`, `$cat.numarticles`, `$art.title`, `$art.views`, `$art@iteration`, `$kbsearchterm` dynamic → SKIP. SVG/`data-*`/`href`/inline body-script attrs skipped.

---

### hadrian/templates/hadrian/core/pages/knowledgebasearticle/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; real key (`nexus/homepage.tpl:74`); strip default | high |
| 31 | text | Read the full article and rate it. | CUSTOM | {$hadrianLang.support.kbArticleSubtitle} | `kbarticlesub` not in refs → invented subtitle → rebadge | high |
| 39 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; section key; strip default | med |
| 42 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 46 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; real key; strip default | high |
| 50 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 54 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |
| 67 | text | views | CUSTOM | {$hadrianLang.support.views} | dedupe of knowledgebase.tpl:64; count-suffix | med |
| 77 | text | Was this article helpful? | WHMCS | {$LANG.knowledgebasehelpful} | real key — `nexus/knowledgebasearticle.tpl:35` `{lang key='knowledgebasehelpful'}`, `lagom2.3/lagom2-theme/knowledgebasearticle.tpl:26`; strip default | high |
| 79 | text | Thanks for your feedback! | WHMCS | {$LANG.knowledgebaseArticleRatingThanks} | real nested key — `nexus/knowledgebasearticle.tpl:2`, lagom:14; already the correct key, strip default | high |
| 85 | text | Yes | WHMCS | {$LANG.knowledgebaseyes} | real key — `nexus/knowledgebasearticle.tpl:41`, lagom:31; strip default | high |
| 89 | text | No | WHMCS | {$LANG.knowledgebaseno} | real key — `nexus/knowledgebasearticle.tpl:46`, lagom:32; strip default | high |
| 95 | text | people found this helpful | CUSTOM | {$hadrianLang.support.helpfulVotes} | `helpfulvotes` not in refs; lagom uses `knowledgebaseratingtext` ("…found this useful") in a different sentence shape — our phrasing is bespoke → rebadge (or remap to `knowledgebaseratingtext`, see ambiguity #3) | med |
| 95 | text | didn't | CUSTOM | {$hadrianLang.support.didnt} | `didnt` invented fragment ("…, N didn't"); bespoke micro-copy → rebadge | low |
| 102 | text | Related articles | WHMCS | {$LANG.knowledgebaserelated} | real key — `nexus/knowledgebasearticle.tpl:59` `{lang key='knowledgebaserelated'}`; **our key is `relatedarticles` (invented) — use real `knowledgebaserelated`**; strip default | high |
| 107 | text | views | CUSTOM | {$hadrianLang.support.views} | dedupe | med |
| 123 | text | Article not found | CUSTOM | {$hadrianLang.support.articleNotFound} | `articlenotfound` not in refs → invented empty-state title → rebadge | high |
| 124 | text | This article may have been removed or is no longer accessible. | CUSTOM | {$hadrianLang.support.articleNotFoundSub} | `articlenotfoundsub` invented → rebadge | high |
| 125 | text | All categories | CUSTOM | {$hadrianLang.support.allCategories} | `kballcategories` not in refs → invented; cf. real `knowledgebasecategories` ("Categories") if exact wording flexible — see ambiguity #4; rebadge | med |

Notes: `$kbarticle.title/.views/.text/.id/.urlfriendlytitle`, `$useful`, `$notuseful`, `$rel.title/.views/.id` dynamic → SKIP. `value="vote"`/`value="yes"`/`value="no"` are POST form values (machine), not UI → SKIP. SVG/`routePath()`/`href` skipped.

---

### hadrian/templates/hadrian/core/pages/knowledgebasecat/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 29 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | fallback h1 when `$category.name` unset; dedupe; strip default | high |
| 33 | text | Browse articles in this category or search to narrow down. | CUSTOM | {$hadrianLang.support.kbCatSubtitle} | `kbcatsub` not in refs → invented subtitle → rebadge | high |
| 42 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; strip default | med |
| 45 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 49 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; strip default | high |
| 53 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 57 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |
| 70 | placeholder | Search in this category… | CUSTOM | {$hadrianLang.support.searchInCategory} | `searchincategory` not in refs → invented placeholder → rebadge | med |
| 81 | text | articles | CUSTOM | {$hadrianLang.support.articlesCount} | dedupe of knowledgebase.tpl:94 count-suffix; see ambiguity #2 | med |
| 96 | text | views | CUSTOM | {$hadrianLang.support.views} | dedupe | med |
| 111 | text | No matching articles | CUSTOM | {$hadrianLang.support.kbNoResults} | `kbnoresults` not in refs → invented (closest real is `knowledgebasenoarticles` but this is a search-empty variant) → rebadge | med |
| 112 | text | Try a broader search or browse all categories. | CUSTOM | {$hadrianLang.support.kbNoResultsSub} | `kbnoresultssub` invented → rebadge | high |
| 113 | text | All categories | CUSTOM | {$hadrianLang.support.allCategories} | dedupe of knowledgebasearticle.tpl:125 | med |

Notes: `$category.name/.description/.id`, `$kbsearchterm`, `$cat.name/.numarticles/.id`, `$art.title/.views/.id` dynamic → SKIP. `value="displaycat"` hidden form value (machine) → SKIP. SVG/`href` skipped.

---

### hadrian/templates/hadrian/core/pages/announcements/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 30 | text | Announcements | WHMCS | {$LANG.announcementstitle} | real key — `nexus/announcements.tpl:3` `{lang key="announcementstitle"}`; strip default | high |
| 31 | text | Product updates, network notices, and news from Hostnodes. | CUSTOM | {$hadrianLang.support.announcementsSubtitle} | `announcementssub` not in refs → invented subtitle ("Hostnodes" brand inside sentence; sentence still tokenizable) → rebadge | high |
| 39 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; strip default | med |
| 42 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 46 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; strip default | high |
| 50 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 54 | text | Downloads | WHMCS | {$LANG.downloadstitle} | standard WHMCS key (cf. `nexus/homepage.tpl` downloads card); strip default | med |
| 58 | text | Network status | WHMCS | {$LANG.networkstatus} | standard WHMCS key — nav label "Network Status" (cf. `nexus/homepage.tpl:66` `networkstatustitle`); strip default | med |
| 62 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |
| 66 | text | View RSS feed | CUSTOM | {$hadrianLang.support.viewRss} | `viewrss` not in refs → invented → rebadge | med |
| 80 | text | No announcements yet | WHMCS | {$LANG.noannouncements} | real key — `nexus/announcements.tpl:41` `{lang key='noannouncements'}`, `lagom2.3/lagom2-theme/announcements.tpl:73`; **our key is `announcementsnone` (invented) — use real `noannouncements`**; default "No announcements yet" vs WHMCS "There are currently no announcements"; strip default | high |
| 81 | text | Product updates, network notices and news will appear here. Subscribe to the RSS feed… | CUSTOM | {$hadrianLang.support.announcementsNoneSub} | `announcementsnonesub` invented empty-state body → rebadge | high |
| 84 | text | Subscribe to RSS | CUSTOM | {$hadrianLang.support.subscribeRss} | `subscribetorss` not in refs → invented → rebadge | med |

Notes: `$ann.id/.title/.text/.timestamp/.date`, `$carbon->…format()`, `$annCount` dynamic → SKIP. SVG/`href`/`?rss=true` skipped.

---

### hadrian/templates/hadrian/core/pages/viewannouncement/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 48 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; real key; strip default | high |
| 49 | text | Read the full announcement and related news. | CUSTOM | {$hadrianLang.support.viewAnnouncementSubtitle} | `viewannouncementsub` not in refs → invented subtitle → rebadge | high |
| 57 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; strip default | med |
| 60 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 64 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; strip default | high |
| 68 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 72 | text | Network status | WHMCS | {$LANG.networkstatus} | dedupe of announcements.tpl:58; strip default | med |
| 76 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |
| 80 | text | View RSS feed | CUSTOM | {$hadrianLang.support.viewRss} | dedupe of announcements.tpl:66 | med |
| 101 | text | All announcements | CUSTOM | {$hadrianLang.support.allAnnouncements} | `allannouncements` not in refs; nexus uses `clientareabacklink` for the back link (`nexus/viewannouncement.tpl:73`) — remap candidate (see ambiguity #5); rebadge | med |
| 106 | text | Copy link | CUSTOM | {$hadrianLang.support.copyLink} | `copylink` not in refs → invented share-button label → rebadge | high |
| 118 | text | Announcement not found | CUSTOM | {$hadrianLang.support.announcementNotFound} | `announcementnotfound` invented empty-state title → rebadge | high |
| 119 | text | This announcement may have been removed or is no longer accessible. | CUSTOM | {$hadrianLang.support.announcementNotFoundSub} | `announcementnotfoundsub` invented → rebadge | high |
| 120 | text | All announcements | CUSTOM | {$hadrianLang.support.allAnnouncements} | dedupe of line 101 | med |
| 137 | js-string | Copied | CUSTOM | {$hadrianLang.support.copied} | `<script>` toast on copy-link success (`btn.innerHTML = '… Copied'`); inject via a seeded JS lang object; rebadge | high |

Notes: `$annTitle`, `$annText`, `$annDate`, `$author`, `$title`, `$text`, `$timestamp`, `$date`, `$id` dynamic → SKIP. The SVG inside the JS string is markup, not copy → SKIP (only the word "Copied" is user-facing). `·` separator glyph → SKIP.

---

### hadrian/templates/hadrian/core/pages/contact/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 17 | text | Message sent | WHMCS | {$LANG.contactsent} | real key — `nexus/contact.tpl:10` `{lang key='contactsent'}`, `lagom2.3/lagom2-theme/contact.tpl:17`; strip default (wording shifts) | high |
| 18 | text | Thanks — our team will reply by email as soon as possible. | CUSTOM | {$hadrianLang.support.contactSentSub} | `contactsentsub` not in refs → invented success body → rebadge | high |
| 19 | text | Back to home | WHMCS | {$LANG.errorPage.404.home} | real nested key — `lagom2.3/lagom2-theme/contact.tpl:19` `{lang key="errorPage.404.home"}` for this exact back-to-home button; our `backtohome` invented (also dup of `$hadrianLang.error.backHome` in `core/lang/english.php:23`); prefer WHMCS key; strip default — see ambiguity #6 | med |
| 21 | text | Contact us | WHMCS | {$LANG.contactus} | real key — `nexus/contact.tpl:5` `{lang key='contactus'}`; strip default | high |
| 22 | text | Send us a message and our team will follow up. | CUSTOM | {$hadrianLang.support.contactSubtitle} | `contactsub` invented; nexus uses `readyforquestions` ("Ready to get your questions answered?") for this subtitle (`nexus/contact.tpl:6`) — remap candidate; rebadge (or `{$LANG.readyforquestions}`) — see ambiguity #7 | med |
| 37 | text | Your name | WHMCS | {$LANG.supportticketsclientname} | real key — `nexus/contact.tpl:22`, `lagom2.3/lagom2-theme/contact.tpl:31` use `supportticketsclientname` for this field; our `contactname` invented; strip default (wording shifts to WHMCS "Your Name") | high |
| 41 | text | Email address | WHMCS | {$LANG.supportticketsclientemail} | real key — `nexus/contact.tpl:28`, lagom:37; our `contactemail` invented; strip default | high |
| 47 | text | Department | WHMCS | {$LANG.contactdepartment} | standard WHMCS contact key (supportticketsubmit uses `clientareasubject`/`supportdepartment` family); `contactdepartment` plausibly real — verify in lang/english.php; strip default | low |
| 56 | text | Subject | WHMCS | {$LANG.supportticketsticketsubject} | real key — `nexus/contact.tpl:34`, lagom:43 use `supportticketsticketsubject`; our `contactsubject` invented; strip default | high |
| 60 | text | Message | WHMCS | {$LANG.contactmessage} | real key — `nexus/contact.tpl:40`, lagom:49; strip default | high |
| 69 | text | Send message | WHMCS | {$LANG.contactsend} | real key — `nexus/contact.tpl:53`, lagom:59; strip default | high |

Notes: `$name`, `$email`, `$subject`, `$message`, `$dept.id/.name`, `$errormessage`, `$captcha->…`, `$captchaForm` dynamic → SKIP. `value="true"`/`value="send"` hidden form values (machine) → SKIP. captcha `{include}` skipped.

---

### hadrian/templates/hadrian/core/pages/downloads/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 62 | text | Downloads | WHMCS | {$LANG.downloadstitle} | standard WHMCS key; strip default | med |
| 63 | text | Software, guides and templates for your Hostnodes account. Browse by category or search. | CUSTOM | {$hadrianLang.support.downloadsIntro} | `downloadsintro` not in refs → invented subtitle ("Hostnodes" brand inside sentence) → rebadge | high |
| 74 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; strip default | med |
| 77 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 81 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; strip default | high |
| 85 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 89 | text | Downloads | WHMCS | {$LANG.downloadstitle} | dedupe; strip default | med |
| 93 | text | Server status | WHMCS | {$LANG.networkstatus} | **`|default`-trap: key `networkstatus`, default "Server status"** (cf. line 58 same key defaulted "Network status"); strip default unifies to WHMCS wording; med | med |
| 97 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |
| 109 | placeholder | Search downloads... | WHMCS | {$LANG.downloadssearch} | real key — `nexus/downloads.tpl:3` `{lang key='downloadssearch'}`, `lagom2.3/lagom2-theme/downloads.tpl:16`; strip default | high |
| 116 | text | Browse by category | WHMCS | {$LANG.downloadscategories} | real key — `lagom2.3/lagom2-theme/downloads.tpl:27` `{$LANG.downloadscategories}`; default "Browse by category" vs WHMCS "Categories"; strip default (wording shifts) | high |
| 126 | text | files | WHMCS | {$LANG.downloadsfiles} | real key — `nexus/downloadscat.tpl:37` `{lang key='downloadsfiles'}` (section title "Files"); **`|default`-trap: we use it as count-suffix "files"; WHMCS string = "Files"** — strip default but verify it reads OK after "{N} "; med | med |
| 137 | text | Most popular | WHMCS | {$LANG.downloadspopular} | real key — `nexus/downloads.tpl:40`, `lagom2.3/lagom2-theme/downloads.tpl:55`; strip default | high |
| 150 | text | Restricted | WHMCS | {$LANG.restricted} | real key — `nexus/downloads.tpl:52` `{lang key='restricted'}`; strip default | high |
| 150 | text | Login required | CUSTOM | {$hadrianLang.support.loginRequired} | `loginrequired` not in refs (nexus shows `restricted` regardless of login) → invented → rebadge | med |
| 156 | title | Login required | CUSTOM | {$hadrianLang.support.loginRequired} | dedupe of line 150 (lock action `title`) | med |
| 160 | title | Download | WHMCS | {$LANG.downloadbutton} | standard WHMCS key "Download" (the download CTA); not citable in nexus/lagom download tpls but a core key; strip default | med |

Notes: all demo array literals (lines 28–42, under `?preview=1`) are mock content (titles, descriptions, filesizes) → SKIP. `$dlcat.name/.description/.numarticles/.id`, `$download.title/.type/.link/.filesize/.description/.clientsonly`, `$loggedin`, `$ft` dynamic → SKIP. `#fff` SVG stroke, `·` glyph, SVG/`routePath()` skipped.

---

### hadrian/templates/hadrian/core/pages/downloadscat/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 37 | text | Downloads | WHMCS | {$LANG.downloadstitle} | `$pagetitle|default:$LANG.downloadstitle…` fallback chain — the `downloadstitle` lookup; strip its default | med |
| 52 | text | Files in this category. Search, filter by type, or download directly. | CUSTOM | {$hadrianLang.support.downloadsCatIntro} | `downloadscatintro` invented subtitle → rebadge | high |
| 55 | text | files | WHMCS | {$LANG.downloadsfiles} | dedupe of downloads.tpl:126; count-suffix trap | med |
| 67 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; strip default | med |
| 70 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 74 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; strip default | high |
| 78 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 82 | text | Downloads | WHMCS | {$LANG.downloadstitle} | dedupe; strip default | med |
| 86 | text | Server status | WHMCS | {$LANG.networkstatus} | dedupe of downloads.tpl:93; `|default`-trap; strip default | med |
| 90 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |
| 105 | text | Documents and tools in this category, ready to download. | CUSTOM | {$hadrianLang.support.downloadsCatBanner} | `downloadscatbanner` invented banner sub → rebadge | high |
| 118 | text | files | WHMCS | {$LANG.downloadsfiles} | dedupe; count-suffix trap | med |
| 121 | text | Open | WHMCS | {$LANG.viewcart} | **`|default`-trap: key `viewcart` (WHMCS = "View Cart"), default "Open"** — wrong semantics; should be CUSTOM "Open" (see ambiguity #8). Treat as CUSTOM `{$hadrianLang.common.open}` instead; med | med |
| 132 | placeholder | Search in this category... | CUSTOM | {$hadrianLang.support.downloadsSearchInCat} | `downloadssearchincat` invented placeholder (distinct key from kbcat `searchincategory`) → rebadge | med |
| 135 | text | All | WHMCS | {$LANG.all} | real key — `lagom2.3/lagom2-theme/domain-pricing.tpl:19` `{lang key='all'}`; filter tab; strip default | high |
| 138 | text | Other | CUSTOM | {$hadrianLang.support.otherType} | `other` filter tab; not found as a standalone WHMCS key in refs → rebadge | low |
| 141 | aria-label | Sort by | CUSTOM | {$hadrianLang.common.sortBy} | `sortby` not in refs → invented a11y label → rebadge | med |
| 142 | option | Most recent | CUSTOM | {$hadrianLang.common.sortRecent} | `sortrecent` invented option label → rebadge | med |
| 143 | option | Alphabetical | CUSTOM | {$hadrianLang.common.sortAlpha} | `sortalpha` invented option label → rebadge | med |
| 159 | text | New | WHMCS | {$LANG.new} | standard WHMCS key "New" (status/badge); plausibly real — verify; strip default | low |
| 160 | text | Restricted | WHMCS | {$LANG.restricted} | dedupe of downloads.tpl:150; real key; strip default | high |
| 160 | text | Login required | CUSTOM | {$hadrianLang.support.loginRequired} | dedupe of downloads.tpl:150 | med |
| 169 | text | Log in | WHMCS | {$LANG.login} | real key — `nexus/oauth/login.tpl:41` `{lang key='login'}`; default "Log in" vs WHMCS "Login"; strip default | high |
| 171 | text | Download | WHMCS | {$LANG.downloadbutton} | dedupe of downloads.tpl:160; strip default | med |
| 179 | text | Showing | CUSTOM | {$hadrianLang.support.showingCount} | `recordscount` here defaulted "Showing" (used as "Showing {N}"); not the WHMCS records-count phrase → invented fragment → rebadge | low |
| 181 | text | All downloads | CUSTOM | {$hadrianLang.support.allDownloads} | `downloadsall` not in refs → invented → rebadge | med |
| 198 | text | No downloads in this category | CUSTOM | {$hadrianLang.support.downloadsNoneInCat} | `downloadsnone` key here defaulted to a category-specific phrase; the real `downloadsnone` (nexus/downloads.tpl:32) = generic "There are no downloads…"; our category wording is bespoke → rebadge (see ambiguity #9) | med |
| 199 | text | This category doesn't have any downloads yet. | CUSTOM | {$hadrianLang.support.downloadsCatEmpty} | `downloadscatempty` invented → rebadge | high |
| 200 | text | All downloads | CUSTOM | {$hadrianLang.support.allDownloads} | dedupe of line 181 | med |

Notes: PDF/ZIP filter buttons (lines 136–137) are file-format brand tokens → SKIP. demo array literals (lines 22–29) mock content → SKIP. `$catName`, `$pagetitle`, `$sub.name/.numarticles/.id`, `$download.*`, `$downloads|@count`, `$ft`, `$loggedin` dynamic → SKIP. The `{literal}` filter/sort `<script>` (207–251) has no user-facing strings → SKIP. `role="tablist"`/`data-type` skipped.

---

### hadrian/templates/hadrian/core/pages/downloaddenied/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 23 | text | Downloads | WHMCS | {$LANG.downloadstitle} | eyebrow; standard key; strip default | med |
| 24 | text | Download denied | CUSTOM | {$hadrianLang.support.downloadDeniedTitle} | `downloaddeniedtitle` not in refs (nexus/downloaddenied.tpl has no heading, uses `downloadproductrequired` body) → invented → rebadge | high |
| 25 | text | You don't have access to this download. | CUSTOM | {$hadrianLang.support.downloadDeniedSub} | `downloaddeniedsub` invented subtitle → rebadge | high |
| 38 | text | You don't have permission to download this file | CUSTOM | {$hadrianLang.support.downloadDeniedHeading} | `downloaddeniedheading` invented; closest real is `downloadproductrequired` (`nexus/downloaddenied.tpl:25`) but that's product-specific wording → rebadge (see ambiguity #10) | med |
| 39 | text | It may require an active service subscription, or your account may not have the required role. Contact support if you believe this is an error. | CUSTOM | {$hadrianLang.support.downloadDeniedBody} | `downloaddeniedbody` invented fallback body (only when `$errormessage` empty) → rebadge | high |
| 41 | text | View my services | WHMCS | {$LANG.clientareanavservices} | real WHMCS nav key — `lagom2.3/lagom2-theme/core/config/menu/content/client-main-menu.json:261` maps `clientareanavservices`; default "View my services"; strip default | med |
| 42 | text | Contact support | WHMCS | {$LANG.contactus} | `contactus` real key (`nexus/contact.tpl:5`); default "Contact support" vs "Contact us" — same key; strip default | med |
| 52 | text | No download in progress | CUSTOM | {$hadrianLang.support.downloadDeniedNoneTitle} | `downloaddeniednonetitle` preview-only empty-state title → invented → rebadge | high |
| 53 | text | There's no protected download to deny right now. | CUSTOM | {$hadrianLang.support.downloadDeniedNoneSub} | `downloaddeniednonesub` invented → rebadge | high |
| 54 | text | All downloads | CUSTOM | {$hadrianLang.support.allDownloads} | dedupe of downloadscat.tpl:181 | med |

Notes: `$errormessage` dynamic → SKIP. SVG/`href`/`?action=services` skipped.

---

### hadrian/templates/hadrian/core/pages/markdown-guide/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 16 | text | Support | WHMCS | {$LANG.supporttab} | eyebrow; dedupe; strip default | med |
| 17 | text | Markdown guide | WHMCS | {$LANG['markdown.title']} | real nested key — `nexus/includes/head.tpl:17` `{lang key="markdown.title"}`; our key is `markdownguide` (invented) → use `markdown.title`; strip default | high |
| 18 | text | Format your ticket replies and messages with simple markdown syntax. | CUSTOM | {$hadrianLang.support.markdownGuideIntro} | `markdownguideintro` not in refs → invented subtitle → rebadge | high |
| 24 | text | Emphasis | WHMCS | {$LANG['markdown.emphasis']} | real key — `nexus/markdown-guide.tpl:1`; already correct key, strip default | high |
| 25 | text | bold text | WHMCS | {$LANG['markdown.bold']} | real key — `nexus/markdown-guide.tpl:3`; **our tpl hardcodes "bold text" (no LANG lookup)** → wrap in `markdown.bold`; high | high |
| 26 | text | italic text | WHMCS | {$LANG['markdown.italics']} | real key — `nexus/markdown-guide.tpl:4` (`markdown.italics`); **our tpl hardcodes "italic text"** → wrap; high | high |
| 27 | text | strikethrough | CUSTOM | {$hadrianLang.support.markdownStrikethrough} | hardcoded "~~strikethrough~~" body; no `markdown.strikethrough` key in nexus (nexus omits strikethrough) → invented → rebadge | med |
| 31 | text | Headers | WHMCS | {$LANG['markdown.headers']} | real key — `nexus/markdown-guide.tpl:6`; strip default | high |
| 32 | text | Big header | WHMCS | {$LANG['markdown.bigHeader']} | real key — `nexus/markdown-guide.tpl:8`; strip default | high |
| 33 | text | Medium header | WHMCS | {$LANG['markdown.mediumHeader']} | real key — `nexus/markdown-guide.tpl:9`; strip default | high |
| 34 | text | Small header | WHMCS | {$LANG['markdown.smallHeader']} | real key — `nexus/markdown-guide.tpl:10`; strip default | high |
| 38 | text | Lists | WHMCS | {$LANG['markdown.lists']} | real key — `nexus/markdown-guide.tpl:13`; strip default | high |
| 39 | text | List item | WHMCS | {$LANG['markdown.genericListItem']} | real key — `nexus/markdown-guide.tpl:15`; strip default | high |
| 40 | text | List item | WHMCS | {$LANG['markdown.genericListItem']} | dedupe of line 39 | high |
| 42 | text | Numbered item | WHMCS | {$LANG['markdown.numberedListItem']} | real key — `nexus/markdown-guide.tpl:19`; strip default | high |
| 43 | text | Numbered item | WHMCS | {$LANG['markdown.numberedListItem']} | dedupe of line 42 | high |
| 47 | text | Links | WHMCS | {$LANG['markdown.links']} | real key — `nexus/markdown-guide.tpl:23`; strip default | high |
| 48 | text | text to display | WHMCS | {$LANG['markdown.textToDisplay']} | real key — `nexus/markdown-guide.tpl:24`; strip default | high |
| 52 | text | Quotes | WHMCS | {$LANG['markdown.quotes']} | real key — `nexus/markdown-guide.tpl:26`; strip default | high |
| 53 | text | This is a quote | WHMCS | {$LANG['markdown.thisIsAQuote']} | real key — `nexus/markdown-guide.tpl:28`; strip default | high |
| 54 | text | spanning multiple lines | WHMCS | {$LANG['markdown.quoteMultipleLines']} | real key — `nexus/markdown-guide.tpl:29`; strip default | high |
| 58 | text | Code | WHMCS | {$LANG['markdown.displayingCode']} | real key — `nexus/markdown-guide.tpl:45`; strip default | high |
| 62 | text | a code block | WHMCS | {$LANG['markdown.spanningMultipleLines']} | real key — `nexus/markdown-guide.tpl:49`; default "a code block" vs WHMCS phrase; strip default | med |
| 68 | text | Tables | WHMCS | {$LANG['markdown.tables']} | real key — `nexus/markdown-guide.tpl:31`; strip default | high |
| 69 | text | Column 1 | WHMCS | {$LANG['markdown.columnOne']} | real key — `nexus/markdown-guide.tpl:33`; strip default | high |
| 69 | text | Column 2 | WHMCS | {$LANG['markdown.columnTwo']} | real key — `nexus/markdown-guide.tpl:33`; strip default | high |
| 71 | text | John | WHMCS | {$LANG['markdown.john']} | real key — `nexus/markdown-guide.tpl:35`; strip default | high |
| 71 | text | Doe | WHMCS | {$LANG['markdown.doe']} | real key — `nexus/markdown-guide.tpl:35`; strip default | high |
| 72 | text | Mary | WHMCS | {$LANG['markdown.mary']} | real key — `nexus/markdown-guide.tpl:36`; strip default | high |
| 72 | text | Smith | WHMCS | {$LANG['markdown.smith']} | real key — `nexus/markdown-guide.tpl:36`; strip default | high |
| 73 | text | Columns do not need to line up in the source — markdown handles the alignment. | CUSTOM | {$hadrianLang.support.markdownTablesNote} | `markdown.tablesnote` not in nexus; nexus uses `markdown.withoutAligning` ("…without aligning…") for a similar note — remap candidate; rebadge (see ambiguity #11) | med |

Notes: literal Markdown syntax `**`/`*`/`~~`/`#`/`>`/`` ` ``/`[ ]( )`/`|`/`var example = "hello";`/`https://example.com` is **sample code**, not translatable UI → SKIP. `<strong>`/`<em>` tags around the LANG output are markup → SKIP. SVG path data skipped.

---

### hadrian/templates/hadrian/core/pages/serverstatus/default/default.tpl
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 74 | text | Server Status | WHMCS | {$LANG.serverstatustitle} | real key — `nexus/serverstatus.tpl:19` `{lang key='serverstatustitle'}`, `lagom2.3/lagom2-theme/serverstatus.tpl:79`; strip default | high |
| 75 | text | Live availability of the Hostnodes network, plus any active incidents and scheduled maintenance. | WHMCS | {$LANG.serverstatusheadingtext} | real key — `nexus/serverstatus.tpl:21`, lagom:80; default is our wording vs WHMCS default; strip default (wording shifts) — "Hostnodes" brand inside | med |
| 86 | text | All systems operational | CUSTOM | {$hadrianLang.network.allOperational} | `serverstatusalloperational` not in refs → invented banner title → rebadge | high |
| 87 | text | No incidents reported. Every monitored service is responding normally. | CUSTOM | {$hadrianLang.network.noIncidents} | `serverstatusnoincidents` invented banner sub → rebadge | high |
| 95 | text | No servers are being monitored yet | CUSTOM | {$hadrianLang.network.noServersTitle} | `serverstatusnoservers` here defaulted to a long empty-state title; the real WHMCS `serverstatusnoservers` (nexus:67) = "No servers to display." (short table cell) — **divergent default on a real key**; our long copy is bespoke → rebadge (see ambiguity #12) | med |
| 96 | text | When network monitoring is enabled, each server and its services will appear here with live uptime indicators. | CUSTOM | {$hadrianLang.network.noServersSub} | `serverstatusnoserverssub` invented → rebadge | high |
| 99 | text | Report a problem | CUSTOM | {$hadrianLang.network.reportProblem} | `serverstatusreport` not in refs → invented CTA → rebadge | med |
| 114 | text | 1 active incident | CUSTOM | {$hadrianLang.network.oneIncident} | `serverstatusoneincident` invented; cf. WHMCS nested `networkIssues.scheduled count=` plural mechanism (nexus:11) but no "active incident" key → rebadge | med |
| 114 | text | active incidents | CUSTOM | {$hadrianLang.network.incidents} | `serverstatusincidents` invented (rendered "{N} active incidents") → rebadge; use %s/count form | med |
| 115 | text | Our team is engaged and posting updates below. | CUSTOM | {$hadrianLang.network.investigating} | `serverstatusinvestigating` invented → rebadge | high |
| 117 | text | Scheduled maintenance planned | CUSTOM | {$hadrianLang.network.maintenance} | `serverstatusmaintenance` invented → rebadge | high |
| 118 | text | All services are operational. See the planned work below. | CUSTOM | {$hadrianLang.network.maintenanceSub} | `serverstatusmaintenancesub` invented → rebadge | high |
| 120 | text | All systems operational | CUSTOM | {$hadrianLang.network.allOperational} | dedupe of line 86 | high |
| 121 | text | No incidents reported. Every monitored service is responding normally. | CUSTOM | {$hadrianLang.network.noIncidents} | dedupe of line 87 | high |
| 124 | text | Preview | CUSTOM | {$hadrianLang.common.preview} | `preview` demo badge; not a WHMCS key → rebadge | med |
| 130 | text | All | WHMCS | {$LANG.all} | real key — `lagom2.3/lagom2-theme/domain-pricing.tpl:19`; filter tab; strip default | high |
| 131 | text | Active | WHMCS | {$LANG.networkissuesstatusopen} | real key — `lagom2.3/lagom2-theme/serverstatus.tpl:13` `{$LANG.networkissuesstatusopen}`; **`|default`-trap: WHMCS string = "Open", our default "Active"** — strip default flips label to "Open" (see ambiguity #13); high | high |
| 132 | text | Scheduled | WHMCS | {$LANG.networkissuesstatusscheduled} | real key — `lagom2.3/lagom2-theme/serverstatus.tpl:15`; strip default | high |
| 133 | text | Resolved | WHMCS | {$LANG.networkissuesstatusresolved} | real key — `lagom2.3/lagom2-theme/serverstatus.tpl:17`; strip default | high |
| 140 | text | Incidents & maintenance | WHMCS | {$LANG.networkstatustitle} | real key — `nexus/homepage.tpl:66`, `nexus/serverstatus.tpl:4`; **`|default`-trap: WHMCS string = "Network Status", our default "Incidents & maintenance"** — strip default changes the heading (see ambiguity #14); med | med |
| 161 | text | Affecting | WHMCS | {$LANG.networkissuesaffecting} | real key — `nexus/serverstatus.tpl:87` `{lang key='networkissuesaffecting'}`, `lagom2.3/lagom2-theme/serverstatus.tpl:51`; strip default | high |
| 167 | text | This incident may be affecting your services. | WHMCS | {$LANG.networkIssues.affectingYou} | real nested key — `nexus/serverstatus.tpl:109` `{lang key='networkIssues.affectingYou'}`, lagom:55; **our key is flat `networkissuesaffectingyou` (invented) — use nested `networkIssues.affectingYou`**; strip default | high |
| 179 | text | Updated | WHMCS | {$LANG.networkissueslastupdated} | real key — `nexus/serverstatus.tpl:104`, `lagom2.3/lagom2-theme/serverstatus.tpl:61`; default "Updated" vs WHMCS "Last Updated"; strip default | high |
| 185 | text | No incidents to report. | WHMCS | {$LANG.networkstatusnone} | real key — `nexus/serverstatus.tpl:4` `{lang key='networkstatusnone'}`; `foreachelse` fallback (after `$noissuesmsg`); strip default | high |
| 194 | text | Previous | WHMCS | {$LANG.previouspage} | real key — `nexus/serverstatus.tpl:123` `{lang key='previouspage'}`; strip default | high |
| 197 | text | Next | WHMCS | {$LANG.nextpage} | real key — `nexus/serverstatus.tpl:124`; strip default | high |
| 208 | text | Network & servers | CUSTOM | {$hadrianLang.network.serversSectionTitle} | `serverstatusservers` not in refs (nexus section uses `serverstatustitle`) → invented section title → rebadge | med |
| 212 | text | Server | WHMCS | {$LANG.servername} | real key — `nexus/serverstatus.tpl:27` `{lang key='servername'}`, lagom:87; strip default | high |
| 213 | text | Services | CUSTOM | {$hadrianLang.network.servicesCol} | `serverstatusservices` not in refs (nexus has per-port HTTP/FTP/POP3 columns, no "Services" header) → invented column header → rebadge | med |
| 214 | text | Load | WHMCS | {$LANG.serverstatusserverload} | real key — `nexus/serverstatus.tpl:32`, lagom:92; strip default | high |
| 215 | text | Uptime | WHMCS | {$LANG.serverstatusuptime} | real key — `nexus/serverstatus.tpl:33`, lagom:93; strip default | high |
| 248 | title | PHP info | WHMCS | {$LANG.serverstatusphpinfo} | real key — `nexus/serverstatus.tpl:31`, lagom:91; strip default | high |
| 255 | text | No servers to display. | WHMCS | {$LANG.serverstatusnoservers} | real key — `nexus/serverstatus.tpl:67` (foreachelse cell); **this is the correct WHMCS use of the key** (cf. line 95 which mis-defaults the same key); strip default | high |
| 260 | text | Operational | CUSTOM | {$hadrianLang.network.legendUp} | `serverstatusup` not in refs → invented legend label → rebadge | med |
| 261 | text | Disrupted | CUSTOM | {$hadrianLang.network.legendDown} | `serverstatusdown` invented legend label → rebadge | med |
| 262 | text | Checking | CUSTOM | {$hadrianLang.network.legendChecking} | `serverstatuschecking` invented legend label → rebadge | med |
| 274 | text | Support | WHMCS | {$LANG.supporttab} | dedupe; strip default | med |
| 277 | text | My support tickets | WHMCS | {$LANG.mytickets} | dedupe; strip default | med |
| 281 | text | Announcements | WHMCS | {$LANG.announcementstitle} | dedupe; strip default | high |
| 285 | text | Knowledgebase | WHMCS | {$LANG.knowledgebasetitle} | dedupe; strip default | high |
| 289 | text | Downloads | WHMCS | {$LANG.downloadstitle} | dedupe; strip default | med |
| 293 | text | Server status | WHMCS | {$LANG.networkstatus} | dedupe of downloads.tpl:93; `|default`-trap; strip default | med |
| 297 | text | Open ticket | WHMCS | {$LANG.opennewticket} | dedupe; strip default | med |

Notes: HTTP/FTP/POP3 column/port labels (lines 226–232) are protocol brand tokens → SKIP. demo array literals (lines 38–47) mock content (server names, issue titles, dates, descriptions) → SKIP. `$issue.*`, `$server.*`, `$ssOpen/$ssScheduled/$ssResolved/$ssView/$ssState/$num`, `$noissuesmsg`, `$prevpage/$nextpage` dynamic → SKIP. `--` muted placeholders, `role="table/row/columnheader/cell"` ARIA roles, `id`/`data-num`/`style`/SVG/`href` skipped. The `{literal}` port/stats `<script>` (304–386) has no user-facing strings (selectors/fetch/regex only) → SKIP.

---

## New ambiguities (flag for the user)
1. **Sub-nav block is duplicated across all 7 list pages.** The same Support sidebar (`supporttab`, `mytickets`, `announcementstitle`, `knowledgebasetitle`, `downloadstitle`, `networkstatus`, `opennewticket`, plus `viewrss`) repeats in knowledgebase/knowledgebasearticle/knowledgebasecat/announcements/viewannouncement/downloads/downloadscat/serverstatus. All WHMCS keys deduped to one row-set conceptually; rebadge `viewrss` once. `networkstatus` carries **two different defaults** ("Network status" vs "Server status") on the same key across files — stripping unifies it (decide which WHMCS string is correct: WHMCS ships "Network Status").
2. **`kbarticles` / `downloadsfiles` count-suffix trap.** Both keys exist as real WHMCS strings but mean the *section heading* ("Articles" / "Files"), whereas our tpls use them as the trailing count word ("{N} articles" / "{N} files"). WHMCS's real *count* mechanism is the nested pluralized key (`knowledgebase.numArticles{s} num=`, `downloads.numDownload{s} num=`, see `nexus/knowledgebase.tpl:20`, `nexus/downloads.tpl:22`). Recommend either adopting the nested `num=` keys (correct WHMCS way) or keeping CUSTOM count words. Left CUSTOM for `kbarticles`→`articlesCount`; left WHMCS (with caveat) for `downloadsfiles`.
3. **Helpful-vote phrasing.** `helpfulvotes` ("people found this helpful") + `didnt` are bespoke. Lagom expresses this via `knowledgebaseratingtext`/`knowledgebasevotes` (`lagom2.3/lagom2-theme/knowledgebasearticle.tpl:27`) in a different sentence ("N found this useful (M votes)"). If you adopt the Lagom phrasing you can drop both custom keys for `knowledgebaseratingtext`+`knowledgebasevotes`.
4. **"All categories" vs WHMCS "Categories".** `kballcategories` (article + cat empty states) is invented; the nearest real key is `knowledgebasecategories` ("Categories", `lagom2.3/lagom2-theme/knowledgebase.tpl:17`). Kept CUSTOM because the wording ("All categories") differs; remap if "Categories" acceptable.
5. **Announcement back-link.** `allannouncements` ("All announcements", viewannouncement) is invented; nexus uses the generic `clientareabacklink` ("« Go back", `nexus/viewannouncement.tpl:73`). Kept CUSTOM to preserve the explicit wording; remap to `{$LANG.clientareabacklink}` if a generic back link is fine.
6. **`backtohome` is triply-specified.** contact "Back to home" is (a) our invented `LANG.backtohome`, (b) already a Hadrian custom key `error.backHome`="Back to home" in `hadrian/templates/hadrian/core/lang/english.php:23`, and (c) a real WHMCS key `errorPage.404.home` (used for this exact button in `lagom2.3/lagom2-theme/contact.tpl:19`). Recommend WHMCS `errorPage.404.home`; if staying custom, reuse the existing `error.backHome`, don't mint a new key.
7. **Contact subtitle.** `contactsub` ("Send us a message…") is invented; nexus uses `readyforquestions` ("Ready to get your questions answered?", `nexus/contact.tpl:6`). Remap candidate if wording flexible.
8. **`viewcart` mis-keyed as "Open".** downloadscat.tpl:121 sub-category "Open" button is wrapped in `{$LANG.viewcart}` — but `viewcart` is the WHMCS "View Cart" string. Stripping the default would print "View Cart" on a KB sub-category row (wrong). Reported as **CUSTOM** `common.open` instead; flag as a likely mis-key.
9. **`downloadsnone` divergent defaults.** Used in downloads.tpl:183 ("No downloads available"), downloadscat.tpl:198 ("No downloads in this category"). The real WHMCS `downloadsnone` (nexus/downloads.tpl:32) is the generic phrase. downloads.tpl:183's generic use → could be WHMCS; downloadscat.tpl:198's category-specific wording → CUSTOM. Both currently same key with different defaults.
10. **Download-denied copy is fully bespoke.** nexus/lagom render denial via `downloadproductrequired` (+ `ordernowbutton`), which is product-purchase oriented. Our page (title/heading/body/none-state) is a richer custom notice with no WHMCS equivalent → all CUSTOM. If you want WHMCS parity, the body could map to `downloadproductrequired`.
11. **`markdown.tablesnote` invented.** All other `markdown.*` keys are real (proven in `nexus/markdown-guide.tpl`); only our tables note has no match. nexus's adjacent real key is `markdown.withoutAligning` ("…without aligning the columns"). Remap candidate. Also note lines **25/26 hardcode "bold text"/"italic text" with NO LANG lookup** — they should be wrapped in the real `markdown.bold`/`markdown.italics`. And "strikethrough" (line 27) has no WHMCS key (nexus omits it) → CUSTOM.
12. **`serverstatusnoservers` used twice with different copy.** serverstatus.tpl:255 (foreachelse table cell, "No servers to display.") matches WHMCS exactly → WHMCS. serverstatus.tpl:95 (big empty-state title, "No servers are being monitored yet") overloads the same key with long bespoke copy → reported CUSTOM (`network.noServersTitle`). Decide whether the empty-state should reuse the short WHMCS string or keep custom.
13. **`networkissuesstatusopen` default "Active" ≠ WHMCS "Open".** serverstatus.tpl:131 filter tab. Real key, but stripping the `|default` flips the visible tab from "Active" to "Open". Same family is fine for scheduled/resolved (defaults already match WHMCS). Decide if the "Active" label should be preserved (→ CUSTOM) or unified to "Open".
14. **`networkstatustitle` default "Incidents & maintenance" ≠ WHMCS "Network Status".** serverstatus.tpl:140 incidents section heading. Real key but semantically our default is a section subtitle. Stripping changes the heading to "Network Status". Decide: keep CUSTOM heading or accept WHMCS wording.
15. **`mytickets` / `opennewticket` / `supporttab` / `downloadstitle` / `networkstatus` / `new` / `downloadbutton` / `contactdepartment` are standard WHMCS keys not citable in a reference *template*** (they live in core lang or core-resolved menus). Kept **WHMCS at med/low confidence** per the "prefer real keys" policy with "verify in lang/english.php; strip default" — same posture as B08's core-resolved nav keys.

---

## Proposed custom keys
```
hadrianLang.common.open = "Open"
hadrianLang.common.sortBy = "Sort by"
hadrianLang.common.sortRecent = "Most recent"
hadrianLang.common.sortAlpha = "Alphabetical"
hadrianLang.common.preview = "Preview"
hadrianLang.support.kbSubtitle = "Setup guides, troubleshooting and answers to frequently asked questions."
hadrianLang.support.views = "views"
hadrianLang.support.kbHeroSub = "Search the knowledgebase or browse by category below."
hadrianLang.support.articlesCount = "articles"
hadrianLang.support.kbEmptySub = "When our team publishes setup guides and troubleshooting articles, they will appear here."
hadrianLang.support.kbArticleSubtitle = "Read the full article and rate it."
hadrianLang.support.helpfulVotes = "people found this helpful"
hadrianLang.support.didnt = "didn't"
hadrianLang.support.articleNotFound = "Article not found"
hadrianLang.support.articleNotFoundSub = "This article may have been removed or is no longer accessible."
hadrianLang.support.allCategories = "All categories"
hadrianLang.support.kbCatSubtitle = "Browse articles in this category or search to narrow down."
hadrianLang.support.searchInCategory = "Search in this category…"
hadrianLang.support.kbNoResults = "No matching articles"
hadrianLang.support.kbNoResultsSub = "Try a broader search or browse all categories."
hadrianLang.support.announcementsSubtitle = "Product updates, network notices, and news from Hostnodes."
hadrianLang.support.viewRss = "View RSS feed"
hadrianLang.support.announcementsNoneSub = "Product updates, network notices and news will appear here. Subscribe to the RSS feed to be notified when new posts arrive."
hadrianLang.support.subscribeRss = "Subscribe to RSS"
hadrianLang.support.viewAnnouncementSubtitle = "Read the full announcement and related news."
hadrianLang.support.allAnnouncements = "All announcements"
hadrianLang.support.copyLink = "Copy link"
hadrianLang.support.copied = "Copied"
hadrianLang.support.announcementNotFound = "Announcement not found"
hadrianLang.support.announcementNotFoundSub = "This announcement may have been removed or is no longer accessible."
hadrianLang.support.contactSentSub = "Thanks — our team will reply by email as soon as possible."
hadrianLang.support.contactSubtitle = "Send us a message and our team will follow up."
hadrianLang.support.downloadsIntro = "Software, guides and templates for your Hostnodes account. Browse by category or search."
hadrianLang.support.loginRequired = "Login required"
hadrianLang.support.downloadsCatIntro = "Files in this category. Search, filter by type, or download directly."
hadrianLang.support.downloadsCatBanner = "Documents and tools in this category, ready to download."
hadrianLang.support.downloadsSearchInCat = "Search in this category..."
hadrianLang.support.otherType = "Other"
hadrianLang.support.showingCount = "Showing"
hadrianLang.support.allDownloads = "All downloads"
hadrianLang.support.downloadsNoneInCat = "No downloads in this category"
hadrianLang.support.downloadsCatEmpty = "This category doesn't have any downloads yet."
hadrianLang.support.downloadDeniedTitle = "Download denied"
hadrianLang.support.downloadDeniedSub = "You don't have access to this download."
hadrianLang.support.downloadDeniedHeading = "You don't have permission to download this file"
hadrianLang.support.downloadDeniedBody = "It may require an active service subscription, or your account may not have the required role. Contact support if you believe this is an error."
hadrianLang.support.downloadDeniedNoneTitle = "No download in progress"
hadrianLang.support.downloadDeniedNoneSub = "There's no protected download to deny right now."
hadrianLang.support.markdownGuideIntro = "Format your ticket replies and messages with simple markdown syntax."
hadrianLang.support.markdownStrikethrough = "strikethrough"
hadrianLang.support.markdownTablesNote = "Columns do not need to line up in the source — markdown handles the alignment."
hadrianLang.network.allOperational = "All systems operational"
hadrianLang.network.noIncidents = "No incidents reported. Every monitored service is responding normally."
hadrianLang.network.noServersTitle = "No servers are being monitored yet"
hadrianLang.network.noServersSub = "When network monitoring is enabled, each server and its services will appear here with live uptime indicators."
hadrianLang.network.reportProblem = "Report a problem"
hadrianLang.network.oneIncident = "1 active incident"
hadrianLang.network.incidents = "%s active incidents"
hadrianLang.network.investigating = "Our team is engaged and posting updates below."
hadrianLang.network.maintenance = "Scheduled maintenance planned"
hadrianLang.network.maintenanceSub = "All services are operational. See the planned work below."
hadrianLang.network.serversSectionTitle = "Network & servers"
hadrianLang.network.servicesCol = "Services"
hadrianLang.network.legendUp = "Operational"
hadrianLang.network.legendDown = "Disrupted"
hadrianLang.network.legendChecking = "Checking"
```
