import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eWarranty/models/categories_model.dart';
import 'package:eWarranty/models/dashboard_model.dart';
import 'package:eWarranty/screens/components/categories.dart';
import 'package:eWarranty/screens/login.dart';
import 'package:eWarranty/screens/retailer_customer_details.dart';
import 'package:eWarranty/screens/retailer_customers_list.dart';
import 'package:eWarranty/services/dashboard_service.dart';
import 'package:eWarranty/utils/wooden_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RetailerDashboard extends StatefulWidget {
  @override
  _RetailerDashboardState createState() => _RetailerDashboardState();
}

class _RetailerDashboardState extends State<RetailerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<DashboardData> dashboardData;
  late Future<List<Categories>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    dashboardData = fetchRetailerDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Color(0xff0878fe))),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 22,
                    right: 9,
                    top: 5,
                    bottom: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.refresh, color: Color(0xFFFFFFFF)),
                            onPressed: _refreshDashboard,
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: Color(0xFFFFFFFF)),
                            onPressed: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: FutureBuilder<DashboardData>(
                    future: dashboardData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1565C0),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed loading dashboard',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                alignment: Alignment.center,
                                child: Text(
                                  'Please try refreshing or log out and log back in.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return _buildDashboardContent(context, snapshot.data!);
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final padding = isTablet ? 24.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWalletSection(context, data.walletBalance, isTablet),
          SizedBox(height: 20),

          _buildCategorySection(),
          SizedBox(height: 20),

          _buildActionButtons(),
          SizedBox(height: 20),

          _buildEWarrantyStatsSection(
            context,
            data.eWarrantyStats,
            data.totalCustomersCount,
            isTablet,
          ),

          SizedBox(height: 20),

          _buildRecentCustomersSection(context, data.customers, isTablet),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      height: 380, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: CategoriesComponent(),
    );
  }

  Widget _buildEWarrantyStatsSection(
    BuildContext context,
    EWarrantyStats stats,
    int totalCustomers,
    bool isTablet,
  ) {
    final double titleFontSize = isTablet ? 16 : 11.5;
    final double valueFontSize = isTablet ? 20 : 16.5;
    final double headerFontSize = isTablet ? 22 : 18;
    final double iconSize = isTablet ? 28 : 24;

    final textStyleTitle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: titleFontSize,
      color: Colors.white,
      letterSpacing: 0.3,
    );

    final textStyleValue = TextStyle(
      fontSize: valueFontSize,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 0.2,
    );

    Widget _buildStatCard(String title, String value, IconData icon) {
      return Container(
        decoration: BoxDecoration(
          color: Color(0xff0878fe), // card background
          borderRadius: BorderRadius.circular(12), // rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 15 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: textStyleValue),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white, // icons white
                      size: iconSize,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                title,
                style: textStyleTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    /// Full width card for Total Customers
    Widget _buildFullWidthCard(String title, String value, IconData icon) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff0878fe),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isTablet ? 18 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: value + title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: textStyleValue),
                SizedBox(height: 6),
                Text(title, style: textStyleTitle),
              ],
            ),
            // Right side: icon
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 12,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statistics",
            style: TextStyle(
              fontSize: headerFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double cardSpacing = isTablet ? 16 : 12;
              double cardWidth = (screenWidth - cardSpacing) / 2;
              double cardHeight = isTablet ? 140 : 120;
              double aspectRatio = cardWidth / cardHeight;

              return Column(
                children: [
                  GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: cardSpacing,
                    mainAxisSpacing: cardSpacing,
                    childAspectRatio: aspectRatio,
                    children: [
                      _buildStatCard(
                        "Total Warranties",
                        formatNumber(stats.totalWarranties),
                        Icons.description_outlined,
                      ),
                      _buildStatCard(
                        "Active Warranties",
                        formatNumber(stats.activeWarranties),
                        Icons.verified_outlined,
                      ),
                      _buildStatCard(
                        "Expired Warranties",
                        formatNumber(stats.expiredWarranties),
                        Icons.schedule_outlined,
                      ),
                      _buildStatCard(
                        "Claimed Warranties",
                        formatNumber(stats.claimedWarranties),
                        Icons.task_alt_outlined,
                      ),
                      _buildStatCard(
                        "Premium Collected",
                        formatNumber(stats.totalPremiumCollected),
                        Icons.currency_rupee,
                      ),
                      _buildStatCard(
                        "Last Warranty",
                        stats.lastWarrantyDate != null
                            ? "${stats.lastWarrantyDate!.toLocal().day.toString().padLeft(2, '0')}/"
                                "${stats.lastWarrantyDate!.toLocal().month.toString().padLeft(2, '0')}"
                            : "N/A",
                        Icons.event_outlined,
                      ),
                    ],
                  ),
                  SizedBox(height: cardSpacing),
                  _buildFullWidthCard(
                    "Total Customers",
                    formatNumber(totalCustomers),
                    Icons.people_alt_rounded,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String formatNumber(num value) {
    if (value.abs() > 999) {
      double newValue = value / 1000;
      // Show 1 decimal place only if needed
      return "${newValue.toStringAsFixed(newValue.truncateToDouble() == newValue ? 0 : 1)}k";
    } else {
      return value.toString();
    }
  }

  Widget _buildWalletSection(
    BuildContext context,
    WalletBalance wallet,
    bool isTablet,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green, // green border
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12), // rounded
                        color: Colors.white, // background inside the box
                      ),
                      child: Icon(
                        Icons.currency_rupee,
                        color: Colors.green, // rupee symbol green
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatAmount(wallet.remainingAmount),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0878fe), // text black
                      ),
                    ),
                  ],
                ),
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // text black
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  title: 'View Customers',
                  icon: Icons.people_rounded,
                  color: Colors.white,
                  bgColor: Color(0xFFE3F2FD),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RetailerViewCustomers(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: _buildActionButton(
                  title: 'View Claims',
                  icon: Icons.assignment_rounded,
                  color: Colors.white,
                  bgColor: Color(0xFFFFF3E0),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No claims available'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Color(0xff0878fe),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCustomersSection(
    BuildContext context,
    List<Customer> customers,
    bool isTablet,
  ) {
    final recentCustomers = customers.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Customers',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (recentCustomers.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xff0878fe),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFFFFFF), width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: Color(0xFFFFFFFF)),
                SizedBox(height: 16),
                Text(
                  'No customers found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade200,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentCustomers.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final customer = recentCustomers[index];
              final dynamicHeight = _calculateCustomerCardHeight(
                context,
                customer,
              );

              return Container(
                height: dynamicHeight,
                child: _buildCustomerCard(customer, isTablet),
              );
            },
          ),
      ],
    );
  }

  double _calculateCustomerCardHeight(BuildContext context, Customer customer) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Base components heights
    double paddingHeight = 32; // Container padding (16 * 2)
    double headerRowHeight = 36; // Icon + customer name + warranty key row
    double spacingAfterHeader = 12; // SizedBox after header
    double categoryModelRowHeight = 32; // Category and model chips row
    double spacingAfterChips = 8; // SizedBox after chips
    double dateAmountRowHeight = 20; // Date and amount row
    double spacingAfterDate = 8; // SizedBox after date

    // Notes section (only if present)
    double notesHeight = 0;
    if (customer.notes?.isNotEmpty == true) {
      notesHeight = 8 + 20; // Padding + notes text height
    }

    // Calculate base height
    double calculatedHeight =
        paddingHeight +
        headerRowHeight +
        spacingAfterHeader +
        categoryModelRowHeight +
        spacingAfterChips +
        dateAmountRowHeight +
        spacingAfterDate +
        notesHeight;

    // Add buffer to prevent overflow
    double totalHeight = calculatedHeight + 15;

    // Set reasonable bounds based on screen size
    double minHeight = screenHeight * 0.18; // Slightly smaller than previous
    double maxHeight = screenHeight * 0.35;

    return totalHeight.clamp(minHeight, maxHeight);
  }

  Widget _buildCustomerCard(Customer customer, bool isTablet) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(customer.createdDate.toLocal());
    final premiumAmount =
        customer.premiumAmount is int ? customer.premiumAmount as int : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewCustomer(customerId: customer.customerId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xff0878fe).withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, size: 20, color: Color(0xFF1565C0)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.customerName.isNotEmpty
                            ? customer.customerName
                            : 'Unknown Customer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0878fe),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        customer.warrantyKey,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.yellow.shade900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.category,
                    customer.category.isNotEmpty ? customer.category : 'N/A',
                    Colors.blue.shade50,
                    Colors.blue.shade600,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.devices,
                    customer.modelName.isNotEmpty ? customer.modelName : 'N/A',
                    Colors.orange.shade50,
                    Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Spacer(), // pushes the amount to the right
                if (premiumAmount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '₹${_formatAmount(premiumAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),

            // Notes section - only show if present, no extra spacing when absent
            if (customer.notes?.isNotEmpty == true) ...[
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Remark: ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      customer.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0878fe),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade200, width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return NumberFormat('#,##,###').format(amount);
  }

  void _refreshDashboard() {
    setState(() {
      dashboardData = fetchRetailerDashboardStats();
    });
  }
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white, // White background
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents full height
            children: [
              const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF0878fe),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Close the dialog
                      navigator.pop();

                      // Clear token from SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');

                      if (!context.mounted) return;

                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );

                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Logged out successfully'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
