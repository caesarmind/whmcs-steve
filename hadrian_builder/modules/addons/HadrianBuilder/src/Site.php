<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * What moving a page between sites needs to know about the site it is on:
 * its languages, its products and its media library.
 *
 * PageFile and Importer ask this object and nothing else, so a test hands
 * them a stand-in and runs with no WHMCS, no database and no Hadrian.
 */
class Site
{
    /** @return list<string> installed WHMCS languages */
    public function languages(): array
    {
        return Bridge::languages();
    }

    /** @return list<array{id:int, name:string, group:string}> every product an admin can pick */
    public function products(): array
    {
        return Catalog::options();
    }

    /** Images can travel: the library hands files over and takes them in. */
    public function movesMedia(): bool
    {
        return Bridge::movesMedia();
    }

    /** The library file an image address points at, or '' when it is not a library image. */
    public function mediaNameIn(string $address): string
    {
        return Bridge::mediaNamesIn($address)[0] ?? '';
    }

    /** @return array{path:string,label:string,w:int,h:int}|null */
    public function mediaFile(string $name): ?array
    {
        return Bridge::mediaFile($name);
    }

    public function mediaUrl(string $name): string
    {
        return Bridge::mediaUrl($name);
    }

    /** @return array{ok:bool, name?:string, url?:string, reused?:bool, error?:string} */
    public function mediaAdd(string $path, string $label): array
    {
        return Bridge::mediaAdd($path, $label);
    }
}
