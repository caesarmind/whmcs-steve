<?php
declare(strict_types=1);

namespace MyTheme\Database;

/**
 * Simple migration runner. Walks resources/migrations/*.php and runs each
 * once, tracking executed versions in `mytheme_migrations`.
 *
 * Migration files implement: { public function up(): void; public function down(): void; }
 * and live in MyTheme\Resources\Migrations namespace.
 */
final class Migrator
{
    private string $migrationsPath;

    public function __construct(string $addonRoot)
    {
        $this->migrationsPath = $addonRoot . DIRECTORY_SEPARATOR . 'resources' . DIRECTORY_SEPARATOR . 'migrations';
    }

    public function migrate(): void
    {
        $this->ensureTable();
        foreach ($this->discover() as $name => $file) {
            if ($this->wasRun($name)) {
                continue;
            }
            $instance = $this->load($name, $file);
            $instance->up();
            $this->recordRun($name);
        }
    }

    public function rollback(): void
    {
        $this->ensureTable();
        $migrations = array_reverse($this->discover(), true);
        foreach ($migrations as $name => $file) {
            if (!$this->wasRun($name)) {
                continue;
            }
            $instance = $this->load($name, $file);
            $instance->down();
            $this->forgetRun($name);
        }

        // After all migrations rolled back, drop the migrations table itself
        \WHMCS\Database\Capsule::schema()->dropIfExists('mytheme_migrations');
    }

    private function discover(): array
    {
        if (!is_dir($this->migrationsPath)) {
            return [];
        }
        $found = [];
        foreach (glob($this->migrationsPath . DIRECTORY_SEPARATOR . '*.php') ?: [] as $path) {
            $base = basename($path, '.php');
            if ($base === 'index') continue;
            $found[$base] = $path;
        }
        ksort($found);
        return $found;
    }

    private function load(string $name, string $file)
    {
        require_once $file;
        $class = "MyTheme\\Resources\\Migrations\\{$name}";
        if (!class_exists($class)) {
            throw new \RuntimeException("Migration class not found: {$class}");
        }
        return new $class();
    }

    private function ensureTable(): void
    {
        if (\WHMCS\Database\Capsule::schema()->hasTable('mytheme_migrations')) {
            return;
        }
        \WHMCS\Database\Capsule::schema()->create('mytheme_migrations', function ($t) {
            $t->increments('id');
            $t->string('name')->unique();
            $t->timestamp('ran_at')->useCurrent();
        });
    }

    private function wasRun(string $name): bool
    {
        return \WHMCS\Database\Capsule::table('mytheme_migrations')
            ->where('name', $name)
            ->exists();
    }

    private function recordRun(string $name): void
    {
        \WHMCS\Database\Capsule::table('mytheme_migrations')
            ->insert(['name' => $name, 'ran_at' => date('Y-m-d H:i:s')]);
    }

    private function forgetRun(string $name): void
    {
        \WHMCS\Database\Capsule::table('mytheme_migrations')
            ->where('name', $name)
            ->delete();
    }
}
