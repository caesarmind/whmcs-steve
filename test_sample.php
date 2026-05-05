<?php
class Greeter {
    private $prefix;
    private static $count = 0;

    public function __construct($prefix) {
        $this->prefix = $prefix;
    }

    public function greet($name) {
        self::$count++;
        return $this->buildMessage($name);
    }

    private function buildMessage($name) {
        return $this->prefix . ", " . $name . "!";
    }

    public static function total() {
        return self::$count;
    }
}

$g = new Greeter("Hello");
echo $g->greet("World"), "\n";
echo $g->greet("Claude"), "\n";
echo "Total greetings: ", Greeter::total(), "\n";
