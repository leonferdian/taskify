import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskify/theme/theme_colors.dart';
import 'package:taskify/ui/project_ui/user_account_settings_page.dart'; // Add this import

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserAccountSettingsPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.only(right: 10, left: 10),
          height: 60,
          width: double.infinity,
          color: ThemeColors().grey,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/person.svg',
                fit: BoxFit.none,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  'Account Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
