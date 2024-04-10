import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Market> marketList = [];
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listin - Feira Colaborativa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (marketList.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  marketList.length,
                  (index) {
                    Market model = marketList[index];
                    return Dismissible(
                      key: ValueKey<Market>(model),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        remove(model);
                      },
                      child: ListTile(
                        onLongPress: () {
                          showFormModal(model: model);
                        },
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                        subtitle: Text(model.id),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal({Market? model}) {
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    if (model != null) {
      title = "Editando feira de ${model.name}";
      nameController.text = model.name;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(label: Text("Nome do Listin")),
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
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Market market = Market(
                        id: const Uuid().v1(),
                        name: nameController.text,
                      );

                      if (model != null) {
                        market.id = model.id;
                      }

                      db
                          .collection("market")
                          .doc(market.id)
                          .set(market.toMap());

                      refresh();

                      Navigator.pop(context);
                    },
                    child: Text(confirmationButton),
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
    List<Market> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await db.collection("market").get();

    for (var doc in snapshot.docs) {
      temp.add(Market.fromMap(doc.data()));
    }

    setState(() {
      marketList = temp;
    });
  }

  void remove(Market model) {
    db.collection("market").doc(model.id).delete();
    refresh();
  }
}
