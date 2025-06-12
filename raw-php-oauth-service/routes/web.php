<?php

use App\Controllers\AuthController;

return [
    'GET /' => [AuthController::class, 'index'],
    'GET /google/login' => [AuthController::class, 'googleLogin'],
    'POST /google/login' => [AuthController::class, 'handleGoogleLogin'],
    'GET /google/register' => [AuthController::class, 'googleRegister'],
    'POST /google/register' => [AuthController::class, 'handleGoogleRegister'],
];
