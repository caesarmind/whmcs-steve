{* =========================================================================
   supportticketsubmit-customfields.tpl — department-specific custom fields.
   Re-rendered via AJAX when department changes.
   ========================================================================= *}
{if $customfields}
    {foreach $customfields as $customfield}
        <div class="form-group">
            <label for="customfield{$customfield.id}" class="form-label">
                {$customfield.name}
                {if $customfield.required} <span class="form-label-required">*</span>{/if}
            </label>
            {$customfield.input}
            {if $customfield.description}<div class="form-hint">{$customfield.description}</div>{/if}
        </div>
    {/foreach}
{/if}
