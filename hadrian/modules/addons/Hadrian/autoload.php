<?php
declare(strict_types=1);

/**
 * Hadrian PSR-4 style autoloader.
 *
 * Maps:
 *   Hadrian\Foo\Bar  →  modules/addons/Hadrian/src/Foo/Bar.php
 */

// Declared conditionally: a top-level function is bound when the file
// compiles, so a second include under another path spelling (a junction,
// another slash style) was a fatal "Cannot redeclare" that require_once
// does not catch. It must come before spl_autoload_register below.
if (!function_exists('HadrianAutoload')) {
    function HadrianAutoload($class)
    {
        if (strpos($class, 'Hadrian\\') !== 0) {
            return false;
        }

        $relative = substr($class, strlen('Hadrian\\'));
        $path     = HADRIAN_DIR . DS . 'src' . DS . str_replace('\\', DS, $relative) . '.php';

        if (file_exists($path)) {
            require_once $path;
            return class_exists($class) || interface_exists($class) || trait_exists($class);
        }

        return false;
    }
}

if (!defined('HADRIAN_DIR')) {
    define('HADRIAN_DIR', __DIR__);

    if (!defined('DS')) {
        define('DS', DIRECTORY_SEPARATOR);
    }

    spl_autoload_register('HadrianAutoload');
}
