import 'package:flutter/material.dart';

void main() {
  runApp(const OptionRiskApp());
}

class OptionRiskApp extends StatelessWidget {
  const OptionRiskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff97ea6b),
          brightness: Brightness.light,
          primary: const Color(0xff60b246),
          primaryContainer: const Color(0xffc4f5be),
          secondary: const Color(0xff4caf50),
          secondaryContainer: const Color(0xffe3fadc),
        ),
        scaffoldBackgroundColor: const Color(0xfff7ffef),
      ),
      home: const RiskCalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RiskCalculatorScreen extends StatefulWidget {
  const RiskCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<RiskCalculatorScreen> createState() => _RiskCalculatorScreenState();
}

class _RiskCalculatorScreenState extends State<RiskCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  double? capital, entryPrice, stopLoss;
  double maxRiskPct = 12.0;
  int? totalLots, buy1Lots, buy2Lots, lotSize = 75;
  double? maxRiskAmount, avgPrice;
  String? optionType = 'Nifty';

  final Map<String, int> lotSizes = {
    'Nifty': 75,
    'Bank Nifty': 35,       // Updated lot size
    'Sensex': 20,
    'Natural Gas': 1250,
    'Crude Oil': 100,
  };

  final Map<String, int> averagePointsMap = {
    'Nifty': 20,
    'Bank Nifty': 40,       // Updated average points
    'Sensex': 50,
    'Natural Gas': 2,
    'Crude Oil': 20,
  };

  void updateLotSize(String? selected) {
    setState(() {
      optionType = selected;
      lotSize = lotSizes[selected];
    });
  }

  void calculate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      maxRiskAmount = (maxRiskPct / 100) * capital!;
      final riskPerLot = stopLoss! * lotSize!;
      totalLots = (riskPerLot == 0) ? 0 : (maxRiskAmount! / riskPerLot).floor();

      buy1Lots = totalLots != null ? (totalLots! / 2).floor() : 0;
      buy2Lots = totalLots != null ? totalLots! - buy1Lots! : 0;

      int avgPointsBelow = averagePointsMap[optionType] ?? 20;

      avgPrice = (totalLots != null && totalLots != 0)
          ? ((buy1Lots! * entryPrice!) + (buy2Lots! * (entryPrice! - avgPointsBelow))) /
              (buy1Lots! + buy2Lots!)
          : null;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options Lot Size & Risk Calculator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900, minWidth: 320),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
              child: isNarrow
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormCard(),
                          const SizedBox(height: 24),
                          if (totalLots != null) _buildResultsCard(context),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildFormCard(),
                        ),
                        const SizedBox(width: 24),
                        if (totalLots != null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: _buildResultsCard(context),
                          ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: optionType,
                decoration: const InputDecoration(
                  labelText: "Option Type",
                  prefixIcon: Icon(Icons.view_list),
                  border: OutlineInputBorder(),
                ),
                items: lotSizes.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value  (Lot: ${lotSizes[value]})'),
                  );
                }).toList(),
                onChanged: updateLotSize,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Capital Amount (₹)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  helperText: "Enter your total trading capital.",
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter capital" : null,
                onSaved: (v) => capital = double.parse(v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Entry Price (Option Premium)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: "Initial buy price of the option.",
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter entry price" : null,
                onSaved: (v) => entryPrice = double.parse(v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Stop Loss (Points per lot)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_down),
                  helperText: "Your stop loss in points.",
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter stop loss" : null,
                onSaved: (v) => stopLoss = double.parse(v!),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate, size: 26),
                  label: const Text("Calculate",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff60b246),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: calculate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    int avgPointsBelow = averagePointsMap[optionType] ?? 20;

    return Card(
      color: const Color(0xffe3fadc),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Option: $optionType (Lot: $lotSize)",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: "Max Risk (12%): ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: maxRiskAmount != null
                          ? '₹${maxRiskAmount!.toStringAsFixed(2)}'
                          : '-'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: "Total Lots: ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: totalLots != null ? '$totalLots' : "-"),
                ],
              ),
            ),
            const Divider(height: 24),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                      text: "1st Buy: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: (buy1Lots != null && entryPrice != null)
                        ? "$buy1Lots lots @ ₹${entryPrice!.toStringAsFixed(2)}"
                        : "-",
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                      text: "2nd Buy: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: (buy2Lots != null && entryPrice != null)
                        ? "$buy2Lots lots @ ₹${(entryPrice! - avgPointsBelow).toStringAsFixed(2)} (if price drops $avgPointsBelow pts)"
                        : "-",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                      text: "Average Buy Price: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: (avgPrice != null)
                        ? "₹${avgPrice!.toStringAsFixed(2)}"
                        : "-",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
