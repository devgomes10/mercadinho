import 'package:flutter/material.dart';
import '../../model/product.dart';

class ListTileProduct extends StatelessWidget {
  final Product product;
  final bool isPurchased;
  final Function showModal;

  const ListTileProduct({
    super.key,
    required this.product,
    required this.isPurchased,
    required this.showModal,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModal(model: product);
      },
      leading: Icon(
        (isPurchased) ? Icons.shopping_basket : Icons.check,
      ),
      title: Text(
        (product.amount == null)
            ? product.name
            : "${product.name} (x${product.amount!.toInt()})",
      ),
      subtitle: Text(
        (product.price == null)
            ? "Clique para adicionar preço"
            : "R\$ ${product.price!}",
      ),
    );
  }
}
