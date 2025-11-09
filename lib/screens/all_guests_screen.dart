import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaultx_solution/models/guest_model.dart';
import 'package:vaultx_solution/screens/guest_registration.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class AllGuestsScreen extends StatefulWidget {
  final List<GuestModel> guests;
  
  const AllGuestsScreen({
    Key? key,
    required this.guests,
  }) : super(key: key);

  @override
  _AllGuestsScreenState createState() => _AllGuestsScreenState();
}

class _AllGuestsScreenState extends State<AllGuestsScreen> {
  List<GuestModel> _filteredGuests = [];
  String _searchQuery = '';
  String _filterOption = 'All'; // 'All', 'Upcoming', 'Past'
  
  @override
  void initState() {
    super.initState();
    _filteredGuests = widget.guests;
  }
  
  void _filterGuests() {
    setState(() {
      _filteredGuests = widget.guests.where((guest) {
        // Apply search filter
        final nameMatches = guest.guestName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Apply status filter
        bool statusMatches = true;
        if (_filterOption == 'Upcoming') {
          statusMatches = guest.eta.isAfter(DateTime.now());
        } else if (_filterOption == 'Past') {
          statusMatches = guest.eta.isBefore(DateTime.now());
        }
        
        return nameMatches && statusMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(
          showBackButton: true,
          actions: [],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'All Guests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF600f0f),
              ),
            ),
          ),
          
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search guests...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFFE57373)),
                      filled: true,
                      fillColor: Color(0xFFFFF1ED),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterGuests();
                      });
                    },
                  ),
                ),
                
                // Filter dropdown
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: Color(0xFFE57373)),
                  onSelected: (value) {
                    setState(() {
                      _filterOption = value;
                      _filterGuests();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'All',
                      child: Text('All Guests'),
                    ),
                    PopupMenuItem(
                      value: 'Upcoming',
                      child: Text('Upcoming Visits'),
                    ),
                    PopupMenuItem(
                      value: 'Past',
                      child: Text('Past Visits'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('All'),
                  selected: _filterOption == 'All',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filterOption = 'All';
                        _filterGuests();
                      });
                    }
                  },
                  backgroundColor: Color(0xFFFFF1ED),
                  selectedColor: Color(0xFFE57373).withOpacity(0.2),
                  checkmarkColor: Color(0xFFE57373),
                ),
                FilterChip(
                  label: Text('Upcoming'),
                  selected: _filterOption == 'Upcoming',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filterOption = 'Upcoming';
                        _filterGuests();
                      });
                    }
                  },
                  backgroundColor: Color(0xFFFFF1ED),
                  selectedColor: Color(0xFFE57373).withOpacity(0.2),
                  checkmarkColor: Color(0xFFE57373),
                ),
                FilterChip(
                  label: Text('Past'),
                  selected: _filterOption == 'Past',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filterOption = 'Past';
                        _filterGuests();
                      });
                    }
                  },
                  backgroundColor: Color(0xFFFFF1ED),
                  selectedColor: Color(0xFFE57373).withOpacity(0.2),
                  checkmarkColor: Color(0xFFE57373),
                ),
              ],
            ),
          ),
          
          // Guest list
          Expanded(
            child: _filteredGuests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No guests found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GuestRegistrationForm(),
                              ),
                            ).then((_) => Navigator.pop(context));
                          },
                          icon: Icon(Icons.person_add),
                          label: Text('Add Guest'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD6A19F),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredGuests.length,
                    itemBuilder: (context, index) {
                      final guest = _filteredGuests[index];
                      return _buildGuestCard(guest);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GuestRegistrationForm(),
            ),
          ).then((_) => Navigator.pop(context));
        },
        backgroundColor: Color(0xFFD6A19F),
        child: Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildGuestCard(GuestModel guest) {
    final now = DateTime.now();
    final isUpcoming = guest.eta.isAfter(now);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFD6A19F),
                  child: Text(
                    guest.guestName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.guestName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy - hh:mm a').format(guest.eta),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Past',
                    style: TextStyle(
                      color: isUpcoming ? Colors.green.shade800 : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            // Vehicle info if available
            if (guest.vehicleId != null) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Vehicle:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${guest.vehicleModel ?? "Unknown"} (${guest.vehicleLicensePlateNumber ?? "No plate"})',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (guest.vehicleColor != null) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(width: 24),
                    Text(
                      'Color:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColorFromName(guest.vehicleColor!),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      guest.vehicleColor!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getColorFromName(String colorName) {
    // Simple mapping of color names to Color objects
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'silver':
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      default:
        return Color(0xFF600f0f); // Default color
    }
  }
}
