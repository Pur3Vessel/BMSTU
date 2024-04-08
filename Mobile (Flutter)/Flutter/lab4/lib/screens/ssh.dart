import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSHSettingsScreen extends StatefulWidget {
  @override
  _SSHSettingsScreenState createState() => _SSHSettingsScreenState();
}

class _SSHSettingsScreenState extends State<SSHSettingsScreen> {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    hostController.text = prefs.getString("ssh_host") ?? "";
    usernameController.text = prefs.getString("ssh_username") ?? "";
    passwordController.text = prefs.getString("ssh_password") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SSH Settings'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoTextField(
              controller: hostController,
              placeholder: 'SSH Host',
            ),
            const SizedBox(height: 16.0),
            CupertinoTextField(
              controller: usernameController,
              placeholder: 'Username',
            ),
            const SizedBox(height: 16.0),
            CupertinoTextField(
              controller: passwordController,
              placeholder: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CupertinoButton.filled(
              onPressed: () {
                // Сохранение параметров подключения SSH
                saveSSHSettings();
                // Переход к экрану выполнения команд
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => SSHCommandScreen(),
                  ),
                );
              },
              child: const Text('Save and Connect'),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для сохранения параметров подключения SSH
  Future<void> saveSSHSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ssh_host', hostController.text);
    prefs.setString('ssh_username', usernameController.text);
    prefs.setString('ssh_password', passwordController.text);
  }
}

class SSHCommandScreen extends StatefulWidget {
  @override
  _SSHCommandScreenState createState() => _SSHCommandScreenState();
}

class _SSHCommandScreenState extends State<SSHCommandScreen> {
  final TextEditingController commandController = TextEditingController();
  final List<String> commandOutput = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('SSH Commands'),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: commandOutput
                    .map((output) => Text(output))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: commandController,
                    placeholder: 'Enter SSH Command',
                  ),
                ),
                SizedBox(width: 8.0),
                CupertinoButton.filled(
                  onPressed: () async {
                    // Выполнение SSH-команды
                    await executeSSHCommand();
                  },
                  child: Text('Run Command'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Метод для выполнения SSH-команды
  Future<void> executeSSHCommand() async {
    try {
      // Загрузка параметров подключения SSH из сохраненных значений
      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString("ssh_host") ?? "";  
      String username = prefs.getString("ssh_username") ?? "";  
      String password = prefs.getString("ssh_passsword") ?? "";   
      
      // Подключение к SSH-серверу
      final socket = await SSHSocket.connect(host.split(':')[0], int.parse(host.split(":")[1]));
      final client = SSHClient(socket, username: username, onPasswordRequest: () => password);

      // Выполнение команды
      var result = await client.run(commandController.text);
      // Обновление интерфейса с результатами команды
      setState(() {
        commandOutput.add(utf8.decode(result));
      });

      client.close();
      await client.done;

    } catch (e) {
      setState(() {
        commandOutput.add("Error: $e");
      });
    }
  }
}