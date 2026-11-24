<?php
declare(strict_types=1);

/**
 * Hadrian Email Templates: PSR-4 style autoloader.
 *
 *   HadrianEmail\Foo  ->  modules/addons/HadrianEmail/src/Foo.php
 *
 * Guarded by a constant and by function_exists, so it can be required from
 * both the module file and hooks.php without redeclaring anything.
 */

if (!defined('HADRIAN_EMAIL_DIR')) {
    define('HADRIAN_EMAIL_DIR', __DIR__);
}

if (!function_exists('HadrianEmailAutoload')) {
    function HadrianEmailAutoload(string $class): void
    {
        if (strncmp($class, 'HadrianEmail\\', 13) !== 0) {
            return;
        }
        $path = HADRIAN_EMAIL_DIR . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR
            . str_replace('\\', DIRECTORY_SEPARATOR, substr($class, 13)) . '.php';
        if (is_file($path)) {
            require_once $path;
        }
    }
    spl_autoload_register('HadrianEmailAutoload');
}
