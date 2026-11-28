                  import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      const SizedBox(height: 14),
      _field(phone, 'Mobile Number', Icons.phone, type: TextInputType.phone),
      const SizedBox(height: 14),
      _field(email, 'Email (optional)', Icons.email, type: TextInputType.emailAddress),
      const SizedBox(height: 14),
      _field(pin, 'Create 4-digit Demo PIN', Icons.lock, obscure: true, type: TextInputType.number),
      const SizedBox(height: 24),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: brand, padding: const EdgeInsets.all(16)),
        onPressed: () {
          if (name.text.trim().isEmpty || phone.text.trim().length < 10 || pin.text.trim().length < 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter name, valid mobile number and 4-digit demo PIN.')),
            );
            return;
          }
          data.fullName = name.text.trim();
          data.phone = phone.text.trim();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const KycScreen()),
            (r) => false,
          );
        },
        child: const Text('Continue to KYC Demo'),
      ),
    ]),
  );

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) => TextField(
    controller: c,
    obscureText: obscure,
    keyboardType: type,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final pin = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demo Login')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        TextField(
          controller: phone,
          decoration: const InputDecoration(labelText: 'Mobile Number'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: pin,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Demo PIN'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
          child: const Text('Open Demo Wallet'),
        ),
      ]),
    ),
  );
}

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final cnic = TextEditingController();
  final picker = ImagePicker();

  XFile? frontImage;
  XFile? backImage;
  XFile? selfieImage;

  Future<void> _pick(String kind, ImageSource source) async {
    try {
      final file = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );

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
      builder: (sheet) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(sheet);
              _pick(kind, ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(sheet);
              _pick(kind, ImageSource.camera);
            },
          ),
        ]),
      ),
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
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
        }, child: const Text('Submit Demo KYC')),
      TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), child: const Text('Skip for now')),
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Dashboard(),
      const HistoryScreen(),
      const QuickActionsScreen(),
      const CardsScreen(),
      const HelpScreen()
    ];

    return Scaffold(
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Pay'),
          NavigationDestination(icon: Icon(Icons.credit_card), label: 'Cards'),
          NavigationDestination(icon: Icon(Icons.support_agent), label: 'Help'),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: data,
    builder: (_, __) => Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(children: [
                const Expanded(
                  child: Text('APNA PAY',
                    style: TextStyle(color: brand, fontSize: 25, fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                  icon: const Icon(Icons.notifications_none),
                ),
                const CircleAvatar(
                  backgroundColor: brand,
                  child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assalam-o-Alaikum, ${data.fullName.isEmpty ? "User" : data.fullName}',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 18),
                  const Text('Available Demo Balance', style: TextStyle(color: Colors.white70)),
                  Text('Rs. ${data.balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('DEMO WALLET • No real funds',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(children: [
                Expanded(child: _action(context, Icons.send_rounded, 'Send Money',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendMoneyScreen())))),
                Expanded(child: _action(context, Icons.account_balance_wallet, 'Add Money',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyScreen())))),
                Expanded(child: _action(context, Icons.phone_android, 'Mobile Loads',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobileLoadScreen())))),
                Expanded(child: _action(context, Icons.receipt_long, 'Bill Payment',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPayScreen())))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined, color: brand),
                  title: const Text('Payments & Services'),
                  subtitle: const Text('Electricity • Gas • Water • Internet • Government fees'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE1F4EA),
                    child: Icon(Icons.verified_user, color: brand),
                  ),
                  title: const Text('KYC Status'),
                  subtitle: Text(data.kycStatus),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ...data.activity.take(5).map((e) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
              title: Text(e),
              subtitle: const Text('Demo record'),
            )),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('DEMO ONLY — no real money transfer, bill payment or identity verification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _action(BuildContext c, IconData icon, String title, VoidCallback tap) =>
    InkWell(
      onTap: tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          CircleAvatar(radius: 25, backgroundColor: const Color(0xFFE3F5EB), child: Icon(icon, color: brand)),
          const SizedBox(height: 7),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
}
void _amount(BuildContext context, String title, bool credit) {
  final amount = TextEditingController();

  showDialog(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: amount,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Amount in PKR'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(amount.text);
            if (v == null || v <= 0) return;

            if (!credit && v > data.balance) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insufficient demo balance')),
              );
              return;
            }

            data.add(title, v, credit: credit);
            Navigator.pop(d);
          },
          child: const Text('Confirm Demo'),
        ),
      ],
    ),
  );
}

class MobileLoadScreen extends StatefulWidget {
  const MobileLoadScreen({super.key});
  @override
  State<MobileLoadScreen> createState() => _MobileLoadScreenState();
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
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Select Network',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: networks.map((n) => ChoiceChip(
            label: Text(n),
            selected: network == n,
            onSelected: (_) => setState(() {
              network = n;
              selectedBundle = '';
            }),
            selectedColor: const Color(0xFFD9F3E5),
            side: BorderSide(
              color: network == n ? brand : Colors.grey.shade400,
            ),
          )).toList(),
        ),

        const SizedBox(height: 18),

        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'Load',
              label: Text('Easy Load'),
              icon: Icon(Icons.phone_android),
            ),
            ButtonSegment(
              value: 'Bundles',
              label: Text('Packages'),
              icon: Icon(Icons.card_giftcard),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (v) => setState(() {
            mode = v.first;
            selectedBundle = '';
          }),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            hintText: '03XX XXXXXXX',
            prefixIcon: Icon(Icons.phone),
          ),
        ),

        if (mode == 'Load') ...[
          const SizedBox(height: 16),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Load Amount (PKR)',
              prefixText: 'Rs. ',
            ),
          ),
        ] else ...[
          const SizedBox(height: 18),
          const Text('Available Demo Packages',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ...bundles[network]!.map((b) => Card(
            child: RadioListTile<String>(
              value: b['name']!,
              groupValue: selectedBundle,
              onChanged: (v) {
                setState(() {
                  selectedBundle = v!;
                  amount.text = b['price']!.replaceAll(
                    RegExp(r'[^0-9]'), '',
                  );
                });
              },
              title: Text(b['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${b['detail']}  •  ${b['price']}'),
              secondary: const Icon(Icons.wifi, color: brand),
            ),
          )),

          const SizedBox(height: 8),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Package Price (PKR)',
              prefixText: 'Rs. ',
            ),
          ),
        ],

        const SizedBox(height: 22),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () {
            final value = double.tryParse(amount.text);

            if (phone.text.trim().length < 10 ||
                value == null ||
                value <= 0 ||
                (mode == 'Bundles' && selectedBundle.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter mobile number, amount and select a package if required.'),
                ),
              );
              return;
            }

            if (value > data.balance) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insufficient demo balance.')),
              );
              return;
            }

            final item = mode == 'Load' ? 'Easy Load' : selectedBundle;

            data.add('$item • $network • ${phone.text.trim()}', value);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Demo $item recorded. No real top-up/package was activated.'),
              ),
            );

            Navigator.pop(context);
          },
          child: Text(
            mode == 'Load' ? 'Confirm Demo Load' : 'Activate Demo Package',
          ),
        ),

        const SizedBox(height: 12),
        const Text(
          'Package names and prices are illustrative demo examples only. Actual offers, eligibility and prices must be fetched from an authorized operator/aggregator API. No real load or bundle is activated.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );
}
class BillPayScreen extends StatefulWidget {
  const BillPayScreen({super.key});
  @override
  State<BillPayScreen> createState() => _BillPayScreenState();
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
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Bill Category',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: providers.keys.map((c) => ChoiceChip(
            label: Text(c),
            selected: category == c,
            onSelected: (_) => setState(() {
              category = c;
              provider = providers[c]!.first;
            }),
          )).toList(),
        ),

        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: provider,
          decoration: const InputDecoration(
            labelText: 'Select Company / Biller',
          ),
          items: providers[category]!
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => provider = v);
          },
        ),

        const SizedBox(height: 16),

        TextField(
          controller: reference,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: category.contains('Government') ||
                    category.contains('Education')
                ? 'PSID / Challan / Student Reference Number'
                : 'Consumer / Reference Number',
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Bill / Fee Amount (PKR)',
            prefixText: 'Rs. ',
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Demo only: enter a sample amount. Real bill enquiry, PSID validation and government fee payment require an approved biller/payment partner API.',
          style: TextStyle(color: Colors.deepOrange),
        ),

        const SizedBox(height: 22),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () {
            final value = double.tryParse(amount.text);

            if (reference.text.trim().isEmpty ||
                value == null ||
                value <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter reference number and amount.'),
                ),
              );
              return;
            }

            if (value > data.balance) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Insufficient demo balance.'),
                ),
              );
              return;
            }

            data.add(
              'Bill Pay • $provider • ${reference.text.trim()}',
              value,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demo bill payment recorded. No bill was paid.'),
              ),
            );

            Navigator.pop(context);
          },
          child: const Text('Confirm Demo Bill Payment'),
        ),

        const SizedBox(height: 12),

        const Text(
          'Demo only: biller lookup and real bill payment are not connected.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );
}

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final phone = TextEditingController();
  final amount = TextEditingController();

  String bank = 'APNA PAY Wallet';

  final banks = [
    'APNA PAY Wallet',
    'JazzCash',
    'Easypaisa',
    'HBL',
    'UBL',
    'Meezan Bank',
    'Allied Bank',
    'Bank Alfalah',
    'Other Bank',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Send Money')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'New Transfer',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile / Account Number',
            prefixIcon: Icon(Icons.contact_phone),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Search Bank / Select Bank',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: bank,
          items: banks.map((b) =>
            DropdownMenuItem(value: b, child: Text(b))
          ).toList(),
          onChanged: (v) => setState(() => bank = v!),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.account_balance),
          ),
        ),

        const SizedBox(height: 18),

        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (PKR)',
            prefixText: 'Rs. ',
          ),
        ),

        const SizedBox(height: 22),

        FilledButton(
          onPressed: () {
            final v = double.tryParse(amount.text);

            if (phone.text.trim().length < 8 ||
                v == null ||
                v <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter a valid account number and amount.'),
                ),
              );
              return;
            }

            if (v > data.balance) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Insufficient demo balance.'),
                ),
              );
              return;
            }

            data.add(
              'Send Money • $bank • ${phone.text.trim()}',
              v,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demo transfer recorded only. No money was sent.'),
              ),
            );

            Navigator.pop(context);
          },
          child: const Text('Confirm Demo Transfer'),
        ),

        const SizedBox(height: 10),

        const Text(
          'Real transfers require AFT / bank / wallet partner APIs and regulatory approval.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );
}

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final amount = TextEditingController();

  void _message(String title, String detail) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: Text(detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addDemoCash() {
    final v = double.tryParse(amount.text);

    if (v == null || v <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    data.add('Add Cash • Demo Deposit', v, credit: true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo cash added locally. No bank/card payment occurred.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add Cash')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Choose a method and add cash to your wallet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: brand,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your APNA PAY account number',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Available after partner onboarding',
                  style: TextStyle(
                    color: brand,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                const Text(
                  'Your APNA PAY IBAN',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Not issued in demo mode',
                  style: TextStyle(
                    color: brand,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _cashOption(
          Icons.atm,
          'Search Cash Deposit Machine',
          'Find a nearby cash deposit machine (demo preview)',
          () => _message(
            'Cash Deposit Machine',
            'Machine locations will appear after an authorized banking partner provides its service/API.',
          ),
        ),

        _cashOption(
          Icons.account_balance,
          'Link Your Bank Account',
          'Connect a bank account securely (demo preview)',
          () => _message(
            'Link Your Bank Account',
            'Bank account linking requires a supported bank/Open Banking partner and secure authorization. No bank details are collected in this demo.',
          ),
        ),

        _cashOption(
          Icons.credit_card,
          'Link any Debit/Credit Card',
          'Add a card through a secure provider (demo preview)',
          () => _message(
            'Link Debit/Credit Card',
            'Card tokenization and payments require an approved payment gateway. Do not enter card details in this demo.',
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Demo cash amount',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (PKR)',
            prefixText: 'Rs. ',
          ),
        ),

        const SizedBox(height: 14),

        FilledButton(
          onPressed: _addDemoCash,
          child: const Text('Add Demo Cash'),
        ),

        const SizedBox(height: 10),

        const Text(
          'DEMO ONLY: Account number, IBAN, bank linking, card funding and cash-deposit confirmation are not active. Real deposits require an authorized bank/payment partner.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );

  Widget _cashOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F5EB),
        child: Icon(icon, color: brand),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final search = TextEditingController();

  final groups = <String, List<String>>{
    'Payments': [
      'Electricity', 'Gas', 'Water', 'Telephone',
      'My Bills', 'MTAG', 'Multiple Bills', 'Split Bill'
    ],
    'Education Payments': [
      'School Fees', 'University Fees', 'Colleges',
      'Entry Test & Board Fees'
    ],
    'Government Payments': [
      'Government Fees', 'Passport Fee', 'NADRA Fee',
      'Traffic E-Challan', 'FBR / PSID',
      'Vehicle Token Tax', 'Driving Licence Fee'
    ],
    'Lifestyle & Other': [
      'Internet', 'Insurance', 'E-commerce', 'Travel',
      'Investment', 'Real Estate', 'Leisure', 'Credit Card',
      'Food', 'Corporate', 'Financial Services', 'Hotels'
    ],
  };

  @override
  Widget build(BuildContext context) {
    final q = search.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'All your payments in one place!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search by Biller Name or Category',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 14),

          Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: brand),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: brand),
              title: const Text('My Bills'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BillPayScreen(),
                ),
              ),
            ),
          ),

          ...groups.entries.map((entry) {
            final items = entry.value
                .where((e) => e.toLowerCase().contains(q))
                .toList();

            if (items.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 12),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .82,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final e = items[i];

                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BillPayScreen(),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFFE3F5EB),
                            child: Icon(_icon(e), color: brand),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            e,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }),

          const SizedBox(height: 12),

          const Text(
            'Service availability depends on an approved biller/payment partner. These are demo navigation screens; no real bill is paid.',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }
}

IconData _icon(String s) {
  if (s.contains('Electric')) return Icons.bolt;
  if (s == 'Gas') return Icons.local_fire_department;
  if (s == 'Water') return Icons.water_drop;
  if (s.contains('Fees')) return Icons.school;
  if (s.contains('Internet')) return Icons.wifi;
  if (s.contains('Telephone')) return Icons.phone;
  return Icons.receipt_long;
}

class QuickActionsScreen extends StatelessWidget {
  const QuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pay & Scan')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.qr_code_scanner, size: 90, color: brand),
        const Text(
          'Scan & Pay',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'QR payment preview. Camera and merchant payment network are not connected.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        FilledButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR payments will be enabled after partner integration.'),
            ),
          ),
          child: const Text('Open QR Scanner (Demo)'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SendMoneyScreen(),
            ),
          ),
          child: const Text('Send Money'),
        ),
      ],
    ),
  );
}

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('APNA PAY Cards')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 190,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16B879), Color(0xFF07583C)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'APNA PAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.contactless, color: Colors.white, size: 34),
              Spacer(),
              Text(
                'DEMO CARD • **** **** **** 0000',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Card services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        ListTile(
          leading: const Icon(Icons.credit_card, color: brand),
          title: const Text('Order Debit Card'),
          subtitle: const Text('Physical / Virtual card (preview)'),
          onTap: () => _cardMessage(context),
        ),

        ListTile(
          leading: const Icon(Icons.lock_outline, color: brand),
          title: const Text('Card Controls'),
          subtitle: const Text('Freeze, unfreeze and manage card (demo)'),
          onTap: () => _cardMessage(context),
        ),

        ListTile(
          leading: const Icon(Icons.local_offer, color: brand),
          title: const Text('Card Discounts'),
          onTap: () => _cardMessage(context),
        ),

        const Text(
          'Real card issuance requires issuer/bank partner approval.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );
}

void _cardMessage(BuildContext c) =>
    ScaffoldMessenger.of(c).showSnackBar(
      const SnackBar(
        content: Text('Card feature preview only. No card is issued.'),
      ),
    );

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help & Support')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'How can we help you?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Please select from the options below'),
        const SizedBox(height: 16),

        ...[
          'Register New Complaint',
          'Track My Complaint',
          'Register New Service Request',
          'Track My Service Request',
          'Record Feedback',
          'Vouchers',
          'Terms and Conditions',
          'Schedule of Charges',
          'FAQs',
          'APNA PAY Help',
        ].map(
          (e) => Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent, color: brand),
              title: Text(e),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _helpAction(context, e),
            ),
          ),
        ),
      ],
    ),
  );
}

void _helpAction(BuildContext c, String title) {
  final ctrl = TextEditingController();

  showDialog(
    context: c,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Enter details (demo)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(d);
            ScaffoldMessenger.of(c).showSnackBar(
              SnackBar(
                content: Text('$title saved locally in demo only.'),
              ),
            );
          },
          child: const Text('Submit Demo'),
        ),
      ],
    ),
  );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: data,
    builder: (_, __) => Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView(
        children: data.activity.map(
          (e) => ListTile(
            leading: const Icon(Icons.receipt_long, color: brand),
            title: Text(e),
            subtitle: const Text('Demo transaction'),
          ),
        ).toList(),
      ),
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: data,
    builder: (_, __) => Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: brand,
            child: Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 12),

          Text(
            data.fullName.isEmpty ? 'Demo User' : data.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(data.phone, textAlign: TextAlign.center),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('KYC'),
            subtitle: Text(data.kycStatus),
          ),

          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
            subtitle: Text('Demo PIN only'),
          ),

          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('English • Urdu planned'),
          ),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('APNA PAY Demo 1.0'),
          ),

          const Text(
            'This is a prototype. Do not use real identity or payment details.',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ],
      ),
    ),
  );
}
