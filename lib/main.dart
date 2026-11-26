import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final LocalAuthentication auth = LocalAuthentication();
  bool biometricEnabled = false;
  bool checking = true;
  @override void initState() { super.initState(); _loadBiometric(); }
  Future<void> _loadBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { biometricEnabled = prefs.getBool('apna_biometric_enabled') ?? false; checking = false; });
  }
  Future<void> _biometricLogin() async {
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      if (!supported || !canCheck) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric authentication is not available on this device. Use your demo PIN.')));
        return;
      }
      final ok = await auth.authenticate(localizedReason: 'Authenticate to open your APNA PAY demo wallet');
      if (ok && mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Biometric login unavailable: $e')));
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demo Login')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number')),
      const SizedBox(height: 14),
      TextField(controller: pin, obscureText: true, decoration: const InputDecoration(labelText: 'Demo PIN')),
      const SizedBox(height: 20),
      if (!checking && biometricEnabled) ...[
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _biometricLogin, icon: const Icon(Icons.fingerprint), label: const Text('Login with Fingerprint / Face'))),
        const SizedBox(height: 8),
      ],
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () {
        if (phone.text.trim().isEmpty || pin.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your mobile number and demo PIN.'))); return;
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }, child: const Text('Login with Demo PIN'))),
      const SizedBox(height: 12),
      const Text('Demo login only. Real mobile OTP and server-side account verification are not connected.', style: TextStyle(color: Colors.deepOrange)),
    ])),
  );
}

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});
  @override State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}
class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool busy = false;
  Future<void> _enable() async {
    setState(() => busy = true);
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      if (!supported || !canCheck) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This device does not currently support biometric login. You can continue with your demo PIN.')));
        return;
      }
      final ok = await auth.authenticate(localizedReason: 'Verify your fingerprint or face to enable APNA PAY quick login');
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('apna_biometric_enabled', true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric login enabled on this device.')));
        _continue();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not enable biometrics: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }
  void _continue() { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Secure Login')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Icon(Icons.fingerprint, size: 86, color: brand),
      const SizedBox(height: 18),
      const Text('Enable Fingerprint / Face Unlock', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const Text('Use your phone’s built-in biometric security for quicker future logins. APNA PAY does not collect or store your fingerprint or face data.', textAlign: TextAlign.center),
      const SizedBox(height: 28),
      FilledButton.icon(onPressed: busy ? null : _enable, icon: const Icon(Icons.verified_user), label: Text(busy ? 'Please wait...' : 'Enable Biometric Login')),
      TextButton(onPressed: busy ? null : _continue, child: const Text('Skip — use Demo PIN instead')),
      const SizedBox(height: 12),
      const Text('Prototype only: real OTP verification and production account security still need backend integration.', textAlign: TextAlign.center, style: TextStyle(color: Colors.deepOrange)),
    ])),
  );
}

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override State<KycScreen> createState() => _KycScreenState();
}
class _KycScreenState extends State<KycScreen> {
  final cnic = TextEditingController();
  final picker = ImagePicker();
  XFile? frontImage, backImage, selfieImage;

  Future<void> _pick(String kind, ImageSource source) async {
    try {
      final file = await picker.pickImage(source: source, imageQuality: 82, maxWidth: 1600);
      if (file == null) return;
      setState(() {
        if (kind == 'front') frontImage = file;
        if (kind == 'back') backImage = file;
        if (kind == 'selfie') selfieImage = file;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image picker: $e')),
      );
    }
  }

  void _chooseImage(String kind) {
    showModalBottomSheet(
      context: context,
      builder: (sheet) => SafeArea(child: Wrap(children: [
        ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from Gallery'),
          onTap: () { Navigator.pop(sheet); _pick(kind, ImageSource.gallery); }),
        ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'),
          onTap: () { Navigator.pop(sheet); _pick(kind, ImageSource.camera); }),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Identity Check – Demo')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Icon(Icons.verified_user_outlined, size: 58, color: brand),
      const Text('KYC Verification Preview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Demo only: images are selected on this device for preview. They are not uploaded to NADRA or a verification server. Do not use real CNIC images in this demo.'),
      const SizedBox(height: 20),
      TextField(controller: cnic, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Sample CNIC (demo only)', hintText: '00000-0000000-0')),
      const SizedBox(height: 16),
      _imageCard('CNIC Front', frontImage, () => _chooseImage('front')),
      _imageCard('CNIC Back', backImage, () => _chooseImage('back')),
      _imageCard('Selfie Preview', selfieImage, () => _chooseImage('selfie')),
      const SizedBox(height: 18),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(16)),
        onPressed: () {
          if (frontImage == null || backImage == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both CNIC front and back images for this demo.')));
            return;
          }
          data.updateKyc('Demo Submitted – Not Verified');
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const BiometricSetupScreen()), (r) => false);
        }, child: const Text('Submit Demo KYC')),
      TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const BiometricSetupScreen()), (r) => false), child: const Text('Skip for now')),
    ]),
  );

  Widget _imageCard(String title, XFile? file, VoidCallback onTap) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ListTile(leading: Icon(file == null ? Icons.add_a_photo : Icons.check_circle, color: brand),
        title: Text(title), subtitle: Text(file == null ? 'Select from gallery or camera' : 'Image selected')),
      if (file != null) Image.file(File(file.path), height: 170, fit: BoxFit.contain),
      Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: OutlinedButton.icon(onPressed: onTap, icon: const Icon(Icons.upload_file), label: Text(file == null ? 'Choose Image' : 'Change Image'))),
    ]),
  );
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
      Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), child: Row(children: [
        Expanded(child: _action(context, Icons.send, 'Send Money', () => _amount(context, 'Send Money (Demo)', false))),
        Expanded(child: _action(context, Icons.phone_android, 'Mobile Load', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileLoadScreen())))),
        Expanded(child: _action(context, Icons.receipt_long, 'Bill Pay', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPayScreen())))),
        Expanded(child: _action(context, Icons.add_card, 'Add Money', () => _amount(context, 'Add Demo Money', true))),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 12), child: Row(children: [
        Expanded(child: _action(context, Icons.account_balance, 'Govt Fees', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPayScreen())))),
        Expanded(child: _action(context, Icons.school, 'Education Fee', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPayScreen())))),
        Expanded(child: _action(context, Icons.wifi, 'Packages', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileLoadScreen())))),
        Expanded(child: _action(context, Icons.history, 'History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())))),
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


class MobileLoadScreen extends StatefulWidget {
  const MobileLoadScreen({super.key});
  @override State<MobileLoadScreen> createState() => _MobileLoadScreenState();
}
class _MobileLoadScreenState extends State<MobileLoadScreen> {
  final phone = TextEditingController();
  final amount = TextEditingController();
  String network = 'Jazz';
  String mode = 'Load';
  String selectedBundle = '';
  final networks = ['Jazz', 'Zong', 'Telenor', 'Ufone'];
  final bundles = <String, List<Map<String, String>>>{
    'Jazz': [
      {'name':'Daily Social Bundle', 'detail':'Social data • 1 day', 'price':'Rs. 50'},
      {'name':'Weekly Social Bundle', 'detail':'Social apps • 7 days', 'price':'Rs. 150'},
      {'name':'Monthly Social Bundle', 'detail':'Social apps • 30 days', 'price':'Rs. 500'},
      {'name':'Monthly Data Bundle', 'detail':'Internet data • 30 days', 'price':'Rs. 1,000'},
    ],
    'Zong': [
      {'name':'Daily Social Package', 'detail':'Social data • 1 day', 'price':'Rs. 50'},
      {'name':'Weekly Data Package', 'detail':'Internet data • 7 days', 'price':'Rs. 250'},
      {'name':'Monthly Social Package', 'detail':'Social apps • 30 days', 'price':'Rs. 450'},
      {'name':'Monthly Data Package', 'detail':'Internet data • 30 days', 'price':'Rs. 1,200'},
    ],
    'Telenor': [
      {'name':'Daily Social Pack', 'detail':'Social data • 1 day', 'price':'Rs. 60'},
      {'name':'Weekly EasyCard', 'detail':'Calls, SMS and data • 7 days', 'price':'Rs. 300'},
      {'name':'Monthly Social Pack', 'detail':'Social apps • 30 days', 'price':'Rs. 500'},
      {'name':'Monthly EasyCard', 'detail':'Calls, SMS and data • 30 days', 'price':'Rs. 1,000'},
    ],
    'Ufone': [
      {'name':'Daily Light Package', 'detail':'Calls and data • 1 day', 'price':'Rs. 60'},
      {'name':'Weekly Internet Package', 'detail':'Internet data • 7 days', 'price':'Rs. 250'},
      {'name':'Monthly Social Package', 'detail':'Social apps • 30 days', 'price':'Rs. 450'},
      {'name':'Monthly Super Card', 'detail':'Calls, SMS and data • 30 days', 'price':'Rs. 1,000'},
    ],
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mobile Load & Packages')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Select Network', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Wrap(spacing: 9, runSpacing: 9, children: networks.map((n) => ChoiceChip(
        label: Text(n), selected: network == n, onSelected: (_) => setState(() { network = n; selectedBundle = ''; }),
        selectedColor: const Color(0xFFD9F3E5), side: BorderSide(color: network == n ? brand : Colors.grey.shade400),
      )).toList()),
      const SizedBox(height: 18),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Load', label: Text('Easy Load'), icon: Icon(Icons.phone_android)),
          ButtonSegment(value: 'Bundles', label: Text('Packages'), icon: Icon(Icons.card_giftcard)),
        ],
        selected: {mode}, onSelectionChanged: (v) => setState(() { mode = v.first; selectedBundle = ''; }),
      ),
      const SizedBox(height: 20),
      TextField(controller: phone, keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Mobile Number', hintText: '03XX XXXXXXX', prefixIcon: Icon(Icons.phone))),
      if (mode == 'Load') ...[
        const SizedBox(height: 16),
        TextField(controller: amount, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Load Amount (PKR)', prefixText: 'Rs. ')),
      ] else ...[
        const SizedBox(height: 18),
        const Text('Available Demo Packages', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...bundles[network]!.map((b) => Card(
          child: RadioListTile<String>(
            value: b['name']!, groupValue: selectedBundle,
            onChanged: (v) {
              setState(() { selectedBundle = v!; amount.text = b['price']!.replaceAll(RegExp(r'[^0-9]'), ''); });
            },
            title: Text(b['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${b['detail']}  •  ${b['price']}'),
            secondary: const Icon(Icons.wifi, color: brand),
          ),
        )),
        const SizedBox(height: 8),
        TextField(controller: amount, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Package Price (PKR)', prefixText: 'Rs. ')),
      ],
      const SizedBox(height: 22),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(16)),
        onPressed: () {
          final value = double.tryParse(amount.text);
          if (phone.text.trim().length < 10 || value == null || value <= 0 || (mode == 'Bundles' && selectedBundle.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter mobile number, amount and select a package if required.'))); return;
          }
          if (value > data.balance) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient demo balance.'))); return;
          }
          final item = mode == 'Load' ? 'Easy Load' : selectedBundle;
          data.add('$item • $network • ${phone.text.trim()}', value);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo $item recorded. No real top-up/package was activated.')));
          Navigator.pop(context);
        }, child: Text(mode == 'Load' ? 'Confirm Demo Load' : 'Activate Demo Package')),
      const SizedBox(height: 12),
      const Text('Package names and prices are illustrative demo examples only. Actual offers, eligibility and prices must be fetched from an authorized operator/aggregator API. No real load or bundle is activated.', style: TextStyle(color: Colors.deepOrange)),
    ]),
  );
}

class BillPayScreen extends StatefulWidget {
  const BillPayScreen({super.key});
  @override State<BillPayScreen> createState() => _BillPayScreenState();
}
class _BillPayScreenState extends State<BillPayScreen> {
  final reference = TextEditingController();
  final amount = TextEditingController();
  String category = 'Electricity';
  String provider = 'K-Electric';
  final providers = <String, List<String>>{
    'Electricity': ['K-Electric', 'PESCO', 'IESCO', 'LESCO', 'MEPCO', 'FESCO', 'HESCO', 'SEPCO', 'QESCO', 'GEPCO', 'TESCO'],
    'Gas': ['SNGPL', 'SSGC'],
    'Water': ['Karachi Water & Sewerage Corporation', 'WASA Peshawar', 'WASA Lahore', 'WASA Faisalabad'],
    'Internet': ['PTCL', 'Nayatel', 'StormFiber', 'Transworld'],
    'Telephone': ['PTCL'],
    'Government Fees': ['FBR Tax / PSID', 'Traffic E-Challan', 'Passport Fee', 'NADRA Fee', 'Vehicle Token Tax', 'Driving Licence Fee', 'Court Fee / Challan', 'Government Treasury Challan'],
    'Education Fees': ['Public University Fee', 'Board of Intermediate & Secondary Education', 'Government College Fee'],
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bill Payment')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Bill Category', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: providers.keys.map((c) => ChoiceChip(
        label: Text(c), selected: category == c, onSelected: (_) => setState(() { category = c; provider = providers[c]!.first; }),
      )).toList()),
      const SizedBox(height: 20),
      DropdownButtonFormField<String>(
        value: provider, decoration: const InputDecoration(labelText: 'Select Company / Biller'),
        items: providers[category]!.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) setState(() => provider = v); },
      ),
      const SizedBox(height: 16),
      TextField(controller: reference, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: category.contains('Government') || category.contains('Education') ? 'PSID / Challan / Student Reference Number' : 'Consumer / Reference Number')),
      const SizedBox(height: 16),
      TextField(controller: amount, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Bill / Fee Amount (PKR)', prefixText: 'Rs. ')),
      const SizedBox(height: 10),
      const Text('Demo only: enter a sample amount. Real bill enquiry, PSID validation and government fee payment require an approved biller/payment partner API.', style: TextStyle(color: Colors.deepOrange)),
      const SizedBox(height: 22),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(16)),
        onPressed: () {
          final value = double.tryParse(amount.text);
          if (reference.text.trim().isEmpty || value == null || value <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter reference number and amount.'))); return;
          }
          if (value > data.balance) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient demo balance.'))); return;
          }
          data.add('Bill Pay • $provider • ${reference.text.trim()}', value);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo bill payment recorded. No bill was paid.')));
          Navigator.pop(context);
        }, child: const Text('Confirm Demo Bill Payment')),
      const SizedBox(height: 12),
      const Text('Demo only: biller lookup and real bill payment are not connected.', style: TextStyle(color: Colors.deepOrange)),
    ]),
  );
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
      ListTile(leading: const Icon(Icons.fingerprint), title: const Text('Biometric Login'), subtitle: const Text('Fingerprint / Face Unlock on supported devices'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BiometricSetupScreen()))),
      const ListTile(leading: Icon(Icons.language), title: Text('Language'), subtitle: Text('English • Urdu planned')),
      const ListTile(leading: Icon(Icons.info_outline), title: Text('Version'), subtitle: Text('APNA PAY Demo 1.0')),
      const Text('This is a prototype. Do not use real identity or payment details.', style: TextStyle(color: Colors.deepOrange)),
    ]),
  ));
}
