// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  // Products(this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    fetchAndSetProducts();
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> toggleFavoriteStatus(String id) async {
    int index = _items.indexWhere((element) {
      return element.id == id;
    });
    // final oldStatus = isFavorite;
    // isFavorite = !isFavorite;
    _items[index].isFavorite = !_items[index].isFavorite;

    // final url =
    //     'https://simran-s-shop-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      // final response = await http.put(
      //   url,
      //   body: json.encode(
      //     isFavorite,
      //   ),
      // );
      User user = FirebaseAuth.instance.currentUser;
      if (_items[index].isFavorite)
        await FirebaseFirestore.instance.collection('products').doc(id).update({
          'favourites': FieldValue.arrayUnion([user.uid])
        });
      else
        await FirebaseFirestore.instance.collection('products').doc(id).update({
          'favourites': FieldValue.arrayRemove([user.uid])
        });

      notifyListeners();
      // document
      // if (response.statusCode >= 400) {
      //   _setFavValue(oldStatus);
      //   // }
      // } catch (error) {
      //   _setFavValue(oldStatus);
      // }

    } catch (e) {}
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // var url =
    //     'https://simran-s-shop-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      // final response = await http.get(url);
      final List<Product> loadedProducts = [];
      User user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('products')
          .get()
          .then((value) {
        value.docs.forEach((prodData) {
          loadedProducts.add(
            Product(
              id: prodData['id'],
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              isFavorite:
                  prodData['favourites'].contains(user.uid) ? true : false,
              imageUrl: prodData['imageUrl'],
              creatorId: prodData['creatorId'],
            ),
          );
        });
      });

      // if (extractedData == null) {
      //   return;
      // }

      // FirebaseFirestore.instance.collection('users').doc(user.uid);
      // url =
      //     'https://simran-s-shop-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      // final favoriteResponse = await http.get(url);
      // final favoriteData = json.decode(favoriteResponse.body);
      // extractedData.forEach((prodData) {
      //   loadedProducts.add(
      //     Product(
      //       id: prodData['id'],
      //       title: prodData['title'],
      //       description: prodData['description'],
      //       price: prodData['price'],
      //       isFavorite:
      //           prodData['favourites'].contains(user.uid) ? true : false,
      //       imageUrl: prodData['imageUrl'],
      //     ),
      //   );
      // });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  List<Product> fetchUserProducts() {
    User user = FirebaseAuth.instance.currentUser;
    return _items.where((element) => element.creatorId == user.uid).toList();
  }

  Future<void> addProduct(Product product) async {
    // final url =
    //     'https://simran-s-shop-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      // final response = await http.post(
      //   url,
      //   body: json.encode({
      //     'title': product.title,
      //     'description': product.description,
      //     'imageUrl': product.imageUrl,
      //     'price': product.price,
      //     'id': userId,
      //     // 'isFavorite': product.isFavorite,
      //   }),
      // );
      User user = FirebaseAuth.instance.currentUser;
      DocumentReference document =
          FirebaseFirestore.instance.collection('products').doc();
      document.set({
        'id': document.id,
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId': user.uid,
        'favourites': [],
      });

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: document.id,
        isFavorite: false,
        creatorId: user.uid,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      //   final url =
      //       'https://simran-s-shop-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      //   await http.patch(url,
      //       body: json.encode({
      //         'title': newProduct.title,
      //         'description': newProduct.description,
      //         'imageUrl': newProduct.imageUrl,
      //         'price': newProduct.price
      //       }));

      // User user = FirebaseAuth.instance.currentUser;
      DocumentReference document =
          FirebaseFirestore.instance.collection('products').doc(id);
      document.update({
        // 'id': document.id,
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
        // 'creatorId': user.uid,
        // 'favourites': [],
      });

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    // final url =
    //     'https://simran-s-shop-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    try {
      FirebaseFirestore.instance.collection('products').doc(id).delete();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref(existingProduct.imageUrl);
      await firebaseStorageRef.delete();
      _items.removeAt(existingProductIndex);
      notifyListeners();
    } catch (e) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      print(e);
    }

    // final response = await http.delete(url);
    // if (response.statusCode >= 400) {
    //   throw HttpException('Could not delete product.');
    // }
    existingProduct = null;
  }
}
