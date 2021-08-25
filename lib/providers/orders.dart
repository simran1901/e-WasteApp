// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  // Orders(this._orders);

  List<OrderItem> get orders {
    fetchAndSetOrders();
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    // final url =
    //     'https://simran-s-shop-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    // final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    // final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // if (extractedData == null) {
    //     return;
    //   }
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .get()
        .then((value) {
      value.docs.forEach((orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderData['id'],
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      price: item['price'],
                      quantity: item['quantity'],
                      title: item['title'],
                    ))
                .toList(),
          ),
        );
      });
    });
    // extractedData.forEach((orderId, orderData) {});
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // final url =
    //     'https://simran-s-shop-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    // final response = await http.post(
    //   url,
    //   body: json.encode({
    //     'amount': total,
    //     'dateTime': timestamp.toIso8601String(),
    //     'products': cartProducts
    //         .map((cp) => {
    //               'id': cp.id,
    //               'title': cp.title,
    //               'quantity': cp.quantity,
    //               'price': cp.price,
    //             })
    //         .toList(),
    //   }),
    // );
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc();
    await doc.set({
      'id': doc.id,
      'amount': total,
      'dateTime': timestamp.toIso8601String(),
      'products': cartProducts
          .map((cp) => {
                'id': cp.id,
                'title': cp.title,
                'quantity': cp.quantity,
                'price': cp.price,
              })
          .toList(),
    });
    _orders.insert(
      0,
      OrderItem(
        id: doc.id,
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
