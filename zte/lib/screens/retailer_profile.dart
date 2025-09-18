import 'package:flutter/material.dart';
import 'package:eWarranty/models/retailer_profile_model.dart';
import 'package:eWarranty/screens/retailer_change_password.dart';
import 'package:eWarranty/services/retailer_profile_service.dart';

class RetailerProfileScreen extends StatefulWidget {
  const RetailerProfileScreen({super.key});

  @override
  State<RetailerProfileScreen> createState() => _RetailerProfileScreenState();
}

class _RetailerProfileScreenState extends State<RetailerProfileScreen> {
  late Future<List<dynamic>> combinedFuture;

  @override
  void initState() {
    super.initState();
    combinedFuture = Future.wait([fetchRetailerProfile()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color.fromARGB(255, 19, 19, 19),
      appBar: AppBar(
        title: const Text(
          "Retailer Profile",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RetailerChangePasswordScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, color: Colors.white, size: 24),
              tooltip: 'Edit Profile',
              style: IconButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  11,
                  91,
                  189,
                ).withAlpha(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Color(0xff0878fe),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              FutureBuilder<List<dynamic>>(
                future: combinedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment(0, 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading your profile details...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      height:
                          MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).padding.top + kToolbarHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed loading profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final profile = snapshot.data![0] as RetailerProfile;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 660,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHeaderCard(profile),
                              SizedBox(height: 20),

                              _buildContactInfoCard(profile),
                              SizedBox(height: 20),

                              _buildAddressCard(profile.address),
                              SizedBox(height: 20),

                              _buildWalletBalanceCard(profile.walletBalance),
                              SizedBox(height: 20),

                              _buildContactCard(profile.parentUser),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: Text('No data found'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(RetailerProfile profile) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40, color: Color(0xff0878fe)),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name.isNotEmpty ? profile.name : 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff0878fe),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.userType.isNotEmpty ? profile.userType : 'Retailer',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(RetailerProfile profile) {
    return Card(
      elevation: 2,
      color: const Color(0xffffffff),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: Colors.green[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.email,
              'Email',
              profile.email.isNotEmpty ? profile.email : 'Not provided',
              Colors.red[600]!,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.phone,
              'Phone',
              profile.phone.isNotEmpty ? profile.phone : 'Not provided',
              Colors.blue[600]!,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.phone_android,
              'Alternate Phone',
              profile.alternatePhone.isNotEmpty
                  ? profile.alternatePhone
                  : 'Not provided',
              Colors.purple[600]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      elevation: 2,
      color: const Color(0xffffffff),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.home,
              'Street',
              address.street.isNotEmpty ? address.street : 'Not provided',
              Colors.indigo[600]!,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.location_city,
                    'City',
                    address.city.isNotEmpty ? address.city : 'Not provided',
                    Colors.teal[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    Icons.map,
                    'State',
                    address.state.isNotEmpty ? address.state : 'Not provided',
                    Colors.amber[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.public,
                    'Country',
                    address.country.isNotEmpty
                        ? address.country
                        : 'Not provided',
                    Colors.green[600]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    Icons.markunread_mailbox,
                    'ZIP Code',
                    address.zipCode.isNotEmpty
                        ? address.zipCode
                        : 'Not provided',
                    Colors.deepPurple[600]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard(WalletBalance walletBalance) {
    return Card(
      elevation: 2,
      color: const Color(0xffffffff),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Remaining Amount Card
            _buildBalanceCard(
              'Remaining Amount',
              '₹${walletBalance.remainingAmount}',
              Colors.green[600]!,
              Icons.savings,
              isWide: true,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    String title,
    String amount,
    Color color,
    IconData icon, {
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: isWide ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0878fe),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(ParentUser parentUser) {
    return Card(
      elevation: 2,
      color: const Color(0xffffffff),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_emergency,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Contact Person',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContactInfoRow('Name', parentUser.name),
            _buildContactInfoRow('Phone', parentUser.phone),
            _buildContactInfoRow('Email', parentUser.email),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              formatUserType(value),
              style: const TextStyle(
                color: Color(0xff0878fe),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatUserType(String userType) {
    return userType
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
