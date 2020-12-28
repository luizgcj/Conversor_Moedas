import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert";

const request = "https://api.hgbrasil.com/finance?format=json&key=506aae65";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(
            color: Colors.amber),
      ),
  )));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String texto){
    if (texto.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(texto);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String texto){
    if (texto.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(texto);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / this.euro).toStringAsFixed(2);
  }

  void _euroChanged(String texto){
    if (texto.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(texto);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / this.dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Converor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                 if (snapshot.hasError){
                   return Column(
                       children: [ Text(
                         "Erro ao carregar Dados...${snapshot.error}",
                         style: TextStyle(color: Colors.amber, fontSize: 25.0),
                         textAlign: TextAlign.center,
                       ),
                   RaisedButton(onPressed: getData,
                     child: Text("Tentar novamente", style: TextStyle(color: Colors.amber, fontSize: 25.0),),
                   )]
                   );

                 } else {
                   dolar = snapshot.data['results']["currencies"]["USD"]["buy"];
                   euro = snapshot.data['results']["currencies"]["EUR"]["buy"];

                   return SingleChildScrollView(
                     padding: EdgeInsets.all(10.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: [
                         Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                         buildTextField("Reais", "R\$", realController, _realChanged),
                         Divider(),
                         buildTextField("Doláres", "US\$", dolarController, _dolarChanged),
                         Divider(),
                         buildTextField("Euros", "Є", euroController, _euroChanged),
                         Divider(),
                         Text("Cotação dólar: R\$: ${this.dolar.toStringAsFixed(2)}", style: (TextStyle(color: Colors.amber))),
                         Divider(),
                         Text("Cotação euro: R\$: ${this.euro.toStringAsFixed(2)}", style: (TextStyle(color: Colors.amber))),
                       ],
                     ),
                   );
                 }
              }
            }));
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controlador, Function funcao) {
  return TextField(
    controller: controlador,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: funcao,

  );

}
