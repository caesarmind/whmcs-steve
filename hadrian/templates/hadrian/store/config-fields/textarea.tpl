{* MarketConnect config field: multi-line text. Same contract as input.tpl. *}
<textarea class="form-textarea config-field-input"
          id="config_{$field.name}"
          name="config[{$field.name}]"
          rows="3"
          placeholder="{$field.placeholder|default:''}"{if $field.required} required{/if}>{if isset($configFieldValues[$field.name])}{$configFieldValues[$field.name]}{/if}</textarea>
