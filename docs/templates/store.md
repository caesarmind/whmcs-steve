# Store & Marketplace Templates

### Store Architecture

The store system uses two approaches:

1. **Static store pages** (`store/{provider}/index.tpl`) - Provider-specific templates
2. **Dynamic store system** (`store/dynamic/`) - Data-driven pages built from content blocks

### Dynamic Store System

The dynamic store renders pages from configuration data:

```smarty
{* store/dynamic/index.tpl *}
<div class="dynamic-landing-page"
     style="
        --primary-color: {$pageData->branding->primaryColor};
        --secondary-color: {$pageData->branding->secondaryColor};
        --accent-color: {$pageData->branding->accentColor};
        --text-color: {$pageData->branding->textColor};
        --bg-color: {$pageData->branding->backgroundColor};
        font-family: {$storeConfig->typography->p};
     ">
    {foreach $pageData->blocks->items as $brandingBlock}
        {$blockType = $brandingBlock->getBlockType()}
        {include file="$template/store/dynamic/partial/$blockType.tpl"
            config=$brandingBlock
            products=$products}
    {/foreach}
</div>
```

### Dynamic Block Partials

| Partial | Purpose |
|---------|---------|
| `partial/header.tpl` | Hero section with heading and tagline |
| `partial/grid_of_cards.tpl` | Card grid layout for features |
| `partial/price_comparison.tpl` | Pricing comparison table |
| `partial/product_preview.tpl` | Product preview card |
| `partial/faq.tpl` | FAQ accordion section |
| `partial/free_form.tpl` | Free-form HTML content |
| `partial/video.tpl` | Video embed section |

### Configuration Fields

Product configuration fields are rendered via specialized templates:

```smarty
{foreach $configurationFields as $field}
    <div class="form-group">
        <label>{$field.label} {if $field.required}<span class="text-danger">*</span>{/if}</label>
        
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
```

### Product Order Page (`store/order.tpl`)

The main product order page includes:
1. Product name and description
2. Billing cycle selector
3. Domain selection (tabs: existing, subdomain, custom, or none)
4. Configuration fields
5. Add to cart / checkout buttons
6. Upsell product promotion

### Marketplace Provider Templates

Each provider integration has:
- `{provider}/index.php` - Security redirect
- `{provider}/index.tpl` - Main product landing page
- `{provider}/manage.tpl` (optional) - Product management page

**Providers included:** CodeGuard, MarketGoo, NordVPN, Open-Xchange, Sitebuilder, Sitelock, SitelockVPN, SocialBee, SpamExperts, 360 Monitoring, Weebly, XoviNow

### SSL Certificate Store

The SSL store has its own structure:

```
store/ssl/
├── index.tpl                   # SSL store main page
├── dv.tpl                      # Domain Validation certificates
├── ov.tpl                      # Organization Validation
├── ev.tpl                      # Extended Validation
├── wildcard.tpl                # Wildcard certificates
├── competitive-upgrade.tpl     # Competitive upgrade offer
└── shared/                     # Shared components
    ├── certificate-item.tpl    # Certificate card
    ├── certificate-pricing.tpl # Pricing display
    ├── currency-chooser.tpl    # Currency selector
    ├── features.tpl            # Feature list
    ├── logos.tpl               # Trust logos
    └── nav.tpl                 # SSL store navigation
```

### Dynamic Store Block Variables

### `partial/header.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->logo}` | Logo image URL |
| `{$config->title}` | Hero title text |
| `{$config->subtitle}` | Hero subtitle |
| `{$config->shortDescription}` | Description text |
| `{$elementIndex}` | Block iteration index (for alternating backgrounds) |

### `partial/grid_of_cards.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->services}` | Service/product list |
| `{$service['slug']}` | Product slug identifier |
| `{$service['features']}` | Feature list array |
| `{$products[$slug]}` | Product object from products map |
| `{$plan->isFree()}` | Is free plan |
| `{$plan->pricing()->first()->toPrefixedString()}` | Formatted price |
| `{$hasPlan}` | Whether plan data exists |

### `partial/price_comparison.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->services}` | Services to compare |
| `{$config->title}` | Table title |
| Feature values can be: `boolean` (check/cross), `string`, `numeric` |

### `partial/faq.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->items}` | FAQ items (question/answer pairs) |
| `{$faq->question}` | FAQ question text |
| `{$faq->answer}` | FAQ answer text |
| `{$smarty.foreach.faqs.index}` | FAQ index for IDs |

### `partial/video.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->url}` | Video embed URL |
| `{$config->title}` | Video section title |

### `partial/free_form.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->content}` | Free-form HTML content |

### `partial/product_preview.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->services}` | Products to preview |
| `{$plan.name}` | Product name |
| `{$plan.description}` | Product description |
| `{$plan->pricing()}` | Pricing object |

## Marketplace Provider Templates

Marketplace providers are third-party products sold through WHMCS via dedicated landing pages. Each provider has its own sub-directory under `store/` with an `index.tpl` (public landing page), and optionally a `manage.tpl` (post-purchase management page) and an `index.php` (security redirect).

All provider templates share these common characteristics:
- Render a product/plan list fetched from WHMCS
- Generate "add to cart" / "order" links via `routePath()` helpers
- Respect `$inPreview` to disable interaction while theme previewing
- Respect `$loggedin` to adjust calls-to-action for authenticated clients
- Honor `$currencies` / `$activeCurrency` for currency switching

### CodeGuard (`store/codeguard/index.tpl`)

Landing page for CodeGuard website backup plans. Features an interactive disk-space range slider that lets visitors select backup capacity before ordering.

| Variable | Description |
|----------|-------------|
| `{$products}` | Collection of CodeGuard products |
| `{$codeGuardFaqs}` | FAQ entries for CodeGuard |
| `{$loggedin}` | Whether the visitor is authenticated |
| `{$currencies}` | Available currencies |
| `{$activeCurrency}` | Currently selected currency |
| `{$routePathSlug}` | Slug used for product-group routing |
| `{$inPreview}` | Theme preview mode flag |
| `{$WEB_ROOT}` | WHMCS web root (for asset paths) |

**Methods / objects accessed:**
- `$product->diskSpace`, `$product->id`, `$product->name`
- `$product->pricing()->first()`
- `$product->isFeatured`
- `$product->formattedProductFeatures.featuresDescription`

**Routes used:**
- `routePath('store-product-group', $routePathSlug)`
- `routePath('cart-order')`

**Unique patterns:**
- `ionRangeSlider` integration for backup-space selection driving the add-to-cart action.

### MarketGoo (`store/marketgoo/index.tpl`)

Landing page for MarketGoo SEO plans. Embeds a Vimeo marketing video and lists the SEO tier plans.

| Variable | Description |
|----------|-------------|
| `{$plans}` | MarketGoo plan collection |
| `{$loggedin}` | Authentication flag |
| `{$currencies}` | Available currencies |
| `{$activeCurrency}` | Active currency |
| `{$inPreview}` | Theme preview mode flag |

**Methods / objects accessed:**
- `$plan->name`, `$plan->configoption1`
- `$plan->isFree()`
- `$plan->pricing()->first()`
- `$plan->features`

**Routes used:**
- `routePath('cart-order')`

**Unique patterns:**
- Embedded Vimeo player in the hero section.

### NordVPN (`store/nordvpn/index.tpl`)

Landing page for NordVPN subscription plans. Surfaces monthly-equivalent pricing and yearly savings alongside an FAQ accordion.

| Variable | Description |
|----------|-------------|
| `{$plans}` | Available NordVPN plans |
| `{$pricings}` | Pricing variants keyed by cycle |
| `{$highestMonthlyPrice}` | Reference price used to compute savings |
| `{$inPreview}` | Theme preview mode flag |
| `{$loggedin}` | Authentication flag |

**Methods / objects accessed:**
- `$plan->id`
- `$pricing->cycle()`, `$pricing->monthlyPrice()`
- `$pricing->calculatePercentageDifference()`
- `$pricing->isYearly()`, `$pricing->cycleInYears()`, `$pricing->cycleInMonths()`

**Routes used:**
- `routePath('cart-order-addtocart')`

**Unique patterns:**
- Hidden `billingcycle` input posted to the add-to-cart route.
- Accordion JS with a rotating chevron icon for FAQ toggles.

### Open-Xchange OX (`store/ox/index.tpl`, `store/ox/manage.tpl`)

Landing and management pages for Open-Xchange hosted email/collaboration. The index page renders a feature-comparison table driven by plan configuration options.

| Variable | Description |
|----------|-------------|
| `{$plans}` | OX plan collection |
| `{$inPreview}` | Theme preview mode flag |
| `{$WEB_ROOT}` | WHMCS web root |

**Methods / objects accessed:**
- `$plan->name`, `$plan->configoption1`, `$plan->features`
- `$plan->pricing()->first()->toFullString()`

**Routes used:**
- `routePath('cart-order')`

**Unique patterns:**
- CSS feature-comparison table where column styling is derived from `$plan->configoption1`.

### Sitebuilder (`store/sitebuilder/index.tpl`, `store/sitebuilder/upgrade.tpl`)

Landing page plus an upgrade flow for the Sitebuilder product. The index showcases templates filterable by type; the upgrade page lets existing clients upsell their current Sitebuilder service.

| Variable | Description |
|----------|-------------|
| `{$templates}` | Showcase template entries |
| `{$trialPlan}` | Trial plan reference |
| `{$plans}` | Purchasable Sitebuilder plans |
| `{$promoHelper}` | Helper returning promotional feature data |
| `{$inPreview}` | Theme preview mode flag |
| `{$loggedin}` | Authentication flag |

**Template entry objects:**
- `$template['type']`, `$template['preview']`, `$template['thumbnail']`, `$template['name']`

**Plan objects:**
- `$plan->id`, `$plan->name`, `$plan->features`
- `$plan->pricing()->first()`

**Promo helper:**
- `$promoHelper->getFeatures()`

**Upgrade page variables:**
- `$siteBuilderServices`, `$product`, `$promo`
- `$loggedin`, `$loggedinuser.email`

**Routes used:**
- `routePath('cart-order')`
- `routePath('cart-site-builder-upgrade-order')`

**Unique patterns:**
- Client-side template filtering by type (`single` / `multi` / `ecom`).
- Lazy image loading for template thumbnails.

### Sitelock (`store/sitelock/index.tpl`)

Landing page for Sitelock website security plans. Supports multiple billing cycles per plan and exposes a dedicated emergency cleanup plan.

| Variable | Description |
|----------|-------------|
| `{$plans}` | Sitelock plan collection |
| `{$emergencyPlan}` | Emergency cleanup plan |
| `{$currencies}` | Available currencies |
| `{$activeCurrency}` | Active currency |
| `{$inPreview}` | Theme preview mode flag |
| `{$learnMoreLink}` | "Learn more" destination URL |

**Methods / objects accessed:**
- `$plan->name`, `$plan->description`, `$plan->features`
- `$plan->isFree()`
- `$plan->pricing()->annually()`, `$plan->pricing()->first()`, `$plan->pricing()->allAvailableCycles()`
- `$cycle->isRecurring()`, `$cycle->isYearly()`
- `$cycle->cycleInYears()`, `$cycle->cycleInMonths()`, `$cycle->toFullString()`
- `$emergencyPlan->pricing()->best()`

**Routes used:**
- `routePath('cart-order')`

### Sitelock VPN (`store/sitelockvpn/index.tpl`)

Landing page for the Sitelock VPN product with per-cycle pricing and savings callouts.

| Variable | Description |
|----------|-------------|
| `{$plans}` | VPN plan collection |
| `{$pricings}` | Pricing variants keyed by cycle |
| `{$highestMonthlyPrice}` | Baseline monthly price for savings calculation |
| `{$inPreview}` | Theme preview mode flag |
| `{$plan->planFeatures}` | Plan feature list |

**Methods / objects accessed:**
- `$pricing->isYearly()`, `$pricing->cycleInYears()`, `$pricing->cycleInMonths()`
- `$pricing->calculatePercentageDifference()`
- `$pricing->toPrefixedString()`, `$pricing->cycle()`

**Routes used:**
- `routePath('cart-order')`

### SocialBee (`store/socialbee/index.tpl`)

Landing page for SocialBee social-media management plans. Embeds a complete themed CSS block and renders a side-by-side feature comparison plus FAQ.

| Variable | Description |
|----------|-------------|
| `{$planComparisonData}` | Matrix used by the comparison grid |
| `{$planFeatures}` | Feature labels / rows |
| `{$inPreview}` | Theme preview mode flag |

**Methods / objects accessed:**
- `$plan->name`, `$plan->id`
- `$plan->isFree()`
- `$plan->pricing()->first()->toPrefixedString()`

**Routes used:**
- `routePath('cart-order')`

**Unique patterns:**
- Inline `<style>` block carrying the full provider theme.
- CSS Grid pricing table with a parallel feature-comparison grid.
- FAQ accordion section.

### SpamExperts (`store/spamexperts/index.tpl`)

Landing page offering incoming, outgoing, and archiving spam-filtering products. Uses a complex selector backed by a JSON `servicemap` so visitors can pick a product variant and option.

| Variable | Description |
|----------|-------------|
| `{$products}` | Keyed collection of products (`incoming`, `outgoing`, `archiving` variants) |
| `{$numberOfFeaturedProducts}` | Count of highlighted products |
| `{$inPreview}` | Theme preview mode flag |
| `{$currencies}` | Available currencies |
| `{$activeCurrency}` | Active currency |
| `{$loggedin}` | Authentication flag |

**Methods / objects accessed:**
- `$product->pricing()->best()`, `$product->productKey`
- `$option.pricing->toFullString()`, `$option.description`

**Routes used:**
- `routePath('cart-order')`

**Unique patterns:**
- Product/option selector driven by an embedded `servicemap` JSON payload.

### 360 Monitoring (`store/threesixtymonitoring/index.tpl`)

Landing page for 360 Monitoring uptime/monitoring plans. Follows the shared provider layout with plan cards, feature bullets, and pricing callouts.

**Routes used:**
- `routePath('cart-order')`
- `routePath('cart-threesixtymonitoring-site-check')` for the free site-check CTA.

### Weebly (`store/weebly/index.tpl`, `store/weebly/upgrade.tpl`)

Landing and upgrade pages for the Weebly site-builder product. The landing page shows a Lite tier, full plan list, and per-cycle pricing; the upgrade page handles in-service upsells.

| Variable | Description |
|----------|-------------|
| `{$litePlan}` | Entry-level free/lite plan |
| `{$products}` | Paid Weebly products |
| `{$billingCycles}` | Available cycle options |
| `{$currencies}` | Available currencies |
| `{$activeCurrency}` | Active currency |
| `{$loggedin}` | Authentication flag |
| `{$inPreview}` | Theme preview mode flag |

**Methods / objects accessed:**
- `$product->name`, `$product->idealFor`
- `$product->siteFeatures`, `$product->ecommerceFeatures`
- `$product->pricing()->allAvailableCycles()`
- `$pricing->cycle()`, `$pricing->toFullString()`

**Upgrade page variables:**
- `$weeblyServices`, `$product`, `$promo`

**Routes used:**
- `routePath('cart-order')`
- `routePath('cart-weebly-upgrade-order')`

### XoviNow (`store/xovinow/index.tpl`)

Landing page for the XoviNow SEO suite. Includes a Bootstrap-powered screenshot carousel and highlights the featured plan.

| Variable | Description |
|----------|-------------|
| `{$plans}` | XoviNow plan collection |
| `{$versionHash}` | Cache-busting hash for assets |
| `{$inPreview}` | Theme preview mode flag |
| `{$WEB_ROOT}` | WHMCS web root |

**Methods / objects accessed:**
- `$plan->productGroup->name`
- `$plan->name`, `$plan->is_featured`, `$plan->features`
- `$plan->isFree()`
- `$plan->pricing()->first()->toPrefixedString()`

**Routes used:**
- `routePath('cart-order')`

**Unique patterns:**
- Bootstrap carousel showcasing product screenshots.

### Addon Templates (`store/addon/`)

Addon templates render landing pages for product add-ons that attach to existing services, most notably the WP Toolkit variants.

| Template | Purpose |
|----------|---------|
| `wp-toolkit-cpanel.tpl` | WP Toolkit add-on for cPanel services |
| `wp-toolkit-plesk.tpl` | WP Toolkit add-on for Plesk services |

| Variable | Description |
|----------|-------------|
| `{$loggedin}` | Authentication flag |
| `{$clientServices}` | Eligible client services the addon can attach to |
| `{$firstMatchingAddon}` | Default addon match for the visitor |
| `{$ssoService}` | Service used to generate SSO links |
| `{$browsePackagesAction}` | URL for browsing compatible packages |
| `{$addonSlug}` | Slug for the current addon |
| `{$serviceId}` | Targeted service ID |
| `{$activeCurrency}` | Active currency |

**Routes used:**
- `fqdnRoutePath('store-add-addons')`
- `fqdnRoutePath('store-addon', 'plesk-wordpress-toolkit-with-smart-updates')`
- `routePath('store-addon-login')`

### Promos / Upsell (`store/promos/upsell.tpl`)

Reusable upsell component rendered on order flows. Content is driven entirely by a `$promotion` helper object plus a `$product` for pricing.

| Variable | Description |
|----------|-------------|
| `{$promotion}` | Promotion helper object |
| `{$product}` | Product being promoted |
| `{$targetUrl}` | Destination when the CTA is clicked |
| `{$inputParameters}` | Extra form/input parameters posted to `$targetUrl` |

**Promotion helper methods:**
- `$promotion->getClass()`
- `$promotion->getLearnMoreRoute()`
- `$promotion->getImagePath()`
- `$promotion->getHeadline()`, `$promotion->getTagline()`, `$promotion->getDescription()`
- `$promotion->hasFeatures()`, `$promotion->getFeatures()`
- `$promotion->getCta()`

**Product methods:**
- `$product->isFree()`
- `$product->pricing()->first()->isYearly()`
- `$product->pricing()->first()->monthlyPrice()`

## SSL Store Templates

The SSL store lives under `store/ssl/` and is composed of tier-specific pages plus a shared-components directory used across all SSL pages.

### Pages

| Template | Purpose |
|----------|---------|
| `index.tpl` | SSL store landing / category hub |
| `dv.tpl` | Domain Validation certificate tier |
| `ov.tpl` | Organization Validation certificate tier |
| `ev.tpl` | Extended Validation certificate tier |
| `wildcard.tpl` | Wildcard certificates |
| `competitive-upgrade.tpl` | Competitive upgrade offer (switch from another provider) |

### Shared Components (`store/ssl/shared/`)

| Component | Purpose |
|-----------|---------|
| `certificate-item.tpl` | Single certificate card used across all tier pages |
| `certificate-pricing.tpl` | Pricing display block (per-cycle, savings) |
| `currency-chooser.tpl` | Currency switcher |
| `features.tpl` | Feature list with icons and descriptions |
| `logos.tpl` | Trust-mark / brand logo strip |
| `nav.tpl` | SSL store navigation (DV / OV / EV / Wildcard / Competitive Upgrade) |

### Shared Variables

| Variable | Description |
|----------|-------------|
| `{$certificatesToDisplay}` | Certificates rendered on the current page |
| `{$certificateFeatures}` | Feature rows for the features component |
| `{$certificates}` | Full certificate catalog |
| `{$routePathSlug}` | Slug used for tier routing |
| `{$inPreview}` | Theme preview mode flag |
| `{$certTypes}` | Available certificate type filters |
| `{$highestMonthlyPrice}` | Baseline monthly price for savings callouts |

### Competitive Upgrade (`competitive-upgrade.tpl`)

The competitive upgrade flow validates a prospect's existing certificate (by URL) and, when eligible, offers a free extension for switching.

| Variable | Description |
|----------|-------------|
| `{$validated}` | Whether the submitted URL has been validated |
| `{$eligible}` | Whether the certificate qualifies for upgrade |
| `{$connectionError}` | Connection error encountered while validating |
| `{$error}` | Generic error message |
| `{$url}` | Submitted website URL |
| `{$expirationDate}` | Existing certificate expiration date |
| `{$monthsRemaining}` | Months left on the current certificate |
| `{$freeExtensionMonths}` | Free months offered on upgrade |
| `{$maxPotentialSavingAmount}` | Maximum savings available |
| `{$productGroupSlug}` | Target SSL product group slug |

**Routes used:**
- `routePath('cart-ssl-certificates-competitiveupgrade-validate')`
