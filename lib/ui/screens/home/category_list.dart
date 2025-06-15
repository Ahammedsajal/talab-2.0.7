import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Talab/data/cubits/category/fetch_category_cubit.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Talab/data/model/category_model.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _expandedCategories = {}; // Store expanded states

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FetchCategoryCubit, FetchCategoryState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is FetchCategoryInProgress) {
          return Center(child: UiUtils.progress());
        }

        if (state is FetchCategorySuccess) {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 Main Category Header (Clickable)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedCategories[category.id!] =
                            !(_expandedCategories[category.id!] ?? false);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: context.color.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.name!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _expandedCategories[category.id!] ?? false
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: context.color.textDefaultColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🟢 Show Subcategories if Expanded
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: (_expandedCategories[category.id!] ?? false)
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Builder(builder: (context) {
                              final screenWidth = MediaQuery.of(context).size.width;
                              final isTablet = screenWidth >= 600 && screenWidth <= 1200;
                              final crossAxisCount = isTablet
                                  ? 3
                                  : screenWidth > 1200
                                      ? 4
                                      : 2;
                              if (isTablet) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 6,
                                    mainAxisSpacing: 6,
                                  ),
                                  itemCount: category.children?.length ?? 0,
                                  itemBuilder: (context, subIndex) {
                                    final subCategory = category.children![subIndex];
                                    return _buildSubCategoryItem(subCategory);
                                  },
                                );
                              }
                              return MasonryGridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                ),
                                itemCount: category.children?.length ?? 0,
                                itemBuilder: (context, subIndex) {
                                  final subCategory = category.children![subIndex];
                                  return _buildSubCategoryItem(subCategory);
                                },
                              );
                            }),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            },
          );
        }

        return Container();
      },
    );
  }

  Widget _buildSubCategoryItem(CategoryModel subCategory) {
    return GestureDetector(
      onTap: () {
        // Handle subcategory click
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                subCategory.url!,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.black.withOpacity(0.6),
                  child: Text(
                    subCategory.name!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
