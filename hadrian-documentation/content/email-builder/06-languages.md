---
title: Languages
group: Reference
icon: book
lead: Translate a design in the builder, one language at a time. Each client gets the email in the language on their account, and right-to-left languages are mirrored for you.
---

## How a client's language is chosen

WHMCS records a language on each client account. The module uses it twice:

- the **layout** is built in that language for each email as it is sent
- a **published design** is stored once per language, and WHMCS picks the matching one

A client with no language set gets your WHMCS default language.

## Translating

The builder's language menu lists your default language first, then the others your site offers. The list follows Hadrian's language settings.

:::steps
1. Design the email in the default language.
2. Choose another language from the menu. The preview switches to it.
3. Select a block. Every field that holds words now shows the language name beside its label, with the default text as a greyed hint.
4. Type the translation. Leave a field empty to keep the default text for that language.
5. Publish.
:::

Text, headings, button labels, Details labels, link labels, the subject and the preview text can all be translated. Options such as alignment, sizes and link addresses are shared by every language.

### What publishing does with translations

WHMCS keeps one template per language for each email. Publishing writes your design to the default one, and to one more for each language you have translated something into. Where WHMCS had no template for that language yet, the module creates it.

A language you have not translated anything into is not given a template of its own. WHMCS sends those clients the default one, as it always has.

Removing the design puts back any template that existed before, and deletes the ones the module created.

### The subject

Leave the subject empty in a language to keep whatever subject WHMCS has for that language.

## Right-to-left languages

For Arabic, Farsi, Hebrew and Urdu the email is mirrored: text aligns to the right, the header swaps sides, and list bullets and callout edges move across. It is the same design; you do not build a second one.

"Start" and "End" in a block's alignment option mean the leading and trailing side, so a Start-aligned heading is on the left in English and on the right in Arabic.

## The layout

The header tagline, the header and footer link labels, the footer text and the unsubscribe label are translated in the layout builder, the same way.
