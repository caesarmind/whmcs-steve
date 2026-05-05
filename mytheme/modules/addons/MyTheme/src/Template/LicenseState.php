<?php
declare(strict_types=1);

namespace MyTheme\Template;

/**
 * License state — backed enum (PHP 8.1+).
 *
 * Replaces the typical "switch on string" pattern that ships in most commercial
 * themes. Use it like:
 *
 *   $state = LicenseState::tryFromString($cache['license_status']);
 *   if ($state->shouldRender()) { ... }
 */
enum LicenseState: string
{
    case ACTIVE    = 'Active';
    case SUSPENDED = 'Suspended';
    case EXPIRED   = 'Expired';
    case CANCELLED = 'Cancelled';
    case BANNED    = 'Banned';
    case UNKNOWN   = 'Unknown';
    case INVALID   = 'Invalid';

    /** Lenient parser — anything unrecognised becomes INVALID. */
    public static function tryFromString(?string $raw): self
    {
        return self::tryFrom((string)$raw) ?? self::INVALID;
    }

    /** Currently entitled to render the theme. */
    public function shouldRender(): bool
    {
        return match ($this) {
            self::ACTIVE, self::SUSPENDED, self::EXPIRED => true,
            default => false,
        };
    }

    /** Hard fail — kill template, fall back to 'six' immediately. */
    public function shouldDeactivateImmediately(): bool
    {
        return match ($this) {
            self::CANCELLED, self::BANNED => true,
            default => false,
        };
    }

    /** Soft fail — start the grace timer. */
    public function shouldStartGrace(): bool
    {
        return match ($this) {
            self::UNKNOWN, self::INVALID => true,
            default => false,
        };
    }

    /** Should we show a dashboard banner to the admin? */
    public function shouldShowBanner(?float $daysToExpiry, ?string $message): bool
    {
        if ($message !== null && $message !== '') {
            return true;
        }
        return match (true) {
            $this === self::EXPIRED                                 => true,
            $daysToExpiry !== null && $daysToExpiry <= 14.0 && $daysToExpiry >= 0.0 => true,
            default                                                 => false,
        };
    }
}
