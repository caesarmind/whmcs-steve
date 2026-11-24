{* WHMCS 9 dynamic MarketConnect service: the actions (commands) a service
   exposes on its product details page, each a form of typed fields
   ($commands[]: key, label, description, fields[]) rendered through
   store/config-fields/*. Forms post to the
   marketconnect-service-command-execute route and get JSON back
   {success, message, errors{field: [..]}}. Stock submits them with a handler
   in twenty-one's scripts.js (.js-service-command-form), which Hadrian
   doesn't load, so the same handler is below. Ported from stock twenty-one. *}
<div id="js-global-command-result" style="margin-bottom:16px;"></div>

<div class="hn-svc-commands" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px;">
    {foreach from=$commands item=command name=cmds}
        <form method="post"
              action="{routePath('marketconnect-service-command-execute', $service_group_slug, $command->key)}"
              class="js-service-command-form card" style="margin:0;">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <div class="card-header"><h2 class="card-title">{$command->label}</h2></div>
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
                        </div>
                    {/foreach}
                {/if}
                <button type="submit" class="btn-primary">{$command->label}</button>
                <div class="js-command-result" style="margin-top:8px;"></div>
            </div>
        </form>
    {/foreach}
</div>

<script>{literal}
(function () {
    if (window.hnServiceCommandsBound) return;
    window.hnServiceCommandsBound = true;
    function note(container, ok, text) {
        var el = document.createElement('div');
        el.className = 'callout ' + (ok ? 'success' : 'error');
        el.setAttribute('role', ok ? 'status' : 'alert');
        el.innerText = text;
        container.innerHTML = '';
        container.appendChild(el);
        setTimeout(function () { container.innerHTML = ''; }, 5000);
    }
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form.classList || !form.classList.contains('js-service-command-form')) return;
        e.preventDefault();
        form.querySelectorAll('.js-field-error').forEach(function (el) { el.remove(); });
        var global = document.getElementById('js-global-command-result');
        fetch(form.action, { method: 'POST', body: new FormData(form), credentials: 'same-origin' })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success && data.errors) {
                    Object.keys(data.errors).forEach(function (name) {
                        var input = form.querySelector('[name="config[' + name + ']"]');
                        var group = input ? input.closest('.form-group') : null;
                        if (!group) return;
                        var err = document.createElement('div');
                        err.className = 'form-hint js-field-error';
                        err.style.color = 'var(--color-red-text)';
                        err.innerHTML = [].concat(data.errors[name]).join('<br>');
                        group.appendChild(err);
                    });
                }
                note(global, !!data.success, data.message || (data.success ? 'Success' : 'Error'));
            })
            .catch(function () { note(global, false, 'The request failed.'); });
    });
})();
{/literal}</script>
