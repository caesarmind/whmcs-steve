<?php
/**
 * Custom page entry point (WHMCS root).
 *
 * This file lives in the repo at  hadrian/custom-page.php . The deploy Action
 * strips the leading "hadrian/" and extracts to the WHMCS root, so it lands at
 *   <whmcs-root>/custom-page.php
 * and the page is reachable at
 *   https://your-domain/custom-page.php
 *
 * It ONLY bootstraps WHMCS and names the template. The visible layout is:
 *   - theme header (with nav) + footer  -> templates/hadrian/header.tpl + footer.tpl  (automatic)
 *   - the page body                     -> templates/hadrian/core/pages/custom-page/default/default.tpl  (edit this)
 *
 * To add another custom page: copy this file to <name>.php, add a matching
 * templates/hadrian/<name>.tpl bridge + a core/pages/<name>/ dir, and change
 * the setTemplate() call below to '<name>'.
 */

use WHMCS\ClientArea;

define('CLIENTAREA', true);

require __DIR__ . '/init.php';

$ca = new ClientArea();

$ca->setPageTitle('Custom Page');
$ca->initPage();

// Uncomment to require a logged-in client (otherwise the page is public):
// $ca->requireLogin();

// Template filename without .tpl  ->  templates/hadrian/custom-page.tpl
$ca->setTemplate('custom-page');

$ca->output();
