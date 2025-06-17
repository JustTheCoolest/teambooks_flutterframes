import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class ReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> receiptData;
  final String? donorEmail;

  const ReceiptDialog({super.key, required this.receiptData, this.donorEmail});

  @override
  Widget build(BuildContext context) {
    final String receiptText =
        receiptData['receipt'] as String? ?? 'Error: Receipt not generated.';
    final String donorId = receiptData['donorId'] as String? ?? 'N/A';
    final int bookCount = receiptData['registeredBookCount'] as int? ?? 0;

    return AlertDialog(
      title: const Text('Donation Receipt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (donorEmail != null && donorEmail!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "A copy of this receipt will be sent to: $donorEmail",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            if (donorEmail == null || donorEmail!.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "No donor email was provided for an e-receipt.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            const Text(
              "Thank you for your donation!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Donor ID: $donorId"),
            Text("Books Registered: $bookCount"),
            const SizedBox(height: 15),
            const Text(
              "Full Receipt Details:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.0),
                color: Colors.grey.shade50,
              ),
              child: SelectableText(
                receiptText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.copy_all_outlined),
          tooltip: 'Copy Receipt Text',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: receiptText));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt copied to clipboard')),
            );
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
