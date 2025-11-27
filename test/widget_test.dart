import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard_financeiro/app.dart';
import 'package:dashboard_financeiro/blocs/transaction/transaction_bloc.dart';
import 'package:dashboard_financeiro/blocs/transaction/transaction_event.dart';
import 'package:dashboard_financeiro/blocs/category/category_bloc.dart';
import 'package:dashboard_financeiro/blocs/category/category_event.dart';
import 'package:dashboard_financeiro/blocs/filter/filter_bloc.dart';
import 'package:dashboard_financeiro/blocs/report/report_bloc.dart';

Widget createTestApp() {
	return MultiBlocProvider(
		providers: [
			BlocProvider(create: (_) => TransactionBloc()..add(LoadTransactions())),
			BlocProvider(create: (_) => CategoryBloc()..add(LoadCategories())),
			BlocProvider(create: (_) => FilterBloc()),
			BlocProvider(create: (_) => ReportBloc()),
		],
		child: const MyApp(),
	);
}

void main() {
	group('Dashboard App Tests', () {
		testWidgets('App starts and displays AppBar with title', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Verify AppBar title
			expect(find.text('G-Finance'), findsOneWidget);
		});

		testWidgets('FAB is present and tappable', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Verify FAB is present
			expect(find.byType(FloatingActionButton), findsOneWidget);
		});

		testWidgets('Can open add transaction bottom sheet via FAB', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Tap FAB
			await tester.tap(find.byType(FloatingActionButton));
			await tester.pumpAndSettle(const Duration(milliseconds: 500));
			
			// Verify bottom sheet appears with title
			expect(find.text('Adicionar transação'), findsOneWidget);
		});

		testWidgets('Bottom sheet has form fields', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Tap FAB
			await tester.tap(find.byType(FloatingActionButton));
			await tester.pumpAndSettle(const Duration(milliseconds: 500));
			
			// Verify form elements exist
			expect(find.byType(TextField), findsWidgets);
			expect(find.text('Cancelar'), findsOneWidget);
			expect(find.byType(SingleChildScrollView), findsWidgets);
		});

		testWidgets('Can fill form fields in bottom sheet', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Tap FAB
			await tester.tap(find.byType(FloatingActionButton));
			await tester.pumpAndSettle(const Duration(milliseconds: 500));
			
			// Get all text fields
			final textFields = find.byType(TextField);
			expect(textFields, findsWidgets);
			
			// Enter text in first field (title)
			await tester.enterText(textFields.first, 'Test Transaction');
			await tester.pumpAndSettle();
			
			// Verify text was entered
			expect(find.text('Test Transaction'), findsOneWidget);
		});

		testWidgets('Can close bottom sheet with Cancel button', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Tap FAB
			await tester.tap(find.byType(FloatingActionButton));
			await tester.pumpAndSettle(const Duration(milliseconds: 500));
			
			// Verify bottom sheet is open
			expect(find.text('Adicionar transação'), findsOneWidget);
			
			// Tap Cancel button
			await tester.tap(find.text('Cancelar'));
			await tester.pumpAndSettle(const Duration(milliseconds: 500));
			
			// Verify bottom sheet is closed
			expect(find.text('Adicionar transação'), findsNothing);
		});

		testWidgets('Bottom sheet is scrollable and handles content', (WidgetTester tester) async {
			await tester.pumpWidget(createTestApp());
			await tester.pumpAndSettle(const Duration(seconds: 2));
			
			// Tap FAB
			await tester.tap(find.byType(FloatingActionButton));
			await tester.pumpAndSettle(const Duration(milliseconds: 500));
			
			// Verify SingleChildScrollView is used (for keyboard handling)
			expect(find.byType(SingleChildScrollView), findsWidgets);
			
			// Verify we can find Padding (for viewInsets.bottom)
			expect(find.byType(Padding), findsWidgets);
		});
	});
}
