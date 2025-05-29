class Ticket {
  final String id;
  final String title;
  final String category;
  final int price;
  final bool isAvailable;

  Ticket({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.isAvailable,
  });

  factory Ticket.fromMap(Map<String, dynamic> map, String id) {
    return Ticket(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      price: map['price'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}

class Purchase {
  final String id;
  final String ticketId;
  final String ticketTitle;
  final int price;
  final String customerName;
  final DateTime purchaseDate;
  final String paymentMethod;

  Purchase({
    required this.id,
    required this.ticketId,
    required this.ticketTitle,
    required this.price,
    required this.customerName,
    required this.purchaseDate,
    required this.paymentMethod,
  });

  factory Purchase.fromMap(Map<String, dynamic> map, String id) {
    return Purchase(
      id: id,
      ticketId: map['ticketId'] ?? '',
      ticketTitle: map['ticketTitle'] ?? '',
      price: map['price'] ?? 0,
      customerName: map['customerName'] ?? '',
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate'] ?? 0),
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'ticketTitle': ticketTitle,
      'price': price,
      'customerName': customerName,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
    };
  }
}