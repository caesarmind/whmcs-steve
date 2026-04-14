# Best Practices & Common Pitfalls

### DO

1. **Use child themes** - Never modify parent theme files directly
2. **Override CSS in `custom.css`** - Loads last, highest specificity
3. **Use hooks for PHP logic** - The only future-proof method
4. **Maintain all WHMCS template includes** - Missing includes break functionality
5. **Use `{$template}` in include paths** - Ensures correct theme resolution:
   ```smarty
   {include file="$template/includes/alert.tpl"}
   ```
6. **Use `{assetPath}` for asset URLs** - Resolves correct paths for child themes
7. **Use `{routePath()}` for URLs** - Generates correct WHMCS routes
8. **Use `{lang}` for all user-facing text** - Enables localization
9. **Test with `?systpl=mytheme`** - Preview before activating
10. **Use version control** - Fork the official GitHub repositories
11. **Keep `{$headoutput}` and `{$footeroutput}`** - Required for WHMCS operation
12. **Use `{$token}` in forms** - CSRF protection

### DON'T

1. **Never remove footer JavaScript** - The `{$footeroutput}` in footer.tpl is essential for client area operation
2. **Never use `{php}` blocks** - Deprecated, use hooks instead
3. **Never modify parent theme files** - Will be overwritten on update
4. **Don't remove `{$headeroutput}`** - Required for system functionality
5. **Don't hardcode URLs** - Use `{$WEB_ROOT}` or `{routePath()}`
6. **Don't hardcode text** - Use `{lang key='...'}` for translations
7. **Don't skip CSRF tokens** - POST forms need `{$token}`
8. **Don't change `theme.yaml` structure** - Follow the exact format
9. **Don't use spaces in theme directory names** - Only lowercase letters, numbers, hyphens, underscores
10. **Don't modify `all.min.css`** - Override in `theme.css` or `custom.css`

### Debugging

1. **See all template variables:** Add `{debug}` to any template file
2. **Check error logs:** Configuration > System Logs > Activity Log
3. **Isolate theme issues:** Switch to default theme to confirm the issue is theme-related
4. **Enable PHP tags (if needed):** Configuration > System Settings > General Settings > Security > "Allow Smarty PHP Tags"

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Blank page | Smarty syntax error | Check activity log, fix syntax |
| Missing sidebar | `$primarySidebar` not passed | Ensure header.tpl includes sidebar |
| Broken layout | Missing Bootstrap classes | Verify Bootstrap 4 class usage |
| JS errors | Missing `{$footeroutput}` | Restore footer output variable |
| Assets 404 | Wrong path | Use `{assetPath}` function |
| Forms broken | Missing CSRF token | Include `{$token}` in forms |

### Performance Tips

1. Use minified CSS/JS (`*.min.css`, `*.min.js`)
2. Use `{$versionHash}` for cache busting
3. Keep `serverSidePagination: false` for small datasets, switch to `true` for large ones
4. Optimize images in `/images/` and `/img/` directories
5. Use CSS variables for consistent theming (single source of truth)

## Appendix: Quick Reference

### Creating a New Page Template

1. Create `yourpage.tpl` in your child theme root
2. Content renders between header.tpl and footer.tpl automatically
3. Use standard includes:

```smarty
{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-body">
        <h3 class="card-title">{lang key='yourPageTitle'}</h3>
        {* Your content here *}
    </div>
</div>
```

### Template Variable Debug Cheatsheet

```smarty
{* Show all variables *}
{debug}

{* Check specific variable *}
{if isset($myVar)}exists{else}not set{/if}

{* Dump array contents *}
{foreach $myArray as $key => $value}
    {$key}: {$value}<br>
{/foreach}

{* Check object type *}
{if is_array($var)}array{/if}
{if is_object($var)}object{/if}
```

### Common Route Names

```smarty
{routePath('knowledgebase-search')}
{routePath('knowledgebase-index')}
{routePath('announcement-index')}
{routePath('announcement-view', $id, $slug)}
{routePath('download-index')}
{routePath('domain-pricing')}
{routePath('login-validate')}
{routePath('password-reset-begin')}
{routePath('user-accounts')}
{routePath('cart-order')}
{routePath('cart-order-addtocart')}
{routePath('cart-order-validate')}
{routePath('cart-order-login')}
{routePath('account-contacts')}
{routePath('dismiss-user-validation')}
{routePath('dismiss-email-verification')}
{routePath('user-email-verification-resend')}
{routePath('login-two-factor-challenge-verify')}
{routePath('login-two-factor-challenge-backup-verify')}
{routePath('user-profile-save')}
{routePath('user-profile-email-save')}
{routePath('user-password')}
{routePath('user-security-question')}
{routePath('account-security-two-factor-enable')}
{routePath('account-security-two-factor-disable')}
{routePath('invite-validate', $invite->token)}
{routePath('account-users-permissions')}
{routePath('account-users-permissions-save', $user->id)}
{routePath('account-users-invite')}
{routePath('account-users-invite-resend')}
{routePath('account-users-invite-cancel')}
{routePath('account-users-remove')}
{routePath('account-paymentmethods-add')}
{routePath('account-contacts-save')}
{routePath('account-contacts-new')}
{routePath('password-reset-validate-email')}
{routePath('password-reset-change-perform')}
{routePath('password-reset-security-verify')}
{routePath('upgrade-add-to-cart')}
{routePath('download-search')}
{routePath('knowledgebase-article-view', $id, $slug)}
{routePath('knowledgebase-category-view', $id, $name)}
{routePath('clientarea-ssl-certificates-resend-approver-email')}
{routePath('announcement-view', $id, $slug)}
{routePath('fqdnRoutePath-announcement-view', $id, $slug)}  {* Fully qualified domain route *}
```
