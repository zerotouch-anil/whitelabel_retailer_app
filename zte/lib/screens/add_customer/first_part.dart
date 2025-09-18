import 'package:flutter/material.dart';
import 'package:eWarranty/models/brands_model.dart';
import 'package:eWarranty/models/categories_model.dart';
import 'package:intl/intl.dart';
import 'package:eWarranty/utils/shared_preferences.dart';
import 'package:eWarranty/utils/wooden_container.dart';

class FirstPart extends StatefulWidget {
  final Map<String, dynamic> formData;
  final List<PercentItem> percentList;
  final List<Brand> brands;

  final VoidCallback onNext;
  final int currentPage;
  final int totalPages;

  const FirstPart({
    super.key,
    required this.formData,
    required this.percentList,
    required this.brands,

    required this.onNext,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  State<FirstPart> createState() => _FirstPartState();
}

class _FirstPartState extends State<FirstPart> {
  static const Color _goldenColor = Color(0xff0878fe);

  Brand? selectedBrand;
  int? selectedDuration;
  final _purchasePriceController = TextEditingController();
  final _otherBrandController = TextEditingController();
  bool _isPurchasePriceValid = true;
  bool _showOtherBrandField = false;

  @override
  void initState() {
    super.initState();
    _purchasePriceController.text =
        widget.formData['product']['purchasePrice']?.toString() ?? '';
    _otherBrandController.text =
        widget.formData['product']['otherBrandName']?.toString() ?? '';

    if (selectedBrand?.brandName.toLowerCase() == 'Others') {
      _showOtherBrandField = true;
    }
  }

  @override
  void dispose() {
    _purchasePriceController.dispose();
    _otherBrandController.dispose();
    super.dispose();
  }

  bool _isFormFirstComplete() {
    bool brandValid = widget.formData['product']['brandId'] != null;

    if (_showOtherBrandField) {
      brandValid =
          brandValid &&
          widget.formData['product']['otherBrandName'] != null &&
          widget.formData['product']['otherBrandName']
              .toString()
              .trim()
              .isNotEmpty &&
          widget.formData['product']['otherBrandName'].length >= 2;
    }

    return brandValid &&
        widget.formData['product']['purchasePrice'] != null &&
        widget.formData['product']['originalWarranty'] != null &&
        widget.formData['invoice']['invoiceDate'] != null &&
        widget.formData['warranty']['warrantyPeriod'] != null &&
        widget.formData['warranty']['premiumAmount'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildBrandDropdown(),
            if (_showOtherBrandField) _buildOtherBrandField(),
            _buildPurchasePriceField(),
            _buildOriginalWarrantyDropdown(),
            _buildDatePicker(),
            if (_isCalculationDataAvailable()) ..._buildCalculationSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _isFormFirstComplete()
                          ? () async {
                            final remainingAmount =
                                SharedPreferenceHelper.instance.getInt(
                                  'remainingAmount',
                                ) ??
                                0;
                            final premiumAmount =
                                widget.formData['warranty']['premiumAmount'] ??
                                0;

                            if (premiumAmount > remainingAmount) {
                              // Show popup
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: const Text(
                                      'Insufficient Balance',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    content: const Text(
                                      'Your wallet balance is insufficient to proceed with this transaction.\n'
                                      'Please add funds to your wallet and try again.',
                                      style: TextStyle(
                                        color: Color(0xff0878fe),
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              widget.onNext();
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    // Make a copy of the brands list
    final brands = List<Brand>.from(widget.brands);

    // Move "Others" to the end
    brands.sort((a, b) {
      if (a.brandName == "Others") return 1; // push "Others" down
      if (b.brandName == "Others") return -1; // keep others above
      return a.brandName.compareTo(b.brandName); // normal sorting
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Brand>(
        decoration: InputDecoration(
          labelText: "Brand",
          labelStyle: const TextStyle(color: _goldenColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: _goldenColor.withOpacity(0.1),
        ),
        value: selectedBrand,
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: _goldenColor),
        style: const TextStyle(color: _goldenColor, fontSize: 16),
        items:
            brands.map((brand) {
              return DropdownMenuItem<Brand>(
                value: brand,
                child: Text(
                  brand.brandName,
                  style: const TextStyle(color: _goldenColor),
                ),
              );
            }).toList(),
        onChanged: (Brand? brand) {
          if (brand != null) {
            setState(() {
              selectedBrand = brand;
              widget.formData['product']['brand'] = brand.brandName;
              widget.formData['product']['brandId'] = brand.brandId;

              // Check if "Others" is selected
              _showOtherBrandField = brand.brandName == 'Others';

              // Clear other brand name if not "Others"
              if (!_showOtherBrandField) {
                _otherBrandController.clear();
                widget.formData['product']['otherBrandName'] = null;
              }
            });
            _isFormFirstComplete();
          }
        },
      ),
    );
  }

  Widget _buildOtherBrandField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _otherBrandController,
        decoration: InputDecoration(
          labelText: 'Enter brand name',
          hintText: 'Enter brand name',
          labelStyle: const TextStyle(color: _goldenColor),
          hintStyle: TextStyle(color: _goldenColor.withOpacity(0.6)),
          prefixIcon: const Icon(Icons.edit, color: _goldenColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: _goldenColor.withOpacity(0.1),
        ),
        style: const TextStyle(color: _goldenColor, fontSize: 16),
        onChanged: (value) {
          setState(() {
            widget.formData['product']['otherBrandName'] =
                value.trim().isNotEmpty ? value.trim() : null;
          });
          _isFormFirstComplete();
        },
      ),
    );
  }

  Widget _buildPurchasePriceField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _purchasePriceController,
            decoration: InputDecoration(
              counterText: "",
              labelText: 'Purchase Price',
              labelStyle: const TextStyle(color: _goldenColor),
              prefixIcon: const Icon(Icons.currency_rupee, color: _goldenColor),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: _goldenColor),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _goldenColor),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _isPurchasePriceValid ? _goldenColor : Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: _goldenColor.withOpacity(0.1),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: _goldenColor, fontSize: 16),
            onChanged: (value) {
              setState(() {
                _isPurchasePriceValid = value.length <= 20;

                widget.formData['product']['purchasePrice'] =
                    value.isNotEmpty ? value : null;

                selectedDuration = null;
                widget.formData['warranty']['warrantyPeriod'] = null;
                widget.formData['warranty']['premiumAmount'] = null;
              });
              _isFormFirstComplete();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalWarrantyDropdown() {
    const List<String> warrantyOptions = [
      '1 Year',
      '2 Year',
      '3 Year',
      '4 Year',
      '5 Year',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Original Warranty',
          labelStyle: const TextStyle(color: _goldenColor),
          prefixIcon: const Icon(Icons.verified_outlined, color: _goldenColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _goldenColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: _goldenColor.withOpacity(0.1),
        ),
        value: widget.formData['product']['originalWarranty'],
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: _goldenColor),
        style: const TextStyle(color: _goldenColor, fontSize: 16),
        items:
            warrantyOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(color: _goldenColor),
                ),
              );
            }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              widget.formData['product']['originalWarranty'] = value;
            });
            _isFormFirstComplete();
          }
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    final DateTime today = DateTime.now();
    final DateTime sixMonthsAgo = DateTime(
      today.year,
      today.month - 6,
      today.day,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: widget.formData['invoice']["invoiceDate"] ?? today,
            firstDate: sixMonthsAgo,
            lastDate: today,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: _goldenColor,
                    onPrimary: Colors.white,
                    surface: const Color.fromARGB(255, 79, 107, 117),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.green;
                          }
                          return Colors.black;
                        },
                      ),
                    ),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    return Localizations.override(
                      context: context,
                      locale: Locale('en', 'US'),
                      child: child!,
                    );
                  },
                ),
              );
            },
          );

          if (picked != null) {
            setState(() {
              widget.formData['invoice']["invoiceDate"] = picked;
            });
            _isFormFirstComplete();
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _goldenColor),
            borderRadius: BorderRadius.circular(8),
            color: _goldenColor.withOpacity(0.1),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: _goldenColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.formData['invoice']["invoiceDate"] is DateTime
                      ? 'Invoice Date: ${DateFormat('yyyy-MM-dd').format(widget.formData['invoice']["invoiceDate"])}'
                      : 'Select Invoice Date',
                  style: const TextStyle(color: _goldenColor, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: _goldenColor),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalculationSection() {
    return [
      const SizedBox(height: 16),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _goldenColor,
          ),
        ),
      ),
      const SizedBox(height: 12),
      _buildDetailsCard(),
      const SizedBox(height: 16),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Extended Warranty",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _goldenColor,
          ),
        ),
      ),
      const SizedBox(height: 8),
      ..._buildWarrantyCards(),
    ];
  }

  Widget _buildDetailsCard() {
    return Card(
      color: Color(0xff0878fe),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              Icons.verified,
              "Company Warranty",
              widget.formData['product']["originalWarranty"] ?? "Not selected",
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today,
              "Invoice Date",
              widget.formData['invoice']["invoiceDate"] is DateTime
                  ? DateFormat(
                    'yyyy-MM-dd',
                  ).format(widget.formData['invoice']["invoiceDate"])
                  : 'Not selected',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWarrantyCards() {
    final price =
        double.tryParse(widget.formData['product']["purchasePrice"] ?? "0") ??
        0;

    return widget.percentList.where((item) => item.isActive).map((item) {
      final calculatedAmount = (price * item.percent) / 100;
      final isSelected = selectedDuration == item.duration;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? _goldenColor : _goldenColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        elevation: 2,
        color: isSelected ? _goldenColor.withOpacity(0.1) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.access_time, color: _goldenColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "${item.duration} Month${item.duration > 1 ? 's' : ''}",
                style: const TextStyle(
                  fontSize: 14,
                  color: _goldenColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 100, // limit the width
                child: Text(
                  "₹${calculatedAmount.round()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _goldenColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _goldenColor),
                  ),
                  child: const Text(
                    "Added",
                    style: TextStyle(
                      color: _goldenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedDuration = item.duration;
                      widget.formData['warranty']['warrantyPeriod'] =
                          item.duration;
                      widget.formData['warranty']['premiumAmount'] =
                          calculatedAmount;
                    });
                    _isFormFirstComplete();
                  },
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldenColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  bool _isCalculationDataAvailable() {
    return widget.formData['product']["purchasePrice"] != null &&
        widget.formData['invoice']["invoiceDate"] != null &&
        widget.formData['product']["originalWarranty"] != null &&
        widget.formData['product']["brandId"] != null;
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
