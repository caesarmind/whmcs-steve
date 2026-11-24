{* MarketConnect config field: single or multiple choice, from $field.choices
   (value => label) or $field.options ([{value, label}]). Same contract as
   input.tpl; a multi-select posts config[<name>][]. *}
{assign var=hnCfgValue value=null}
{if isset($configFieldValues[$field.name])}{assign var=hnCfgValue value=$configFieldValues[$field.name]}{/if}
<select class="form-select config-field-input"
        id="config_{$field.name}"
        name="config[{$field.name}]{if $field.allow_multiple}[]{/if}"
        {if $field.allow_multiple}multiple{/if}{if $field.required} required{/if}>
    {if !$field.required && !$field.allow_multiple}<option value="">{$LANG.pleasechooseone}</option>{/if}
    {if $field.choices}
        {foreach $field.choices as $value => $label}
            {assign var=isSelected value=($field.allow_multiple && is_array($hnCfgValue) && in_array($value, $hnCfgValue)) || (!$field.allow_multiple && $hnCfgValue == $value)}
            <option value="{$value}"{if $isSelected} selected{/if}>{$label}</option>
        {/foreach}
    {elseif $field.options}
        {foreach $field.options as $option}
            {assign var=isSelected value=($field.allow_multiple && is_array($hnCfgValue) && in_array($option.value, $hnCfgValue)) || (!$field.allow_multiple && $hnCfgValue == $option.value)}
            <option value="{$option.value}"{if $isSelected} selected{/if}>{$option.label}</option>
        {/foreach}
    {/if}
</select>
