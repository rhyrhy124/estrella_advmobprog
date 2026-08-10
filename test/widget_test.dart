import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:estrella_advmobprog/main.dart';
import 'package:estrella_advmobprog/models/theme_model.dart';

/// This test checks if the counter button works.
void main() {


  testWidgets(
    'Counter button adds number',
    (WidgetTester tester) async {



      // Start the app with ThemeModel.
      await tester.pumpWidget(


        ChangeNotifierProvider(


          create: (context) =>
              ThemeModel(),


          child:
              const MyApp(),


        ),


      );
      // Check if counter starts at zero.
      expect(
        find.text('0'),
        findsOneWidget,
      );

      // Press the add button.
      await tester.tap(
        find.byIcon(Icons.add),
      );
      
      // Update the screen.
      await tester.pump();

      // Check if number became one.
      expect(
        find.text('1'),
        findsOneWidget,
      );

    },

  );

}