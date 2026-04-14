# Smarty Template Patterns

### Variable Access

```smarty
{* Simple variable *}
{$companyname}

{* Array/object property access *}
{$client.companyname}
{$client.fullName}
{$service.id}
{$ticket.department}

{* Object method calls *}
{$item->getName()}
{$item->getUri()}
{$item->hasChildren()}
{$alert->getSeverity()}
{$alert->getMessage()}
{$productGroup->getRoutePath()}
{$product->pricing()->allAvailableCycles()}
{$pricing->cycle()}
{$pricing->isRecurring()}

{* Smarty special variables *}
{$smarty.capture.variableName}
{$smarty.server.PHP_SELF}

{* Loop iteration properties *}
{$item@first}        {* true on first iteration *}
{$item@last}         {* true on last iteration *}
{$item@iteration}    {* current iteration number (1-based) *}
```

### `{$smarty.server}` Access

```smarty
{* PHP $_SERVER superglobal access *}
{$smarty.server.PHP_SELF}

{* Common usage in form actions *}
<form method="post" action="{$smarty.server.PHP_SELF}?action=details">
```

### `{$smarty.foreach}` Named Loop Properties

```smarty
{foreach from=$config->items item=faq name=faqs}
    {$smarty.foreach.faqs.index}    {* 0-based index *}
    {$smarty.foreach.faqs.first}    {* true on first *}
    {$smarty.foreach.faqs.last}     {* true on last *}
    {$smarty.foreach.faqs.total}    {* total count *}
{/foreach}
```

### Modifiers (Pipe Syntax)

```smarty
{* String modifiers *}
{$variable|strtolower}
{$variable|lower}
{$variable|ucfirst}
{$variable|escape}
{$variable|strip_tags}
{$variable|addslashes}

{* Chained modifiers *}
{$announcement.text|strip_tags|strlen}

{* String replacement *}
{$variable|replace:'old':'new'}

{* Array count *}
{$array|count}
{* Or as function: *}
{count($array)}

{* Concatenation modifier *}
{lang key="emailPreferences."|cat:$emailType}

{* Modifier on custom functions *}
{lang|addslashes key="markdown.title"}
{{lang key='more'}|lower}
```

#### Additional Modifiers

| Modifier | Usage | Description |
|----------|-------|-------------|
| `|truncate:100:"..."` | `{$article|truncate:100:"..."}` | Truncate string with ellipsis |
| `|nl2br` | `{$message|nl2br}` | Convert newlines to `<br>` |
| `|substr:0:-1` | `{$string|substr:0:-1}` | PHP substr equivalent |
| `|sprintf2:$param` | `{lang key='key'|sprintf2:$value}` | String format with parameters |
| `|escape` | `{$ticket.subject|escape}` | HTML entity escaping |
| `|count` | `{$array|count}` | Array element count |

### Conditional Patterns

```smarty
{* Basic if/else *}
{if $loggedin}
    Welcome back
{else}
    Please log in
{/if}

{* Comparison operators *}
{if $type eq "error"}danger{/if}
{if $lockstatus eq "unlocked"}...{/if}
{if $service.status|strtolower}...{/if}

{* Logical operators *}
{if $loggedin && $adminLoggedIn}...{/if}
{if $registerdomainenabled || $transferdomainenabled}...{/if}

{* Array functions *}
{if in_array('firstname', $optionalFields)}...{/if}
{if is_array($customActionData)}...{/if}
{if count($locales) > 1}...{/if}

{* Object method checks *}
{if $item->hasChildren()}...{/if}
{if $item->isCurrent()}...{/if}
{if $primarySidebar->hasChildren() || $secondarySidebar->hasChildren()}...{/if}

{* Null/empty checks *}
{if $client.companyname}...{/if}
{if !empty($productGroups)}...{/if}
{if isset($headerTitle)}...{/if}

{* Nested ternary-style *}
{if $alert->getSeverity() == 'danger'}exclamation-circle
{elseif $alert->getSeverity() == 'warning'}exclamation-triangle
{elseif $alert->getSeverity() == 'info'}info-circle
{else}check-circle{/if}

{* Iteration checks *}
{if $item@first}...{/if}
{if $item@last}...{/if}
{if $item@iteration is odd}...{/if}
{if $item@iteration is even}...{/if}

{* File existence check *}
{if file_exists("templates/$template/includes/alert.tpl")}...{/if}

{* Null coalescing via is_null *}
{if is_null($ticket.statusColor)}status-{$ticket.statusClass}"{else}status-custom" style="background-color:{$ticket.statusColor}"{/if}
```

### Loop Patterns

```smarty
{* Basic foreach *}
{foreach $services as $service}
    {$service.product} - {$service.domain}
{/foreach}

{* Foreach with else (empty array) *}
{foreach $clientAlerts as $alert}
    {$alert->getMessage()}
{foreachelse}
    {lang key='notificationsnone'}
{/foreach}

{* Nested foreach *}
{foreach $item->getChildren() as $childItem}
    {$childItem->getLabel()}
{/foreach}

{* Iteration checks within loops *}
{foreach $panels as $item}
    {if $item@iteration is odd}
        {outputHomePanels}
    {/if}
{/foreach}

{* First/last item checks *}
{foreach $breadcrumb as $item}
    <li class="breadcrumb-item{if $item@last} active{/if}">
        {if !$item@last}<a href="{$item.link}">{/if}
        {$item.label}
        {if !$item@last}</a>{/if}
    </li>
{/foreach}

{* Limiting iterations *}
{foreach $featuredTlds as $num => $tldinfo}
    {if $num < 3}
        ...
    {/if}
{/foreach}

{* Object method iteration *}
{foreach $product->pricing()->allAvailableCycles() as $pricing}
    {$pricing->cycle()} - {$pricing->monthlyPrice()}
{/foreach}

{* Eloquent-style query in template *}
{foreach $client->contacts()->orderBy('firstname', 'asc')->get() as $contact}
    {$contact->fullName}
{/foreach}
```

#### `{for}` Loop

The `{for}` construct is used for numeric iteration (e.g., nameserver fields, star ratings):

```smarty
{* Nameserver fields 1-5 *}
{for $num=1 to 5}
    <input type="text" name="ns{$num}" value="{$nameservers[$num]}" class="form-control" />
{/for}

{* Star rating 1-5 *}
{for $rating=1 to 5}
    <span class="star" data-rate="{$rating}">
        <i class="fas fa-star"></i>
    </span>
{/for}
```

### Capture Blocks

Capture blocks store rendered content in a variable for later use:

```smarty
{capture name="domainUnlockedMsg"}
    <strong>{lang key='domaincurrentlyunlocked'}</strong><br />
    {lang key='domaincurrentlyunlockedexp'}
{/capture}

{* Use the captured content *}
{include file="$template/includes/alert.tpl" type="error" msg=$smarty.capture.domainUnlockedMsg}
```

### Variable Assignment

```smarty
{* Assign a variable *}
{assign "customActionData" $childItem->getAttribute('dataCustomAction')}

{* Assign from method return *}
{$blockType = $brandingBlock->getBlockType()}
{$blockLink = "$template/store/dynamic/partial/$blockType.tpl"}

{* Remove from collection *}
{assign "panels" $panels->removeChild($item->getName())}
```

#### Alternative `{assign}` Syntax

```smarty
{* Named parameter syntax *}
{assign var="approvalMethods" value=[]}
{assign var="customActionData" value=$childItem->getAttribute('dataCustomAction')}

{* Shorthand syntax *}
{$blockType = $brandingBlock->getBlockType()}
```

### Function Definitions

You can define reusable template functions within a template:

```smarty
{function name=outputHomePanels}
    <div menuItemName="{$item->getName()}" class="card card-accent-{$item->getExtra('color')}">
        <div class="card-header">
            <h3 class="card-title m-0">
                {$item->getLabel()}
            </h3>
        </div>
        {if $item->hasBodyHtml()}
            <div class="card-body">
                {$item->getBodyHtml()}
            </div>
        {/if}
    </div>
{/function}

{* Call the function *}
{foreach $panels as $item}
    {outputHomePanels}
{/foreach}
```

### Literal Blocks

Prevents Smarty from parsing content (useful for JavaScript with curly braces):

```smarty
{literal}
    {...whmcsPaymentModuleMetadata, ...{event: e}}
{/literal}
```

### Dynamic Include Paths

```smarty
{* Variable-based template path *}
{$blockType = $brandingBlock->getBlockType()}
{$blockLink = "$template/store/dynamic/partial/$blockType.tpl"}
{include file=$blockLink config=$brandingBlock}

{* Dynamic template inclusion based on variable *}
{include file="$template/password-reset-$innerTemplate.tpl"}
```
