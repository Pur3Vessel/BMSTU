import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FTPSettingsScreen extends StatefulWidget {
  @override
  _FTPSettingsScreenState createState() => _FTPSettingsScreenState();
}


class _FTPSettingsScreenState extends State<FTPSettingsScreen> {
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
    hostController.text = prefs.getString("ftp_host") ?? "";
    usernameController.text = prefs.getString("ftp_username") ?? "";
    passwordController.text = prefs.getString("ftp_password") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('FTP Settings'),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoTextField(
              controller: hostController,
              placeholder: 'FTP Host',
            ),
            SizedBox(height: 16.0),
            CupertinoTextField(
              controller: usernameController,
              placeholder: 'Username',
            ),
            SizedBox(height: 16.0),
            CupertinoTextField(
              controller: passwordController,
              placeholder: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            CupertinoButton.filled(
              onPressed: () {
                // Сохранение параметров подключения FTP
                saveFTPSettings();
                // Переход к экрану выполнения команд FTP
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => FTPCommandScreen(),
                  ),
                );
              },
              child: Text('Save and Connect'),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для сохранения параметров подключения FTP
  void saveFTPSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ftp_host', hostController.text);
    prefs.setString('ftp_username', usernameController.text);
    prefs.setString('ftp_password', passwordController.text);
  }
}

class FTPCommandScreen extends StatefulWidget {
  @override
  _FTPCommandScreenState createState() => _FTPCommandScreenState();
}

class _FTPCommandScreenState extends State<FTPCommandScreen> {
  final TextEditingController commandController = TextEditingController();
  final List<String> commandOutput = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('FTP Commands'),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CupertinoButton.filled(
                  onPressed: () async {
                    await executeListCommand();
                  },
                  child: Text('List Directory'),
                ),
                SizedBox(height: 8.0),
                CupertinoButton.filled(
                  onPressed: () async {
                    await executeChangeDirectoryCommand();
                  },
                  child: Text('Change Directory'),
                ),
                SizedBox(height: 8.0),
                CupertinoButton.filled(
                  onPressed: () async {
                    await executeCreateDirectoryCommand();
                  },
                  child: Text('Create Directory'),
                ),
                SizedBox(height: 8.0),
                CupertinoButton.filled(
                  onPressed: () async {
                    await executeUploadFileCommand();
                  },
                  child: Text('Upload File'),
                ),
                SizedBox(height: 8.0),
                CupertinoButton.filled(
                  onPressed: () async {
                    await executeDownloadFileCommand();
                  },
                  child: Text('Download File'),
                ),
              ],
            ),
          ),

          Expanded(
            child: CupertinoTextField(
              controller: commandController,
              placeholder: 'Enter command argument',
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: commandOutput
                    .map((output) => Text(output))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...

  Future<void> executeChangeDirectoryCommand() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString('ftp_host') ?? '';
      String username = prefs.getString('ftp_username') ?? '';
      String password = prefs.getString('ftp_password') ?? '';

      var ftp = FTPConnect(host, user: username, pass: password);

      var result = await ftp.connect();
      if (result) {
        await ftp.changeDirectory(commandController.text);
        await ftp.disconnect();

        setState(() {
          commandOutput.add('Directory changed: ${commandController.text}');
        });
      } else {
        commandOutput.add('Error connecting to FTP server');
      }
    } catch (e) {
      commandOutput.add('Error executing FTP command: $e');
    }
  }


  Future<void> executeListCommand() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString('ftp_host') ?? '';
      String username = prefs.getString('ftp_username') ?? '';
      String password = prefs.getString('ftp_password') ?? '';

      var ftp = FTPConnect(host, user: username, pass: password);

      var result = await ftp.connect();
      if (result) {
        await ftp.listDirectoryContentOnlyNames().then((value) => {
            setState(() {
              commandOutput.add(value.toString());
            })
        });
        await ftp.disconnect();
      } else {
        commandOutput.add('Error connecting to FTP server');
      }
    } catch (e) {
      commandOutput.add('Error executing FTP command: $e');
    }
  }


  Future<void> executeCreateDirectoryCommand() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString('ftp_host') ?? '';
      String username = prefs.getString('ftp_username') ?? '';
      String password = prefs.getString('ftp_password') ?? '';

      var ftp = FTPConnect(host, user: username, pass: password);

      var result = await ftp.connect();
      if (result) {
        await ftp.createFolderIfNotExist(commandController.text);
        await ftp.disconnect();

        setState(() {
          commandOutput.add('Directory created: ${commandController.text}');
        });
      } else {
        commandOutput.add('Error connecting to FTP server');
      }
    } catch (e) {
      commandOutput.add('Error executing FTP command: $e');
    }
  }


  Future<void> executeUploadFileCommand() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString('ftp_host') ?? '';
      String username = prefs.getString('ftp_username') ?? '';
      String password = prefs.getString('ftp_password') ?? '';

      var ftp = FTPConnect(host, user: username, pass: password);

      var result = await ftp.connect();
      if (result) {
        String fileName = commandController.text;
        await ftp.uploadFile(File(fileName));
        await ftp.disconnect();

        setState(() {
          commandOutput.add('File uploaded: ${commandController.text}');
        });
      } else {
        commandOutput.add('Error connecting to FTP server');
      }
    } catch (e) {
      commandOutput.add('Error executing FTP command: $e');
    }
  }


  Future<void> executeDownloadFileCommand() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString('ftp_host') ?? '';
      String username = prefs.getString('ftp_username') ?? '';
      String password = prefs.getString('ftp_password') ?? '';

      var ftp = FTPConnect(host, user: username, pass: password);

      var result = await ftp.connect();
      if (result) {
        String fileName = commandController.text;
        await ftp.downloadFile(fileName, File(fileName));
        await ftp.disconnect();

        setState(() {
          commandOutput.add('File downloaded: ${commandController.text}');
        });
      } else {
        commandOutput.add('Error connecting to FTP server');
      }
    } catch (e) {
      commandOutput.add('Error executing FTP command: $e');
    }
  }
}