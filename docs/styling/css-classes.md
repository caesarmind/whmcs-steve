# CSS Component Classes Reference

### Status Badge Classes

Used throughout for service, domain, invoice, and ticket status:

```css
.status                    /* Base status badge */
.status-active             /* Active service/domain */
.status-open               /* Open ticket */
.status-completed          /* Completed */
.status-pending            /* Pending */
.status-pending-transfer   /* Domain pending transfer */
.status-suspended          /* Suspended */
.status-customer-reply     /* Ticket awaiting customer */
.status-fraud              /* Fraud flagged */
.status-answered           /* Ticket answered */
.status-expired            /* Expired */
.status-transferred-away   /* Domain transferred */
.status-pending-registration /* Domain pending reg */
.status-redemption         /* Domain in redemption */
.status-grace              /* Domain in grace */
.status-terminated         /* Terminated */
.status-onhold             /* On hold */
.status-inprogress         /* In progress */
.status-closed             /* Closed */
.status-paid               /* Paid invoice */
.status-unpaid             /* Unpaid invoice */
.status-cancelled          /* Cancelled */
.status-collections        /* In collections */
.status-refunded           /* Refunded */
.status-payment-pending    /* Payment pending */
.status-delivered          /* Delivered */
.status-accepted           /* Accepted quote */
.status-lost / .status-dead /* Lost/dead quote */
.status-custom             /* Custom status with inline color */
```

### Requestor Type Badges (Tickets)

```css
.requestor-type-operator
.requestor-type-owner
.requestor-type-authorizeduser
.requestor-type-registereduser
.requestor-type-subaccount
.requestor-type-guest
```

### Responsive Tabs Pattern

Used in product details, domain details, and bulk management:

```html
<ul class="nav nav-tabs responsive-tabs-sm">
    <li class="nav-item"><a class="nav-link active" data-toggle="tab">Tab 1</a></li>
    <li class="nav-item"><a class="nav-link" data-toggle="tab">Tab 2</a></li>
</ul>
<div class="responsive-tabs-sm-connector">
    <div class="channel"></div>
    <div class="bottom-border"></div>
</div>
<div class="tab-content">
    <div class="tab-pane fade show active">Content 1</div>
    <div class="tab-pane fade">Content 2</div>
</div>
```

### Utility Classes

```css
.w-hidden           /* display: none (WHMCS utility) */
.w-text-09           /* font-size: 0.9em */
.width-fixed-20      /* width: 20px */
.width-fixed-60      /* width: 60px */
.extra-padding        /* Extra card body padding */
.mw-540              /* max-width: 540px (login card) */
.show-on-hover       /* Visible only on parent hover */
.show-on-card-hover  /* Visible only on card hover */
.disable-on-click    /* Disabled after click */
.no-icheck           /* Prevent iCheck styling */
.input-inline        /* Inline input display */
.input-inline-100    /* 100px wide inline input */
.using-password-strength  /* Wraps password with strength meter */
```

### Active Products/Services Card

```css
.div-service-item           /* Service list item container */
.div-service-status         /* Status badge area */
.div-service-name           /* Name/domain area */
.div-service-buttons        /* Action buttons area */
.btn-custom-action          /* Custom module action button */
.btn-view-details           /* View details button */
```

### Client Dashboard Tiles

```css
.tiles                      /* Tile container */
.tile                       /* Individual stat tile */
.tile .stat                 /* Stat number */
.tile .title                /* Stat label */
.tile .highlight            /* Bottom colored border */
.client-home-cards          /* Card panel container */
```

### Domain Search (Homepage)

```css
.home-domain-search         /* Search section container */
.input-group-wrapper        /* Input wrapper */
.tld-logos                  /* Featured TLD logos */
.tld-logos li               /* Individual TLD */
```
