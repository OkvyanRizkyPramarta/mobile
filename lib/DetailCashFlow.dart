// ignore_for_file: file_names, use_key_in_widget_constructors, must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class DetailCashFlow extends StatefulWidget {
  const DetailCashFlow({Key? key}) : super(key: key);

  @override
  _DetailCashFlowState createState() => _DetailCashFlowState();
}

class _DetailCashFlowState extends State<DetailCashFlow> {
  DatabaseHelper dbHelper = DatabaseHelper();

  void _refreshData() {
    setState(() {
      incomes = dbHelper.getAllIncomes();
      outcomes = dbHelper.getAllOutcomes();
    });
  }

  late Future<List<Income>> incomes;
  late Future<List<Outcome>> outcomes;

  @override
  void initState() {
    super.initState();
    incomes = dbHelper.getAllIncomes();
    outcomes = dbHelper.getAllOutcomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cash Flow'),
      ),
      body: FutureBuilder<List<Income>>(
        future: incomes,
        builder: (context, incomeSnapshot) {
          return FutureBuilder<List<Outcome>>(
            future: outcomes,
            builder: (context, outcomeSnapshot) {
              if (incomeSnapshot.connectionState == ConnectionState.waiting ||
                  outcomeSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (incomeSnapshot.hasError || outcomeSnapshot.hasError) {
                return Text(
                    'Error: ${incomeSnapshot.error ?? outcomeSnapshot.error}');
              } else if ((!incomeSnapshot.hasData ||
                      incomeSnapshot.data!.isEmpty) &&
                  (!outcomeSnapshot.hasData || outcomeSnapshot.data!.isEmpty)) {
                return const Text('Tidak ada data pemasukkan dan pengeluaran.');
              } else {
                final List<Income> incomeData = incomeSnapshot.data ?? [];
                final List<Outcome> outcomeData = outcomeSnapshot.data ?? [];

                // Combine incomeData and outcomeData as needed
                List<dynamic> combinedData = [...incomeData, ...outcomeData];

                // Sort combinedData by tanggal
                combinedData.sort((a, b) {
                  return a.tanggal.compareTo(b.tanggal);
                });

                // Tampilkan data dalam daftar DetailItem
                return ListView.builder(
                  itemCount: combinedData.length,
                  itemBuilder: (context, index) {
                    var item = combinedData[index];
                    return DetailItem(
                      tanggal: item.tanggal,
                      nominal: item is Income
                          ? item.nominal.toStringAsFixed(2)
                          : '-${item.nominal.toStringAsFixed(2)}',
                      keterangan: item.keterangan,
                      isIncome: item is Income,
                      id: item is Income
                          ? item.id
                          : 0, // Use 0 as a default value when id is null
                      refreshData:
                          _refreshData, // Pass the refreshData function
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String tanggal;
  final String nominal;
  final String keterangan;
  final bool isIncome;
  final int id;
  final VoidCallback refreshData;

  DetailItem({
    required this.tanggal,
    required this.nominal,
    required this.keterangan,
    required this.isIncome,
    required this.id,
    required this.refreshData,
  });

  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green : Colors.red,
          child: Icon(
            isIncome ? Icons.arrow_back : Icons.arrow_forward,
            color: Colors.white,
          ),
        ),
        title: Text('Tanggal: $tanggal'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nominal: Rp $nominal'),
            Text('Keterangan: $keterangan'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            if (isIncome) {
              dbHelper.deleteIncome(id).then((rowsDeleted) {
                if (rowsDeleted > 0) {
                  refreshData();
                } else {
                  print('Data Tidak Ditemukan');
                }
              });
            } else {
              dbHelper.deleteOutcome(id).then((rowsDeleted) {
                if (rowsDeleted > 0) {
                  refreshData();
                } else {
                  print('Data Tidak Ditemukan');
                }
              });
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DetailCashFlow(),
  ));
}
