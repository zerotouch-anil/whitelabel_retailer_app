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
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFffffff),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xff0878fe),
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
                                    color: Colors.blue,
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
                                    color: Colors.blue,
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

                  const SizedBox(height: 16),

                  // Transaction Type Filter Row
                  Row(
                    children: [
                      const Icon(Icons.filter_list, color: Color(0xFFffffff)),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter by ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFFffffff),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFffffff)),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue,
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
                                        ), // 👈 show mapped text
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
                              child: Card(
                                elevation: 4,
                                color: const Color(0xFFffffff),

                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getTransactionTypeColor(
                                                history.transactionType,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _getTransactionTypeColor(
                                                  history.transactionType,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getTransactionTypeIcon(
                                                    history.transactionType,
                                                  ),
                                                  size: 16,
                                                  color:
                                                      _getTransactionTypeColor(
                                                        history.transactionType,
                                                      ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getDisplayText(
                                                    history.transactionType,
                                                  ), // 👈 mapped label
                                                  style: TextStyle(
                                                    color:
                                                        _getTransactionTypeColor(
                                                          history
                                                              .transactionType,
                                                        ),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            history.transactionType ==
                                                    "WARRANTY_USAGE"
                                                ? '-₹${history.amount}'
                                                : '₹${history.amount}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: _getTransactionTypeColor(
                                                history.transactionType,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      // Customer Information
                                      if (history.transactionType ==
                                          "WARRANTY_USAGE")
                                        _buildInfoRow(
                                          'Customer Name',
                                          history
                                                  .customerDetails
                                                  ?.customerName ??
                                              'n/a',
                                          Icons.person,
                                        ),

                                      const SizedBox(height: 8),

                                      // Warranty Key
                                      if (history.transactionType ==
                                          "WARRANTY_USAGE")
                                        _buildInfoRow(
                                          'Warranty Key',
                                          history.warrantyKey ?? 'n/a',
                                          Icons.vpn_key,
                                        ),

                                      if (history.transactionType ==
                                          "ALLOCATION")
                                        _buildInfoRow(
                                          'Transaction Id',
                                          history.transactionId,
                                          Icons.vpn_key,
                                        ),

                                      const SizedBox(height: 8),

                                      // User Types Row
                                      Row(
                                        children: [
                                          if (history.transactionType ==
                                              "ALLOCATION")
                                            Expanded(
                                              child: _buildInfoRow(
                                                'From',
                                                history.fromUser != null
                                                    ? history.fromUser!.name
                                                    : 'n/a',
                                                Icons.person_outline,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      if (history.transactionType ==
                                              "ALLOCATION" &&
                                          history.bonusAmount != "0" &&
                                          history.bonusPercentage != "0")
                                        _buildBonusRow(
                                          'Bonus amount',
                                          history.bonusAmount,
                                          history.bonusPercentage,
                                          Icons.currency_rupee,
                                        ),
                                      const SizedBox(height: 8),

                                      if (history.notes != null &&
                                          history.notes!.isNotEmpty)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (history.notes != null &&
                                                      history
                                                          .notes!
                                                          .isNotEmpty) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (
                                                        BuildContext context,
                                                      ) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Color(0xffffffff),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  18,
                                                                ),
                                                            side:
                                                                const BorderSide(
                                                                  color: Color(
                                                                    0xff0878fe,
                                                                  ),
                                                                  width: 1,
                                                                ),
                                                          ),
                                                          title: const Text(
                                                            'Remark',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xff0878fe,
                                                              ),
                                                            ),
                                                          ),
                                                          content: SizedBox(
                                                            height: 200,
                                                            width:
                                                                double
                                                                    .maxFinite,
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Divider(
                                                                    color: Color(
                                                                      0xFF000000,
                                                                    ),
                                                                    thickness:
                                                                        1,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 18,
                                                                  ),
                                                                  SingleChildScrollView(
                                                                    child: Text(
                                                                      history
                                                                          .notes!,
                                                                      style: const TextStyle(
                                                                        color: Color(
                                                                          0xff0878fe,
                                                                        ),
                                                                        fontSize:
                                                                            14,
                                                                      ),
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
                                                                      0xff0878fe,
                                                                    ),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          8,
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
                                                                      FontWeight
                                                                          .bold,
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
                                                child: _buildInfoRow(
                                                  'Remark',
                                                  history.notes ?? "n/a",
                                                  Icons.notes,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                      const SizedBox(height: 12),

                                      // Date
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xff0878fe),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(
                                                history.transactionDate,
                                              ),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
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
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Color(0xff0878fe)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
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
                  color: Color(0xff0878fe),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    // Rupee icon before value
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.currency_rupee,
                        size: 20,
                        color: Color.fromARGB(255, 95, 141, 11), // green
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 95, 141, 11), // green
                      ),
                    ),
                    TextSpan(
                      text: " ($percentValue%)",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
