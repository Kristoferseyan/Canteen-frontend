import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserpaymentDetailsBox extends StatelessWidget {
  final String name;
  final String? orderCode;
  final double paymentAmount;
  final String paymentMethod;
  final String? paymentStatus;

  const UserpaymentDetailsBox({
    super.key,
    required this.orderCode,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 500;

            return isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildColumn(Icons.person, "Name", name),
                      _buildColumn(Icons.confirmation_number, "Order Code", orderCode ?? ""),
                      _buildColumn(Icons.attach_money, "Amount",
                          "₱${NumberFormat('#,##0.00').format(paymentAmount)}"),
                      _buildColumn(_getPaymentMethodIcon(), "Payment Method", paymentMethod),
                      _buildColumn(_getStatusIcon(), "Status", paymentStatus ?? "", _getStatusColor()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(Icons.person, "Name", name),
                      _buildRow(Icons.confirmation_number, "Order Code", orderCode!),
                      _buildRow(Icons.attach_money, "Amount",
                          "₱${NumberFormat('#,##0.00').format(paymentAmount)}"),
                      _buildRow(_getPaymentMethodIcon(), "Payment Method", paymentMethod),
                      _buildRow(_getStatusIcon(), "Status", paymentStatus!, _getStatusColor()),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildColumn(IconData icon, String title, String value, [Color? textColor]) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String value, [Color? textColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: textColor ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon() {
    switch (paymentMethod.toLowerCase()) {
      case "credit card":
        return Icons.credit_card;
      case "paypal":
        return Icons.account_balance_wallet;
      case "cash":
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  IconData _getStatusIcon() {
    return paymentStatus?.toLowerCase() == "paid" ? Icons.check_circle : Icons.warning_amber_rounded;
  }

  Color _getStatusColor() {
    switch (paymentStatus?.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "unpaid":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
