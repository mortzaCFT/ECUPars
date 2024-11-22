import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:treenode/controllers/utills/LangController.dart';
import 'package:treenode/controllers/utills/NavigationController.dart';
import 'package:treenode/controllers/utills/ThemeController.dart';
import 'package:treenode/controllers/utills/components/appTheme.dart';
import 'package:treenode/controllers/utills/components/translator.dart';
import 'package:treenode/views/components/customNavigationBar.dart';
import 'package:treenode/views/components/animatedIco.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  final NavigationController navigationController = Get.put(NavigationController());
  final ThemeController themeController = Get.find<ThemeController>();
  final LangController langController = Get.find<LangController>();

  final List<Map<String, dynamic>> items = [
    {'icon': Icons.favorite, 'text': "My Cars"},
    {'icon': Icons.star, 'text': "Favorites"},
    {'icon': Icons.home, 'text': "Home"},
    {'icon': Icons.settings, 'text': "Settings"},
    {'icon': Icons.shop, 'text': "Shop"},
    {'icon': Icons.map, 'text': "Map"},
    {'icon': Icons.work, 'text': "Work"},
    {'icon': Icons.flight, 'text': "Travel"},
    {'icon': Icons.directions_car, 'text': "Garage"},
    {'icon': Icons.phone, 'text': "Contact"},
  ];

  Widget _buildContent() {
    return Obx(() {
      switch (navigationController.selectedIndex.value) {
        case 0:
          return _buildHomeContent();
        case 1:
          return Center(
              child: Text(
                "Search Page",
                style: TextStyle(
                  fontSize: 24,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ));
        case 2:
          return Center(
              child: Text(
                "Notifications Page",
                style: TextStyle(
                  fontSize: 24,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ));
        case 3:
          return Center(
              child: Text(
                "Profile Page",
                style: TextStyle(
                  fontSize: 24,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ));
        default:
          return Center(
              child: Text(
                "Page Not Found",
                style: TextStyle(
                  fontSize: 24,
                  color: themeController.isDarkTheme.value
                      ? Colors.white
                      : Colors.black,
                ),
              ));
      }
    });
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "ECU".tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Sarbaz',
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ecuColor,
                          ),
                        ),
                        TextSpan(
                          text: "PARS".tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Sarbaz",
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkTheme.value
                                ? AppTheme.nightParsColor
                                : AppTheme.dayParsColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  onPressed: themeController.toggleTheme,
                  icon: Icon(
                    themeController.isDarkTheme.value
                        ? Icons.nightlight_round
                        : Icons.wb_sunny,
                    color: themeController.isDarkTheme.value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 100),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    langController.changeLanguage("en");
                  },
                  child: Obx(() {
                    return Text(
                      "Home".tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Sarbaz",
                        color: themeController.isDarkTheme.value
                            ? Colors.white
                            : Colors.black,
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 14,
              alignment: WrapAlignment.start,
              children: items.map((item) {
                return Container(
                  width: (Get.width + 70) / 4,
                  height: 140,
                  decoration: BoxDecoration(
                    color: themeController.isDarkTheme.value
                        ? Color(0xFF545454)
                        : Color(0xFFFFF2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedIco(
                          logo: item['icon'],
                          width: 50,
                          height: 50,
                          speed: Duration(milliseconds: 600),
                          timeToRepeat: Duration(seconds: 1),
                          pauseBetweenRepeats: Duration(seconds: 2),
                          maxScale: 2,
                        ),
                        SizedBox(height: 8),
                        Text(
                          item['text'],
                          style: TextStyle(
                            fontSize: 12,
                            color: themeController.isDarkTheme.value
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: AnimatedNavigationBar(),
    );
  }
}
