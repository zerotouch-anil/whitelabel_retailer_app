import 'package:flutter/material.dart';
import 'package:eWarranty/screens/components/categories.dart';
import 'package:eWarranty/screens/retailer_customers_list.dart';
import 'package:eWarranty/screens/retailer_dashboard.dart';
import 'package:eWarranty/screens/retailer_history.dart';
import 'package:eWarranty/screens/retailer_profile.dart';
import 'package:eWarranty/utils/pixelutil.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    RetailerDashboard(),
    RetailerViewCustomers(),
    HistoryData(),
    RetailerProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 2,
      onPopInvoked: (didPop) {
        if (!didPop && _selectedIndex != 2) {
          setState(() {
            _selectedIndex = 2;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: ScreenUtil.unitHeight * 100,
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xff244D9C),
                unselectedItemColor: const Color(0xFF6B7280),
                selectedFontSize: 10,
                unselectedFontSize: 9,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.dashboard_outlined,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.dashboard_rounded,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.people_outline_rounded,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    label: 'Customers',
                  ),
                  // BottomNavigationBarItem(
                  //   icon: Padding(
                  //     padding: EdgeInsets.only(
                  //       bottom: ScreenUtil.unitHeight * 4,
                  //     ),
                  //     child: Icon(
                  //       Icons.person_add_outlined,
                  //       size: ScreenUtil.unitHeight * 24,
                  //     ),
                  //   ),
                  //   activeIcon: Padding(
                  //     padding: EdgeInsets.only(
                  //       bottom: ScreenUtil.unitHeight * 4,
                  //     ),
                  //     child: Icon(
                  //       Icons.person_add_rounded,
                  //       size: ScreenUtil.unitHeight * 24,
                  //     ),
                  //   ),
                  //   label: 'Add Customer',
                  // ),
                  
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    label: 'Transactions',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: ScreenUtil.unitHeight * 4,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: ScreenUtil.unitHeight * 24,
                      ),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}