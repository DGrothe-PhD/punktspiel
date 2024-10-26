import 'package:flutter/material.dart';

import './privatgruppe.dart';

class StyleDecorator {
  static const textstil = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  //const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
}

class TableExampleApp extends StatelessWidget {
  const TableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Table Sample')),
        body: const TableExample(),
      ),
    );
  }
}
/*
 TODO Make table work
 ! First add return-to-front-page button
 ? Background canvas?
 * Music playing
*/

class TableExample extends StatelessWidget {
  const TableExample({super.key});

  @override
  Widget build(BuildContext context) {
    try{
    return DataTable(
      columns: <DataColumn>[
        for (var name in wirhier.names)
        DataColumn(  
          label: Expanded(
          child: Text(name, style: StyleDecorator.textstil),
          ),
        ),
      ],
      rows: <DataRow>[
        for (int j=0; j<3; j++)
        const // TODO make dynamic
        DataRow(
          cells: <DataCell>[
            DataCell(Text('0')),
            DataCell(Text('0')),
            DataCell(Text('0')),
            DataCell(Text('0')),
          ],
        ),
      ],
    );

  }
    catch (exception){
    return Text(exception.toString());
  }
}}