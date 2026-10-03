import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/transaction_viewmodel.dart';

class SummaryChartScreen extends StatelessWidget {
  const SummaryChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();
    final income = viewModel.totalIncome;
    final expense = viewModel.totalExpense;
    final total = income + expense;
    final currency = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปภาพรวม')),
      body: total == 0
          ? Center(child: Text('ยังไม่มีข้อมูลเพียงพอสำหรับสรุปผล\nเพิ่มรายการก่อนเพื่อดูกราฟ', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        sections: [
                          PieChartSectionData(value: income, color: AppColors.gold, title: 'รายรับ', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          PieChartSectionData(value: expense, color: AppColors.clay, title: 'รายจ่าย', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _SummaryRow(label: 'รายรับรวม', value: currency.format(income), color: AppColors.gold),
                          const Divider(height: 24),
                          _SummaryRow(label: 'รายจ่ายรวม', value: currency.format(expense), color: AppColors.clay),
                          const Divider(height: 24),
                          _SummaryRow(label: 'คงเหลือ', value: currency.format(income - expense), color: AppColors.jade, bold: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(label, style: Theme.of(context).textTheme.bodyMedium)]),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w600, fontSize: bold ? 18 : 15)),
      ],
    );
  }
}