import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mercadinho/firestore_produtos/helpers/enum_order.dart';
import 'package:uuid/uuid.dart';
import '../../firestore/models/listin.dart';
import '../model/product.dart';
import 'widgets/list_tile_product.dart';

class ProductScreen extends StatefulWidget {
  final Market market;

  const ProductScreen({super.key, required this.market});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  EnumOrder enumOrder = EnumOrder.name;
  bool isDescending = false;

  List<Product> listPlannedProducts = [];
  List<Product> listCaughtProducts = [];

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.market.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: EnumOrder.name,
                  child: Text("Ordenar por nome"),
                ),
                const PopupMenuItem(
                  value: EnumOrder.amount,
                  child: Text("Ordenar por quantidade"),
                ),
                const PopupMenuItem(
                  value: EnumOrder.price,
                  child: Text("Ordenar por preço"),
                ),
              ];
            },
            onSelected: (value) {
              setState(
                () {
                  if (enumOrder == value) {
                    isDescending = !isDescending;
                  } else {
                    enumOrder = value;
                    isDescending = false;
                  }
                },
              );
              refresh();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: const Column(
                children: [
                  Text(
                    "R\$${0}",
                    style: TextStyle(fontSize: 42),
                  ),
                  Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listPlannedProducts.length, (index) {
                Product product = listPlannedProducts[index];
                return ListTileProduct(
                  product: product,
                  isPurchased: false,
                  showModal: showFormModal,
                  iconClick: toggleProduct,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listCaughtProducts.length, (index) {
                Product product = listCaughtProducts[index];
                return ListTileProduct(
                  showModal: showFormModal,
                  product: product,
                  isPurchased: true,
                  iconClick: toggleProduct,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Product? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do product
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isComprado = model.isPurchased;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(labelTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Product product = Product(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isPurchased: isComprado,
                      );

                      // Usar id do model
                      if (model != null) {
                        product.id = model.id;
                      }

                      if (amountController.text != "") {
                        product.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        product.price = double.parse(priceController.text);
                      }

                      // Salvar no Firestore
                      db
                          .collection("market")
                          .doc(widget.market.id)
                          .collection("product")
                          .doc(product.id)
                          .set(product.toMap());

                      // Atualizar a lista
                      refresh();

                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Product> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection("market")
        .doc(widget.market.id)
        .collection("product")
        // .where("isPurchased", isEqualTo: true)
        .orderBy(
          enumOrder.name,
          descending: isDescending,
        )
        .get();

    for (var doc in snapshot.docs) {
      Product product = Product.fromMap(doc.data());
      temp.add(product);
    }

    filterProducts(temp);
  }

  filterProducts(List<Product> productList) async {
    List<Product> tempPlanned = [];
    List<Product> tempTakes = [];

    for (var product in productList) {
      if (product.isPurchased) {
        tempTakes.add(product);
      } else {
        tempPlanned.add(product);
      }
    }

    setState(() {
      listPlannedProducts = tempPlanned;
      listCaughtProducts = tempTakes;
    });
  }

  toggleProduct(Product product) async {
    product.isPurchased = !product.isPurchased;

    await db
        .collection("market")
        .doc(widget.market.id)
        .collection("product")
        .doc(product.id)
        .update({"isPurchased": product.isPurchased});

    refresh();
  }
}
