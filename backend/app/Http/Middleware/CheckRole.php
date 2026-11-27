<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request for Role-Based Access Control (RBAC).
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Sesi habis. Silakan login kembali.',
            ], 401);
        }

        $userRole = strtolower($user->role ?? 'operator');

        if (!in_array($userRole, array_map('strtolower', $roles))) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses ditolak. Anda tidak memiliki izin untuk melakukan tindakan ini.',
            ], 403);
        }

        return $next($request);
    }
}
