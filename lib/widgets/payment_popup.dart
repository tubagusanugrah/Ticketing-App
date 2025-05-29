import 'package:flutter/material.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Payment Method Icon and Title
            _buildPaymentMethodHeader(),
            
            SizedBox(height: 24),
            
            // Payment Details
            _buildPaymentDetails(),
            
            SizedBox(height: 32),
            
            // Confirm Button
            Container(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _confirmPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
    );
  }

  Widget _buildPaymentMethodHeader() {
    IconData icon;
    Color color;
    String title;

    switch (paymentMethod) {
      case 'Tunai (Cash)':
        icon = Icons.money;
        color = Color(0xFF10B981);
        title = 'Pembayaran Tunai';
        break;
      case 'Kartu Kredit':
        icon = Icons.credit_card;
        color = Color(0xFFF59E0B);
        title = 'Transfer Pembayaran';
        break;
      case 'QRIS / QR Pay':
        icon = Icons.qr_code;
        color = Color(0xFF3B82F6);
        title = 'Scan QR untuk Membayar';
        break;
      default:
        icon = Icons.payment;
        color = Color(0xFF4F46E5);
        title = 'Pembayaran';
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            icon,
            color: color,
            size: 40,
          ),
        ),
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        if (paymentMethod == 'Kartu Kredit') ...[
          SizedBox(height: 8),
          Text(
            '8810 7769 1234 5678',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
        if (paymentMethod == 'QRIS / QR Pay') ...[
          SizedBox(height: 16),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Icon(
                Icons.qr_code,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (paymentMethod == 'Tunai (Cash)') ...[
            Text(
              'Jika pembayaran telah diterima, klik\ntombol konfirmasi untuk bantuan\nmenyelesaikan transaksi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ] else if (paymentMethod == 'Kartu Kredit') ...[
            Text(
              'Transfer kepada rekening kami berikut\nuntuk menyelesaikan proses\npembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ] else if (paymentMethod == 'QRIS / QR Pay') ...[
            Text(
              'Gunakan aplikasi yang dapat membaca\nkode QR (QRIS) untuk melakukan\npembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          
          SizedBox(height: 12),
          
          Row(
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
          ),
        ],
      ),
    );
  }

  void _confirmPayment(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Create purchase record
    Purchase purchase = Purchase(
      id: '',
      ticketId: ticket.id,
      ticketTitle: ticket.title,
      price: ticket.price,
      customerName: customerName,
      purchaseDate: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    // Save to Firebase
    String? purchaseId = await FirebaseService.addPurchase(purchase);

    // Close loading dialog
    Navigator.pop(context);

    if (purchaseId != null) {
      // Close payment popup
      Navigator.pop(context);
      
      // Navigate to receipt screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(purchaseId: purchaseId),
        ),
      );
    } else {
      // Show error
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
      (Match m) => '${m[1]}.',
    );
  }
}