import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(CostCalculatorApp());
}

class CostCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CPM Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CostCalculatorScreen(),
    );
  }
}

class CostCalculatorScreen extends StatefulWidget {
  @override
  _CostCalculatorScreenState createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  final TextEditingController _impressionController = TextEditingController();
  final TextEditingController _cpmController = TextEditingController();

  double costUSD = 0.0;
  double costINR = 0.0;
  double usdToInrRate = 0.0;
  final NumberFormat formatter = NumberFormat("#,##0.00");

  @override
  void initState() {
    super.initState();
    fetchExchangeRate();
  }

  Future<void> fetchExchangeRate() async {
    final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        usdToInrRate = data['rates']['INR'];
      });
    } else {
      print('Failed to fetch exchange rate');
    }
  }

  void calculateCost() {
    double impressions = double.tryParse(_impressionController.text) ?? 0.0;
    double cpm = double.tryParse(_cpmController.text) ?? 0.0;

    setState(() {
      costUSD = (impressions / 1000) * cpm;
      costINR = costUSD * usdToInrRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cost Finder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _impressionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Impressions'),
              onChanged: (_) => calculateCost(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cpmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'CPM (\$)'),
              onChanged: (_) => calculateCost(),
            ),
            SizedBox(height: 20),
            Text('Total Cost: \$${formatter.format(costUSD)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Total Cost in INR: ₹${formatter.format(costINR)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            SizedBox(height: 10),
            Text('Live USD to INR: ₹${formatter.format(usdToInrRate)}',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImpressionFinderScreen()),
                );
              },
              child: Text('Find Impressions'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CPMFinderScreen()),
                );
              },
              child: Text('Find CPM'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImpressionFinderScreen extends StatefulWidget {
  @override
  _ImpressionFinderScreenState createState() => _ImpressionFinderScreenState();
}

class _ImpressionFinderScreenState extends State<ImpressionFinderScreen> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _cpmController = TextEditingController();

  double impressions = 0.0;
  final NumberFormat formatter = NumberFormat("#,##0");

  void calculateImpressions() {
    double cost = double.tryParse(_costController.text) ?? 0.0;
    double cpm = double.tryParse(_cpmController.text) ?? 0.0;

    setState(() {
      impressions = (cost * 1000) / cpm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Impression Finder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Cost (₹)'),
              onChanged: (_) => calculateImpressions(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cpmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'CPM (\$)'),
              onChanged: (_) => calculateImpressions(),
            ),
            SizedBox(height: 20),
            Text('Estimated Impressions: ${formatter.format(impressions)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Calculator'),
            ),
          ],
        ),
      ),
    );
  }
}

class CPMFinderScreen extends StatefulWidget {
  @override
  _CPMFinderScreenState createState() => _CPMFinderScreenState();
}

class _CPMFinderScreenState extends State<CPMFinderScreen> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _impressionController = TextEditingController();

  double cpm = 0.0;
  final NumberFormat formatter = NumberFormat("#,##0.00");
  void calculateCPM() {
    double cost = double.tryParse(_costController.text) ?? 0.0;
    double impressions = double.tryParse(_impressionController.text) ?? 0.0;

    setState(() {
      cpm = (cost * 1000) / impressions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CPM Finder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Cost (₹)'),
              onChanged: (_) => calculateCPM(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _impressionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Impressions'),
              onChanged: (_) => calculateCPM(),
            ),
            SizedBox(height: 20),
            Text('CPM: \$${formatter.format(cpm)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
