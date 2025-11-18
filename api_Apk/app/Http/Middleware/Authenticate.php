<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
protected function redirectTo($request)
{
    // Untuk API, jangan redirect
    if ($request->is('api/*')) {
        abort(401, 'Unauthenticated');
    }

    return route('login'); // untuk web
}

}
