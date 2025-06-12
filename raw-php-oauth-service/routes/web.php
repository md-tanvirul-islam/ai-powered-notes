<?php

use App\Controllers\AuthController;

return [
    'GET /login' => [AuthController::class, 'login'],
    'POST /login' => [AuthController::class, 'handleLogin'],
    'GET /register' => [AuthController::class, 'register'],
    'POST /register' => [AuthController::class, 'handleRegister'],
];
