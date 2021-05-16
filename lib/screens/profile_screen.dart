import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicine/config/assets.dart';
import 'package:medicine/config/strings.dart';
import 'package:medicine/utils/gradient_container.dart';
import 'package:medicine/utils/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  bool enableEdit = false;
  String name = "John Doe";
  String email = "john@example.com";
  String phone = "+1 323 233 234";

  Future<String> initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString("name") ?? "John Doe";
    email = prefs.getString("email") ?? "john@example.com";
    phone = prefs.getString("mobile") ?? "+1 323 233 234";
    return "0";
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      initPrefs();
    });
    // final deviceSize = MediaQuery.of(context).size;
    final focus = FocusScope.of(context);
    return FutureBuilder(
        future: initPrefs(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Column(
              children: [
                LinearProgressIndicator(),
              ],
            );
          }
          return GestureDetector(
            onTap: () {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: Stack(
              children: <Widget>[
                GradientContainer(),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(25.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: Variables.borderRadius,
                      ),
                      elevation: 6,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        child: ListView(
                          // shrinkWrap: true,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 140,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: 120.0,
                                        height: 120.0,
                                        padding: const EdgeInsets.all(3.0),
                                        child: CircleAvatar(
                                          foregroundImage: ExactAssetImage(
                                            Assets.avatar,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 25,
                                              offset: Offset(1.5, 1.5),
                                              // topRight
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  Strings.Personal,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Divider(
                                  color: Colors.black45,
                                ),
                                getBoldText(Strings.NAME),
                                enableEdit
                                    ? getEditText(nameController,
                                        Strings.ENTER_NAME, focus)
                                    : getNormalText(name),
                                Divider(
                                  color: Colors.black45,
                                ),
                                getBoldText(Strings.EMAIL),
                                enableEdit
                                    ? getEditText(emailController,
                                        Strings.ENTER_EMAIL, focus)
                                    : getNormalText(email),
                                Divider(
                                  color: Colors.black45,
                                ),
                                getBoldText(Strings.MOBILE),
                                enableEdit
                                    ? getEditText(mobileController,
                                        Strings.ENTER_MOBILE, focus)
                                    : getNormalText(phone),
                                Divider(
                                  color: Colors.black45,
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: enableEdit
                                        ? FloatingActionButton.extended(
                                            backgroundColor: Variables.color,
                                            elevation: 3,
                                            icon: Icon(
                                              Icons.save,
                                              size: 15,
                                              color: Colors.black,
                                            ),
                                            label: Text(
                                              Strings.SAVE,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            onPressed: () async {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString(
                                                  "name", nameController.text);
                                              prefs.setString("email",
                                                  emailController.text);
                                              prefs.setString("mobile",
                                                  mobileController.text);
                                              setState(() {
                                                enableEdit = false;
                                                name = nameController.text;
                                                email = emailController.text;
                                                phone = mobileController.text;
                                              });
                                            },
                                          )
                                        : FloatingActionButton.extended(
                                            backgroundColor: Variables.color,
                                            elevation: 3,
                                            icon: Icon(
                                              Icons.edit,
                                              size: 15,
                                              color: Colors.black,
                                            ),
                                            label: Text(
                                              Strings.EDIT,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                enableEdit = true;
                                              });
                                            },
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget getEditText(
      TextEditingController controller, String label, FocusScopeNode focus) {
    return TextField(
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        controller: controller,
        keyboardType: TextInputType.name,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14.0),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(width: 1, color: Colors.grey),
          ),
        ),
        onSubmitted: (val) {
          // controller
          // focus.unfocus();
        });
  }

  Widget getBoldText(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 8, bottom: 8),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget getNormalText(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
