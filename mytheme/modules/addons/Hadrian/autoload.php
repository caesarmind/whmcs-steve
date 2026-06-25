<?php
declare(strict_types=1);

/**
 * Hadrian PSR-4 style autoloader.
 *
 * Maps:
 *   Hadrian\Foo\Bar  →  modules/addons/Hadrian/src/Foo/Bar.php
 */

if (!defined('HADRIAN_DIR')) {
    define('HADRIAN_DIR', __DIR__);

    if (!defined('DS')) {
        define('DS', DIRECTORY_SEPARATOR);
    }

    spl_autoload_register('HadrianAutoload');
}

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
