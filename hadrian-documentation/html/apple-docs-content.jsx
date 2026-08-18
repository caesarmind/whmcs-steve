// apple-docs-content.jsx — Hadrian docs articles. Uses apple-docs-kit.jsx globals.

const ARTICLES = {
  introduction: {
    group: 'Getting started', title: 'Introduction', icon: 'book',
    lead: 'Hadrian is a premium WHMCS client area theme built on a single, variable-driven design system — recolor, restyle, and relayout your entire client area without touching a line of template code.',
    toc: [['overview', 'Overview'], ['whats-included', 'What’s included'], ['requirements', 'Requirements'], ['design-system', 'One design system']],
    body: () => (
      <>
        <H2 id="overview">Overview</H2>
        <P>Hadrian replaces the default WHMCS client area with a calm, content-first interface. Every surface — dashboard, services, billing, support — is rebuilt around generous whitespace, a clear type scale, and a single accent color. The look is configured entirely from the admin panel; no developer is required.</P>
        <Callout kind="info" title="Built on CSS variables">Every color, radius, and spacing token is a CSS variable. The Style Manager edits those variables live, so your customizations survive theme updates.</Callout>
        <Shot label="Hadrian client dashboard" />
        <H2 id="whats-included">What’s included</H2>
        <UL items={[
          '<strong>Client theme</strong> — the full WHMCS client area, responsive from mobile to ultrawide.',
          '<strong>Style Manager</strong> — visual editor for colors, typography, and component styles.',
          '<strong>Layout &amp; Menu builders</strong> — arrange navigation and page layouts without hooks.',
          '<strong>Dark mode</strong> — every style ships with a matching dark palette.',
          '<strong>Order form template</strong> — a cleaner, faster cart and checkout.',
        ]} />
        <H2 id="requirements">Requirements</H2>
        <PropTable rows={[
          ['WHMCS', '8.0+', 'Tested against every current WHMCS release.'],
          ['PHP', '7.4+', 'Matches WHMCS’ own minimum requirement.'],
          ['License', '1 domain', 'Each license covers one installation; add more from your account.'],
        ]} />
        <H2 id="design-system">One design system</H2>
        <P>Hadrian and its companion modules share one set of tokens. A color you set on the theme flows through to the order form and every extension, so the whole account stays visually consistent.</P>
      </>
    ),
  },
  installation: {
    group: 'Getting started', title: 'Installation', icon: 'rocket',
    lead: 'Upload the theme, activate the Hadrian addon, and apply your license. The whole process takes a few minutes.',
    toc: [['upload', 'Upload the files'], ['activate', 'Activate the addon'], ['license', 'Apply your license'], ['select', 'Select the theme']],
    body: () => (
      <>
        <H2 id="upload">Upload the files</H2>
        <Steps items={[
          'Download the latest release from your account area.',
          'Unzip and upload the <code>hadrian</code> folder to <code>/templates/</code> in your WHMCS install.',
          'Upload the <code>hadrian_addon</code> folder to <code>/modules/addons/</code>.',
        ]} />
        <Code lang="directory">templates/
  └── hadrian/
modules/
  └── addons/
      └── hadrian_addon/</Code>
        <H2 id="activate">Activate the addon</H2>
        <Steps items={[
          'In WHMCS admin, go to <strong>System Settings → Addon Modules</strong>.',
          'Find <strong>Hadrian</strong> and click <strong>Activate</strong>.',
          'Grant access to the relevant admin roles, then <strong>Save Changes</strong>.',
        ]} />
        <H2 id="license">Apply your license</H2>
        <P>Open the Hadrian addon and paste the license key from your account into the License field.</P>
        <Code lang="config">License Key:  HADRIAN-XXXX-XXXX-XXXX
Status:       Active ✓</Code>
        <Callout kind="warn" title="Keep the key private">Treat your license key like a password — it ties the installation to your account.</Callout>
        <H2 id="select">Select the theme</H2>
        <P>Go to <strong>System Settings → General Settings → General</strong> and set the Client Area Template to <strong>Hadrian</strong>. Save, then reload the client area.</P>
        <Callout kind="tip">You can preview Hadrian for your own session first via <code>?systpl=hadrian</code> before switching it on for everyone.</Callout>
      </>
    ),
  },
  addon: {
    group: 'Getting started', title: 'The Hadrian addon', icon: 'puzzle',
    lead: 'The addon is the control center — a clean admin panel where you manage styles, layouts, menus, pages, and licensing.',
    toc: [['panel', 'The panel'], ['sections', 'Sections']],
    body: () => (
      <>
        <H2 id="panel">The panel</H2>
        <P>The Hadrian addon mirrors the theme’s aesthetic inside WHMCS admin: a fixed-width, centered layout with a pill navigation and iOS-style controls. Changes preview live and apply instantly.</P>
        <Shot label="Hadrian admin panel" />
        <H2 id="sections">Sections</H2>
        <UL items={[
          '<strong>Styles</strong> — pick a preset, then edit colors, type, and components.',
          '<strong>Layouts</strong> — choose navigation and page structures.',
          '<strong>Menu</strong> — build client and guest menus per location.',
          '<strong>Pages</strong> — per-page template, SEO, and visibility.',
          '<strong>Extensions</strong> — manage companion modules.',
        ]} />
      </>
    ),
  },
  styles: {
    group: 'Customization', title: 'Style Manager', icon: 'palette',
    lead: 'Recolor and restyle the entire client area from one place. Pick a preset, then fine-tune the tokens behind it.',
    toc: [['presets', 'Style presets'], ['colors', 'Colors'], ['typography', 'Typography'], ['dark', 'Dark mode']],
    body: () => (
      <>
        <H2 id="presets">Style presets</H2>
        <P>Each style is a named bundle of variables. Activate one as your base, then customize it — or duplicate it to keep the original intact.</P>
        <Shot label="Style presets gallery" />
        <H2 id="colors">Colors</H2>
        <P>The palette is intentionally simple: neutral surfaces, a near-black ink, and a single accent that marks the one primary action per view. Edit any token with the swatch or by hex.</P>
        <PropTable rows={[
          ['--accent', '#0071e3', 'Primary actions, links, focus.'],
          ['--surface', '#ffffff', 'Cards and panels.'],
          ['--text-primary', '#1d1d1f', 'Headings and body.'],
          ['--success', '#30d158', 'Active / paid states.'],
        ]} />
        <H2 id="typography">Typography</H2>
        <P>Choose heading and body fonts independently from a curated library, then set the base size and scale. The system font is the default for a native, fast-loading feel.</P>
        <Callout kind="tip">Keep headings at weight 600 — it reads as confident without the heaviness of 700.</Callout>
        <H2 id="dark">Dark mode</H2>
        <P>Every style includes a matching dark palette. Choose how it’s applied: off, a visitor-facing toggle, or forced dark.</P>
        <PropTable rows={[
          ['User choice', '—', 'Shows a toggle; remembers the visitor’s choice.'],
          ['Forced dark', '—', 'Always renders the dark palette.'],
          ['Off', 'default', 'Light only.'],
        ]} />
      </>
    ),
  },
  layouts: {
    group: 'Customization', title: 'Layouts & Menu', icon: 'layout',
    lead: 'Arrange the shell of the client area — navigation placement, content width, and the menus themselves — without editing templates.',
    toc: [['layouts', 'Layouts'], ['login', 'Login-based layouts'], ['menu', 'Menu builder']],
    body: () => (
      <>
        <H2 id="layouts">Layouts</H2>
        <P>Pick where navigation lives and how wide content runs. Layouts can be set globally or overridden per page.</P>
        <UL items={[
          '<strong>Top nav</strong> — horizontal bar, content boxed.',
          '<strong>Sidebar</strong> — vertical navigation, great for dense accounts.',
          '<strong>Icon rail</strong> — compact, icon-led sidebar.',
        ]} />
        <H2 id="login">Login-based layouts</H2>
        <P>Serve a different layout to guests and signed-in clients — a marketing-style entry for visitors, a focused dashboard for customers.</P>
        <Callout kind="info">Login-based layouts are evaluated before the page renders, so there’s no flash of the wrong layout.</Callout>
        <H2 id="menu">Menu builder</H2>
        <P>Build navigation visually. Each location (Main, Secondary, Footer) has its own menus, and each menu targets an audience.</P>
        <Steps items={[
          'Open <strong>Menu</strong> and choose a location tab.',
          'Create a menu and assign it to <strong>Client</strong>, <strong>Guest</strong>, or <strong>All</strong>.',
          'Add items — pages, links, dropdowns, dividers — and drag to reorder.',
          'Expand any item to edit its label and target.',
        ]} />
        <Shot label="Menu builder" />
      </>
    ),
  },
  pages: {
    group: 'Customization', title: 'Pages & SEO', icon: 'book',
    lead: 'Control the template, SEO, and visibility of every WHMCS page individually.',
    toc: [['template', 'Page template'], ['seo', 'SEO'], ['visibility', 'Visibility']],
    body: () => (
      <>
        <H2 id="template">Page template</H2>
        <P>Open any page to choose its template variant and template-specific settings. Pages with no extra options simply show the base layout.</P>
        <Shot label="Page detail — template, settings, SEO" />
        <H2 id="seo">SEO</H2>
        <P>Enable SEO on a page to reveal its options: indexing, a custom title and description, and a social share image.</P>
        <Callout kind="tip">Leave indexing on <code>Inherit</code> unless a page needs to differ from your global rule.</Callout>
        <H2 id="visibility">Visibility</H2>
        <PropTable rows={[
          ['Public', '—', 'Reachable by anyone.'],
          ['Authenticated', '—', 'Signed-in clients only.'],
          ['Disabled', '—', 'Returns a 404.'],
        ]} />
      </>
    ),
  },
  orderform: {
    group: 'Order form', title: 'Order form', icon: 'cart',
    lead: 'A cleaner, faster WHMCS order process — from product selection to checkout — that matches the rest of Hadrian.',
    toc: [['enable', 'Enable the template'], ['layouts', 'Layouts'], ['preview', 'Admin preview']],
    body: () => (
      <>
        <H2 id="enable">Enable the template</H2>
        <P>Set Hadrian as your default order form under <strong>System Settings → General Settings → Ordering</strong>.</P>
        <Code lang="setting">Default Order Form Template:  Hadrian</Code>
        <H2 id="layouts">Layouts</H2>
        <UL items={[
          '<strong>Pricing columns</strong> — side-by-side plans with one highlighted.',
          '<strong>Product rows</strong> — compact list, ideal for many products.',
        ]} />
        <H2 id="preview">Admin preview</H2>
        <P>In the order-form picker, Hadrian shows a branded 165×90 preview so it’s easy to spot among the built-in templates.</P>
        <Shot label="Order form — checkout" />
      </>
    ),
  },
  email_overview: {
    group: 'Getting started', title: 'Overview', icon: 'mail', coming: true,
    lead: 'Design branded WHMCS email templates visually — drag blocks, set colors, and preview in light and dark. Templates inherit your Hadrian palette automatically.',
    toc: [['about', 'About'], ['workflow', 'Workflow']],
    body: () => (
      <>
        <Callout kind="info" title="Coming soon">The Email Template Builder is in active development. Enable notifications in the Hadrian addon to hear when it ships.</Callout>
        <H2 id="about">About</H2>
        <P>The Email Template Builder replaces hand-edited HTML emails with a visual editor. Blocks snap into a single-column layout that renders reliably across email clients, and every block picks up your theme’s colors and type.</P>
        <Shot label="Email Template Builder" />
        <H2 id="workflow">Workflow</H2>
        <Steps items={[
          'Pick a starting template or begin from a blank canvas.',
          'Drag in blocks — header, text, button, divider, footer.',
          'Set colors and content; merge fields stay intact.',
          'Preview light and dark, then assign to a WHMCS email.',
        ]} />
      </>
    ),
  },
  email_blocks: {
    group: 'Reference', title: 'Blocks & merge fields', icon: 'puzzle', coming: true,
    lead: 'The building blocks of an email and the WHMCS merge fields you can drop into them.',
    toc: [['blocks', 'Blocks'], ['merge', 'Merge fields']],
    body: () => (
      <>
        <H2 id="blocks">Blocks</H2>
        <UL items={[
          '<strong>Header</strong> — logo and optional nav.',
          '<strong>Text</strong> — rich paragraphs with merge fields.',
          '<strong>Button</strong> — a single primary action.',
          '<strong>Divider</strong> &amp; <strong>Spacer</strong> — rhythm and separation.',
          '<strong>Footer</strong> — company details and unsubscribe.',
        ]} />
        <H2 id="merge">Merge fields</H2>
        <P>Drop any WHMCS smarty merge field into a text or button block; it renders live in WHMCS as usual.</P>
        <Code lang="merge">{`{$client_name}
{$invoice_num}
{$invoice_total}
{$invoice_payment_link}`}</Code>
      </>
    ),
  },
  invoice_overview: {
    group: 'Getting started', title: 'Overview', icon: 'doc', coming: true,
    lead: 'Compose polished, on-brand invoices and quotes with a live editor and reusable layouts.',
    toc: [['about', 'About'], ['workflow', 'Workflow']],
    body: () => (
      <>
        <Callout kind="info" title="Coming soon">The Invoice Builder is in active development. Enable notifications in the Hadrian addon to hear when it ships.</Callout>
        <H2 id="about">About</H2>
        <P>The Invoice Builder gives WHMCS invoices and quotes the same considered look as the rest of Hadrian — clear hierarchy, your brand colors, and tidy line items — with a live preview as you edit.</P>
        <Shot label="Invoice Builder" />
        <H2 id="workflow">Workflow</H2>
        <Steps items={[
          'Choose an invoice layout.',
          'Set logo, colors, and the fields you want shown.',
          'Preview against sample data, then save as the default.',
        ]} />
      </>
    ),
  },
  invoice_layouts: {
    group: 'Reference', title: 'Layouts', icon: 'layout', coming: true,
    lead: 'Reusable invoice and quote layouts you can switch between.',
    toc: [['layouts', 'Layouts']],
    body: () => (
      <>
        <H2 id="layouts">Layouts</H2>
        <UL items={[
          '<strong>Classic</strong> — header, billed-to, itemized table, totals.',
          '<strong>Compact</strong> — tighter spacing for long invoices.',
          '<strong>Statement</strong> — summary-first for account statements.',
        ]} />
      </>
    ),
  },
};

// Products shown in the left rail — each owns a set of articles.
const PRODUCTS = [
  { id: 'client-theme', name: 'Client Theme', icon: 'layout', articles: ['introduction', 'installation', 'addon', 'styles', 'layouts', 'pages', 'orderform'] },
  { id: 'email-builder', name: 'Email Templates', icon: 'mail', coming: true, articles: ['email_overview', 'email_blocks'] },
  { id: 'invoice-builder', name: 'Invoice Builder', icon: 'doc', coming: true, articles: ['invoice_overview', 'invoice_layouts'] },
];

window.ARTICLES = ARTICLES;
window.PRODUCTS = PRODUCTS;
