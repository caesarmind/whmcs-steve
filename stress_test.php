<?php

interface Shape {
    public function area(): float;
    public function describe(): string;
}

abstract class BaseShape implements Shape {
    protected string $name;
    private static int $instanceCount = 0;

    public function __construct(string $name) {
        $this->name = $name;
        self::$instanceCount++;
    }

    public static function totalInstances(): int {
        return self::$instanceCount;
    }

    public function describe(): string {
        return sprintf('%s with area %.2f', $this->name, $this->area());
    }

    abstract public function area(): float;
}

class Rectangle extends BaseShape {
    private float $width;
    private float $height;

    public function __construct(float $width, float $height) {
        parent::__construct('Rectangle');
        $this->width = $width;
        $this->height = $height;
    }

    public function area(): float {
        return $this->computeArea($this->width, $this->height);
    }

    private function computeArea(float $w, float $h): float {
        return $w * $h;
    }
}

class Circle extends BaseShape {
    private float $radius;
    private const PI_APPROX = 3.14159265;

    public function __construct(float $radius) {
        parent::__construct('Circle');
        $this->radius = $radius;
    }

    public function area(): float {
        return self::PI_APPROX * $this->radius * $this->radius;
    }
}

function summarize(array $shapes): string {
    $lines = [];
    foreach ($shapes as $i => $shape) {
        $lines[] = ($i + 1) . '. ' . $shape->describe();
    }
    return implode("\n", $lines);
}

$shapes = [
    new Rectangle(4.0, 5.0),
    new Circle(3.0),
    new Rectangle(2.5, 8.0),
];

echo summarize($shapes), "\n";
echo 'Total shapes created: ', BaseShape::totalInstances(), "\n";
