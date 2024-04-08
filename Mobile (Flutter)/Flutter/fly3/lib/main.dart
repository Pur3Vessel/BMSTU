import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:async';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DbForm(),
  ));
}


class DbForm extends StatefulWidget {
  const DbForm({super.key});

  @override
  DbFormState createState() => DbFormState();
}

class DbFormState extends State<DbForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final List<String> databaseContent = [];

  void insertData() async {
    final name = nameController.text;
    final email = emailController.text;
    final age = ageController.text;

    if (name.isEmpty || email.isEmpty || age.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Пожалуйста, заполните все поля.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final MySqlConnection connection = await MySqlConnection.connect(ConnectionSettings(
      host: 'students.yss.su',
      port: 3306,
      user: 'iu9mobile',
      password: 'bmstubmstu123',
      db: 'iu9mobile',
    ));

    await connection.query(
      'CREATE TABLE IF NOT EXISTS Baev (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL, age INT NOT NULL)',
    );

    final result = await connection.query(
      'INSERT INTO Baev (name, email, age) VALUES (?, ?, ?)',
      [name, email, int.parse(age)],
    );

    print('Inserted row id=${result.insertId}');

    final queryResult = await connection.query('SELECT * FROM Baev');
    final rows = queryResult.toList();

    setState(() {
      databaseContent.clear();
      for (var row in rows) {
        databaseContent.add('Name: ${row['name']}, Email: ${row['email']}, Age: ${row['age']}');
      }
    });
    await connection.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FLY3"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            ElevatedButton(
              onPressed: () {
                insertData();
              },
              child: const Text('Отправить'),
            ),
            const Text('Содержимое таблицы:'),
            for (var item in databaseContent) Text(item),
          ],
        ),
      ),
    );
  }
}


