import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/enum/box_types.dart';
import '../../../data/category/model/category.dart';
import '../../../domain/category/use_case/category_use_case.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required this.getCategoryUseCase,
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(AddCategoryInitial()) {
    on<CategoryEvent>((event, emit) {});
    on<AddOrUpdateCategoryEvent>(_addOrUpdateCategory);
    on<CategoryDeleteEvent>(_deleteCategory);
    on<FetchCategoryFromIdEvent>(_fetchCategoryFromId);
    on<CategoryIconSelectedEvent>(_categoryIcon);
    on<UpdateCategoryBudgetEvent>(_updateCategoryBudget);
    on<CategoryColorSelectedEvent>(_updateCategoryColor);
  }

  final GetCategoryUseCase getCategoryUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  late final box = Hive.box<Category>(BoxType.category.stringValue);
  int? selectedIcon;
  String? categoryTitle;
  String? categoryDesc;
  double? categoryBudget;
  Category? currentCategory;
  bool isBudgetSet = false;
  int? selectedColor;

  Future<void> _fetchCategoryFromId(
    FetchCategoryFromIdEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final int? categoryId = int.tryParse(event.categoryId ?? '');
    if (categoryId == null) return;

    final Category? category = await getCategoryUseCase.execute(categoryId);
    if (category != null) {
      categoryTitle = category.name;
      categoryDesc = category.description;
      categoryBudget = category.budget;
      selectedIcon = category.icon;
      currentCategory = category;
      isBudgetSet = category.isBudget;
      selectedColor = category.color;
      emit(CategorySuccessState(category));
    }
  }

  _addOrUpdateCategory(
    AddOrUpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final String? title = categoryTitle;
    final String? description = categoryDesc;
    final int? icon = selectedIcon;
    final double? budget = categoryBudget;
    final bool setBudget = isBudgetSet;
    final int? color = selectedColor;
    if (icon == null) {
      return emit(const CategoryErrorState('Select category icon'));
    }
    if (title == null) {
      return emit(const CategoryErrorState('Add category title'));
    }

    if (color == null) {
      return emit(const CategoryErrorState('Select category color'));
    }
    if (event.isAddOrUpdate) {
      await addCategoryUseCase.execute(
        icon: icon,
        desc: description,
        name: title,
        budget: budget ?? 0,
        isBudget: setBudget,
        color: color,
      );
    } else {
      if (currentCategory != null) {
        currentCategory!
          ..budget = budget ?? 0
          ..description = description ?? ''
          ..icon = icon
          ..isBudget = setBudget
          ..color = color
          ..name = title;

        await currentCategory!.save();
      }
    }
    emit(CategoryAddedState(isCategoryAddedOrUpdate: event.isAddOrUpdate));
  }

  Future<void> _deleteCategory(
    CategoryDeleteEvent event,
    Emitter<CategoryState> emit,
  ) async {
    await deleteCategoryUseCase.execute(event.category.key);
    emit(CategoryDeletedState());
  }

  void _categoryIcon(
    CategoryIconSelectedEvent event,
    Emitter<CategoryState> emit,
  ) {
    emit(CategoryIconSelectedState(event.categoryIcon));
  }

  _updateCategoryBudget(
    UpdateCategoryBudgetEvent event,
    Emitter<CategoryState> emit,
  ) {
    isBudgetSet = event.isBudget;
    emit(UpdateCategoryBudgetState(event.isBudget));
  }

  _updateCategoryColor(
    CategoryColorSelectedEvent event,
    Emitter<CategoryState> emit,
  ) {
    selectedColor = event.categoryColor;
    emit(CategoryColorSelectedState(event.categoryColor));
  }
}