import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DataService {
  final ValueNotifier<List> tableStateNotifier = ValueNotifier([]);
  final ValueNotifier<List<String>> columnNamesNotifier = ValueNotifier([]);

  late final ValueNotifier<List<String>> propertyNamesNotifier =
      ValueNotifier([]);

  void load(index) {
    Map<int, Function> funcs = {0: loadCoffees, 1: loadBeers, 2: loadNations};
    funcs[index]?.call();
  }

  void loadCoffees() {
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
    tableStateNotifier.value = [
      {
        "blend_name": "Chocolate Star",
        "origin": "Western Region, Bukova, Tanzania",
        "variety": "Bourbon",
      },
      {
        "blend_name": "Brooklyn Select",
        "origin": "Kabirizi, Rwanda",
        "variety": "Pacamara",
      },
      {
        "blend_name": "Street Star",
        "origin": "Alotepec-Metapán, El Salvador",
        "variety": "Villalobos",
      },
      {
        "blend_name": "Chocolate Coffee",
        "origin": "San Marcos, Guatemala",
        "variety": "Sarchimor",
      },
      {
        "blend_name": "Cascara Nuts",
        "origin": "Lintong, Sumatra",
        "variety": "SL34",
      }
    ];
  }

  void loadBeers() {
    propertyNamesNotifier.value = ["name", "style", "ibu", "alcohol"];
    columnNamesNotifier.value = ["Name", "Style", "Ibu", "Alcohol"];

    tableStateNotifier.value = [
      {
        "name": "Stone IPA",
        "style": "Vegetable Beer",
        "ibu": "80 IBU",
        "alcohol": "6.0%"
      },
      {
        "name": "Péché Mortel",
        "style": "Bock",
        "ibu": "86 IBU",
        "alcohol": "5.1%",
      },
      {
        "name": "La Fin Du Monde",
        "style": "Light Lager",
        "ibu": "51 IBU",
        "alcohol": "7.5%",
      },
      {
        "name": "Weihenstephaner Hefeweissbier",
        "style": "Light Lager",
        "ibu": "18 IBU",
        "alcohol": "6.4%",
      },
      {
        "name": "Orval Trappist Ale",
        "style": "European Amber Lager",
        "ibu": "100 IBU",
        "alcohol": "3.1%",
      }
    ];
  }

  void loadNations() {
    propertyNamesNotifier.value = [
      "nationality",
      "language",
      "capital",
    ];
    columnNamesNotifier.value = [
      "Nationality",
      "Language",
      "Capital",
    ];
    tableStateNotifier.value = [
      {
        "nationality": "Norwegians",
        "language": "Marathi",
        "capital": "Jerusalem",
      },
      {
        "nationality": "Tanzanians",
        "language": "Dutch",
        "capital": "Jakarta",
      },
      {
        "nationality": "Kazakhs",
        "language": "Hakka",
        "capital": "Vilnius",
      },
      {
        "nationality": "Guatemalans",
        "language": "Romanian",
        "capital": "Muscat",
      },
      {
        "nationality": "Arubans",
        "language": "Swedish",
        "capital": "Minsk",
      }
    ];
  }
}

final dataService = DataService();

void main() {
  MyApp app = MyApp();
  dataService.loadBeers();
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.indigo),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Receita 6"),
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
  var itemSelectedCallback;

  NewNavBar({this.itemSelectedCallback}) {
    itemSelectedCallback ??= (_) {};
  }

  @override
  Widget build(BuildContext context) {
    var state = useState(1);

    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;

          itemSelectedCallback(index);
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

  DataTableWidget({this.jsonObjects = const []});

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
