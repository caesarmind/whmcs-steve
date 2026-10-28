<?php
/**
 * The login variants and their style arms, through REAL Smarty.
 *
 * Renders core/pages/login/beacon/beacon.tpl and .../split/split.tpl against
 * fixture data, once per declared style value, and links the REAL stylesheets.
 * The style lists are READ OUT OF the variant manifests, so this cannot pass
 * while the shipped options say something else -- add a style to beacon.php and
 * a pane for it appears here without anyone editing this file.
 *
 * Smarty is real, not a subset: these templates use {include}, get_flash_message()
 * and a $captcha OBJECT, and a subset renderer would quietly skip all three.
 *
 *   php tests/static/check-login-styles.php   -> tests/.local/adminpreview/loginstyles.html
 */

$root  = dirname(__DIR__, 2);
$theme = $root . '/hadrian/templates/hadrian';

/* Smarty, installed by Composer beside this file: composer install -d tests/static */
if (!is_file(__DIR__ . '/vendor/autoload.php')) {
    fwrite(STDERR, "Smarty is not installed - run: composer install -d tests/static\n");
    exit(2);
}
require __DIR__ . '/vendor/autoload.php';

/* WHMCS helpers the login templates call. Declared before Smarty compiles. */
if (!function_exists('get_flash_message')) {
    function get_flash_message() { return null; }
}
/* {routePath('x')} is PHP-function-call syntax in Smarty, not a function
   plugin, so it has to exist as a real global function -- registerPlugin does
   not satisfy it and fails at COMPILE time with "unknown function". */
if (!function_exists('routePath')) {
    function routePath($name) { return '/index.php/' . str_replace('-', '/', $name); }
}

$lang = require $theme . '/core/lang/english.php';

/* Read each variant's declared styles out of its own manifest. */
$variants = [
    'beacon' => ['file' => 'core/pages/login/beacon/beacon.tpl',
                 'manifest' => 'core/pages/login/beacon/beacon.php',
                 'optKey' => 'bcn_field_style', 'colourKey' => 'bcn_field_colour'],
    'split'  => ['file' => 'core/pages/login/split/split.tpl',
                 'manifest' => 'core/pages/login/split/split.php',
                 'optKey' => 'spl_panel_style', 'colourKey' => 'spl_panel_colour'],
];

$panes  = [];   // per variant -- see the write loop for why
$report = [];
foreach ($variants as $name => $v) {
    $meta   = require $theme . '/' . $v['manifest'];
    $spec   = $meta['supportedOptions'][$v['optKey']] ?? null;
    if (!is_array($spec)) {
        echo "FAIL {$name}: {$v['optKey']} not declared in its manifest\n";
        exit(1);
    }
    $styles = $spec['options'];
    $report[] = sprintf('%-7s %-16s default=%-9s styles: %s',
        $name, $v['optKey'], $spec['default'], implode(', ', $styles));

    foreach ($styles as $style) {
        $smarty = new Smarty();
        $smarty->setTemplateDir($theme);
        $smarty->setCompileDir(sys_get_temp_dir() . '/hadrian-login-harness');
        $smarty->caching = false;
        $smarty->assign([
            'template'  => 'hadrian',
            'WEB_ROOT'  => '',
            'token'     => 'FIXTURE',
            'companyname' => 'Hostnodes',
            'LANG'      => [
                'loginemail' => 'Email Address', 'clientareapassword' => 'Password',
                'loginrememberme' => 'Remember Me', 'forgotpw' => 'Forgot Password?',
                'loginbutton' => 'Login', 'or' => 'or', 'noannouncements' => 'No Announcements',
                'viewall' => 'View All',
                'userLogin' => ['notRegistered' => 'Not registered yet?', 'createAccount' => 'Create an Account'],
            ],
            'hadrianLang' => $lang,
            'hadrian'   => [
                'version'  => 'harness',
                'branding' => ['logo' => ['light' => '', 'dark' => '']],
                // A stored COLOUR alongside the style, so the harness proves the
                // whole chain: option -> Smarty preamble -> custom property ->
                // the fill built from it. Teal is a palette key, so this also
                // exercises the theme: branch rather than a literal hex.
                'pages'    => ['login' => ['options' => [
                    $v['optKey'] => $style,
                    $v['colourKey'] => 'theme:teal',
                ]]],
            ],
            'loginAnnouncements' => [
                ['id' => 1, 'title' => 'New Singapore data center now available',
                 'date' => 'Apr 5, 2026', 'excerpt' => 'All hosting plans can now be provisioned in the SG region for improved latency across Asia-Pacific.'],
                ['id' => 2, 'title' => 'Two-factor authentication now available',
                 'date' => 'Mar 28, 2026', 'excerpt' => 'Enable 2FA on your account for added security.'],
                ['id' => 3, 'title' => 'Scheduled network upgrade - London DC',
                 'date' => 'Apr 10, 2026', 'excerpt' => 'A scheduled upgrade will run Apr 20, 02:00-06:00 UTC.'],
            ],
            'rememberMe' => false, 'logout' => false, 'incorrect' => false,
            'verifylinkexpired' => false, 'passwordResetSuccessful' => false,
            'ssoProviders' => [], 'captcha' => null, 'captchaForm' => 'login',
        ]);
        $body = $smarty->fetch($v['file']);
        $panes[$name] = ($panes[$name] ?? '')
            . '<div class="pane"><div class="cap">' . htmlspecialchars("{$name} / {$style}") . '</div>'
            . '<div class="frame" data-probe="' . htmlspecialchars("{$name}|{$style}") . '">' . $body . '</div></div>' . "\n";
    }
}

/* INLINED, and deliberately not linked: the preview pane renders a file outside
   the project as a static snapshot and a relative <link> out of this folder does
   not resolve -- every pane then measured as black-on-black, which reads exactly
   like the templates being broken. Inlining is also why the output is split per
   variant below: all five sheets plus eight panes came to 554 KB and the pane
   refuses to open a file that large.

   apple-layout.css is NOT inlined. It is the nav/sidebar/rail stylesheet, and
   both of these variants declare fullPage -- the theme suppresses that chrome
   entirely, so nothing here can read a rule from it. */
$css = '';
foreach (['apple-theme.css', 'pages/login.css',
          'pages/login-split.css', 'pages/login-beacon.css'] as $f) {
    $css .= "\n/* ---- {$f} ---- */\n" . file_get_contents($theme . '/assets/css/' . $f);
}

$shell = <<<CSS
body{margin:0;font:14px system-ui;background:#666}
.pane{margin:0 0 18px}
.cap{font:600 11px system-ui;letter-spacing:.06em;text-transform:uppercase;padding:7px 12px;background:#111;color:#fff}
/* Each pane is its own viewport-ish box so a 100vh field does not run the page. */
.frame{height:620px;overflow:auto;background:var(--color-bg);position:relative}
.frame .mt-bcn{min-height:620px}
CSS;

@mkdir($root . '/tests/.local/adminpreview', 0777, true);
$wrote = [];
foreach ($panes as $name => $markup) {
    $html = "<!doctype html><html><head><meta charset=\"utf-8\"><title>login {$name}</title>\n"
          . "<style>{$css}</style>\n<style>{$shell}</style>\n</head><body>\n{$markup}</body></html>";
    $out = $root . "/tests/.local/adminpreview/login-{$name}.html";
    file_put_contents($out, $html);
    $wrote[] = sprintf('tests/.local/adminpreview/login-%s.html (%d KB)', $name, (int)(strlen($html) / 1024));
}

echo implode("\n", $report) . "\n\n" . implode("\n", $wrote) . "\n";
