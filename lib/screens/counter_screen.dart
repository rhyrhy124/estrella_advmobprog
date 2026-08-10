import 'package:flutter/material.dart';
import 'theme_screen.dart';

/// This screen shows Ephemeral State.
/// The counter only works inside this screen.
/// It uses setState() to update the number.
class CounterScreen extends StatefulWidget {

  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {


  // This stores the counter number.
  int _counter = 0;



  /// This adds 1 to the counter.
  void _incrementCounter() {

    // setState updates the screen.
    setState(() {

      // Increase the number.
      _counter++;

    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          Theme.of(context).colorScheme.surface,


      appBar: AppBar(

        centerTitle: true,

        title: const Text(
          "Counter State",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),



      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(25),


          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,


            children: [


              // Card design for counter.
              Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.all(30),


                decoration: BoxDecoration(

                  borderRadius:
                      BorderRadius.circular(25),


                  color:
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer,


                  boxShadow: const [

                    BoxShadow(

                      blurRadius: 10,

                      offset: Offset(0,5),

                    )

                  ],

                ),



                child: Column(

                  children: [


                    const Icon(

                      Icons.touch_app,

                      size: 60,

                    ),



                    const SizedBox(height:20),



                    const Text(

                      "You clicked the button",

                      style: TextStyle(

                        fontSize:18,

                      ),

                    ),



                    const SizedBox(height:10),



                    Text(

                      "$_counter",

                      style: const TextStyle(

                        fontSize:50,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),


                  ],

                ),

              ),



              const SizedBox(height:40),




              ElevatedButton.icon(

                style:
                    ElevatedButton.styleFrom(

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal:35,

                    vertical:15,

                  ),


                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(30),

                  ),

                ),



                icon:
                    const Icon(Icons.palette),



                label:
                    const Text(

                  "Open Theme Settings",

                  style:
                      TextStyle(

                    fontSize:16,

                  ),

                ),



                onPressed: () {


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder:(context)=>

                          const ThemeScreen(),

                    ),

                  );


                },

              )

            ],

          ),

        ),

      ),




      floatingActionButton:


          FloatingActionButton.extended(

        onPressed:
            _incrementCounter,


        icon:
            const Icon(Icons.add),


        label:
            const Text("Add"),


      ),

    );

  }

}