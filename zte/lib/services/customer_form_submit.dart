import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eWarranty/screens/retailer_drawer.dart';
import 'package:eWarranty/services/customer_service.dart';

Future<void> submitCustomerForm(
  BuildContext context,
  Map<String, dynamic> formData,
) async {
  final combinedData = {
    "customerDetails": {
      "name": formData['customer']['name'] ?? '',
      "email": formData['customer']['email'] ?? '',
      "mobile": formData['customer']['mobile'] ?? '',
      "alternateNumber": formData['customer']['alternateNumber'] ?? '',
      "address": {
        "street": formData['customer']['street'] ?? '',
        "city": formData['customer']['city'] ?? '',
        "state": formData['customer']['state'] ?? '',
        "country": formData['customer']['country'] ?? '',
        "zipCode": formData['customer']['zipCode'] ?? '',
      },
    },
    "productDetails": {
      "modelName": formData['product']['modelName'] ?? '',
      "serialNumber": formData['product']['serialNumber'] ?? '',
      "originalWarranty":
          int.tryParse(
            formData['product']['originalWarranty'].toString().split(' ')[0],
          ) ??
          0,

      "brand": formData['product']['brand'] ?? '',
      "brandId": formData['product']['brandId'] ?? '',
      "otherBrandName": formData['product']['otherBrandName'] ?? '',
      "category": formData['product']['category'] ?? '',
      "categoryId": formData['product']['categoryId'] ?? '',
      "purchasePrice":
          double.tryParse(formData['product']['purchasePrice'] ?? '') ?? 0,
    },
    "notes": formData['notes'] ?? '',
    "invoiceDetails": {
      "invoiceNumber": formData['invoice']['invoiceNumber'] ?? '',
      "invoiceImage":
          formData['invoice']['invoiceImage'] ?? '', // Now a URL string
      "invoiceDate": DateFormat(
        'yyyy-MM-dd',
      ).format(formData['invoice']['invoiceDate']),
    },
    "productImages": {
      "frontImage": formData['images']['frontImage'] ?? '', // Now a URL string
      "backImage": formData['images']['backImage'] ?? '', // Now a URL string
      "leftImage": formData['images']['leftImage'] ?? '', // Now a URL string
      "rightImage": formData['images']['rightImage'] ?? '', // Now a URL string
      "additionalImages":
          formData['images']['additionalImages'] ??
          [], 
    },
    "warrantyDetails": {
      "warrantyPeriod":
          int.tryParse(
            formData['warranty']['warrantyPeriod']?.toString() ?? '',
          ) ??
          0,
      "startDate": DateFormat(
        'yyyy-MM-dd',
      ).format(formData['warranty']['startDate']),
      "expiryDate": DateFormat(
        'yyyy-MM-dd',
      ).format(formData['warranty']['expiryDate']),
      "premiumAmount":
          double.tryParse(
            formData['warranty']['premiumAmount']?.toString() ?? '',
          ) ??
          0,
    },
  };

  debugPrint("FORMDATA: $combinedData", wrapWidth: 1024);

  try {
    final response = await submitCustomerData(combinedData);

    if (context.mounted) {
      final isSuccess =
          response.statusCode == 200 || response.statusCode == 201;

      String serverMessage = '';
      try {
        final decoded = jsonDecode(response.body);
        serverMessage = decoded['message'] ?? '';
      } catch (_) {
        serverMessage =
            isSuccess
                ? 'Customer created successfully!'
                : 'Failed to create customer. Please try again.';
      }

      showStatusDialog(
        context: context,
        isSuccess: isSuccess,
        message: serverMessage,
        onDismiss:
            isSuccess
                ? () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CustomDrawer()),
                  );
                }
                : null, // No navigation if failure
      );
    }
  } catch (e) {
    if (context.mounted) {
      showStatusDialog(
        context: context,
        isSuccess: false,
        message:
            'An error occurred while creating the customer. Please check your connection and try again.',
        // No navigation in catch
      );
    }
  }
}

class StatusDialog extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback? onDismiss;

  const StatusDialog({
    Key? key,
    required this.isSuccess,
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Auto dismiss after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _dismissDialog();
      }
    });
  }

  void _dismissDialog() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  widget.isSuccess
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isSuccess
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              size: 50,
                              color:
                                  widget.isSuccess ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.isSuccess ? 'Success!' : 'Error',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isSuccess ? Colors.green : Colors.red,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress indicator
                    SizedBox(
                      width: double.infinity,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 3),
                        tween: Tween(begin: 1.0, end: 0.0),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isSuccess ? Colors.green : Colors.red,
                            ),
                            minHeight: 4,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dismiss button
                    TextButton(
                      onPressed: _dismissDialog,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: widget.isSuccess ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper function to show the dialog
void showStatusDialog({
  required BuildContext context,
  required bool isSuccess,
  required String message,
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder:
        (context) => StatusDialog(
          isSuccess: isSuccess,
          message: message,
          onDismiss: onDismiss,
        ),
  );
}
