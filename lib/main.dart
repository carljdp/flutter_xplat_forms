import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ideal time to initialize
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MyForm',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // TODO: 3s delay is a bit long, investigate other methods
    // - or perhaps it's just this slow in dev/debug modes?
    Future.delayed(const Duration(milliseconds: 3000), () {
      FocusScope.of(context).requestFocus(_nameFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Firebase Anonymous Auth')),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    UserCredential userCredential =
                        await _auth.signInAnonymously();
                    print("User ID: ${userCredential.user?.uid}\n");
                  },
                  child: const Text('Sign in Anonymously'),
                ),
                TextFormField(
                  focusNode: _nameFocus,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                  // autofocus: true, // Add this line
                ),
                TextFormField(
                  focusNode: _emailFocus,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0), // Add top padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop(); // Exit the app
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(
                          width: 16), // Optional spacing between the buttons
                      ElevatedButton(
                        onPressed: () {
                          // Show submitted info and exit or restart app
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Info submitted'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Future.delayed(const Duration(seconds: 3), () {
                              if (const bool.fromEnvironment(
                                  "dart.vm.product")) {
                                // Exit the app if in release mode
                                // TODO: Add your exit code here
                              } else {
                                // Restart the app if in debug mode
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyApp()),
                                );
                              }
                            });
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
