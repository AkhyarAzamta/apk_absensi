<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;

class UserController extends Controller
{
    // GET Semua Karyawan
    public function index()
    {
        $users = User::where('role_id', '!=', 1)->get(); // kecuali admin
        return response()->json($users);
    }

    // GET Detail Karyawan
    public function show($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }
        return response()->json($user);
    }

    // POST Membuat Karyawan Baru
    public function store(Request $request)
    {
        $request->validate([
            'name'        => 'required',
            'email'       => 'required|email|unique:users,email',
            'password'    => 'required|min:6',
            'role_id'     => 'required|integer',
            'division_id' => 'nullable|integer',
            'photo'       => 'nullable|string', // menerima base64
        ]);

        $user = User::create([
            'name'        => $request->name,
            'email'       => $request->email,
            'password'    => Hash::make($request->password),
            'role_id'     => $request->role_id,
            'division_id' => $request->division_id ?? null,
            'photo'       => $request->photo ?? null,
            'is_active'   => 1,
        ]);

        return response()->json([
            'message' => 'User created successfully',
            'user'    => $user
        ], 201);
    }


    public function registerFace(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|max:5120',
        ]);

        $user = $request->user();
        $path = $request->file('photo')->store('faces', 'public');

        // Kirim foto ke Python/OpenCV service untuk generate embedding
        $response = Http::attach(
            'photo', file_get_contents(storage_path('app/public/' . $path)), basename($path)
        )->post('http://localhost:5000/generate-embedding', [
            'user_id' => $user->id
        ]);

        $embedding = $response->json()['embedding'] ?? null;

        if ($embedding) {
            $user->face_vector = json_encode($embedding);
            $user->save();

            return response()->json([
                'message' => 'Wajah berhasil didaftarkan',
                'user' => $user
            ]);
        }

        return response()->json(['message' => 'Gagal mendaftarkan wajah'], 500);
    }


    // PUT UPDATE Karyawan
   public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) return response()->json(['message' => 'User not found'], 404);

        $request->validate([
            'name'        => 'required',
            'email'       => 'required|email|unique:users,email,' . $id,
            'division_id' => 'nullable|integer',
            'photo'       => 'nullable|string',
            'is_active'   => 'nullable|boolean',
        ]);

        if ($request->password) {
            $user->password = Hash::make($request->password);
        }

        $user->name        = $request->name;
        $user->email       = $request->email;
        $user->division_id = $request->division_id;
        $user->photo       = $request->photo ?? $user->photo;
        $user->is_active   = $request->is_active ?? $user->is_active;

        $user->save();

        return response()->json([
            'message' => 'User updated successfully',
            'user'    => $user
        ]);
    }


    // DELETE Hapus Karyawan
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) return response()->json(['message' => 'User not found'], 404);

        $user->delete();

        return response()->json(['message' => 'User deleted successfully']);
    }
}
