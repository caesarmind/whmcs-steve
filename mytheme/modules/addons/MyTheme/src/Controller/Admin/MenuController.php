<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;

final class MenuController extends AbstractController
{
    public function indexAction(): string
    {
        $tab = (string)($_GET['tab'] ?? 'main');

        // Stub data — a real implementation reads from a `mytheme_menus` table.
        $menus = [
            ['name' => 'Client Main Menu',                'rule' => 'Existing Client',  'active' => true],
            ['name' => 'Client Main Menu — WHMCS Defaults', 'rule' => 'Unassigned',       'active' => false],
            ['name' => 'Guest Main Menu',                 'rule' => 'Guest Client',     'active' => true],
            ['name' => 'Guest Main Menu — WHMCS Defaults',  'rule' => 'Unassigned',       'active' => false],
        ];

        return $this->view('menu/index', ['menus' => $menus, 'tab' => $tab]);
    }

    public function editAction(): string
    {
        return $this->view('menu/edit', [
            'menuName'    => (string)($_GET['name'] ?? 'Guest Main Menu'),
            'displayRule' => 'Guest Client',
            'active'      => true,
            // Items: stub tree; real impl reads from mytheme_menu_items
            'items'       => [
                ['name' => 'Products'],
                ['name' => 'Product Groups'],
                ['name' => 'Domains', 'children' => [
                    ['name' => 'Register a New Domain'],
                    ['name' => 'Transfer Domains to Us'],
                    ['name' => '', 'divider' => true],
                    ['name' => 'Domain Pricing'],
                ]],
                ['name' => 'Website & Security'],
                ['name' => 'MarketConnect Products'],
                ['name' => 'Affiliates'],
                ['name' => 'Support', 'children' => [
                    ['name' => 'Contact Us'],
                    ['name' => '', 'divider' => true],
                    ['name' => 'Network Status'],
                    ['name' => 'Knowledgebase'],
                    ['name' => 'News'],
                ]],
                ['name' => 'Register',  'badge' => 'Right'],
                ['name' => 'Login',     'badge' => 'Right'],
                ['name' => 'Language',  'badge' => 'Right'],
            ],
        ]);
    }
}
