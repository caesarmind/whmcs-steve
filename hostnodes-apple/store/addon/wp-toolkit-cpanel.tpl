{* store/addon/wp-toolkit-cpanel.tpl — WordPress Toolkit (cPanel) addon page. *}
<div class="addon-promo card">
    <div class="card-body">
        <div class="addon-promo-icon"><i class="fab fa-wordpress"></i></div>
        <h3 class="addon-promo-title">{lang key='store.wpToolkit.cpanel.title'}</h3>
        <p class="addon-promo-description">{lang key='store.wpToolkit.cpanel.description'}</p>
        {if $pricing}<div class="addon-promo-price">{$pricing}</div>{/if}
        <a href="{$addUrl}" class="btn btn-primary">{lang key='store.wpToolkit.add'}</a>
    </div>
</div>
