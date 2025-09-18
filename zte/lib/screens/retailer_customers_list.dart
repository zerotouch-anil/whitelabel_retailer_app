import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eWarranty/models/customers_list_model.dart';
import 'package:eWarranty/screens/retailer_customer_details.dart';
import 'package:eWarranty/utils/wooden_container.dart';
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
        backgroundColor: Colors.transparent,
        title: const Text(
          'Customer List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        
      ),
      
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Color(0xff0878fe))),
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
                                    color: Color(0xFF000000),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: const TextStyle(
                                      color: Color(0xff0878fe),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFffffff),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
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
                                          color: Colors.black,
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
      fillColor: Colors.blue,
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
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
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
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- Customer Name Header ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF1976D2),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.042,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff0878fe),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.yMMMd().format(
                                  customer.createdDate.toLocal(),
                                ),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// --- Product Info ---
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Model Name Container
                        Flexible(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.devices,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    customer.modelName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.036,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Category Container
                        Flexible(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade500.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category,
                                  size: 16,
                                  color: Colors.orange.shade600,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    customer.category.isNotEmpty
                                        ? customer.category
                                        : 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.036,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    /// --- Premium Amount ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.currency_rupee,
                            size: 20,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${customer.premiumAmount}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 5, 145, 40),
                              ),
                            ),
                            Text(
                              'Premium Amount',
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// --- Warranty Key ---
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.security,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              customer.warrantyKey,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'monospace',
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
          ),
        );
      },
    );
  }
}
