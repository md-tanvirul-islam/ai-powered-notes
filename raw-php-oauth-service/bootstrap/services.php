<?php

use App\Helpers\Csrf;
use Twig\Environment;
use Twig\Loader\FilesystemLoader;

$loader = new FilesystemLoader(__DIR__ . '/../views');
$twig = new Environment($loader, [
    'cache' => false,
    'autoescape' => 'html',
]);

// Make CSRF token available globally
$twig->addGlobal('csrf_token', Csrf::generateToken());

return [
    'twig' => $twig
];
