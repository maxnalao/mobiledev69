import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/category_model.dart';
import '../../domain/models/transaction_kind.dart';
import '../../domain/models/transaction_model.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionKind _kind = TransactionKind.expense;
  DateTime _occurredOn = DateTime.now();
  int? _categoryId;
  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _amountController.text = transaction.amount.toStringAsFixed(0);
      _noteController.text = transaction.note;
      _kind = transaction.kind;
      _occurredOn = transaction.occurredOn;
      _categoryId = transaction.categoryId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  void _loadCategories() {
    context.read<CategoryViewModel>().loadForKind(_kind);
  }

  void _onKindChanged(TransactionKind kind) {
    setState(() {
      _kind = kind;
      _categoryId = null;
    });
    _loadCategories();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _occurredOn, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
    if (picked != null) setState(() => _occurredOn = picked);
  }

  Future<void> _addCategoryDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มหมวดหมู่ใหม่'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'ชื่อหมวดหมู่')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('เพิ่ม')),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;

    final categoryViewModel = context.read<CategoryViewModel>();
    final created = await categoryViewModel.create(name: name, kind: _kind);
    if (created != null) setState(() => _categoryId = created.id);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final transaction = TransactionModel(
      kind: _kind,
      amount: double.parse(_amountController.text),
      note: _noteController.text,
      occurredOn: _occurredOn,
      categoryId: _categoryId,
    );

    final viewModel = context.read<TransactionViewModel>();
    final success = _isEditing ? await viewModel.edit(widget.transaction!.id!, transaction) : await viewModel.add(transaction);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage ?? 'บันทึกรายการไม่สำเร็จ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = context.watch<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการใหม่')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<TransactionKind>(
              segments: const [
                ButtonSegment(value: TransactionKind.expense, label: Text('รายจ่าย'), icon: Icon(Icons.arrow_upward_rounded)),
                ButtonSegment(value: TransactionKind.income, label: Text('รายรับ'), icon: Icon(Icons.arrow_downward_rounded)),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) => _onKindChanged(selection.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'จำนวนเงิน (บาท)', prefixText: '฿ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'กรุณาระบุจำนวนเงิน';
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) return 'จำนวนเงินต้องมากกว่า 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: categoryViewModel.categories.any((c) => c.id == _categoryId) ? _categoryId : null,
                    decoration: InputDecoration(labelText: _kind == TransactionKind.income ? 'ได้มาจาก (หมวดหมู่รายรับ)' : 'หมวดหมู่รายจ่าย'),
                    items: categoryViewModel.categories
                        .map((CategoryModel c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                    hint: Text(categoryViewModel.isLoading ? 'กำลังโหลด...' : 'เลือกหมวดหมู่ (ไม่บังคับ)'),
                  ),
                ),
                IconButton(
                  tooltip: 'เพิ่มหมวดหมู่ใหม่',
                  onPressed: _addCategoryDialog,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(decoration: const InputDecoration(labelText: 'วันที่'), child: Text('${_occurredOn.day}/${_occurredOn.month}/${_occurredOn.year + 543}')),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _noteController, decoration: const InputDecoration(labelText: 'บันทึกช่วยจำ (ไม่บังคับ)')),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}