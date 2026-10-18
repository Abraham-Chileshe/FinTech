<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecurityHeadersMiddleware
{
    /**
     * Handle an incoming request and enforce enterprise fintech security headers.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // 1. Prevent Clickjacking & Framing
        $response->headers->set('X-Frame-Options', 'DENY');

        // 2. Prevent MIME Sniffing attacks
        $response->headers->set('X-Content-Type-Options', 'nosniff');

        // 3. Disable Legacy Insecure XSS Auditor (modern OWASP standard)
        $response->headers->set('X-XSS-Protection', '0');

        // 4. Strict Referrer Policy
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');

        // 5. Restrict Unused Hardware & Browser Features
        $response->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=(), payment=()');

        // 6. Content Security Policy: Prevent Framing
        $response->headers->set('Content-Security-Policy', "frame-ancestors 'none';");

        // 7. Ephemeral Data Guarantee: Prevent proxy/browser disk caching of sensitive SMS queries
        if ($request->is('api/*')) {
            $response->headers->set('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0');
            $response->headers->set('Pragma', 'no-cache');
        }

        return $response;
    }
}
