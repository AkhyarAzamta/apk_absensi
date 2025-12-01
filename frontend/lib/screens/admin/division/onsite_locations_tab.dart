// lib/screens/admin/division/onsite_locations_tab.dart
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/onsite_location_model.dart';
import 'package:apk_absensi/services/onsite_location_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';
import 'package:apk_absensi/models/division_model.dart';

class OnsiteLocationsTab extends StatefulWidget {
  final String division;

  const OnsiteLocationsTab({Key? key, required this.division})
    : super(key: key);

  @override
  State<OnsiteLocationsTab> createState() => _OnsiteLocationsTabState();
}

class _OnsiteLocationsTabState extends State<OnsiteLocationsTab> {
  List<OnsiteLocation> _locations = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final locations = await OnsiteLocationService.getAllLocations();

      if (!mounted) return;

      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddLocationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationFormDialog(division: widget.division),
    );

    if (result != null) {
      await _createLocation(result);
    }
  }

  Future<void> _showEditLocationDialog(OnsiteLocation location) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          LocationFormDialog(division: widget.division, location: location),
    );

    if (result != null) {
      await _updateLocation(location.id, result);
    }
  }

  // ✅ TAMBAHKAN: Method _createLocation yang hilang
  Future<void> _createLocation(Map<String, dynamic> data) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await OnsiteLocationService.createLocation(data);
      await _loadLocations();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ TAMBAHKAN: Method _updateLocation yang hilang
  Future<void> _updateLocation(int id, Map<String, dynamic> data) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await OnsiteLocationService.updateLocation(id, data);
      await _loadLocations();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ TAMBAHKAN: Method _toggleLocationStatus yang hilang
  Future<void> _toggleLocationStatus(int id, bool currentStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await OnsiteLocationService.toggleLocationStatus(id);
      await _loadLocations();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lokasi berhasil ${!currentStatus ? 'diaktifkan' : 'dinonaktifkan'}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ TAMBAHKAN: Method _deleteLocation yang hilang
  Future<void> _deleteLocation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus lokasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        await OnsiteLocationService.deleteLocation(id);
        await _loadLocations();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildLocationCard(OnsiteLocation location) {
    final division = DivisionHelper.fromString(location.division);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: division.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(division.icon, color: division.color, size: 20),
        ),
        title: Text(
          location.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: location.isActive ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.address),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: division.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: division.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    division.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: division.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  location.isActive ? Icons.check_circle : Icons.remove_circle,
                  size: 12,
                  color: location.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  location.isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    fontSize: 10,
                    color: location.isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Koordinat: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Radius: ${location.radius} meter',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditLocationDialog(location),
            ),
            IconButton(
              icon: Icon(
                location.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: location.isActive ? Colors.green : Colors.grey,
              ),
              onPressed: () =>
                  _toggleLocationStatus(location.id, location.isActive),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteLocation(location.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada lokasi untuk divisi ${widget.division}',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddLocationDialog,
            icon: const Icon(Icons.add_location),
            label: const Text('Tambah Lokasi Pertama'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLocations,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Lokasi Onsite - ${widget.division}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddLocationDialog,
                icon: const Icon(Icons.add_location),
                label: const Text('Tambah Lokasi'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _locations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLocations,
                  child: ListView.builder(
                    itemCount: _locations.length,
                    itemBuilder: (context, index) =>
                        _buildLocationCard(_locations[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

class LocationFormDialog extends StatefulWidget {
  final String division;
  final OnsiteLocation? location;

  const LocationFormDialog({Key? key, required this.division, this.location})
    : super(key: key);

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();

  Division _selectedDivision = Division.ONSITE;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.location != null) {
      _selectedDivision = DivisionHelper.fromString(widget.location!.division);
      _nameController.text = widget.location!.name;
      _addressController.text = widget.location!.address;
      _latitudeController.text = widget.location!.latitude.toString();
      _longitudeController.text = widget.location!.longitude.toString();
      _radiusController.text = widget.location!.radius.toString();
      _isActive = widget.location!.isActive;
    } else {
      _selectedDivision = DivisionHelper.fromString(widget.division);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.location == null ? 'Tambah Lokasi' : 'Edit Lokasi'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Division>(
                value: _selectedDivision,
                decoration: const InputDecoration(
                  labelText: 'Divisi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: Division.values.map((Division division) {
                  return DropdownMenuItem<Division>(
                    value: division,
                    child: Row(
                      children: [
                        Icon(division.icon, color: division.color, size: 20),
                        const SizedBox(width: 8),
                        Text(division.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Division? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDivision = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih divisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lokasi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lokasi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.explore),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Latitude harus diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Latitude harus angka';
                        }
                        final lat = double.parse(value);
                        if (lat < -90 || lat > 90) {
                          return 'Latitude harus antara -90 sampai 90';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.explore),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Longitude harus diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Longitude harus angka';
                        }
                        final lng = double.parse(value);
                        if (lng < -180 || lng > 180) {
                          return 'Longitude harus antara -180 sampai 180';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(
                  labelText: 'Radius (meter)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.radar),
                  suffixText: 'meter',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Radius harus diisi';
                  }
                  final radius = int.tryParse(value);
                  if (radius == null) {
                    return 'Radius harus angka';
                  }
                  if (radius < 5 || radius > 5000) {
                    return 'Radius harus antara 5-5000 meter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (widget.location != null)
                SwitchListTile(
                  title: const Text('Aktif'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'address': _addressController.text,
                'latitude': double.parse(_latitudeController.text),
                'longitude': double.parse(_longitudeController.text),
                'radius': int.parse(_radiusController.text),
                'division': _selectedDivision.label,
                'isActive': _isActive,
              });
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
