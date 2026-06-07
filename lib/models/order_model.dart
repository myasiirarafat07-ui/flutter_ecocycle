int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

String rupiah(num amount) {
  final str = amount.toInt().toString();
  final buffer = StringBuffer();
  var count = 0;
  for (var i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
    count++;
  }
  return 'Rp ${buffer.toString().split('').reversed.join()}';
}

class OrderItem {
  final int productId;
  final String productName;
  final int unitPrice;
  final int quantity;
  final int subtotal;
  final String imageUrl;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        productId: _toInt(j['product_id']),
        productName: j['product_name']?.toString() ?? '',
        unitPrice: _toInt(j['unit_price']),
        quantity: _toInt(j['quantity']),
        subtotal: _toInt(j['subtotal']),
        imageUrl: j['image_url']?.toString() ?? '',
      );
}

class Order {
  final int orderId;
  final String orderCode;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String shippingMethod;
  final String shippingAddress;
  final int subtotal;
  final int shippingCost;
  final int discount;
  final int totalAmount;
  final int itemCount;
  final String firstItem;
  final String buyerName;
  final String createdAt;
  final List<OrderItem> items;

  const Order({
    required this.orderId,
    required this.orderCode,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.subtotal,
    required this.shippingCost,
    required this.discount,
    required this.totalAmount,
    required this.itemCount,
    required this.firstItem,
    required this.buyerName,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        orderId: _toInt(j['order_id']),
        orderCode: j['order_code']?.toString() ?? '',
        orderStatus: j['order_status']?.toString() ?? '',
        paymentStatus: j['payment_status']?.toString() ?? '',
        paymentMethod: j['payment_method']?.toString() ?? '',
        shippingMethod: j['shipping_method']?.toString() ?? '',
        shippingAddress: j['shipping_address']?.toString() ?? '',
        subtotal: _toInt(j['subtotal']),
        shippingCost: _toInt(j['shipping_cost']),
        discount: _toInt(j['discount']),
        totalAmount: _toInt(j['total_amount']),
        itemCount: _toInt(j['item_count']),
        firstItem: j['first_item']?.toString() ?? '',
        buyerName: j['buyer_name']?.toString() ?? '',
        createdAt: j['created_at']?.toString() ?? '',
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String get formattedTotal => rupiah(totalAmount);
}
