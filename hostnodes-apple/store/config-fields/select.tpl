{* store/config-fields/select.tpl — dropdown config field. *}
<div class="form-group">
    <label for="field-{$field.id}" class="form-label">{$field.label}</label>
    <select name="{$field.name}" id="field-{$field.id}" class="form-input"{if $field.required} required{/if}>
        {foreach $field.options as $value => $label}
            <option value="{$value}"{if $value eq $field.value} selected{/if}>{$label}</option>
        {/foreach}
    </select>
    {if $field.description}<div class="form-hint">{$field.description}</div>{/if}
</div>
