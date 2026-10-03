import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/transaction_viewmodel.dart';

/// Extra feature: summary statistics with charts.
class SummaryChartScreen extends StatefulWidget {
  const SummaryChartScreen({super.key});

  @override
  State<SummaryChartScreen> createState() => _SummaryChartScreenState();
}

class _SummaryChartScreenState extends State<SummaryChartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TransactionViewModel>();
      if (viewModel.transactions.isEmpty) viewModel.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('สรุปภาพรวม')),
      body: viewModel.isLoading && viewModel.transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : viewModel.transactions.isEmpty
              ? Center(
                  child: Text(
                    'ยังไม่มีข้อมูลเพียงพอสำหรับสรุปผล\nเพิ่มรายการก่อนเพื่อดูกราฟ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        _BalanceCard(income: viewModel.totalIncome, expense: viewModel.totalExpense),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'รายรับ-รายจ่าย 6 เดือนล่าสุด',
                          subtitle: 'แตะที่แท่งกราฟเพื่อดูจำนวนเงิน',
                          child: _MonthlyBarChart(data: viewModel.monthlyTotals()),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'รายจ่ายแยกตามหมวดหมู่',
                          child: _CategoryBreakdown(data: viewModel.expenseByCategory, total: viewModel.totalExpense),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

final _baht = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);

class _BalanceCard extends StatelessWidget {
  final double income;
  final double expense;

  const _BalanceCard({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    final spentRatio = income > 0 ? (expense / income) : (expense > 0 ? 1.0 : 0.0);
    final overspent = expense > income;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.jade, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ยอดคงเหลือทั้งหมด', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(_baht.format(balance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: spentRatio.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(overspent ? Colors.redAccent.shade100 : AppColors.gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            income > 0
                ? (overspent
                    ? 'ใช้จ่ายเกินรายรับ ${_baht.format(expense - income)}'
                    : 'ใช้ไป ${(spentRatio * 100).toStringAsFixed(spentRatio < 0.1 ? 1 : 0)}% ของรายรับ')
                : 'ยังไม่มีรายรับ',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'รายรับรวม', value: _baht.format(income), icon: Icons.arrow_downward_rounded, color: AppColors.gold)),
              const SizedBox(width: 12),
              Expanded(child: _MiniStat(label: 'รายจ่ายรวม', value: _baht.format(expense), icon: Icons.arrow_upward_rounded, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            if (subtitle != null)
              Text(subtitle!, style: textTheme.bodyMedium?.copyWith(fontSize: 12, color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<({DateTime month, double income, double expense})> data;

  const _MonthlyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final axisStyle = TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7));
    final compact = NumberFormat.compact(locale: 'en');
    final monthLabel = DateFormat('MMM', 'th');
    final maxValue = data.fold<double>(0, (m, d) => [m, d.income, d.expense].reduce((a, b) => a > b ? a : b));

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: AppColors.gold, label: 'รายรับ'),
            SizedBox(width: 20),
            _Legend(color: AppColors.clay, label: 'รายจ่าย'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxValue == 0 ? 100 : maxValue * 1.15,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      return SideTitleWidget(axisSide: meta.axisSide, child: Text(compact.format(value), style: axisStyle));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(monthLabel.format(data[value.toInt()].month), style: axisStyle),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.ink,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    '${rodIndex == 0 ? 'รายรับ' : 'รายจ่าย'}\n${_baht.format(rod.toY)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(toY: data[i].income, color: AppColors.gold, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      BarChartRodData(toY: data[i].expense, color: AppColors.clay, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<({String category, double amount})> data;
  final double total;

  const _CategoryBreakdown({required this.data, required this.total});

  static const _palette = [
    AppColors.clay,
    AppColors.gold,
    AppColors.jade,
    Color(0xFF4F7CAC),
    Color(0xFF8E6BB8),
    Color(0xFFD08C60),
    Color(0xFF5E9E8F),
    Color(0xFF9A8F7A),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || total == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('ยังไม่มีรายจ่าย', style: Theme.of(context).textTheme.bodyMedium)),
      );
    }

    Color colorAt(int i) => _palette[i % _palette.length];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 56,
                  startDegreeOffset: -90,
                  sections: [
                    for (var i = 0; i < data.length; i++)
                      PieChartSectionData(value: data[i].amount, color: colorAt(i), radius: 28, showTitle: false),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('รายจ่ายรวม', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  Text(_baht.format(total), style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < data.length; i++)
          _CategoryRow(
            color: colorAt(i),
            name: data[i].category,
            amount: data[i].amount,
            ratio: data[i].amount / total,
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Color color;
  final String name;
  final double amount;
  final double ratio;

  const _CategoryRow({required this.color, required this.name, required this.amount, required this.ratio});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: textTheme.bodyLarge)),
              Text('${(ratio * 100).toStringAsFixed(0)}%', style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: Text(_baht.format(amount), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
