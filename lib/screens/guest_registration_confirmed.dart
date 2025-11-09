import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vaultx_solution/loading/loading.dart';
import 'package:vaultx_solution/widgets/custom_app_bar.dart';

class GuestConfirmationPage extends StatefulWidget {
  final String qrCodeImage;
  
  const GuestConfirmationPage({
    Key? key, 
    required this.qrCodeImage,
  }) : super(key: key);

  @override
  State<GuestConfirmationPage> createState() => _GuestConfirmationPageState();
}

class _GuestConfirmationPageState extends State<GuestConfirmationPage> {
  bool _showQR = false;
  bool _isLoading = false;
  File? _qrImageFile;

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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading
                const Text(
                  'Guest Added!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7D2828), // Maroon/burgundy color
                  ),
                ),
                const SizedBox(height: 40),
                
                // Checkmark image
                Image.asset(
                  'assets/qr_confirm.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.check_circle,
                      size: 120,
                      color: Color(0xFF7D2828),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Generate QR Code Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _showQR = true;
                      _prepareQrImage();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5A3A3), // Pink/rose color
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(200, 45),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: UnderReviewScreen()
                        )
                      : const Text(
                          'Generate QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 30),
                
                // QR Code
                if (_showQR) ...[
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.qrCodeImage.isNotEmpty
                        ? Image.memory(
                            base64Decode(widget.qrCodeImage.split(',').last),
                            width: 180,
                            height: 180,
                          )
                        : Image.asset(
                            'assets/qr.png',
                            width: 180,
                            height: 180,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.qr_code,
                                size: 180,
                                color: Colors.grey,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Share Button
                  ElevatedButton.icon(
                    onPressed: _shareQrCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD5A3A3), // Pink/rose color
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(160, 45),
                    ),
                    icon: Icon(Icons.share),
                    label: const Text(
                      'Share QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _prepareQrImage() async {
    if (widget.qrCodeImage.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Convert base64 to bytes
      final bytes = base64Decode(widget.qrCodeImage.split(',').last);
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/guest_qr_code.png');
      
      // Write bytes to file
      await file.writeAsBytes(bytes);
      
      setState(() {
        _qrImageFile = file;
      });
    } catch (e) {
      print('Error preparing QR image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareQrCode() async {
    if (_qrImageFile == null) {
      await _prepareQrImage();
    }
    
    if (_qrImageFile != null) {
      await Share.shareXFiles(
        [XFile(_qrImageFile!.path)],
        text: 'Guest registration QR code',
        subject: 'VaultX Guest QR Code',
      );
    } else {
      // Fallback if file creation failed
      await Share.share(
        'Guest registration confirmed! Please show this message at the gate.',
        subject: 'VaultX Guest Registration',
      );
    }
  }
}
