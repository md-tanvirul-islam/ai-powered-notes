<?php

namespace App\Helpers;

class Csrf
{
    public static function generateToken(): string
    {
        if (!isset($_SESSION)) {
            session_start();
        }

        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }

        return $_SESSION['csrf_token'];
    }

    public static function validateToken(?string $token): bool
    {
        if (!isset($_SESSION)) {
            session_start();
        }

        return hash_equals($_SESSION['csrf_token'] ?? '', $token ?? '');
    }
}
