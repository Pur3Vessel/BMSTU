import 'package:flutter/cupertino.dart';
import 'screens/ftp.dart';
import 'screens/ssh.dart';
import 'screens/smtp.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.antenna_radiowaves_left_right),
            label: 'SSH',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'FTP',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.mail),
            label: 'SMTP',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) {
            switch (index) {
              case 0:
                return SSHSettingsScreen();
              case 1:
                return FTPSettingsScreen();
              case 2:
                return SMTPSettingsScreen();
              default:
                return Container();
            }
          },
        );
      },
    );
  }
}