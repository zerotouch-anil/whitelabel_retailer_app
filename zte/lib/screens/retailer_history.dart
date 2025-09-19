import 'package:flutter/material.dart';
import 'package:eWarranty/models/history_model.dart';
import 'package:eWarranty/services/history_service.dart';
import 'package:eWarranty/utils/wooden_container.dart';

class HistoryData extends StatefulWidget {
  const HistoryData({super.key});

  @override
  State<HistoryData> createState() => _HistoryDataState();
}

class _HistoryDataState extends State<HistoryData> {
  List<RetailerHistoryData> _allHistoryData = [];
  HistoryPaginationData? _historyPaginationData;

  // Filter variables
  String _selectedTransactionType = 'ALL';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 60));
  DateTime _endDate = DateTime.now();

  // Pagination variables
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  final List<String> _transactionTypes = [
    'ALL',
    'ALLOCATION',
    'WARRANTY_USAGE',
    'REVOKE',
    'REFUND',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _allHistoryData.clear();
        _hasMoreData = true;
      }
    });

    try {
      final data = await fetchRetailerHistoryData({
        "page": _currentPage,
        "limit": 20,
        "transactionType": _selectedTransactionType,
        "startDate":
            "${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}",
        "endDate":
            "${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}",
        "sortBy": "createdAt",
        "sortOrder": "desc",
      });

      setState(() {
        if (isRefresh) {
          _allHistoryData = data.retailerHistory;
        } else {
          _allHistoryData.addAll(data.retailerHistory);
        }
        _historyPaginationData = data.historyPagination;
        _hasMoreData = _currentPage < (data.historyPagination?.totalPages ?? 0);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        print('Error loading transactions data: $e');
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (!_hasMoreData || _isLoading) return;

    _currentPage++;
    await _loadData();
  }

  void _onFilterChanged() {
    _loadData(isRefresh: true);
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _onFilterChanged();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _onFilterChanged();
    }
  }

  void _onTransactionTypeChanged(String? value) {
    if (value != null && value != _selectedTransactionType) {
      setState(() {
        _selectedTransactionType = value;
      });
      _onFilterChanged();
    }
  }

  String _formatDate(DateTime date) {
    final istDate = date.toLocal();
    final hour =
        istDate.hour % 12 == 0 ? 12 : istDate.hour % 12; // 12-hour format
    final amPm = istDate.hour >= 12 ? 'PM' : 'AM';

    return '${istDate.day}/${istDate.month}/${istDate.year} '
        '${hour}:${istDate.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTransactionTypeColor(String transactionType) {
    switch (transactionType) {
      case 'ALLOCATION':
        return const Color.fromARGB(255, 3, 65, 5);
      case 'WARRANTY_USAGE':
        return Colors.red;
      case 'REVOKE':
        return Colors.orange;
      case 'REFUND':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDisplayText(String option) {
    switch (option) {
      case 'ALLOCATION':
        return 'CREDIT';
      case 'WARRANTY_USAGE':
        return 'DEBIT';
      default:
        return option; // fallback to original
    }
  }

  IconData _getTransactionTypeIcon(String transactionType) {
    switch (transactionType) {
      case 'ALLOCATION':
        return Icons.add_circle;
      case 'WARRANTY_USAGE':
        return Icons.build;
      case 'REVOKE':
        return Icons.remove_circle;
      case 'REFUND':
        return Icons.money_off;
      default:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xff244D9C),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),

            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFffffff)),
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff244D9C),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTransactionType,
                              onChanged: _onTransactionTypeChanged,
                              isExpanded: true,
                              items:
                                  _transactionTypes.map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        _getDisplayText(
                                          option,
                                        ), 
                                        style: TextStyle(
                                          color:
                                              option == 'ALL'
                                                  ? Colors.black
                                                  : _getTransactionTypeColor(
                                                    option,
                                                  ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectStartDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFFdffffff),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xff244D9C),
                                  ),

                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Start Date',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _formatDateShort(_startDate),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectEndDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xff244D9C),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'End Date',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _formatDateShort(_endDate),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Data List Section
            Expanded(
              child:
                  _allHistoryData.isEmpty && !_isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Color(0xFFE53E3E),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedTransactionType == 'ALL'
                                  ? 'No history data found for the selected date range.'
                                  : 'No $_selectedTransactionType transactions found for the selected date range.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[100],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadData(isRefresh: true),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.black,
                                ),
                                side: MaterialStateProperty.all(
                                  BorderSide(
                                    color: Color(0xFFdccf7b),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Refresh',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: () => _loadData(isRefresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              _allHistoryData.length + (_hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Loading indicator at bottom
                            if (index == _allHistoryData.length) {
                              return _isLoading
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }

                            final history = _allHistoryData[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF2E5BBA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'DATE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(
                                                  history.transactionDate,
                                                ).split(
                                                  ' ',
                                                )[0], // Just date part
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'TIME',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(
                                                      history.transactionDate,
                                                    ).split(' ')[1] ??
                                                    '00:00', // Time part
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  history.transactionType ==
                                                          "WARRANTY_USAGE"
                                                      ? Colors.white
                                                          .withOpacity(0.9)
                                                      : history
                                                              .transactionType ==
                                                          "ALLOCATION"
                                                      ? Colors.white
                                                          .withOpacity(0.9)
                                                      : Colors.grey.withOpacity(
                                                        0.9,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    history.transactionType ==
                                                            "WARRANTY_USAGE"
                                                        ? Colors
                                                            .red // Red border if WARRANTY_USAGE
                                                        : Colors
                                                            .green, // Green border otherwise
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(
                                                        0.2,
                                                      ), // soft shadow color
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              history.transactionType ==
                                                      "WARRANTY_USAGE"
                                                  ? '- ₹${history.amount}'
                                                  : '+ ₹${_getTotalReceived(history)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    history.transactionType ==
                                                            "WARRANTY_USAGE"
                                                        ? Colors.red
                                                        : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Customer Name Section
                                      if (history.transactionType ==
                                          "WARRANTY_USAGE")
                                        _buildModernInfoRow(
                                          Icons.person,
                                          'CUSTOMER NAME',
                                          history
                                                  .customerDetails
                                                  ?.customerName ??
                                              history.fromUser?.name ??
                                              'n/a',
                                        ),

                                      const SizedBox(height: 16),

                                      // Transaction Type and Details Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModernInfoRow(
                                              Icons.swap_horiz,
                                              'TYPE',
                                              _getDisplayText(
                                                history.transactionType,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: _buildModernInfoRow(
                                              Icons.account_balance_wallet,
                                              'BASE AMOUNT',
                                              '₹${history.amount}',
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.95),
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ), // soft shadow color
                                              blurRadius:
                                                  6, // how soft the shadow looks
                                              spreadRadius:
                                                  1, // how much it spreads
                                              offset: const Offset(
                                                0,
                                                3,
                                              ), // x=0, y=3 → shadow below
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        history.transactionType ==
                                                                "WARRANTY_USAGE"
                                                            ? 'DEBIT AMOUNT'
                                                            : 'BONUS AMOUNT',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        history.transactionType ==
                                                                "WARRANTY_USAGE"
                                                            ? '- ₹${history.amount}'
                                                            : '₹${history.bonusAmount}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              history.transactionType ==
                                                                      "WARRANTY_USAGE"
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (history.bonusPercentage !=
                                                        "0" &&
                                                    history.bonusAmount != "0")
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'MARGIN %',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.trending_up,
                                                              size: 16,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              '${history.bonusPercentage}%',
                                                              style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            if (history.bonusAmount != "0" &&
                                                history.bonusPercentage !=
                                                    "0") ...[
                                              const SizedBox(height: 16),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[800],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'TOTAL RECEIVED: ₹${_getTotalReceived(history)}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Policy/Transaction ID Section
                                      if (history.warrantyKey != null ||
                                          history.transactionId != null)
                                        _buildModernInfoRow(
                                          Icons.vpn_key,
                                          history.transactionType ==
                                                  "WARRANTY_USAGE"
                                              ? 'POLICY NUMBER'
                                              : 'TRANSACTION ID',
                                          history.warrantyKey ??
                                              history.transactionId ??
                                              'n/a',
                                        ),

                                      // Notes Section
                                      if (history.notes != null &&
                                          history.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        GestureDetector(
                                          onTap: () {
                                            if (history.notes != null &&
                                                history.notes!.isNotEmpty) {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        const Color(0xffffffff),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),
                                                      side: const BorderSide(
                                                        color: Color(
                                                          0xff244D9C,
                                                        ),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    title: const Text(
                                                      'Remark',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xff244D9C,
                                                        ),
                                                      ),
                                                    ),
                                                    content: SizedBox(
                                                      height: 200,
                                                      width: double.maxFinite,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Divider(
                                                              color: Color(
                                                                0xFF000000,
                                                              ),
                                                              thickness: 1,
                                                            ),
                                                            const SizedBox(
                                                              height: 18,
                                                            ),
                                                            Text(
                                                              history.notes!,
                                                              style:
                                                                  const TextStyle(
                                                                    color: Color(
                                                                      0xff244D9C,
                                                                    ),
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        style: TextButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                0xff244D9C,
                                                              ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 8,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'Close',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onPressed:
                                                            () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.notes,
                                                    size: 16,
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                  ),
                                                ),

                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Remark: ${history.notes!.length > 50 ? history.notes!.substring(0, 50) + "..." : history.notes!}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalReceived(dynamic history) {
    int bonus =
        int.tryParse(history.bonusAmount) ??
        double.tryParse(history.bonusAmount)?.toInt() ??
        0;

    int amount = 0;
    if (history.amount is int) {
      amount = history.amount;
    } else if (history.amount is String) {
      amount =
          int.tryParse(history.amount) ??
          double.tryParse(history.amount)?.toInt() ??
          0;
    } else if (history.amount is double) {
      amount = history.amount.toInt();
    }

    return bonus + amount;
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        ),

        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBonusRow(
    String label,
    String value,
    String percentValue,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹$value',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$percentValue%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
