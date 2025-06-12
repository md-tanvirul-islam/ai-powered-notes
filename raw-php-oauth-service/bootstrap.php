<?php

require_once __DIR__ . '/vendor/autoload.php';

use Dotenv\Dotenv;

$dotenv = Dotenv::createImmutable(__DIR__);
$dotenv->safeLoad();

$services = require __DIR__ . '/bootstrap/services.php';
$twig = $services['twig'];

$routes = require __DIR__ . '/routes/web.php';

$requestUri = strtok($_SERVER['REQUEST_URI'], '?');
$requestMethod = $_SERVER['REQUEST_METHOD'];
$routeKey = "$requestMethod $requestUri";

if (!isset($routes[$routeKey])) {
    http_response_code(404);
    echo $twig->render('errors/404.twig');
    exit;
}

[$controllerClass, $method] = $routes[$routeKey];

// echo "<pre>";
// echo var_dump($routeKey);
// echo var_dump($controllerClass);
// echo var_dump($method);
// echo "</pre>";

$controller = new $controllerClass($twig);
echo call_user_func([$controller, $method]);
