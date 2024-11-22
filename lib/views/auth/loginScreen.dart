import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:treenode/controllers/auth/LoginController.dart';
import 'package:treenode/controllers/utills/LangController.dart';
import 'package:treenode/controllers/utills/ThemeController.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final LangController langController = Get.find<LangController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      return Directionality(
        textDirection: langController.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Spacer(),
                Text('login'.tr,style:TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Sarbaz',
                    fontSize: 30
                ),),
              ],
            ),
            leading: IconButton(onPressed: (){Get.toNamed('start');}, icon: Icon(Icons.arrow_back_ios_sharp)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 50),
                TextField(
                  controller: usernameController,
                  onChanged: (value) => loginController.updateUsername(value),
                  decoration: InputDecoration(
                    hintText: 'username'.tr,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                        fontFamily: 'Sarbaz',
                        fontSize: 25
                    ),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 30),
                // Password Field
                TextField(
                  controller: passwordController,
                  onChanged: (value) => loginController.updatePassword(value),
                  decoration: InputDecoration(
                    hintText: 'password'.tr,
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Sarbaz',
                        fontSize: 25
                    ),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                Spacer(),
                // Login Button
                Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(320, 60),
                      elevation: 7,
                      shadowColor: Colors.black,
                      backgroundColor: loginController.isFormValid()
                          ? Colors.yellow.shade600
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: loginController.isFormValid()
                        ? () async {
                      await loginController.login(
                        usernameController.text,
                        passwordController.text,
                      );
                    }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "login".tr,
                            style: TextStyle(color: Colors.black, fontSize: 18,    fontFamily: 'Sarbaz',),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 20),
                Obx(() {
                  if (loginController.isOtpSent.value) {
                    return Column(
                      children: [
                        TextField(
                          controller: otpController,
                          decoration: InputDecoration(labelText: 'enter_otp'.tr),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            int otp = int.tryParse(otpController.text.trim()) ?? 0;
                            if (otp != 0) {
                              await loginController.verifyOtp(otp.toString());
                            } else {
                              Get.snackbar(
                                'error'.tr,
                                'invalid_otp'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          child: Text('verify_otp'.tr),
                        ),
                      ],
                    );
                  }
                  return Container();
                }),
                SizedBox(height: 20),
                Obx(() {
                  if (loginController.isLoggedIn.value) {
                    return Text('login_successful'.tr);
                  } else if (!loginController.isOtpValid.value &&
                      loginController.isOtpSent.value) {
                    return Text('otp_invalid'.tr);
                  }
                  return Container();
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}
