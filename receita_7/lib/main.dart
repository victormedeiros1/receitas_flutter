import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_hooks/flutter_hooks.dart';

class DataService {
  late int querySize = 5;
  final ValueNotifier<List> tableStateNotifier = ValueNotifier([]);
  final ValueNotifier<List<String>> columnNamesNotifier = ValueNotifier([]);
  final ValueNotifier<List<String>> propertyNamesNotifier = ValueNotifier([]);

  void load(index) {
    var res;

    if (index == 1) {
      res = loadBeers();
    } else if (index == 2) {
      res = loadNations();
    } else if (index == 0) {
      res = loadCoffees();
    }
  }

// https://random-data-api.com/api/beer/random_beer?size=5
  Future<void> loadBeers() async {
    var beersUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/beer/random_beer',
        queryParameters: {'size': '$querySize'});

    var jsonString = await http.read(beersUri);
    var beersJson = jsonDecode(jsonString);

    tableStateNotifier.value = beersJson;

    columnNamesNotifier.value = [
      "Brand",
      "Name",
      "Style",
    ];
    propertyNamesNotifier.value = [
      "brand",
      "name",
      "style",
    ];
  }

// https://random-data-api.com/api/coffee/random_coffee?size=5
  Future<void> loadCoffees() async {
    var coffesUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/coffee/random_coffee',
        queryParameters: {'size': '$querySize'});

    var jsonString = await http.read(coffesUri);
    var coffeesJson = jsonDecode(jsonString);

    tableStateNotifier.value = coffeesJson;
    propertyNamesNotifier.value = [
      "blend_name",
      "origin",
      "variety",
    ];

    columnNamesNotifier.value = [
      "Blend_name",
      "Origin",
      "Variety",
    ];
  }

// https://random-data-api.com/api/nation/random_nation?size=5
  Future<void> loadNations() async {
    var nationsUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/nation/random_nation',
        queryParameters: {'size': '$querySize'});

    var jsonString = await http.read(nationsUri);

    var nationsJson = jsonDecode(jsonString);
    tableStateNotifier.value = nationsJson;
    columnNamesNotifier.value = ["Nationality", "Language", "Capital"];
    propertyNamesNotifier.value = ["nationality", "language", "capital"];
  }
}

final dataService = DataService();

enum rows {
  value5(5),
  value10(10),
  value15(15);

  final int id;
  const rows(this.id);
}

void main() {
  MyApp app = const MyApp();
  dataService.loadBeers();
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Receita 7"),
            actions: [
              PopupMenuButton<rows>(
                onSelected: (rows rows) {
                  dataService.querySize = rows.id;
                },
                itemBuilder: (BuildContext context) => const [
                  PopupMenuItem(
                    // value: dataService.zize10().Actio,
                    value: rows.value5,
                    child: Text("5 elementos"),
                  ),
                  PopupMenuItem(
                    value: rows.value10,
                    child: Text("10 elementos"),
                  ),
                  PopupMenuItem(
                    value: rows.value15,
                    child: Text("15 elementos"),
                  ),
                ],
              )
            ],
          ),
          body: ValueListenableBuilder(
              valueListenable: dataService.tableStateNotifier,
              builder: (_, value, __) {
                return DataTableWidget(jsonObjects: value);
              }),
          bottomNavigationBar:
              NewNavBar(itemSelectedCallback: dataService.load),
        ));
  }
}

class NewNavBar extends HookWidget {
  final _itemSelectedCallback;

  NewNavBar({itemSelectedCallback})
      : _itemSelectedCallback = itemSelectedCallback ?? (int);

  @override
  Widget build(BuildContext context) {
    var state = useState(1);

    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;

          _itemSelectedCallback(index);
        },
        currentIndex: state.value,
        items: const [
          BottomNavigationBarItem(
            label: "Coffees",
            icon: Icon(Icons.coffee_outlined),
          ),
          BottomNavigationBarItem(
              label: "Beers", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nations", icon: Icon(Icons.flag_outlined))
        ]);
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;

  const DataTableWidget({super.key, this.jsonObjects = const []});

  @override
  Widget build(BuildContext context) {
    final columnNames = dataService.columnNamesNotifier.value;
    final propertyNames = dataService.propertyNamesNotifier.value;
    return DataTable(
        columns: columnNames
            .map((name) => DataColumn(
                label: Expanded(
                    child: Text(name,
                        style: const TextStyle(fontStyle: FontStyle.italic)))))
            .toList(),
        rows: jsonObjects
            .map((obj) => DataRow(
                cells: propertyNames
                    .map((propName) => DataCell(Text(obj[propName])))
                    .toList()))
            .toList());
  }
}
