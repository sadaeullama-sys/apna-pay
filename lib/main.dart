import 'package:flutter/material.dart';

void main() => runApp(const ApnaPayDemo());

const brand = Color(0xFF079B5B);
const ink = Color(0xFF12372B);

class ApnaPayDemo extends StatelessWidget {
  const ApnaPayDemo({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'APNA PAY Demo',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brand),
      scaffoldBackgroundColor: const Color(0xFFF5F8F6),
      appBarTheme: const AppBarTheme(backgroundColor: brand, foregroundColor: Colors.white),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: const WelcomeScreen(),
  );
}

class DemoData extends ChangeNotifier {
  String fullName = '';
  String phone = '';
  String cnic = '';
  String kycStatus = 'Not Submitted';
  double balance = 25000;
  final List<String> activity = ['Welcome to APNA PAY Demo'];
  void add(String label, double amount, {bool credit = false}) {
    if (!credit && amount > balance) return;
    balance += credit ? amount : -amount;
    activity.insert(0, label);
    notifyListeners();
  }
  void updateKyc(String status) { kycStatus = status; notifyListeners(); }
}
final data = DemoData();

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Spacer(),
        const Icon(Icons.account_balance_wallet_rounded, size: 88, color: brand),
        const SizedBox(height: 12),
        const Text('APNA PAY', textAlign: TextAlign.center, style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: brand)),
        const Text('Your Money, Your Way', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 38),
        const Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ink)),
        const SizedBox(height: 8),
        const Text('Start with a demo account. No real money or identity verification is processed.'),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(17)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationScreen())),
          child: const Text('Create Demo Account'),
        ),
        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('I already have a demo account')),
        const Spacer(),
        const Text('DEMO MODE • NOT A REAL WALLET', textAlign: TextAlign.center, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
      ]),
    )),
  );
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override State<RegistrationScreen> createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen> {
  final name = TextEditingController(), phone = TextEditingController(), email = TextEditingController(), pin = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Account')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Demo Registration', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Use sample details only. Do not enter your real CNIC or banking PIN.'),
      const SizedBox(height: 20),
      _field(name, 'Full Name', Icons.person),
      const SizedBox(height: 14), _field(phone, 'Mobile Number', Icons.phone, type: TextInputType.phone),
      const SizedBox(height: 14), _field(email, 'Email (optional)', Icons.email, type: TextInputType.emailAddress),
      const SizedBox(height: 14), _field(pin, 'Create 4-digit Demo PIN', Icons.lock, obscure: true, type: TextInputType.number),
      const SizedBox(height: 24),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(16)), onPressed: () {
        if (name.text.trim().isEmpty || phone.text.trim().length < 10 || pin.text.trim().length < 4) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name, valid mobile number and 4-digit demo PIN.'))); return;
        }
        data.fullName = name.text.trim(); data.phone = phone.text.trim();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const KycScreen()), (r) => false);
      }, child: const Text('Continue to KYC Demo')),
    ]),
  );
  Widget _field(TextEditingController c, String label, IconData icon, {bool obscure = false, TextInputType type = TextInputType.text}) => TextField(controller: c, obscureText: obscure, keyboardType: type, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController(), pin = TextEditingController();
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demo Login')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: phone, decoration: const InputDecoration(labelText: 'Mobile Number')),
      const SizedBox(height: 14),
      TextField(controller: pin, obscureText: true, decoration: const InputDecoration(labelText: 'Demo PIN')),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())), child: const Text('Open Demo Wallet')),
    ])),
  );
}

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override State<KycScreen> createState() => _KycScreenState();
}
class _KycScreenState extends State<KycScreen> {
  final cnic = TextEditingController();
  bool front = false, back = false, selfie = false;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Identity Check – Demo')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Icon(Icons.verified_user_outlined, size: 58, color: brand),
      const Text('KYC Verification Preview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('This screen demonstrates the intended process only. It does not connect to NADRA or verify any identity. Use dummy details in this demo.'),
      const SizedBox(height: 20),
      TextField(controller: cnic, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sample CNIC (demo only)', hintText: '00000-0000000-0')),
      const SizedBox(height: 16),
      _uploadTile('CNIC Front', front, () => setState(() => front = !front)),
      _uploadTile('CNIC Back', back, () => setState(() => back = !back)),
      _uploadTile('Selfie / Face Check', selfie, () => setState(() => selfie = !selfie)),
      const SizedBox(height: 18),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(16)), onPressed: () {
        data.updateKyc('Demo Submitted – Not Verified');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
      }, child: const Text('Submit Demo KYC')),
      TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), child: const Text('Skip for now')),
    ]),
  );
  Widget _uploadTile(String title, bool selected, VoidCallback tap) => Card(child: ListTile(
    leading: Icon(selected ? Icons.check_circle : Icons.add_a_photo, color: selected ? brand : Colors.grey),
    title: Text(title), subtitle: Text(selected ? 'Demo placeholder selected' : 'Tap to simulate adding image'),
    trailing: TextButton(onPressed: tap, child: Text(selected ? 'Remove' : 'Add')),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  @override Widget build(BuildContext context) {
    final pages = [const Dashboard(), const HistoryScreen(), const ProfileScreen()];
    return Scaffold(
      body: pages[tab],
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account'),
      ]),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: data, builder: (_, __) => Scaffold(
    body: SafeArea(child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Container(padding: const EdgeInsets.fromLTRB(20, 24, 20, 32), decoration: const BoxDecoration(color: brand, borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Expanded(child: Text('APNA PAY', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900))), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white))]),
        Text('Assalam-o-Alaikum, ${data.fullName.isEmpty ? "User" : data.fullName}', style: const TextStyle(color: Colors.white, fontSize: 17)),
        const SizedBox(height: 20), const Text('Demo Wallet Balance', style: TextStyle(color: Colors.white70)),
        Text('Rs. ${data.balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
      ])),
      Padding(padding: const EdgeInsets.all(18), child: Row(children: [
        Expanded(child: _action(context, Icons.send, 'Send Money', () => _amount(context, 'Send Money (Demo)', false))),
        Expanded(child: _action(context, Icons.phone_android, 'Mobile Load', () => _amount(context, 'Mobile Load (Demo)', false))),
        Expanded(child: _action(context, Icons.receipt_long, 'Bill Pay', () => _amount(context, 'Bill Payment (Demo)', false))),
        Expanded(child: _action(context, Icons.add_card, 'Add Money', () => _amount(context, 'Add Demo Money', true))),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Card(child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFE1F4EA), child: Icon(Icons.verified_user, color: brand)),
        title: const Text('KYC Status'), subtitle: Text(data.kycStatus),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())),
      ))),
      const Padding(padding: EdgeInsets.fromLTRB(20, 14, 20, 8), child: Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      ...data.activity.take(5).map((e) => ListTile(leading: const CircleAvatar(child: Icon(Icons.swap_horiz)), title: Text(e), subtitle: const Text('Demo record'))),
      const Padding(padding: EdgeInsets.all(16), child: Text('DEMO ONLY — no real money transfer, bill payment or identity verification.', textAlign: TextAlign.center, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600))),
    ])),
  ));
  Widget _action(BuildContext c, IconData icon, String title, VoidCallback tap) => InkWell(onTap: tap, child: Column(children: [
    CircleAvatar(radius: 25, backgroundColor: const Color(0xFFE3F5EB), child: Icon(icon, color: brand)),
    const SizedBox(height: 7), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
  ]));
}

void _amount(BuildContext context, String title, bool credit) {
  final amount = TextEditingController();
  showDialog(context: context, builder: (d) => AlertDialog(title: Text(title), content: TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount in PKR')), actions: [
    TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
    FilledButton(onPressed: () {
      final v = double.tryParse(amount.text);
      if (v == null || v <= 0) return;
      if (!credit && v > data.balance) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient demo balance'))); return; }
      data.add(title, v, credit: credit); Navigator.pop(d);
    }, child: const Text('Confirm Demo')),
  ]));
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: data, builder: (_, __) => Scaffold(
    appBar: AppBar(title: const Text('Transaction History')),
    body: ListView(children: data.activity.map((e) => ListTile(leading: const Icon(Icons.receipt_long, color: brand), title: Text(e), subtitle: const Text('Demo transaction'))).toList()),
  ));
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: data, builder: (_, __) => Scaffold(
    appBar: AppBar(title: const Text('My Account')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 42, backgroundColor: brand, child: Icon(Icons.person, size: 48, color: Colors.white)),
      const SizedBox(height: 12),
      Text(data.fullName.isEmpty ? 'Demo User' : data.fullName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text(data.phone, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ListTile(leading: const Icon(Icons.verified_user), title: const Text('KYC'), subtitle: Text(data.kycStatus)),
      const ListTile(leading: Icon(Icons.security), title: Text('Security'), subtitle: Text('Demo PIN only')),
      const ListTile(leading: Icon(Icons.language), title: Text('Language'), subtitle: Text('English • Urdu planned')),
      const ListTile(leading: Icon(Icons.info_outline), title: Text('Version'), subtitle: Text('APNA PAY Demo 1.0')),
      const Text('This is a prototype. Do not use real identity or payment details.', style: TextStyle(color: Colors.deepOrange)),
    ]),
  ));
}
