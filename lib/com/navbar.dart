import 'package:flutter/material.dart';
import 'package:flutter_application_1/com/articles_display.dart';
import 'package:flutter_application_1/com/friends_list_page.dart';
import 'package:flutter_application_1/Appointments/appointments_page.dart';
import 'package:flutter_application_1/user/profile_page.dart';

// Palette
const Color kWhite = Colors.white;
const Color kPrimary = Color(0xFF01BCE5);
const Color kDark = Color(0xFF52575A);

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static final List<Widget> _pages = [
    ArticlesDisplay(),
    FriendsListPage(),
    AppointmentsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: kDark.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.chat_bubble_outline, 1),
            _buildNavItem(Icons.local_hospital, 2),
            _buildNavItem(Icons.person_outline, 3),
          ],
          currentIndex: selectedIndex,
          onTap: (index) {
            if (index != selectedIndex) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => _pages[index]),
              );
            }
            onTap(index);
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedIndex == index ? kPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: selectedIndex == index ? kPrimary : kDark.withOpacity(0.5),
        ),
      ),
      label: '',
    );
  }
}
