// import 'package:e_waste_app/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(builder: (ctx, productsData, _) {
                      var userItems = productsData.fetchUserProducts();
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: userItems.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductItem(
                                userItems[i].id,
                                userItems[i].title,
                                userItems[i].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
      ),
    );
  }
}
