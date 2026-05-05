<?php
declare(strict_types=1);

/**
 * MyTheme PSR-4 style autoloader.
 *
 * Maps:
 *   MyTheme\Foo\Bar  →  modules/addons/MyTheme/src/Foo/Bar.php
 */

if (!defined('MYTHEME_DIR')) {
    define('MYTHEME_DIR', __DIR__);

    if (!defined('DS')) {
        define('DS', DIRECTORY_SEPARATOR);
    }

    spl_autoload_register('MyThemeAutoload');
}

function MyThemeAutoload($class)
{
    if (strpos($class, 'MyTheme\\') !== 0) {
        return false;
    }

    $relative = substr($class, strlen('MyTheme\\'));
    $path     = MYTHEME_DIR . DS . 'src' . DS . str_replace('\\', DS, $relative) . '.php';

    if (file_exists($path)) {
        require_once $path;
        return class_exists($class) || interface_exists($class) || trait_exists($class);
    }

    return false;
}
