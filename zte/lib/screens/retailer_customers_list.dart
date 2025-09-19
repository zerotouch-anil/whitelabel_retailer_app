import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eWarranty/models/customers_list_model.dart';
import 'package:eWarranty/screens/retailer_customer_details.dart';
import '../services/customer_service.dart';

class RetailerViewCustomers extends StatefulWidget {
  const RetailerViewCustomers({Key? key}) : super(key: key);

  @override
  State<RetailerViewCustomers> createState() => _RetailerViewCustomersState();
}

class _RetailerViewCustomersState extends State<RetailerViewCustomers> {
  List<CustomersData> _allCustomers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  PaginationData? _paginationData;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchCustomers(isRefresh: true);
    _searchController = TextEditingController();
    _initializeDateFields();
    _setupScrollListener();
  }

  void _initializeDateFields() {
    final now = DateTime.now();
    final defaultStartDate = now.subtract(Duration(days: 7));
    final defaultEndDate = now;

    _selectedStartDate = defaultStartDate;
    _selectedEndDate = defaultEndDate;

    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(defaultStartDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(defaultEndDate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_paginationData != null &&
            _paginationData!.currentPage < _paginationData!.totalPages &&
            !_isLoadingMore) {
          _loadMoreCustomers();
        }
      }
    });
  }

  void _fetchCustomers({
    bool isRefresh = false,
    String searchValue = "",
  }) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _allCustomers.clear();
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    final now = DateTime.now();
    final startDate = _selectedStartDate ?? now.subtract(Duration(days: 7));
    final endDate = _selectedEndDate ?? now;

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final response = await fetchAllCustomers({
        "page": _currentPage,
        "limit": 20,
        "startDate": startDateStr,
        "endDate": endDateStr,
        "search": searchValue,
        "sortBy": "createdDate",
        "sortOrder": "desc",
      });

      setState(() {
        if (isRefresh) {
          _allCustomers = response.customers;
        } else {
          _allCustomers.addAll(response.customers);
        }
        _paginationData = response.pagination;
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void _loadMoreCustomers() {
    if (_paginationData != null &&
        _paginationData!.currentPage < _paginationData!.totalPages) {
      setState(() {
        _currentPage++;
        _isLoadingMore = true;
      });
      _fetchCustomers();
    }
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required bool isStart,
  }) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    // Set initial date based on current selection or default
    if (isStart && _selectedStartDate != null) {
      initialDate = _selectedStartDate!;
    } else if (!isStart && _selectedEndDate != null) {
      initialDate = _selectedEndDate!;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        // Use consistent date formatting
        final formatted = DateFormat('dd MMM yyyy').format(pickedDate);
        // OR use: DateFormat('yyyy-MM-dd').format(pickedDate) for different format

        controller.text = formatted;
        if (isStart) {
          _selectedStartDate = pickedDate;
        } else {
          _selectedEndDate = pickedDate;
        }
      });
    }
  }

  void _onSearchPressed() {
    final searchText = _searchController.text.trim();
    _fetchCustomers(
      isRefresh: true,
      searchValue: searchText.isNotEmpty ? searchText : "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Allows AppBar to sit above background
      appBar: AppBar(
        foregroundColor: Color(0xFFffffff),
        backgroundColor: Color(0xff244D9C),
        title: const Text(
          'Customer List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
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
              ],
            ),
          ),
          // Your main content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        children: [
                          // Start Date
                          SizedBox(
                            width:
                                MediaQuery.of(context).size.width > 600
                                    ? 250
                                    : MediaQuery.of(context).size.width / 2 -
                                        24,
                            child: TextField(
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              controller: _startDateController,
                              decoration: _buildInputDecoration('Start Date'),
                              onTap:
                                  () => _pickDate(
                                    controller: _startDateController,
                                    isStart: true,
                                  ),
                            ),
                          ),
                          // End Date
                          SizedBox(
                            width:
                                MediaQuery.of(context).size.width > 600
                                    ? 250
                                    : MediaQuery.of(context).size.width / 2 -
                                        24,
                            child: TextField(
                              readOnly: true,
                              style: const TextStyle(color: Colors.white),
                              controller: _endDateController,
                              decoration: _buildInputDecoration('End Date'),
                              onTap:
                                  () => _pickDate(
                                    controller: _endDateController,
                                    isStart: false,
                                  ),
                            ),
                          ),
                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 🔍 Search Box
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    // Store or process the search value
                                    // e.g., update state or call a debounce function
                                  },
                                  style: const TextStyle(
                                    color: Color(0xFFffffff),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xffffffff),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xff244D9C),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: Color(0xFFffffff),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFffffff),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _onSearchPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFffffff),
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(
                                    12,
                                  ), // Adjust size as needed
                                  elevation: 2,
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.black,
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.search,
                                          color: Color(0xff244D9C),
                                          size: 25,
                                        ),
                              ),

                              const SizedBox(width: 12),

                              // 📊 Pagination Info (Optional)
                              if (_paginationData != null)
                                Text(
                                  '(${_paginationData?.totalData ?? '-'})',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFffffff),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildCustomerList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for consistent TextField style
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: const Icon(Icons.calendar_today, color: Color(0xffffffff)),
      filled: true,
      fillColor: Color(0xff244D9C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFffffff), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFffffff), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xffffffff), width: 2),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_isLoading && _allCustomers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffffffff)),
        ),
      );
    }

    if (_hasError && _allCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
            const SizedBox(height: 16),
            Text(
              'Failed loading customers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                side: MaterialStateProperty.all(
                  const BorderSide(color: Color(0xFFdccf7b), width: 1),
                ),
              ),
              onPressed: () => _fetchCustomers(isRefresh: true),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_allCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No customers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customer data will appear here once available',
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      itemCount: _allCustomers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allCustomers.length && _isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        final customer = _allCustomers[index];
        final screenWidth = MediaQuery.of(context).size.width;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ViewCustomer(customerId: customer.customerId),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff244D9C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Customer Name
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Model Name & Category chips
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.devices,
                                size: 18,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customer.modelName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.category,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customer.category.isNotEmpty
                                      ? customer.category
                                      : "N/A",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildBalanceSection(customer),
                  const SizedBox(height: 16),

                  /// Warranty Key
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff244D9C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.vpn_key,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customer.warrantyKey,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: "monospace",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection(CustomersData customer) {
    final int profit = customer.premiumAmount - customer.actualAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B), // dark green background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white, // white border
          width: 1, // border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Top Row (Amounts + Margin %) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actual Amount
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
                      const SizedBox(width: 4),
                      Text(
                        "${customer.actualAmount}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Premium Amount
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
                      const SizedBox(width: 4),
                      Text(
                        "${customer.premiumAmount}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Margin %
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  "${customer.actualPercent}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// --- Profit Earned Center Box ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade800.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // blue highlight
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
}
