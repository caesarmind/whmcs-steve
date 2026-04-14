# WHMCS Smarty Functions

### `{assetPath}` - Theme Asset URL

Returns the URL path to a theme asset file.

```smarty
{* Basic usage *}
{assetPath file='all.min.css'}
{assetPath file='scripts.min.js'}
{assetPath file='theme.min.css'}

{* With version hash for cache busting *}
{assetPath file='all.min.css'}?v={$versionHash}

{* With namespace for subdirectory assets *}
{assetPath ns='store/dynamic/assets' file='dynamic-store.css'}
{assetPath ns='store/dynamic/assets' file='dynamic-store.js'}
```

### `{assetExists}` - Conditional Asset Loading

Block tag that only renders content if the asset file exists. Sets `{$__assetPath__}` inside the block:

```smarty
{assetExists file="custom.css"}
    <link href="{$__assetPath__}" rel="stylesheet">
{/assetExists}
```

### `{routePath}` - Route URL Generation

Generates URLs for named WHMCS routes:

```smarty
{* Simple route *}
{routePath('knowledgebase-search')}
{routePath('announcement-index')}
{routePath('knowledgebase-index')}
{routePath('download-index')}
{routePath('domain-pricing')}
{routePath('user-accounts')}
{routePath('login-validate')}
{routePath('password-reset-begin')}
{routePath('cart-order-login')}
{routePath('cart-order-addtocart')}
{routePath('cart-order-validate')}
{routePath('cart-order')}
{routePath('account-contacts')}
{routePath('dismiss-user-validation')}
{routePath('dismiss-email-verification')}
{routePath('user-email-verification-resend')}

{* Route with parameters *}
{routePath('announcement-view', $announcement.id, $announcement.urlfriendlytitle)}
{routePath('clientarea-sitejet-get-preview', $sitejetServices[0]->id)}
```

### `{lang}` - Language String

Outputs a translated language string:

```smarty
{* Basic usage *}
{lang key='loginbutton'}
{lang key='notifications'}
{lang key='clientareaemail'}

{* With modifier *}
{lang|addslashes key="markdown.title"}

{* With parameters *}
{lang key='copyrightFooterNotice' year=$date_year company=$companyname}
{lang key='passwordtips' maximum_length=$maximumPasswordLength}
{lang key='oauth.currentlyLoggedInAs' firstName=$userInfo.firstName lastName=$userInfo.lastName}

{* Nested key patterns *}
{lang key='clientHomePanels.productsAndServices'}
{lang key='userLogin.signInToContinue'}
{lang key='homepage.submitTicket'}
{lang key='store.choosePaymentTerm'}
{lang key='errorPage.404.title'}
{lang key='emailPreferences.general'}

{* Dynamic key construction *}
{lang key="emailPreferences."|cat:$emailType}
```

### `{include}` - Template Inclusion

Includes another template file with optional parameter passing:

```smarty
{* Basic include *}
{include file="$template/includes/head.tpl"}
{include file="$template/includes/flashmessage.tpl"}

{* Include with parameters *}
{include file="$template/includes/alert.tpl" type="success" msg="Changes saved"}
{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
{include file="$template/includes/alert.tpl" type="info" msg=$customMessage textcenter=true}

{* Include with object parameters *}
{include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
{include file="$template/includes/navbar.tpl" navbar=$secondaryNavbar rightDrop=true}
{include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}

{* Include with DataTable config *}
{include file="$template/includes/tablelist.tpl" 
    tableName="ServicesList" 
    filterColumn="4" 
    noSortColumns="0"}

{include file="$template/includes/tablelist.tpl" 
    tableName="DomainsList" 
    noSortColumns="0, 1" 
    startOrderCol="2" 
    filterColumn="5"}

{* Include with dynamic path *}
{include file=$blockLink config=$brandingBlock products=$products}
```

### `{get_flash_message}` - Flash Message Retrieval

Custom function to retrieve flash messages from the session:

```smarty
{if $message = get_flash_message()}
    <div class="alert alert-{$message.type}">
        {$message.text}
    </div>
{/if}
```

### PHP Class Methods in Templates

WHMCS exposes some PHP helpers directly:

```smarty
{* Asset helper *}
{\WHMCS\View\Asset::fontCssInclude('open-sans-family.css')}

{* Environment helper *}
{\WHMCS\Utility\Environment\WebHelper::getBaseUrl()}

{* Carbon date formatting *}
{$carbon->createFromTimestamp($announcement.timestamp)->format('jS F Y')}

{* Captcha methods *}
{$captcha->getMarkup()}
{$captcha->getPageJs()}
{$captcha->isEnabled()}
{$captcha->isEnabledForForm($captchaForm)}
{$captcha->getButtonClass($captchaForm)}
```
