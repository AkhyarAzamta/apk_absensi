<?php

namespace App\Http\Controllers;

use App\Models\DivisionSetting;
use Illuminate\Http\Request;

class DivisionSettingController extends Controller
{
    public function index()
    {
        return DivisionSetting::all();
    }

    public function show($id)
    {
        return DivisionSetting::findOrFail($id);
    }

    public function store(Request $r)
    {
        $data = $r->validate([
            'division_id' => 'required|integer|unique:division_settings',
            'work_start' => 'required',
            'work_end' => 'required',
            'grace_minutes' => 'required|integer',
            'penalty_per_minute' => 'required|numeric',
            'radius_meters' => 'required|numeric',
            'office_lat' => 'required|numeric',
            'office_lng' => 'required|numeric',
        ]);

        $setting = DivisionSetting::create($data);

        return response()->json(['message' => 'Division setting created', 'data' => $setting]);
    }

    public function update(Request $r, $id)
    {
        $setting = DivisionSetting::findOrFail($id);

        $setting->update($r->all());

        return response()->json(['message' => 'Division setting updated', 'data' => $setting]);
    }

    public function destroy($id)
    {
        DivisionSetting::destroy($id);

        return response()->json(['message' => 'Division setting deleted']);
    }

    public function getByDivision($division_id)
    {
        $setting = DivisionSetting::where('division_id', $division_id)->first();

        if (!$setting) {
            return response()->json([
                'status' => false,
                'message' => 'Division setting not found'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'data' => $setting
        ]);
    }
}
