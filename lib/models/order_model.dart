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
  final bool reviewed;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    required this.imageUrl,
    this.reviewed = false,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: _toInt(j['product_id']),
    productName: j['product_name']?.toString() ?? '',
    unitPrice: _toInt(j['unit_price']),
    quantity: _toInt(j['quantity']),
    subtotal: _toInt(j['subtotal']),
    imageUrl: j['image_url']?.toString() ?? '',
    reviewed: j['reviewed'] == true || j['reviewed'] == 1,
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
  final int totalAmount;
  final int itemCount;
  final String firstItem;
  final String buyerName;
  final String createdAt;
  final bool isBuyer;
  final bool isSeller;
  final bool needsReview;
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
    required this.totalAmount,
    required this.itemCount,
    required this.firstItem,
    required this.buyerName,
    required this.createdAt,
    this.isBuyer = false,
    this.isSeller = false,
    this.needsReview = false,
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
    totalAmount: _toInt(j['total_amount']),
    itemCount: _toInt(j['item_count']),
    firstItem: j['first_item']?.toString() ?? '',
    buyerName: j['buyer_name']?.toString() ?? '',
    createdAt: j['created_at']?.toString() ?? '',
    isBuyer: j['is_buyer'] == true || j['is_buyer'] == 1,
    isSeller: j['is_seller'] == true || j['is_seller'] == 1,
    needsReview: j['needs_review'] == true || j['needs_review'] == 1,
    items: (j['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  String get formattedTotal => rupiah(totalAmount);
}
