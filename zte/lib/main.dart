import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eWarranty/screens/splashscreen.dart';
import 'package:eWarranty/utils/pixelutil.dart';
import 'package:eWarranty/utils/shared_preferences.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized(); 

   await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await SharedPreferenceHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    ScreenUtil.initialize(context); 
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ewarranty',
      home: SplashScreen(),
    );
  }
}
