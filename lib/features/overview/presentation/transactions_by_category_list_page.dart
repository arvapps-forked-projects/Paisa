// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:paisa/core/common.dart';
import 'package:paisa/core/widgets/paisa_widget.dart';
import 'package:paisa/features/account/domain/entities/account_entity.dart';
import 'package:paisa/features/category/domain/entities/category.dart';
import 'package:paisa/features/home/presentation/controller/summary_controller.dart';
import 'package:paisa/features/home/presentation/pages/home/home_cubit.dart';
import 'package:paisa/features/home/presentation/pages/summary/widgets/expense_item_widget.dart';
import 'package:paisa/features/transaction/domain/entities/transaction_entity.dart';

class TransactionByCategoryListPage extends StatelessWidget {
  const TransactionByCategoryListPage({
    super.key,
    required this.categoryId,
    required this.summaryController,
  });

  final String categoryId;
  final SummaryController summaryController;

  @override
  Widget build(BuildContext context) {
    final int cid = int.parse(categoryId);
    final List<TransactionEntity> expenses =
        BlocProvider.of<HomeCubit>(context).fetchExpensesFromCategoryId(cid);

    return PaisaAnnotatedRegionWidget(
      color: Colors.transparent,
      child: Scaffold(
        extendBody: true,
        appBar: context.materialYouAppBar(context.loc.transactionsByCategory),
        bottomNavigationBar: SafeArea(
          child: PaisaFilledCard(
            child: ListTile(
              title: Text(
                context.loc.total,
                style: context.titleSmall
                    ?.copyWith(color: context.onSurfaceVariant),
              ),
              subtitle: Text(
                expenses.total.toFormateCurrency(context),
                style: context.titleMedium?.copyWith(
                  color: context.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: expenses.length,
          itemBuilder: (BuildContext context, int index) {
            final AccountEntity? account = BlocProvider.of<HomeCubit>(context)
                .fetchAccountFromId(expenses[index].accountId);
            final CategoryEntity? category = BlocProvider.of<HomeCubit>(context)
                .fetchCategoryFromId(expenses[index].categoryId);
            if (account == null || category == null) {
              return const SizedBox.shrink();
            }
            return ExpenseItemWidget(
              expense: expenses[index],
              account: account,
              category: category,
            );
          },
        ),
      ),
    );
  }
}