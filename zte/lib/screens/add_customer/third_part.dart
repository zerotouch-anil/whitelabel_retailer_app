import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/models/categories_model.dart';
import 'package:eWarranty/screens/add_customer/components/for_third_part.dart';
import 'package:eWarranty/services/file_handle_service.dart';

class ThirdPart extends StatefulWidget {
  final Map<String, dynamic> formData;

  final VoidCallback onPrevious;
  final int currentPage;
  final int totalPages;
  final VoidCallback onSubmit;
  final List<Video> videoList;

  const ThirdPart({
    required this.formData,
    required this.onPrevious,
    required this.currentPage,
    required this.totalPages,
    required this.onSubmit,
    required this.videoList,
  });

  @override
  State<ThirdPart> createState() => _ThirdPartState();
}

class _ThirdPartState extends State<ThirdPart> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Text controllers for better state management
  late TextEditingController _modelNameController;
  late TextEditingController _serialNumberController;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values
    _modelNameController = TextEditingController(
      text: widget.formData['product']['modelName']?.toString() ?? '',
    );
    _serialNumberController = TextEditingController(
      text: widget.formData['product']['serialNumber']?.toString() ?? '',
    );
    _invoiceNumberController = TextEditingController(
      text: widget.formData['invoice']['invoiceNumber']?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.formData['notes']?.toString() ?? '',
    );

    // Add listeners to update maps and trigger rebuilds
    _modelNameController.addListener(() {
      final trimmedValue = _modelNameController.text.trim();
      widget.formData['product']['modelName'] =
          trimmedValue.isEmpty ? "" : trimmedValue;
      setState(() {}); // Trigger rebuild for button state
    });

    _serialNumberController.addListener(() {
      final trimmedValue = _serialNumberController.text.trim();
      widget.formData['product']['serialNumber'] =
          trimmedValue.isEmpty ? "" : trimmedValue;
      setState(() {});
    });

    _invoiceNumberController.addListener(() {
      final trimmedValue = _invoiceNumberController.text.trim();
      widget.formData['invoice']['invoiceNumber'] =
          trimmedValue.isEmpty ? "" : trimmedValue;
      setState(() {});
    });

    _notesController.addListener(() {
      final trimmedValue = _notesController.text.trim();
      widget.formData['notes'] = trimmedValue.isEmpty ? "" : trimmedValue;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _serialNumberController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // VALIDATION CHECK with debug info
  bool _isFormFirstComplete() {
    String? modelName =
        widget.formData['product']['modelName']?.toString().trim();
    String? serialNumber =
        widget.formData['product']['serialNumber']?.toString().trim();
    String? invoiceNumber =
        widget.formData['invoice']['invoiceNumber']?.toString().trim();

    if (serialNumber != null && serialNumber.length > 15) {
      print('Serial number exceeds 15 digits');
      return false;
    }

    bool isComplete =
        modelName != null &&
        modelName.isNotEmpty &&
        serialNumber != null &&
        serialNumber.isNotEmpty &&
        invoiceNumber != null &&
        invoiceNumber.isNotEmpty &&
        widget.formData['invoice']['invoiceImage'] != null &&
        widget.formData['images']['frontImage'] != null &&
        widget.formData['images']['backImage'] != null &&
        widget.formData['images']['rightImage'] != null &&
        widget.formData['images']['leftImage'] != null;

    return isComplete;
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildSectionHeader(Icons.receipt_long, "Invoice Details"),
              _divider(),
              const SizedBox(height: 16),

              _buildSimpleFieldWithController(
                'Product Name',
                _modelNameController,
              ),
              const SizedBox(height: 5),

              _buildSimpleFieldWithController(
                'Serial / Unique / IMEI Number',
                _serialNumberController,
                errorText:
                    widget.formData['product']['serialNumber'] != null &&
                            widget.formData['product']['serialNumber']
                                    .toString()
                                    .trim()
                                    .length >
                                15
                        ? 'Serial number exceeds 15 digits'
                        : null,
              ),
              const SizedBox(height: 5),

              _buildSimpleFieldWithController(
                'Invoice Number',
                _invoiceNumberController,
              ),
              const SizedBox(height: 16),

              _buildImageBox(
                "invoiceImage",
                "Invoice Image",
                widget.formData['invoice'],
              ),
              const SizedBox(height: 25),

              _buildSectionHeader(Icons.shopping_bag, "Product Images"),
              _divider(),
              const SizedBox(height: 16),

              _buildImageBox(
                "frontImage",
                "Front side product image",
                widget.formData['images'],
              ),
              _buildImageBox(
                "backImage",
                "Back side product image",
                widget.formData['images'],
              ),
              _buildImageBox(
                "rightImage",
                "Right side product image",
                widget.formData['images'],
              ),
              _buildImageBox(
                "leftImage",
                "Left side product image",
                widget.formData['images'],
              ),

              const SizedBox(height: 18),
              _buildSectionHeader(Icons.security, "Warranty Details"),
              _divider(),
              const SizedBox(height: 16),

              _buildSimpleFieldReadOnly(
                'Warranty Period (months)',
                'warrantyPeriod',
              ),
              _buildSimpleFieldReadOnly('Premium Amount', 'premiumAmount'),

              const SizedBox(height: 18),
              _buildSectionHeader(Icons.security, "Remark"),
              _divider(),
              const SizedBox(height: 16),

              _buildSimpleFieldWithController('Add a remark', _notesController),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 49, 48, 43),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 75, 74, 70),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isFormFirstComplete() ? widget.onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFormFirstComplete() ? Colors.green[800] : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 1,
        color: const Color.fromARGB(255, 126, 124, 115),
        width: double.infinity,
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xff244D9C), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFieldWithController(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Color(0xff244D9C)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff244D9C)),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.red),
          filled: true,
          fillColor: const Color(0xffffffff),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff244D9C)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff244D9C), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff244D9C)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff244D9C), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: type,
      ),
    );
  }

  Widget _buildSimpleFieldReadOnly(
    String label,
    String key, [
    TextInputType? type,
  ]) {
    final text = widget.formData['warranty'][key]?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(text: _getRoundedText(text))
          ..selection = TextSelection.collapsed(
            offset: _getRoundedText(text).length,
          ),
        readOnly: true,
        style: const TextStyle(color: Color(0xff244D9C)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff244D9C)),
          filled: true,
          fillColor:  Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff244D9C)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff244D9C), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: type,
      ),
    );
  }

  String _getRoundedText(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      return parsed.toStringAsFixed(
        0,
      ); // Change toFixed(2) if 2 decimals needed
    }
    return value;
  }

  Widget _buildImageBox(
    String key,
    String label,
    Map<String, dynamic> targetMap,
  ) {
    final String? imageUrl = targetMap[key];

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xff244D9C),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff244D9C)),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xffffffff),
            ),
            child:
                _isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrl != null
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            baseUrl + imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    SizedBox(height: 4),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Color(0xff244D9C),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed:
                                  () => ForThirdPart(
                                    context: context,
                                    picker: _picker,
                                    videoList: widget.videoList,
                                    setUploading:
                                        (value) => setState(
                                          () => _isUploading = value,
                                        ),
                                    updateTargetMap:
                                        (key, url) => setState(
                                          () => targetMap[key] = url,
                                        ),
                                    dismissKeyboard: _dismissKeyboard,
                                    uploadFile: uploadFile,
                                    deleteFile: deleteFile,
                                  ).deleteImage(key, targetMap),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        ),
                      ],
                    )
                    : InkWell(
                      onTap: () {
                        _dismissKeyboard();
                        ForThirdPart(
                          context: context,
                          picker: _picker,
                          videoList: widget.videoList,
                          setUploading:
                              (value) => setState(() => _isUploading = value),
                          updateTargetMap:
                              (key, url) =>
                                  setState(() => targetMap[key] = url),
                          dismissKeyboard: _dismissKeyboard,
                          uploadFile: uploadFile,
                          deleteFile: deleteFile,
                        ).showDisclaimerAndPickImage(key, targetMap);
                      },
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 32,
                              color: Color(0xff244D9C),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to capture image',
                              style: TextStyle(color: Color(0xff244D9C)),
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
