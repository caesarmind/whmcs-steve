{* Floating save bar -- ONE copy, included by every page that has a page-level
   save. It started life hand-written in styles/_colors.tpl; rolling that markup
   out to eleven pages by copy-paste would have meant eleven places to fix the
   next time a button moved.

   Place it INSIDE the <form> it saves, immediately before </form>: a bare
   <button type="submit"> then belongs to that form with no `form=` attribute
   and no id to keep in sync. Where a page genuinely cannot nest it -- the bar
   has to live outside, or the page has two forms -- pass `form` and the buttons
   associate explicitly instead.

   .mt-savebar is position:fixed and .mt-body reserves 72px of bottom padding,
   which is what keeps the last row clear of the bar rather than behind it
   (measured: the bar is 63.8px, the panel's bottom edge clears it by 16px).
   Nothing extra is needed per page.

   Safe to include from a template that renders more than once per page: the six
   styles/_*.tpl panels all render together with [hidden] on the five inactive
   ones, and a fixed element inside a display:none ancestor has a zero rect and
   is never painted. Measured, not assumed -- only the visible panel's bar
   appears.

   Params (all optional except what you want drawn):
     label    primary button text. Defaults to "Save changes". Pass the page's
              own wording -- "Save typography" says what it writes, and that is
              information, not decoration.
     cancel   href for a Cancel link. Omit for no Cancel. Emitted RAW, so build
              it as valid HTML (escape the values you interpolate into it).
     quiet    text for the left-aligned quiet action (e.g. "Restore defaults").
              Omit for none. margin-right:auto on it is what puts distance
              between a destructive action and the confirming one.
     quietId  id for that quiet button, for JS to hook.
     form     id of the <form> to submit, when the bar cannot sit inside it.
     name     name/value pair for the submit button, for pages whose handler
     value    switches on which button was pressed.
*}
<div class="mt-savebar">
    {if $quiet|default:''}
        <button type="button" class="mt-savebar-quiet"{if $quietId|default:''} id="{$quietId|escape}"{/if}{if $form|default:''} form="{$form|escape}"{/if}>{$quiet|escape}</button>
    {/if}
    {if $cancel|default:''}
        <a class="mt-btn mt-btn-secondary" href="{$cancel}">Cancel</a>
    {/if}
    <button type="submit" class="mt-btn mt-btn-primary"{if $form|default:''} form="{$form|escape}"{/if}{if $name|default:''} name="{$name|escape}" value="{$value|default:''|escape}"{/if}>{$label|default:'Save changes'|escape}</button>
</div>
