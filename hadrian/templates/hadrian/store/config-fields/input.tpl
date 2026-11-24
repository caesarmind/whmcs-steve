{* MarketConnect config field: text-like input (text, email, url, domain...).
   WHMCS's dynamic MarketConnect services describe their order and command
   fields as $field {name, type, label, placeholder, required, ...}; the
   store order page and the dynamic-service command forms include one of
   these four templates per field. name="config[<name>]", the id and the
   .config-field-input hook match stock. Values come back in
   $configFieldValues after a failed submit. *}
<input type="{$field.type}"
       class="form-input config-field-input"
       id="config_{$field.name}"
       name="config[{$field.name}]"
       value="{if isset($configFieldValues[$field.name])}{$configFieldValues[$field.name]}{/if}"
       placeholder="{if $field.type == 'domain'}example.com{else}{$field.placeholder|default:''}{/if}"{if $field.required} required{/if}>
