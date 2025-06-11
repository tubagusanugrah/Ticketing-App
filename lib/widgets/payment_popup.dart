import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ticket.dart';
import '../services/firebase_service.dart';
import '../screens/receipt_screen.dart';

class PaymentPopup extends StatelessWidget {
  final Ticket ticket;
  final String customerName;
  final String paymentMethod;

  PaymentPopup({
    required this.ticket,
    required this.customerName,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                _buildHeader(),
                SizedBox(height: 16),
                _buildDescription(),
                SizedBox(height: 20),
                _buildTotal(),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _confirmPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tombol Close (Back)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String assetPath;
    String title;

    switch (paymentMethod) {
      case 'Tunai (Cash)':
        assetPath = 'assets/images/QR.png';
        title = 'Pembayaran Tunai';
        break;
      case 'Kartu Kredit':
        assetPath = 'assets/images/6963703 1.png';
        title = 'Pembayaran Kartu Kredit';
        break;
      case 'QRIS / QR Pay':
        assetPath = 'assets/images/QR (1).png';
        title = 'Pembayaran QRIS';
        break;
      default:
        assetPath = 'assets/images/default_payment.png';
        title = 'Pembayaran';
    }

    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F46E5),
          ),
        ),
        if (paymentMethod == 'Kartu Kredit') ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '8810 7769 1234 9876',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '8810776912349876'));
                  },
                  child: Icon(Icons.copy, size: 16, color: Color(0xFF4F46E5)),
                )
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    String description;

    switch (paymentMethod) {
      case 'Tunai (Cash)':
        description =
            'Jika pembayaran telah diterima, klik tombol konfirmasi pembayaran untuk menyelesaikan transaksi.';
        break;
      case 'Kartu Kredit':
        description =
            'Pastikan nominal dan tujuan transfer sudah benar sebelum melakukan pembayaran.';
        break;
      case 'QRIS / QR Pay':
        description =
            'Gunakan aplikasi e-wallet atau mobile banking untuk scan QR di atas dan selesaikan pembayaran.';
        break;
      default:
        description = '';
    }

    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          'Rp ${_formatPrice(ticket.price)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }

  void _confirmPayment(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    Purchase purchase = Purchase(
      id: '',
      ticketId: ticket.id,
      ticketTitle: ticket.title,
      price: ticket.price,
      customerName: customerName,
      purchaseDate: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    String? purchaseId = await FirebaseService.addPurchase(purchase);

    Navigator.pop(context); // Remove loading
    if (purchaseId != null) {
      Navigator.pop(context); // Close dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(purchaseId: purchaseId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pembayaran. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
