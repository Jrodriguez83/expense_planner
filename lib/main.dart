import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './screens/home_screen.dart';
import './screens/auth_screen.dart';
import './models/transactions.dart';
import './models/auth.dart';
import './screens/settings_page.dart';
import './screens/splash_screen.dart';

main(List<String> args) {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]).then((_){
  runApp(new MyApp());
  // });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Transactions>(
          builder: (ctx, auth, previoustrans) {
            return Transactions(token: auth.token, userId: auth.userId);
          },
        )
      ],
      child: Consumer<Transactions>(
        builder: (ctx, transData, _) => Consumer<Auth>(
          builder: (ctx, authData, _) => MaterialApp(
            title: 'Personal Expenses',
            theme: ThemeData(
                errorColor: Colors.red,
                primarySwatch: transData.themeColor(),
                accentColor: Colors.amber,
                fontFamily: 'Quicksand',
                textTheme: ThemeData.light().textTheme.copyWith(
                    title: TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    button: TextStyle(color: Colors.white)),
                appBarTheme: AppBarTheme(
                  textTheme: ThemeData.light().textTheme.copyWith(
                          title: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                )),
            home: authData.isAuth
                ? HomePage()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              'settings_screen': (_) => SettingsPage(),
            },
          ),
        ),
      ),
    );
  }
}
