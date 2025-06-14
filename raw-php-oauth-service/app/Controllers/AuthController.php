<?php

namespace App\Controllers;

use Twig\Environment;

class AuthController
{
    protected Environment $twig;

    public function __construct(Environment $twig)
    {
        $this->twig = $twig;
    }

    public function index(){
        header("Location: /google/login");
        exit;
    }

    public function googleLogin()
    {
        return $this->twig->render('auth/login.twig');
    }

    public function handleGoogleLogin()
    {
        if (!Csrf::validateToken($_POST['csrf_token'] ?? '')) {
            http_response_code(403);
            return $this->twig->render('errors/403.twig', [
            'message' => 'Invalid CSRF token'
            ]);
        }

        // Simulate validation
        $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);
        $password = $_POST['password'] ?? '';

        // TODO: check credentials against DB securely

        return $this->twig->render('auth/login.twig', [
            'message' => 'Login successful!'
        ]);
    }

    public function googleregister()
    {
        return $this->twig->render('auth/register.twig');
    }

    public function handleGoogleRegister()
    {
        return $this->twig->render('auth/register.twig', [
            'message' => 'Registered successfully!'
        ]);
    }
}
