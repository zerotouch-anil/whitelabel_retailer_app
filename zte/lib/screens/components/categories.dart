import 'package:flutter/material.dart';
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/models/categories_model.dart';
import 'package:eWarranty/screens/add_customer/add_customer_screen.dart';
import 'package:eWarranty/services/catalog_service.dart';

class CategoriesComponent extends StatefulWidget {
  const CategoriesComponent({super.key});

  @override
  State<CategoriesComponent> createState() => _CategoriesComponentState();
}

class _CategoriesComponentState extends State<CategoriesComponent> {
  late Future<List<Categories>> _categoriesFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate dynamic row count based on categories length
  int _calculateRowCount(int categoryCount) {
    if (categoryCount == 0) return 1;
    if (categoryCount <= 3) return 1;
    if (categoryCount <= 6) return 2;
    return 3; // Maximum 3 rows
  }


  int _calculateVisibleColumns(double containerWidth) {
    const double itemWidth = 90.0;
    const double spacing = 12.0;
    return ((containerWidth - 24) / (itemWidth + spacing)).floor();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Categories>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No categories available",
              style: TextStyle(
                color: Color(0xFFdccf7b),
                fontSize: 20,
              ),
            ),
          );
        }

        final categories = snapshot.data!;
        final rowCount = _calculateRowCount(categories.length);

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'Add Customer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  Divider(color: Color(0xff0878fe), thickness: 1, height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      'available Categories',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final visibleColumns = _calculateVisibleColumns(
                      constraints.maxWidth,
                    );
                    final maxVisibleItems = rowCount * visibleColumns;
                    final needsScrolling = categories.length > maxVisibleItems;

                    // Calculate the number of columns based on screen width
                    // Aim for items around 80-90px wide to fit 3 per row
                    final screenWidth = constraints.maxWidth;
                    final itemWidth = 85.0;
                    final spacing = 12.0;
                    final crossAxisCount = ((screenWidth - 24) / (itemWidth + spacing)).floor().clamp(3, 6);

                    // Only show scrollbar when scrolling is needed
                    if (needsScrolling) {
                      return RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 3,
                        radius: const Radius.circular(20),
                        thumbColor: const Color(0xff0878fe),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GridView.builder(
                            controller: _scrollController, // Attach controller to GridView
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.9, // Slightly taller than wide
                                ),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return _buildCategoryItem(category);
                            },
                          ),
                        ),
                      );
                    } else {
                      // No scrollbar when not needed - use Wrap for better layout with few items
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: categories.map((category) {
                              return SizedBox(
                                width: itemWidth,
                                height: itemWidth * 1.1, // Slightly taller
                                child: _buildCategoryItem(category),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(Categories category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => AddCustomerScreen(
                  categoryId: category.categoryId,
                  categoryName: category.categoryName,
                  percentList: category.percentList,
                  videoList: category.video != null ? [category.video!] : [],
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFdccf7b), width: 0.6),
          borderRadius: BorderRadius.circular(7),
          color: const Color(0xff0878fe),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fixed size image container
            SizedBox(
              height: 40,
              width: 40,
              child: Image.network(
                '$baseUrl${category.img}',
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Image load error for: $baseUrl${category.img}');
                  print('Error: $error');
                  return const Icon(
                    Icons.broken_image, 
                    color: Colors.grey,
                    size: 32,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Fixed padding and text styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                category.categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Allow 2 lines for longer category names
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}