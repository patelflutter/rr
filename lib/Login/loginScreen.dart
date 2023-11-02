import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/DashBord/dashbord.dart';
import 'package:homofix_expert/JoinExpert/join.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _showPassword = false;
  bool isLoading = false;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  late StreamSubscription subscription;

  int? state = 0;
  final formKey = GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  Future<void> _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://support.homofixcompany.com/api/Login/');
    final body = {
      'username': _email.text,
      'password': _password.text,
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final user = jsonResponse['user'];
        final id = user['id'];
        final email = user['email'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', _email.text);
        prefs.setString('id', id.toString());
        prefs.setString('email', email.toString());
        prefs.setBool('loggedIn', true); 

        final expertUrl =
            Uri.parse('https://support.homofixcompany.com/api/Expert/$id/');
        final expertResponse = await http.get(expertUrl);

        if (expertResponse.statusCode == 200) {
          final expertJsonResponse = json.decode(expertResponse.body);
          final expertStatus = expertJsonResponse['status'];

          if (expertStatus == 'Hold') {
            Fluttertoast.showToast(
              msg: "Your account is on hold, please contact support",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else if (expertStatus == 'Deactivate') {
            Fluttertoast.showToast(
              msg: "Your account has been deactivated",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            Fluttertoast.showToast(
              msg: "Login successful",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            bool loggedIn = prefs.getBool('loggedIn') ?? false;
            if (loggedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => DashBord()),
              );
            } else {
              // Handle the case when the user logs in for the first time
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: "Error checking expert status",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Invalid username or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred, please try again later",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  void _checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('loggedIn') ?? false;

    if (loggedIn) {
      // User is already logged in, navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => DashBord()),
      );
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Image.asset("assets/blob.png")),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 180, left: 30),
                        child: GradientText("Login",
                            gradient: LinearGradient(colors: [
                              Color(0xff002790),
                              Color.fromARGB(255, 14, 60, 187)
                            ]),
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87))),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 30, right: 30),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Username',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Color(4288914861), fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 2,
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter userId';
                                    }
                                    return null;
                                  },
                                  controller: _email,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 14.0),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Color(4288914861),
                                    ),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Password',
                                style: TextStyle(
                                    color: Color(4288914861), fontSize: 18),
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Material(
                            elevation: 3,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: !_showPassword,
                                controller: _password,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    color: Colors.grey,
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 14.0),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(4288914861),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => MyJoin()));
                                },
                                child: Text(
                                  'Join as Expert?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF646464)),
                                ),
                              ),
                              TextButton(
                                autofocus: true,
                                child: Text(
                                  'Joinnow',
                                  style: customSmallTextStyle,
                                  textAlign: TextAlign.right,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyJoin()),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  await _login(context);
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 180,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Login ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(colors: [
                                      Color(0xff002790),
                                      Color(0xff002790)
                                    ])),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget setUpButtonChild() {
    if (state == 0) {
      return Text(
        "Update Profile",
      );
    } else if (state == 1) {
      return CircularProgressIndicator(
        color: Colors.white,
      );
    } else {
      Timer(Duration(seconds: 2), () {
        setState(() {
          state = 0;
        });
      });
      return Text(
        "Updated",
        // style: GoogleFonts.outfit(
        //     color: Color(0xffffffff),
        //     fontSize: 20,
        //     fontWeight: FontWeight.w500),
      );
    }
  }

//   showDialogBox(context) {
//     showCupertinoDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: const Text("No Connection"),
//           content: const Text("Please check your internet connectivity"),
//           actions: [
//             CupertinoDialogAction(
//               child: const Text("OK"),
//               onPressed: () async {
//                 Navigator.pop(context, 'cancel');
//                 setState(() => isAlertSet = false);

//                 isAlertSet = false;
//                 isDeviceConnected =
//                     await InternetConnectionChecker().hasConnection;
//                 if (!isDeviceConnected) {
//                   showDialogBox(context);
//                   setState(() {
//                     isAlertSet = true;
//                   });
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
