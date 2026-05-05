{* store/config-fields/boolean.tpl — boolean config field (yes/no toggle). *}
<label class="checkbox-label">
    <input type="checkbox" name="{$field.name}" value="1" class="form-checkbox"{if $field.value} checked{/if}>
    <span>{$field.label}</span>
</label>
{if $field.description}<div class="form-hint">{$field.description}</div>{/if}
