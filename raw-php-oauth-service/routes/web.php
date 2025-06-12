<?php

use App\Controllers\AuthController;

return [
    'GET oauth/google/login' => [AuthController::class, 'googleLogin'],
    'POST oauth/google/login' => [AuthController::class, 'handleGoogleLogin'],
    'GET oauth/google/login' => [AuthController::class, 'googleRegister'],
    'POST oauth/google/register' => [AuthController::class, 'handleGoogleRegister'],
];
