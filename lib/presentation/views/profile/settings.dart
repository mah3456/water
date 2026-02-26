import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/themes/theme.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});


  @override
  Widget build(BuildContext context) {

    final themecont theme = Get.put(themecont());


    return Scaffold(
       
      appBar: AppBar(
        title: Text('الاعدادات'),leading: IconButton(
        icon: const Icon(Iconsax.arrow_right),
        onPressed: () => Get.back(),
      ),

      ),



      body: SingleChildScrollView(
        child: Column(
          children: [


            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الدخول بالبصمه'),
                  Obx(() => Switch(
                    value: theme.biometric,
                    onChanged: (value) => theme.toggleBio(),
                  ),
                  ),

                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الوضع الداكن'),
                  Obx(() => Switch(
                    value: theme.isDarkMode,
                    onChanged: (value) => theme.toggleTheme(),
                    // activeThumbColor: Theme.of(context).colorScheme.secondary,
                  ),
                  ),

                ],
              ),
            )


          ],
        ),
      ),
    );
  }
}
