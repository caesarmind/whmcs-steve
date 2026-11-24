{* WHMCS 9 dynamic MarketConnect service: one command's fields as a plain
   (non-JS) form, posted to $actionUrl with WHMCS's $csrfToken input;
   validation errors come back in $fieldErrors[name]. Ported from stock
   twenty-one, restyled with Hadrian's form classes. *}
<form method="post" action="{$actionUrl}">
    {$csrfToken}
    <div class="card-body">
        {if $command->description}
            <p style="margin:0 0 14px;color:var(--color-text-secondary);">{$command->description}</p>
        {/if}

        {if $command->fields && count($command->fields) > 0}
            {foreach from=$command->fields item=field}
                <div class="form-group">
                    <label class="form-label" for="config_{$field.name}">
                        {$field.label}{if $field.required} <span style="color:var(--color-red-text)">*</span>{/if}
                    </label>

                    {if $field.type == 'select'}
                        {include file="$template/store/config-fields/select.tpl" field=$field}
                    {elseif $field.type == 'textarea'}
                        {include file="$template/store/config-fields/textarea.tpl" field=$field}
                    {elseif $field.type == 'boolean'}
                        {include file="$template/store/config-fields/boolean.tpl" field=$field}
                    {else}
                        {include file="$template/store/config-fields/input.tpl" field=$field}
                    {/if}

                    {if isset($fieldErrors[$field.name])}
                        <div class="form-hint" style="color:var(--color-red-text)">
                            {foreach from=$fieldErrors[$field.name] item=err}{$err}<br>{/foreach}
                        </div>
                    {/if}
                </div>
            {/foreach}
        {/if}
    </div>
</form>
