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
                'message' => "Email tidak terdaftar di sistem",
                'success' => false,
                'status_code' => 404
            ];
        }

        if(Hash::check($request->password, $user->password)){
            $data = [
                'name' => $user->name,
                'token' => $user->createToken('auth-token')->plainTextToken
            ];

            return [
                'message' => "Login berhasil",
                'success' => true,
                'status_code' => 200,
                'data' => $data
            ];
        }else{
            return[
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
            'message' => "Register berhasil",
            'success' => true,
            'status_code' => 201,
            'data' => $data
        ];
    }
}