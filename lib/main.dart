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
      appBarTheme: const AppBarTheme(
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
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

  final List<String> activity = [
    'Welcome to APNA PAY Demo'
  ];

  void add(String label, double amount, {bool credit = false}) {
    if (!credit && amount > balance) return;

    balance += credit ? amount : -amount;
    activity.insert(0, label);
    notifyListeners();
  }

  void updateKyc(String status) {
    kycStatus = status;
    notifyListeners();
  }
}

final data = DemoData();

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 88,
              color: brand,
            ),

            const SizedBox(height: 12),

            const Text(
              'APNA PAY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: brand,
              ),
            ),

            const Text(
              'Your Money, Your Way',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 38),

            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Start with a demo account. No real money or identity verification is processed.',
            ),

            const SizedBox(height: 24),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: brand,
                padding: const EdgeInsets.all(17),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegistrationScreen(),
                ),
              ),
              child: const Text('Create Demo Account'),
            ),

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              ),
              child: const Text('I already have a demo account'),
            ),

            const Spacer(),

            const Text(
              'DEMO MODE • NOT A REAL WALLET',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final pin = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Account')),

    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Demo Registration',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Use sample details only. Do not enter your real CNIC or banking PIN.',
        ),

        const SizedBox(height: 20),

        _field(name, 'Full Name', Icons.person),

        const SizedBox(height: 14),

        _field(
          phone,
          'Mobile Number',
          Icons.phone,
          type: TextInputType.phone,
        ),

        const SizedBox(height: 14),

        _field(
          email,
          'Email (optional)',
          Icons.email,
          type: TextInputType.emailAddress,
        ),

        const SizedBox(height: 14),

        _field(
          pin,
          'Create 4-digit Demo PIN',
          Icons.lock,
          obscure: true,
          type: TextInputType.number,
        ),

        const SizedBox(height: 24),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: const EdgeInsets.all(16),
          ),

          onPressed: () {
            if (name.text.trim().isEmpty ||
                phone.text.trim().length < 10 ||
                pin.text.trim().length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter name, valid mobile number and 4-digit demo PIN.',
                  ),
                ),
              );
              return;
            }

            data.fullName = name.text.trim();
            data.phone = phone.text.trim();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const KycScreen(),
              ),
              (r) => false,
            );
          },

          child: const Text('Continue to KYC Demo'),
        ),
      ],
    ),
  );
    Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
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
      child: Column(
        children: [
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Demo PIN',
            ),
          ),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: () {
              if (phone.text.trim().isEmpty ||
                  pin.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter mobile number and PIN.'),
                  ),
                );
                return;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
              );
            },
            child: const Text('Open Demo Wallet'),
          ),
        ],
      ),
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

  Future<void> _pick(
    String kind,
    ImageSource source,
  ) async {
    try {
      final file = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );

      if (file == null || !mounted) return;

      setState(() {
        if (kind == 'front') frontImage = file;
        if (kind == 'back') backImage = file;
        if (kind == 'selfie') selfieImage = file;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open image picker: $e'),
        ),
      );
    }
  }

  void _chooseImage(String kind) {
    showModalBottomSheet(
      context: context,
      builder: (sheet) => SafeArea(
        child: Wrap(
          children: [
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Identity Check – Demo'),
    ),

    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 58,
          color: brand,
        ),

        const Text(
          'KYC Verification Preview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Demo only: images are selected on this device for preview. They are not uploaded to NADRA or a verification server. Do not use real CNIC images in this demo.',
        ),

        const SizedBox(height: 20),

        TextField(
          controller: cnic,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Sample CNIC (demo only)',
            hintText: '00000-0000000-0',
          ),
        ),

        const SizedBox(height: 16),

        _imageCard(
          'CNIC Front',
          frontImage,
          () => _chooseImage('front'),
        ),

        _imageCard(
          'CNIC Back',
          backImage,
          () => _chooseImage('back'),
        ),

        _imageCard(
          'Selfie Preview',
          selfieImage,
          () => _chooseImage('selfie'),
        ),

        const SizedBox(height: 18),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: const EdgeInsets.all(16),
          ),

          onPressed: () {
            if (frontImage == null || backImage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please select both CNIC front and back images for this demo.',
                  ),
                ),
              );
              return;
            }

            data.updateKyc(
              'Demo Submitted – Not Verified',
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
              (r) => false,
            );
          },

          child: const Text('Submit Demo KYC'),
        ),

        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
              (r) => false,
            );
          },
          child: const Text('Skip for now'),
        ),
      ],
    ),
  );

  Widget _imageCard(
    String title,
    XFile? file,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(
              file == null
                  ? Icons.add_a_photo
                  : Icons.check_circle,
              color: brand,
            ),
            title: Text(title),
            subtitle: Text(
              file == null
                  ? 'Select from gallery or camera'
                  : 'Image selected',
            ),
          ),

          if (file != null)
            Image.file(
              File(file.path),
              height: 170,
              fit: BoxFit.contain,
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upload_file),
              label: Text(
                file == null ? 'Choose Image' : 'Change Image',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
      const HelpScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) {
          setState(() => tab = v);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Pay',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'APNA PAY',
                        style: TextStyle(
                          color: brand,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_outline),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalam-o-Alaikum, ${data.fullName.isEmpty ? "User" : data.fullName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Available Demo Balance',
                      style: TextStyle(color: Colors.white70),
                    ),

                    Text(
                      'Rs. ${data.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'DEMO WALLET • No real funds',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
                child: Text(
                  'Quick Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _action(
                        context,
                        Icons.send_rounded,
                        'Send Money',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SendMoneyScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: _action(
                        context,
                        Icons.account_balance_wallet,
                        'Add Money',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddMoneyScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: _action(
                        context,
                        Icons.phone_android,
                        'Mobile Load',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MobileLoadScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: _action(
                        context,
                        Icons.receipt_long,
                        'Bill Payment',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F5EB),
                      child: Icon(Icons.payments, color: brand),
                    ),
                    title: const Text(
                      'Payments & Services',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Electricity • Gas • Water • Government Fees',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F5EB),
                      child: Icon(
                        Icons.verified_user,
                        color: brand,
                      ),
                    ),
                    title: const Text('KYC Status'),
                    subtitle: Text(data.kycStatus),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KycScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ...data.activity.take(5).map(
                (e) => ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.swap_horiz),
                  ),
                  title: Text(e),
                  subtitle: const Text('Demo transaction'),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'DEMO ONLY — no real money transfer, bill payment or identity verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback tap,
  ) {
    return InkWell(
      onTap: tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE3F5EB),
              child: Icon(icon, color: brand),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      {'name': 'Daily Social Bundle', 'detail': 'Social data • 1 day', 'price': '50'},
      {'name': 'Weekly Social Bundle', 'detail': 'Social apps • 7 days', 'price': '150'},
      {'name': 'Monthly Social Bundle', 'detail': 'Social apps • 30 days', 'price': '500'},
      {'name': 'Monthly Data Bundle', 'detail': 'Internet data • 30 days', 'price': '1000'},
    ],
    'Zong': [
      {'name': 'Daily Social Package', 'detail': 'Social data • 1 day', 'price': '50'},
      {'name': 'Weekly Data Package', 'detail': 'Internet data • 7 days', 'price': '250'},
      {'name': 'Monthly Social Package', 'detail': 'Social apps • 30 days', 'price': '450'},
      {'name': 'Monthly Data Package', 'detail': 'Internet data • 30 days', 'price': '1200'},
    ],
    'Telenor': [
      {'name': 'Daily Social Pack', 'detail': 'Social data • 1 day', 'price': '60'},
      {'name': 'Weekly EasyCard', 'detail': 'Calls, SMS and data • 7 days', 'price': '300'},
      {'name': 'Monthly Social Pack', 'detail': 'Social apps • 30 days', 'price': '500'},
      {'name': 'Monthly EasyCard', 'detail': 'Calls, SMS and data • 30 days', 'price': '1000'},
    ],
    'Ufone': [
      {'name': 'Daily Light Package', 'detail': 'Calls and data • 1 day', 'price': '60'},
      {'name': 'Weekly Internet Package', 'detail': 'Internet data • 7 days', 'price': '250'},
      {'name': 'Monthly Social Package', 'detail': 'Social apps • 30 days', 'price': '450'},
      {'name': 'Monthly Super Card', 'detail': 'Calls, SMS and data • 30 days', 'price': '1000'},
    ],
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mobile Load & Packages')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Select Network',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),

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
              amount.clear();
            }),
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
            amount.clear();
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

          const Text(
            'Available Demo Packages',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...bundles[network]!.map((b) => Card(
            child: RadioListTile<String>(
              value: b['name']!,
              groupValue: selectedBundle,
              onChanged: (v) {
                setState(() {
                  selectedBundle = v!;
                  amount.text = b['price']!;
                });
              },
              title: Text(
                b['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${b['detail']} • Rs. ${b['price']}',
              ),
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
                  content: Text('Enter mobile number, amount and select a package.'),
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

            data.add(
              '$item • $network • ${phone.text.trim()}',
              value,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$item demo transaction recorded.'),
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
          'Demo prices only. Real mobile load and packages require an authorized operator API.',
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

        DropdownButtonFormField<String>(
          value: bank,
          items: banks.map((b) =>
            DropdownMenuItem(value: b, child: Text(b))
          ).toList(),
          onChanged: (v) {
            if (v != null) setState(() => bank = v);
          },
          decoration: const InputDecoration(
            labelText: 'Select Bank / Wallet',
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

            Navigator.pop(context);
          },
          child: const Text('Confirm Demo Transfer'),
        ),

        const SizedBox(height: 10),

        const Text(
          'Demo transfer only. No real money is sent.',
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add Money')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.account_balance_wallet,
          size: 65,
          color: brand,
        ),

        const Text(
          'Add Cash to APNA PAY',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        _addOption(
          context,
          Icons.account_balance,
          'Link Bank Account',
          'Bank connection preview',
        ),

        _addOption(
          context,
          Icons.credit_card,
          'Link Debit / Credit Card',
          'Card connection preview',
        ),

        _addOption(
          context,
          Icons.atm,
          'Cash Deposit Machine',
          'Machine finder preview',
        ),

        const SizedBox(height: 20),

        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Demo Deposit Amount',
            prefixText: 'Rs. ',
          ),
        ),

        const SizedBox(height: 18),

        FilledButton(
          onPressed: () {
            final v = double.tryParse(amount.text);

            if (v == null || v <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter a valid amount.'),
                ),
              );
              return;
            }

            data.add(
              'Demo Cash Deposit',
              v,
              credit: true,
            );

            Navigator.pop(context);
          },
          child: const Text('Add Demo Cash'),
        ),

        const SizedBox(height: 12),

        const Text(
          'Demo balance only. Real bank and card deposits are not connected.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );

  Widget _addOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: brand),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title is a demo preview.')),
          );
        },
      ),
    );
  }
}
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final search = TextEditingController();

  final Map<String, List<String>> groups = {
    'Utility Payments': [
      'Electricity',
      'Gas',
      'Water',
      'Telephone',
      'Internet',
    ],
    'Government Payments': [
      'NADRA Fee',
      'Passport Fee',
      'FBR / PSID',
      'Traffic E-Challan',
      'Vehicle Token Tax',
      'Driving Licence Fee',
      'Government Challan',
    ],
    'Education Payments': [
      'School Fees',
      'University Fees',
      'College Fees',
      'Board Examination Fee',
      'Entry Test Fee',
    ],
    'Other Services': [
      'Insurance',
      'Credit Card',
      'E-commerce',
      'Travel',
      'Financial Services',
      'Hotels',
    ],
  };

  IconData getIcon(String name) {
    if (name == 'Electricity') return Icons.bolt;
    if (name == 'Gas') return Icons.local_fire_department;
    if (name == 'Water') return Icons.water_drop;
    if (name == 'Telephone') return Icons.phone;
    if (name == 'Internet') return Icons.wifi;
    if (name.contains('NADRA')) return Icons.badge;
    if (name.contains('Passport')) return Icons.menu_book;
    if (name.contains('FBR')) return Icons.account_balance;
    if (name.contains('Challan')) return Icons.receipt_long;
    if (name.contains('School')) return Icons.school;
    if (name.contains('University')) return Icons.cast_for_education;
    if (name.contains('College')) return Icons.school_outlined;
    if (name.contains('Driving')) return Icons.directions_car;
    if (name.contains('Vehicle')) return Icons.directions_car_filled;
    if (name.contains('Insurance')) return Icons.security;
    if (name.contains('Credit')) return Icons.credit_card;
    if (name.contains('Travel')) return Icons.flight;
    return Icons.payments;
  }

  void openService(String service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicePaymentScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = search.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Services'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'All Payments in One Place',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Select the service you want to use.',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search service...',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 20),

          ...groups.entries.map((entry) {
            final items = entry.value
                .where((e) => e.toLowerCase().contains(q))
                .toList();

            if (items.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 12,
                  ),
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
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: .90,
                  ),

                  itemBuilder: (context, index) {
                    final service = items[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),

                      onTap: () {
                        openService(service);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFDCE9E1),
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  const Color(0xFFE3F5EB),
                              child: Icon(
                                getIcon(service),
                                color: brand,
                                size: 26,
                              ),
                            ),

                            const SizedBox(height: 9),

                            Text(
                              service,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),

          if (groups.values
              .expand((e) => e)
              .where((e) => e.toLowerCase().contains(q))
              .isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'No service found.',
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 20),

          const Text(
            'Demo services only. Real payments require authorized service provider APIs.',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }
}


// INDIVIDUAL SERVICE PAYMENT SCREEN

class ServicePaymentScreen extends StatefulWidget {
  final String service;

  const ServicePaymentScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServicePaymentScreen> createState() =>
      _ServicePaymentScreenState();
}

class _ServicePaymentScreenState
    extends State<ServicePaymentScreen> {

  final reference = TextEditingController();
  final amount = TextEditingController();
  final customerName = TextEditingController();

  String get referenceLabel {
    final s = widget.service;

    if (s.contains('NADRA')) return 'CNIC / Application Number';
    if (s.contains('Passport')) return 'Passport Application Number';
    if (s.contains('FBR')) return 'PSID Number';
    if (s.contains('E-Challan')) return 'Challan Number';
    if (s.contains('Vehicle')) return 'Vehicle Registration Number';
    if (s.contains('Driving')) return 'Licence / Application Number';
    if (s.contains('School')) return 'Student ID / Fee Reference';
    if (s.contains('University')) return 'University Registration Number';
    if (s.contains('College')) return 'College Student ID';
    if (s.contains('Board')) return 'Roll Number / Challan Number';
    if (s.contains('Entry')) return 'Application / Test Number';

    if (s == 'Electricity') return '14-digit Reference Number';
    if (s == 'Gas') return 'Consumer Number';
    if (s == 'Water') return 'Consumer / Account Number';
    if (s == 'Telephone') return 'Telephone Number';
    if (s == 'Internet') return 'Customer / Account Number';

    return 'Reference / Account Number';
  }

  IconData get serviceIcon {
    final s = widget.service;

    if (s == 'Electricity') return Icons.bolt;
    if (s == 'Gas') return Icons.local_fire_department;
    if (s == 'Water') return Icons.water_drop;
    if (s == 'Internet') return Icons.wifi;
    if (s.contains('School') || s.contains('University')) {
      return Icons.school;
    }
    if (s.contains('Passport')) return Icons.menu_book;
    if (s.contains('NADRA')) return Icons.badge;
    if (s.contains('Vehicle') || s.contains('Driving')) {
      return Icons.directions_car;
    }

    return Icons.receipt_long;
  }

  void submitPayment() {
    final value = double.tryParse(amount.text.trim());

    if (reference.text.trim().isEmpty ||
        value == null ||
        value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter reference number and valid amount.',
          ),
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
      '${widget.service} • ${reference.text.trim()}',
      value,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Demo Transaction Successful'),
        content: Text(
          '${widget.service}\n'
          'Reference: ${reference.text.trim()}\n'
          'Amount: Rs. ${value.toStringAsFixed(2)}\n\n'
          'This is only a local demo record. No real bill or fee was paid.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.service),
    ),

    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xFFE3F5EB),
          child: Icon(
            serviceIcon,
            color: brand,
            size: 42,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          widget.service,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Enter your payment information below.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),

        const SizedBox(height: 24),

        TextField(
          controller: customerName,
          decoration: const InputDecoration(
            labelText: 'Customer Name (Optional)',
            prefixIcon: Icon(Icons.person),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: reference,
          decoration: InputDecoration(
            labelText: referenceLabel,
            prefixIcon: const Icon(Icons.numbers),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Amount in PKR',
            prefixText: 'Rs. ',
            prefixIcon: Icon(Icons.payments),
          ),
        ),

        const SizedBox(height: 24),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            padding: const EdgeInsets.all(16),
          ),

          onPressed: submitPayment,

          icon: const Icon(Icons.check_circle),
          label: const Text('Continue Demo Payment'),
        ),

        const SizedBox(height: 16),

        const Text(
          'IMPORTANT: This screen is a demonstration only. It does not verify bill details, PSID, CNIC, challan or student fees. No actual payment is made.',
          style: TextStyle(
            color: Colors.deepOrange,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
class QuickActionsScreen extends StatelessWidget {
  const QuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pay & Scan')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.qr_code_scanner,
          size: 90,
          color: brand,
        ),

        const SizedBox(height: 12),

        const Text(
          'Scan & Pay',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Scan QR and pay merchants (demo preview).',
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 22),

        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'QR scanner requires an approved QR payment integration.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Open QR Scanner'),
        ),

        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentsScreen(),
              ),
            );
          },
          child: const Text('All Payments & Services'),
        ),

        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SendMoneyScreen(),
              ),
            );
          },
          child: const Text('Send Money'),
        ),

        const SizedBox(height: 20),

        const Text(
          'QR scanning and real merchant payments are not connected in this demo.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );
}


// CARDS SCREEN

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
              colors: [
                Color(0xFF16B879),
                Color(0xFF07583C),
              ],
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
              Icon(
                Icons.contactless,
                color: Colors.white,
                size: 34,
              ),
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
          'Card Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        ListTile(
          leading: const Icon(
            Icons.credit_card,
            color: brand,
          ),
          title: const Text('Order Debit Card'),
          subtitle: const Text('Physical / Virtual Card'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _cardMessage(
            context,
            'Card ordering requires an approved issuing bank.',
          ),
        ),

        ListTile(
          leading: const Icon(
            Icons.lock_outline,
            color: brand,
          ),
          title: const Text('Card Controls'),
          subtitle: const Text('Freeze / Unfreeze Card'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _cardMessage(
            context,
            'Card controls are available after card issuance.',
          ),
        ),

        ListTile(
          leading: const Icon(
            Icons.local_offer,
            color: brand,
          ),
          title: const Text('Card Discounts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _cardMessage(
            context,
            'Card discounts will be available after partner integration.',
          ),
        ),

        const Text(
          'Demo card only. No real card has been issued.',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ],
    ),
  );
}

void _cardMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('APNA PAY Cards'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}


// HELP AND SUPPORT

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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
              leading: const Icon(
                Icons.support_agent,
                color: brand,
              ),
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

void _helpAction(BuildContext context, String title) {
  final ctrl = TextEditingController();

  showDialog(
    context: context,
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
            if (ctrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter details.'),
                ),
              );
              return;
            }

            data.activity.insert(
              0,
              '$title • ${ctrl.text.trim()}',
            );

            data.notifyListeners();

            Navigator.pop(d);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Demo request saved locally.'),
              ),
            );
          },
          child: const Text('Submit Demo'),
        ),
      ],
    ),
  );
}


// TRANSACTION HISTORY

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: data,
    builder: (_, __) => Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),

      body: data.activity.isEmpty
          ? const Center(
              child: Text('No transactions found.'),
            )
          : ListView.builder(
              itemCount: data.activity.length,
              itemBuilder: (context, index) {
                final item = data.activity[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F5EB),
                      child: Icon(
                        Icons.receipt_long,
                        color: brand,
                      ),
                    ),
                    title: Text(item),
                    subtitle: const Text('Demo transaction'),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                );
              },
            ),
    ),
  );
}


// PROFILE SCREEN

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: data,
    builder: (_, __) => Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: brand,
            child: Icon(
              Icons.person,
              size: 48,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            data.fullName.isEmpty
                ? 'Demo User'
                : data.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            data.phone,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('KYC Status'),
            subtitle: Text(data.kycStatus),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const KycScreen(),
                ),
              );
            },
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

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const WelcomeScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),

          const SizedBox(height: 12),

          const Text(
            'This is a demo prototype. Real financial services require authorized partners.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.deepOrange),
          ),
        ],
      ),
    ),
  );
}
