import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});

  void carregar(index) {
    final List<void Function()> funcoes = [
      carregarCafe,
      carregarCervejas,
      carregarNacoes,
      carregarVeiculos
    ];

    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': []
    };

    funcoes[index]();
  }

  void carregarCafe() {
    var coffeeUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': '5'},
    );

    http.read(coffeeUri).then((jsonSting) {
      var coffeeJson = jsonDecode(jsonSting);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': coffeeJson,
        'propertyNames': ["blend_name", "origin", "intensifier"],
        'columnNames': ["Nome", "Nacionalidade", "Intensidade"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }

  void carregarCervejas() {
    var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': '5'},
    );

    http.read(beersUri).then((jsonString) {
      var beersJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': beersJson,
        'propertyNames': ["name", "style", "ibu"],
        'columnNames': ["Nome", "Estilo", "IBU"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }

  void carregarNacoes() {
    var nationUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': '5'},
    );

    http.read(nationUri).then((jsonString) {
      var nationJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': nationJson,
        'propertyNames': ["nationality", "language", "capital"],
        'columnNames': ["Nacionalidade", "Idioma", "Capital"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }

  void carregarVeiculos() {
    var vehicleUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/vehicle/random_vehicle',
        queryParameters: {'size': '5'});

    http.read(vehicleUri).then((jsonString) {
      var vehicleJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': vehicleJson,
        'propertyNames': ["make_and_model", "fuel_type", "license_plate"],
        'columnNames': ["Marca e modelo", "Combustível", "Placa"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }
}

final dataService = DataService();

void main() {
  MyApp app = MyApp();

  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Informações Aleatórias"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: ValueListenableBuilder(
            valueListenable: dataService.tableStateNotifier,
            builder: (_, value, __) {
              switch (value['status']) {
                case TableStatus.idle:
                  return Center(
                    child: Text(
                      "Preparado para informações aleatórias (e completamente úteis)?\nToque em algum botão e seja surpreendido!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );

                case TableStatus.loading:
                  return Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );

                case TableStatus.ready:
                  return DataTableWidget(
                    jsonObjects: value['dataObjects'],
                    propertyNames: value['propertyNames'],
                    columnNames: value['columnNames'],
                  );

                case TableStatus.error:
                  return Center(
                    child: Text(
                      "Erro no carregamento dos dados!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
              }

              return Text("...");
            },
          ),
        ),
        bottomNavigationBar:
            NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

class NewNavBar extends HookWidget {
  var itemSelectedCallback;

  NewNavBar({this.itemSelectedCallback}) {
    itemSelectedCallback ??= (_) {};
  }

  @override
  Widget build(BuildContext context) {
    var state = useState(0);
    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;
          print(state.value);
          itemSelectedCallback(index);
        },
        currentIndex: state.value,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
              label: "Cafés", icon: Icon(Icons.coffee_outlined)),
          BottomNavigationBarItem(
              label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nações", icon: Icon(Icons.flag_outlined)),
          BottomNavigationBarItem(
              label: "Veículos", icon: Icon(Icons.car_crash))
        ]);
  }
}

class DataTableWidget extends StatefulWidget {
  final List jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget({
    this.jsonObjects = const [],
    this.columnNames = const ["Coluna", "Coluna", "Coluna"],
    this.propertyNames = const ["name", "style", "ibu"],
  });

  @override
  _DataTableWidgetState createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  List _sortedJsonObjects = [];
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _sortedJsonObjects = List.from(widget.jsonObjects);
    _sortAscending = true;
  }

  void _sortColumn(String columnName) {
    final columnIndex = widget.columnNames.indexOf(columnName);
    final propertyName = widget.propertyNames[columnIndex];

    setState(() {
      _sortedJsonObjects.sort((a, b) {
        final aValue = a[propertyName];
        final bValue = b[propertyName];

        if (_sortAscending) {
          return Comparable.compare(aValue, bValue);
        } else {
          return Comparable.compare(bValue, aValue);
        }
      });

      _sortAscending = !_sortAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: widget.columnNames
          .map(
            (name) => DataColumn(
              label: InkWell(
                onTap: () {
                  _sortColumn(name);
                },
                child: Text(
                  name,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          )
          .toList(),
      rows: _sortedJsonObjects
          .map(
            (obj) => DataRow(
              cells: widget.propertyNames
                  .map(
                    (propName) => DataCell(
                      Text(obj[propName] ?? 'Nada para se ver aqui'),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
