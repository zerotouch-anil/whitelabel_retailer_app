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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Customer Details',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFffffff),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Color(0xFFffffff)),
        ),
      ),
      body: Stack(
        children: [
           Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/bg.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(color: Colors.black.withOpacity(0.7)),
              ],
            ),
          ),
         

          // Foreground content
          FutureBuilder<ParticularCustomerData>(
            future: fetchCustomerDetails(widget.customerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Color(0xff0878fe),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              } else {
                final customer = snapshot.data!;
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildCustomerDetailsSection(customer.customerDetails),
                        const SizedBox(height: 30),
                        _buildWarrantyDetailsSection(customer),
                        const SizedBox(height: 30),
                        _buildProductDetailsSection(customer.productDetails),
                        const SizedBox(height: 30),
                        
                        _buildInvoiceDetailsSection(customer.invoiceDetails),
                        const SizedBox(height: 30),

                        _buildDatesSection(customer.dates),
                        const SizedBox(height: 30),
                      ],
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
    return Card(
      color: Color(0xffffffff),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Color(0xff0878fe)),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? ' Not provided' : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey[500] : Color(0xff0878fe),
                fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyRow({
    required String label,
    required String value,
    required String actualAmount,
    required String actualPercent,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Color(0xff0878fe)),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: RichText(
              text: TextSpan(
                children: [
                  // Actual Amount
                  TextSpan(
                    text: "₹$actualAmount ",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 95, 141, 11), // green
                    ),
                  ),
                  // Old Value (strikethrough)
                  if (value.isNotEmpty)
                    TextSpan(
                      text: "(₹$value )",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  // Percent Margin
                  TextSpan(
                    text: "\n$actualPercent% Margin",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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
            label: 'Name',
            value: details.name,
            icon: Icons.person_outline,
          ),
          _buildInfoRow(
            label: 'Email',
            value: details.email,
            icon: Icons.email_outlined,
          ),
          _buildInfoRow(
            label: 'Mobile',
            value: details.mobile,
            icon: Icons.phone_outlined,
          ),
          _buildInfoRow(
            label: 'Alternate Number',
            value: details.alternateNumber,
            icon: Icons.phone_android_outlined,
          ),
          const Divider(height: 24, color: Color(0xFFdccf7b)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: Color(0xff0878fe),
            ),
            const SizedBox(width: 12),
            Text(
              'Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            fullAddress.isEmpty ? 'Not provided' : fullAddress,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: fullAddress.isEmpty ? Colors.grey[500] : Color(0xff0878fe),
              fontWeight:
                  fullAddress.isEmpty ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
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
            icon: Icons.smartphone_outlined,
          ),
          _buildInfoRow(
            label: 'Brand',
            value:
                details.brand == "Others"
                    ? (details.otherBrandName ?? '')
                    : (details.brand),
            icon: Icons.branding_watermark_outlined,
          ),
          _buildInfoRow(
            label: 'Category',
            value: details.category,
            icon: Icons.category_outlined,
          ),
          _buildInfoRow(
            label: 'Serial/Unique/IMEI Number',
            value: details.serialNumber,
            icon: Icons.pin_outlined,
          ),
          _buildInfoRow(
            label: 'Original Warranty',
            value:
                details.originalWarranty > 0
                    ? '${details.originalWarranty} year'
                    : '',
            icon: Icons.pin_outlined,
          ),
          _buildInfoRow(
            label: 'Purchase Price',
            value: details.purchasePrice > 0 ? '₹${details.purchasePrice}' : '',
            icon: Icons.currency_rupee_outlined,
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
            icon: Icons.receipt_outlined,
          ),
          _buildInfoRow(
            label: 'Invoice Date',
            value: _formatDate(details.invoiceDate),
            icon: Icons.calendar_today_outlined,
          ),
          if (details.invoiceImage.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showImageDialog(details.invoiceImage),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    baseUrl + details.invoiceImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey[400],
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
            icon: Icons.vpn_key_outlined,
          ),

          _buildInfoRow(
            label: 'Warranty Period',
            value:
                customer.warrantyDetails.warrantyPeriod > 0
                    ? '${customer.warrantyDetails.warrantyPeriod} months'
                    : '',
            icon: Icons.timer_outlined,
          ),
          _buildInfoRow(
            label: 'Start Date',
            value: _formatDate(customer.warrantyDetails.startDate),
            icon: Icons.play_arrow_outlined,
          ),
          _buildInfoRow(
            label: 'Expiry Date',
            value: _formatDate(customer.warrantyDetails.expiryDate),
            icon: Icons.stop_outlined,
          ),
          _buildMoneyRow(
            label: 'Premium Amount',
            value:
                customer.warrantyDetails.premiumAmount > 0
                    ? '${customer.warrantyDetails.premiumAmount.round()}'
                    : '',
            actualAmount: customer.warrantyDetails.actualAmount,
            actualPercent: customer.warrantyDetails.actualPercent,
            icon: Icons.currency_rupee_outlined,
          ),
          const SizedBox(height: 12),
          if (customer.notes.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_outlined, size: 20, color: Color(0xff0878fe)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
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
                                  color: Color(0xff0878fe), // Yellow border
                                  width: 1,
                                ),
                              ),
                              title: const Text(
                                'Remark',
                                style: TextStyle(color: Color(0xff0878fe)),
                              ),
                              content: SizedBox(
                                height: 200,
                                width: double.maxFinite,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(
                                        color: Color(0xff000000),
                                        thickness: 1,
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        customer.notes,
                                        style: const TextStyle(
                                          color: Color(0xff0878fe),
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
                                    backgroundColor: const Color(0xff0878fe),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remark',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff0878fe),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.transparent : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 16,
                  color: isActive ? Colors.green[700] : Colors.red[700],
                ),
                const SizedBox(width: 6),
                Text(
                  isActive ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green[700] : Colors.red[700],
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

  Widget _buildDatesSection(CustomerDates dates) {
    return _buildSectionCard(
      title: 'Important Dates',
      child: Column(
        children: [
          if (dates.pickedDate != null)
            _buildInfoRow(
              label: 'Picked Date',
              value: _formatDate(dates.pickedDate!),
              icon: Icons.event_outlined,
            ),
          _buildInfoRow(
            label: 'Created Date',
            value: _formatDate(dates.createdDate),
            icon: Icons.add_circle_outline,
          ),
          _buildInfoRow(
            label: 'Last Modified',
            value: _formatDate(dates.lastModifiedDate),
            icon: Icons.update_outlined,
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
