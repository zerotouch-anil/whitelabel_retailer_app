import 'package:flutter/material.dart';
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/models/customer_details_model.dart';
import 'package:eWarranty/services/customer_service.dart';

class ViewCustomer extends StatefulWidget {
  final String customerId;

  const ViewCustomer({super.key, required this.customerId});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Customer Details',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff244D9C),
        foregroundColor: const Color(0xFFffffff),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Foreground content
          FutureBuilder<ParticularCustomerData>(
            future: fetchCustomerDetails(widget.customerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong!',
                        style: TextStyle(fontSize: 16, color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                );
              } else {
                final customer = snapshot.data!;
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: Color(0xFF244D9C), // semi-transparent
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildCustomerDetailsSection(
                            customer.customerDetails,
                          ),
                          _buildYellowDivider(),
                          _buildWarrantyDetailsSection(customer),
                          _buildYellowDivider(),
                          _buildProductDetailsSection(customer.productDetails),
                          _buildYellowDivider(),
                          _buildInvoiceDetailsSection(customer.invoiceDetails),
                          _buildYellowDivider(),
                          _buildDatesSection(customer.dates),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Color? borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.yellow,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildYellowDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 1,
      width: double.infinity,
      color: Colors.yellow,
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        value.isEmpty
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyRow({
    required int premiumAmount,
    required int actualAmount,
    required int actualPercent,
  }) {
    final profit = premiumAmount - actualAmount;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B), // dark green like screenshot
        border: Border.all(
          color: Colors.white, // white border
          width: 1, // border width
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Row: Actual Amount + Margin % ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ACTUAL AMOUNT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 16,
                        color: Colors.white70,
                      ),
                      Text(
                        "$actualAmount",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// --- Margin Badge ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$actualPercent%",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// --- Premium Amount ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PREMIUM AMOUNT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: Colors.white70,
                  ),
                  Text(
                    "$premiumAmount",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// --- Profit Earned ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade700.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "Profit Earned ",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: "₹$profit",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffffff), // blue like screenshot
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsSection(CustomerDetails details) {
    return _buildSectionCard(
      title: 'Customer Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Customer Name',
            value: details.name,
            icon: Icons.person,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Email Id',
            value: details.email,
            icon: Icons.email,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Mobile Number',
            value: details.mobile,
            icon: Icons.phone,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Alternate Phone',
            value: details.alternateNumber,
            icon: Icons.phone_android,
          ),
          const SizedBox(height: 12),
          _buildAddressSection(details.address),
        ],
      ),
      borderColor: Colors.purple[600],
    );
  }

  Widget _buildAddressSection(Address address) {
    final fullAddress = [
      address.street,
      address.city,
      address.state,
      address.country,
      address.zipCode,
    ].where((element) => element.isNotEmpty).join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_on,
            size: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADDRESS:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fullAddress.isEmpty ? 'Not provided' : fullAddress,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      fullAddress.isEmpty
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarrantyDetailsSection(ParticularCustomerData customer) {
    final bool isActive = customer.warrantyDetails.expiryDate.isAfter(
      DateTime.now(),
    );

    return _buildSectionCard(
      title: 'Warranty Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Warranty Key',
            value: customer.warrantyKey,
            icon: Icons.vpn_key,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Warranty Period',
            value:
                customer.warrantyDetails.warrantyPeriod > 0
                    ? '${customer.warrantyDetails.warrantyPeriod} Months'
                    : '',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Start Date',
            value: _formatDate(customer.warrantyDetails.startDate),
            icon: Icons.play_arrow,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Expiry Date',
            value: _formatDate(customer.warrantyDetails.expiryDate),
            icon: Icons.stop,
          ),
          const SizedBox(height: 12),
          _buildMoneyRow(
            premiumAmount: customer.warrantyDetails.premiumAmount,
            actualAmount: customer.warrantyDetails.actualAmount,
            actualPercent: customer.warrantyDetails.actualPercent,
          ),

          if (customer.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (customer.notes.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xffffffff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: Color(0xff244D9C),
                            width: 1,
                          ),
                        ),
                        title: const Text(
                          'Remark',
                          style: TextStyle(color: Color(0xff244D9C)),
                        ),
                        content: SizedBox(
                          height: 200,
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(
                                  color: Color(0xff000000),
                                  thickness: 1,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  customer.notes,
                                  style: const TextStyle(
                                    color: Color(0xff244D9C),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xff244D9C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REMARK:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? 'Active' : 'Expired',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      borderColor: Colors.green[600],
    );
  }

  Widget _buildProductDetailsSection(ProductDetails details) {
    return _buildSectionCard(
      title: 'Product Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Model Name',
            value: details.modelName,
            icon: Icons.smartphone,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Brand',
            value:
                details.brand == "Others"
                    ? (details.otherBrandName ?? '')
                    : (details.brand),
            icon: Icons.branding_watermark,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Category',
            value: details.category,
            icon: Icons.category,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'IMEI Number',
            value: details.serialNumber,
            icon: Icons.confirmation_number,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Original Warranty',
            value:
                details.originalWarranty > 0
                    ? '${details.originalWarranty} Year'
                    : '',
            icon: Icons.verified_user,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Purchase Price',
            value: details.purchasePrice > 0 ? '₹${details.purchasePrice}' : '',
            icon: Icons.currency_rupee,
          ),
        ],
      ),
      borderColor: Colors.green[600],
    );
  }

  Widget _buildInvoiceDetailsSection(InvoiceDetails details) {
    return _buildSectionCard(
      title: 'Invoice Information',
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Invoice Number',
            value: details.invoiceNumber,
            icon: Icons.receipt_long,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Invoice Date',
            value: _formatDate(details.invoiceDate),
            icon: Icons.calendar_today,
          ),
          if (details.invoiceImage.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showImageDialog(details.invoiceImage),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    baseUrl + details.invoiceImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.white.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white.withOpacity(0.5),
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      borderColor: Colors.pink[600],
    );
  }

  Widget _buildDatesSection(CustomerDates dates) {
    return _buildSectionCard(
      title: 'Important Dates',
      child: Column(
        children: [
          if (dates.pickedDate != null) ...[
            _buildInfoRow(
              label: 'Picked Date',
              value: _formatDate(dates.pickedDate!),
              icon: Icons.event,
            ),
            const SizedBox(height: 12),
          ],
          _buildInfoRow(
            label: 'Created Date',
            value: _formatDate(dates.createdDate),
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            label: 'Last Modified',
            value: _formatDate(dates.lastModifiedDate),
            icon: Icons.update,
          ),
        ],
      ),
      borderColor: Colors.blue[600],
    );
  }

  String _formatDate(DateTime date) {
    final istDate = date.toLocal();
    return '${istDate.day}/${istDate.month}/${istDate.year}';
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  baseUrl + imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
