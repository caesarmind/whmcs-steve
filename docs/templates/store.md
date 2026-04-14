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
