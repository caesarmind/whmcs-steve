<?php
// Manual preview of the Option C "license required" screen (AddonHelper::renderLicenseRequiredPage).
//
//   php -S 127.0.0.1:8791 -t license-server/test
//   open http://127.0.0.1:8791/render-screen.php
//
// Under php -S the SAPI is 'cli-server' (not 'cli'), so the full HTML path runs.
require __DIR__ . '/../../mytheme/modules/addons/MyTheme/src/Helpers/AddonHelper.php';
\MyTheme\Helpers\AddonHelper::renderLicenseRequiredPage('mytheme');
