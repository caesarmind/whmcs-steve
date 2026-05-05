{* store/config-fields/textarea.tpl — multi-line text config field. *}
<div class="form-group">
    <label for="field-{$field.id}" class="form-label">{$field.label}</label>
    <textarea name="{$field.name}" id="field-{$field.id}" class="form-input" rows="4"{if $field.required} required{/if}>{$field.value}</textarea>
    {if $field.description}<div class="form-hint">{$field.description}</div>{/if}
</div>
