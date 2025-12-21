import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultx_solution/models/residence_model.dart';
import 'package:vaultx_solution/services/api_service.dart';

class ResidenceSelectorWidget extends StatefulWidget {
  final Function(ResidenceModel)? onResidenceChanged;

  const ResidenceSelectorWidget({
    Key? key,
    this.onResidenceChanged,
  }) : super(key: key);

  @override
  State<ResidenceSelectorWidget> createState() => _ResidenceSelectorWidgetState();
}

class _ResidenceSelectorWidgetState extends State<ResidenceSelectorWidget> {
  final ApiService _apiService = ApiService();
  
  List<ResidenceModel> _residences = [];
  ResidenceModel? _selectedResidence;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResidences();
  }

  Future<void> _loadResidences() async {
    setState(() => _isLoading = true);

    try {
      final residences = await _apiService.getResidences();
      
      // Load saved selection or use primary
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('selected_residence_id');
      
      ResidenceModel? selected;
      if (savedId != null) {
        selected = residences.firstWhere(
          (r) => r.id == savedId,
          orElse: () => residences.firstWhere((r) => r.isPrimary),
        );
      } else {
        selected = residences.firstWhere((r) => r.isPrimary);
      }

      setState(() {
        _residences = residences;
        _selectedResidence = selected;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading residences: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectResidence(ResidenceModel residence) async {
    setState(() => _selectedResidence = residence);
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_residence_id', residence.id);
    
    // Notify parent
    widget.onResidenceChanged?.call(residence);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_selectedResidence == null || _residences.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Residence Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D0A0A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.home,
                  color: Color(0xFF2D0A0A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Residence Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedResidence!.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (_selectedResidence!.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (_selectedResidence!.isPrimary) const SizedBox(width: 6),
                        Text(
                          '${_selectedResidence!.guestCount ?? 0} Guests · ${_selectedResidence!.vehicleCount ?? 0} Vehicles',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch Residence Button (only if multiple residences)
                  if (_residences.length > 1)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: 'Switch Residence',
                      onPressed: _showResidencePicker,
                    ),

                  // Refresh Button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: _loadResidences,
                  ),
                ],
              ),
            ],
          ),
        );
  }

  void _showResidencePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch Residence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._residences.map((residence) {
              final isSelected = residence.id == _selectedResidence?.id;
              return ListTile(
                leading: Icon(
                  Icons.home,
                  color: isSelected ? const Color(0xFF2D0A0A) : Colors.grey,
                ),
                title: Text(
                  residence.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  residence.isPrimary ? 'Primary Residence' : residence.address,
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                selected: isSelected,
                onTap: () async {
                  await _selectResidence(residence);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Helper method to get currently selected residence
  static Future<String?> getSelectedResidenceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_residence_id');
  }

  // Helper method to get selected residence model
  Future<ResidenceModel?> getSelectedResidence() async {
    if (_selectedResidence != null) return _selectedResidence;
    
    final residenceId = await getSelectedResidenceId();
    if (residenceId == null) return null;
    
    try {
      return await _apiService.getResidenceDetails(residenceId);
    } catch (e) {
      debugPrint('Error getting residence: $e');
      return null;
    }
  }
}