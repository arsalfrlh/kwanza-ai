<?php
namespace App\Services;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function login(Request $request){
        $user = User::where('email', $request->email)->first();
        if(!$user){
            return [
                'message' => "Akun anda tidak terdaftar di sistem",
                'success' => false,
                'status_code' => 401,
            ];
        }

        if(Hash::check($request->password, $user->password)){
            $data = [
                'name' => $user->name,
                'token' => $user->createToken('auth-token')->plainTextToken
            ];
            return [
                'message' => "Login berhasil, Selamat datang " . $user->name,
                'success' => true,
                'status_code' => 200,
                'data' => $data
            ];
        }else{
            return [
                'message' => "Password anda salah",
                'success' => false,
                'status_code' => 401
            ];
        }
    }

    public function register(Request $request){
        $user = User::create($request->only(['name','email','password']));
        $data = [
            'name' => $user->name,
            'token' => $user->createToken('auth-token')->plainTextToken
        ];

        return [
            'message' => "Register berhasil, Selamat datang " . $user->name,
            'success' => true,
            'status_code' => 201,
            'data' => $data
        ];
    }

    public function logout(Request $request){
        $request->user()->tokens()->delete();
        return [
            'message' => "Anda telah logout",
            'success' => true,
            'status_code' => 200
        ];
    }
}