import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondPart extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int currentPage;
  final int totalPages;

  SecondPart({
    required this.data,
    required this.onNext,
    required this.onPrevious,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  State<SecondPart> createState() => _SecondPartState();
}

class _SecondPartState extends State<SecondPart> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _fieldErrors = {};
  bool _isLocationFetched = false;
  bool _isLocationFetching = false;
  String _locationErrorMessage = '';
  bool _hasValidationRun = false;

  final List<String> _basicFields = [
    'name',
    'email',
    'mobile',
    'alternateNumber',
    'street',
    'zipCode',
  ];

  final List<String> _locationFields = ['city', 'state', 'country'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers for all fields
    for (var key in [..._basicFields, ..._locationFields]) {
      _controllers[key] = TextEditingController(text: widget.data[key] ?? '');
      _controllers[key]!.addListener(() {
        widget.data[key] = _controllers[key]!.text;

        // Clear validation errors when user starts typing (only if validation has run before)
        if (_hasValidationRun && _fieldErrors[key] != null) {
          setState(() {
            _fieldErrors[key] = null;
          });
        }

        if (key == 'zipCode') {
          _handleZipCodeChange(_controllers[key]!.text);
        }
      });
    }

    // Check if location data already exists
    if (widget.data['city']?.isNotEmpty == true) {
      _isLocationFetched = true;
    }
  }

  void _handleZipCodeChange(String zipCode) {
    // Clear location error when zip code changes
    if (_locationErrorMessage.isNotEmpty) {
      setState(() {
        _locationErrorMessage = '';
      });
    }

    if (zipCode.length == 6) {
      _fetchLocationFromPin(zipCode);
    } else {
      setState(() {
        _isLocationFetched = false;
        // Clear location fields
        for (var field in _locationFields) {
          _controllers[field]?.clear();
          widget.data[field] = '';
        }
      });
    }
  }

  bool _validateField(String key) {
    final value = _controllers[key]!.text.trim();
    String? error;

    switch (key) {
      case 'name':
        if (value.isEmpty) {
          error = 'Name is required';
        }
        break;

      case 'email':
        if (value.isEmpty) {
          error = 'Email is required';
        } else if (!_isValidEmail(value)) {
          error = 'Enter a valid email address';
        }
        break;

      case 'mobile':
      case 'alternateNumber':
        if (value.isEmpty) {
          error =
              '${key == 'mobile' ? 'Mobile' : 'Alternate'} number is required';
        } else if (value.length < 10) {
          error = 'Enter a valid phone number (min 10 digits)';
        }
        break;

      case 'street':
        if (value.isEmpty) {
          error = 'Street address is required';
        }
        break;

      case 'zipCode':
        if (value.isEmpty) {
          error = 'Zip code is required';
        } else if (value.length != 6) {
          error = 'Zip code must be 6 digits';
        }
        break;

      case 'city':
      case 'state':
      case 'country':
        if (_isLocationFetched && value.isEmpty) {
          error = '${_capitalizeFirst(key)} is required';
        }
        break;
    }

    _fieldErrors[key] = error;
    return error == null;
  }

  bool _validateAllFields() {
    _hasValidationRun = true;
    bool isValid = true;

    // Validate all basic fields
    for (String key in _basicFields) {
      if (!_validateField(key)) {
        isValid = false;
      }
    }

    // Check zip code specific validation
    if (widget.data['zipCode']?.length == 6) {
      if (!_isLocationFetched) {
        if (_locationErrorMessage.isEmpty) {
          setState(() {
            _locationErrorMessage =
                'Please wait for location to load or enter a valid zip code';
          });
        }
        isValid = false;
      } else {
        // Validate location fields if location is fetched
        for (String key in _locationFields) {
          if (!_validateField(key)) {
            isValid = false;
          }
        }
      }
    }

    return isValid;
  }

  void _handleNextButtonClick() {
    setState(() {
      // Clear previous errors
      _fieldErrors.clear();
      _locationErrorMessage = '';
    });

    if (_validateAllFields()) {
      widget.onNext();
    } else {
      setState(() {}); // Trigger rebuild to show validation errors
    }
  }

  Future<void> _fetchLocationFromPin(String pin) async {
    if (pin.length != 6) return;

    setState(() {
      _isLocationFetching = true;
      _locationErrorMessage = '';
    });

    try {
      final url = Uri.parse('https://api.postalpincode.in/pincode/$pin');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          final city = postOffice['District'];
          final state = postOffice['State'];
          final country = postOffice['Country'];

          setState(() {
            _controllers['city']?.text = city;
            _controllers['state']?.text = state;
            _controllers['country']?.text = country;

            widget.data['city'] = city;
            widget.data['state'] = state;
            widget.data['country'] = country;

            _isLocationFetched = true;
            _isLocationFetching = false;
          });
        } else {
          _handleLocationFetchError();
        }
      } else {
        _handleLocationFetchError();
      }
    } catch (e) {
      _handleLocationFetchError();
    }
  }

  void _handleLocationFetchError() {
    setState(() {
      _isLocationFetched = false;
      _isLocationFetching = false;
      _locationErrorMessage = 'Enter Valid zip code';

      // Clear location fields
      for (var field in _locationFields) {
        _controllers[field]?.clear();
        widget.data[field] = '';
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildSimpleField(
    String label,
    bool readOnly,
    String key, [
    TextInputType? inputType,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _controllers[key],
        readOnly: readOnly,
        keyboardType: inputType,
        inputFormatters: _getInputFormatters(key),
        style: const TextStyle(color: Color(0xff244D9C)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff244D9C)),
          errorText: _fieldErrors[key],
          errorStyle: const TextStyle(color: Colors.red),
          filled: true,
          fillColor: const Color(0xffffffff),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  _fieldErrors[key] != null
                      ? Colors.red
                      : const Color(0xff244D9C),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  _fieldErrors[key] != null
                      ? Colors.red
                      : const Color(0xff244D9C),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  List<TextInputFormatter> _getInputFormatters(String key) {
    switch (key) {
      case 'mobile':
      case 'alternateNumber':
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ];
      case 'zipCode':
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ];
      default:
        return [];
    }
  }

  Widget _buildLocationSection() {
    if (_controllers['zipCode']!.text.length != 6) {
      return const SizedBox.shrink();
    }

    if (_isLocationFetching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff244D9C)),
          ),
        ),
      );
    }

    if (_locationErrorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _locationErrorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLocationFetched) {
      return Column(
        children: [
          _buildSimpleField('City', true, 'city'),
          _buildSimpleField('State', true, 'state'),
          _buildSimpleField('Country', true, 'country'),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildSimpleField('Full Name', false, 'name'),
                  _buildSimpleField(
                    'Email',
                    false,
                    'email',
                    TextInputType.emailAddress,
                  ),
                  _buildSimpleField(
                    'Mobile Number',
                    false,
                    'mobile',
                    TextInputType.phone,
                  ),
                  _buildSimpleField(
                    'Alternate Number',
                    false,
                    'alternateNumber',
                    TextInputType.phone,
                  ),
                  _buildSimpleField('Street Address', false, 'street'),
                  _buildSimpleField(
                    'Zip Code',
                    false,
                    'zipCode',
                    TextInputType.number,
                  ),
                  _buildLocationSection(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Previous button
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

                  // Next button - Always enabled, validation happens on click
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleNextButtonClick,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
