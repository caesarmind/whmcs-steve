{* =========================================================================
   homepage.tpl — public landing page: product groups + domain CTA + quick
   links into self-service.
   ========================================================================= *}
<div class="homepage-layout">
    {if !empty($productGroups) || $registerdomainenabled || $transferdomainenabled}
        <section class="homepage-section">
            <h2 class="homepage-section-title">{lang key='clientHomePanels.productsAndServices'}</h2>

            <div class="homepage-product-grid">
                {foreach $productGroups as $productGroup}
                    <div class="card homepage-product-card">
                        <div class="card-body">
                            <h3 class="card-title">{$productGroup->name}</h3>
                            <p>{$productGroup->tagline}</p>
                            <a href="{$productGroup->getRoutePath()}" class="btn btn-primary btn-full">{lang key='browseProducts'}</a>
                        </div>
                    </div>
                {/foreach}

                {if $registerdomainenabled}
                    <div class="card homepage-product-card">
                        <div class="card-body">
                            <h3 class="card-title">{lang key='orderregisterdomain'}</h3>
                            <p>{lang key='secureYourDomain'}</p>
                            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="btn btn-primary btn-full">{lang key='navdomainsearch'}</a>
                        </div>
                    </div>
                {/if}

                {if $transferdomainenabled}
                    <div class="card homepage-product-card">
                        <div class="card-body">
                            <h3 class="card-title">{lang key='transferYourDomain'}</h3>
                            <p>{lang key='transferExtend'}</p>
                            <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="btn btn-primary btn-full">{lang key='transferYourDomain'}</a>
                        </div>
                    </div>
                {/if}
            </div>
        </section>
    {/if}

    <section class="homepage-section">
        <h2 class="homepage-section-title">{lang key='howCanWeHelp'}</h2>
        <div class="homepage-action-grid">
            <a href="{routePath('announcement-index')}" class="homepage-action-card">
                <div class="homepage-action-icon teal"><i class="far fa-bullhorn"></i></div>
                <div class="homepage-action-label">{lang key='announcementstitle'}</div>
            </a>
            <a href="{$WEB_ROOT}/serverstatus.php" class="homepage-action-card">
                <div class="homepage-action-icon red"><i class="far fa-server"></i></div>
                <div class="homepage-action-label">{lang key='networkstatustitle'}</div>
            </a>
            <a href="{routePath('knowledgebase-index')}" class="homepage-action-card">
                <div class="homepage-action-icon orange"><i class="far fa-book"></i></div>
                <div class="homepage-action-label">{lang key='knowledgebasetitle'}</div>
            </a>
            <a href="{routePath('download-index')}" class="homepage-action-card">
                <div class="homepage-action-icon gray"><i class="far fa-download"></i></div>
                <div class="homepage-action-label">{lang key='downloadstitle'}</div>
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="homepage-action-card">
                <div class="homepage-action-icon green"><i class="far fa-life-ring"></i></div>
                <div class="homepage-action-label">{lang key='homepage.submitTicket'}</div>
            </a>
        </div>
    </section>

    <section class="homepage-section">
        <h2 class="homepage-section-title">{lang key='homepage.yourAccount'}</h2>
        <div class="homepage-action-grid">
            <a href="{$WEB_ROOT}/clientarea.php" class="homepage-action-card">
                <div class="homepage-action-icon blue"><i class="far fa-home"></i></div>
                <div class="homepage-action-label">{lang key='homepage.yourAccount'}</div>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="homepage-action-card">
                <div class="homepage-action-icon purple"><i class="far fa-cubes"></i></div>
                <div class="homepage-action-label">{lang key='homepage.manageServices'}</div>
            </a>
            {if $registerdomainenabled || $transferdomainenabled || $numberOfDomains}
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="homepage-action-card">
                    <div class="homepage-action-icon green"><i class="far fa-globe"></i></div>
                    <div class="homepage-action-label">{lang key='homepage.manageDomains'}</div>
                </a>
            {/if}
            <a href="{$WEB_ROOT}/supporttickets.php" class="homepage-action-card">
                <div class="homepage-action-icon red"><i class="far fa-comments"></i></div>
                <div class="homepage-action-label">{lang key='homepage.supportRequests'}</div>
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="homepage-action-card">
                <div class="homepage-action-icon orange"><i class="far fa-credit-card"></i></div>
                <div class="homepage-action-label">{lang key='homepage.makeAPayment'}</div>
            </a>
        </div>
    </section>
</div>
