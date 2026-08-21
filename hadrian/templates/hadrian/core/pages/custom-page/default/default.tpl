{* ============================================================================
   YOUR CUSTOM PAGE BODY  ("the manual inside")

   The theme's header (with nav) and footer wrap this automatically. Everything
   below is yours to change -- replace it with your own markup / layout. The
   starter content uses the theme's design tokens (var(--color-*)) so it matches
   the site in light and dark mode. You can also reuse the theme's marketing
   components (the hp-* classes from core-theme.css) for hero / pricing /
   feature sections like the homepage.

   When you build your real content, tokenize visible copy into the $hadrianLang
   lang file (core/lang/english.php) the way the other pages do.
   ============================================================================ *}

<div style="max-width: 980px; margin: 0 auto; padding: 64px 22px;">

    {* -- Custom hero -- *}
    <div style="text-align: center; margin-bottom: 56px;">
        <p style="font-size: 12px; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--color-accent); margin: 0 0 10px;">Custom Page</p>
        <h1 style="font-size: 44px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 14px;">Your layout, your rules.</h1>
        <p style="font-size: 17px; color: var(--color-text-secondary); max-width: 580px; margin: 0 auto; line-height: 1.55;">This page uses the theme&rsquo;s header and footer, but everything between them is hand-built in <code>core/pages/custom-page/default/default.tpl</code>. Edit that file to build whatever you need.</p>
    </div>

    {* -- Custom 2-column section -- *}
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 40px;">
        <div style="background: var(--color-surface); border: 1px solid var(--color-border); border-radius: 16px; padding: 28px;">
            <h3 style="font-size: 19px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">Left column</h3>
            <p style="font-size: 14px; color: var(--color-text-secondary); line-height: 1.6; margin: 0;">Drop in any content &mdash; text, images, a form, a pricing table. Because the header and footer come from the theme, you only design what goes here.</p>
        </div>
        <div style="background: var(--color-surface); border: 1px solid var(--color-border); border-radius: 16px; padding: 28px;">
            <h3 style="font-size: 19px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">Right column</h3>
            <p style="font-size: 14px; color: var(--color-text-secondary); line-height: 1.6; margin: 0;">Want a full-width landing instead? Reuse the <code>hp-*</code> marketing components, or set <code>fullPage =&gt; true</code> in a variant meta to drop the chrome entirely.</p>
        </div>
    </div>

    {* -- Custom CTA -- *}
    <div style="text-align: center;">
        <a href="{$WEB_ROOT}/cart.php" style="display: inline-block; background: var(--color-accent); color: #fff; font-size: 15px; font-weight: 500; padding: 13px 28px; border-radius: 12px; text-decoration: none;">A call to action</a>
    </div>

</div>
