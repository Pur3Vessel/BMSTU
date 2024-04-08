import 'package:flutter/cupertino.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SMTPSettingsScreen extends StatefulWidget {
  @override
  _SMTPSettingsScreenState createState() => _SMTPSettingsScreenState();
}

class _SMTPSettingsScreenState extends State<SMTPSettingsScreen> {
  final TextEditingController hostController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSMTPSettings();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('SMTP Settings'),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoTextField(
              controller: hostController,
              placeholder: 'SMTP Host',
            ),
            SizedBox(height: 16.0),
            CupertinoTextField(
              controller: usernameController,
              placeholder: 'Username',
            ),
            SizedBox(height: 16.0),
            CupertinoTextField(
              controller: passwordController,
              placeholder: 'AppKey',
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            CupertinoTextField(
              controller: portController,
              placeholder: 'Port',
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            CupertinoButton.filled(
              onPressed: () {
                saveSMTPSettings();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void loadSMTPSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    hostController.text = prefs.getString('smtp_host') ?? '';
    usernameController.text = prefs.getString('smtp_username') ?? '';
    passwordController.text = prefs.getString('smtp_password') ?? '';
    portController.text = prefs.getString('smtp_port') ?? '';
  }

  void saveSMTPSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('smtp_host', hostController.text);
    prefs.setString('smtp_username', usernameController.text);
    prefs.setString('smtp_password', passwordController.text);
    prefs.setString('smtp_port', portController.text);
  }
}

class SMTPSendMailScreen extends StatefulWidget {
  @override
  _SMTPSendMailScreenState createState() => _SMTPSendMailScreenState();
}

class _SMTPSendMailScreenState extends State<SMTPSendMailScreen> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final List<String> commandOutput = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Send Email'),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: toController,
                  placeholder: 'To Email Address',
                ),
                SizedBox(height: 16.0),
                CupertinoTextField(
                  controller: subjectController,
                  placeholder: 'Email Subject',
                ),
                SizedBox(height: 16.0),
                CupertinoTextField(
                  controller: messageController,
                  placeholder: 'Email Message',
                  maxLines: 5,
                ),
                SizedBox(height: 16.0),
                CupertinoButton.filled(
                  onPressed: () async {
                    await sendEmail();
                  },
                  child: Text('Send Email'),
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
          ),
        ],
      ),
    );
  }

  Future<void> sendEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString('smtp_host') ?? '';
      String username = prefs.getString('smtp_username') ?? '';
      String password = prefs.getString('smtp_password') ?? '';
      String port = prefs.getString('smtp_port') ?? '';

      final smtpServer = SmtpServer(
        host,
        username: username,
        password: password,
        port: int.parse(port),
        ssl: true,
      );

      final message = Message()
        ..from = Address(username, 'Danila Palych')
        ..recipients.add(toController.text)
        ..subject = subjectController.text
        ..text = messageController.text;

      final sendReport = await send(message, smtpServer);
      setState(() {
        commandOutput.add('Email sent: $sendReport');
      });
    } catch (e) {
      setState(() {
        commandOutput.add('Error sending email: $e');
      });
    }
  }
}