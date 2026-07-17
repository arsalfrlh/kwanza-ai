<?php

use App\Http\Controllers\AuthApiController;
use App\Http\Controllers\MessageApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Broadcast::routes(['middleware' => ['auth:sanctum']]);
Route::middleware(['auth:sanctum'])->group(function(){
    Route::apiResource('/message',MessageApiController::class);
    Route::post('/logout',[AuthApiController::class,'logout']);
});

Route::post('/login',[AuthApiController::class,'login']);
Route::post('/register',[AuthApiController::class,'register']);