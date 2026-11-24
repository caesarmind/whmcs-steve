<?php
declare(strict_types=1);

/**
 * Hadrian Page Builder: PSR-4 style autoloader.
 *
 *   HadrianBuilder\Foo  ->  modules/addons/HadrianBuilder/src/Foo.php
 *
 * Guarded by a constant and by function_exists, so it can be required from
 * both the module file and hooks.php without redeclaring anything.
 */

if (!defined('HADRIAN_BUILDER_DIR')) {
    define('HADRIAN_BUILDER_DIR', __DIR__);
}

if (!function_exists('HadrianBuilderAutoload')) {
    function HadrianBuilderAutoload(string $class): void
    {
        if (strncmp($class, 'HadrianBuilder\\', 15) !== 0) {
            return;
        }
        $path = HADRIAN_BUILDER_DIR . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR
            . str_replace('\\', DIRECTORY_SEPARATOR, substr($class, 15)) . '.php';
        if (is_file($path)) {
            require_once $path;
        }
    }
    spl_autoload_register('HadrianBuilderAutoload');
}
