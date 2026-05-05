{* store/config-fields/input.tpl — plain text config field. *}
<div class="form-group">
    <label for="field-{$field.id}" class="form-label">{$field.label}</label>
    <input type="text" name="{$field.name}" id="field-{$field.id}" value="{$field.value}" class="form-input"{if $field.required} required{/if}>
    {if $field.description}<div class="form-hint">{$field.description}</div>{/if}
</div>
