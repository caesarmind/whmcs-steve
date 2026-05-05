<?php
declare(strict_types=1);

namespace MyTheme\Service;

/**
 * Thin wrapper around Hooks::dispatch(). Future code (middleware, instrumentation,
 * feature flags) can wrap dispatch without touching Hooks itself.
 */
final class HookDispatcher
{
    public static function dispatch(string $hookName, mixed $arg): mixed
    {
        return Hooks::instance()->dispatch($hookName, $arg);
    }
}
