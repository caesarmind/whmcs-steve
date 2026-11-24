{* MarketConnect config field: on/off checkbox. Same contract as input.tpl;
   the description doubles as the label text, as in stock. *}
<label class="form-checkbox-row" for="config_{$field.name}">
    <input type="checkbox"
           class="form-checkbox config-field-input"
           id="config_{$field.name}"
           name="config[{$field.name}]"
           value="1"{if isset($configFieldValues[$field.name]) && $configFieldValues[$field.name]} checked{/if}>
    <span>{$field.description|default:'Enable this option.'}</span>
</label>
