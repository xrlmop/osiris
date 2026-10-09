import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;

class OsirisTheme {
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141419);
  static const Color neonGreen = Color(0xFF00FFA3);
  static const Color alertRed = Color(0xFFFF3333);
  static const Color textGray = Color(0xFF8A8A93);

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: background,
      fontFamily: 'monospace',
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: neonGreen,
        selectionColor: Color(0x3300FFA3),
        selectionHandleColor: neonGreen,
      ),
    );
  }

  static BoxDecoration neonBox({Color color = neonGreen}) {
    return BoxDecoration(
      color: surface,
      border: Border.all(color: color, width: 1.5),
      borderRadius: BorderRadius.circular(4),
    );
  }
}

class CryptoEngine {
  static Uint8List deriveKey(String password, Uint8List salt) {
    final digest = pc.Digest("SHA-256");
    final passwordBytes = utf8.encode(password);
    
    final input = Uint8List(passwordBytes.length + salt.length);
    input.setAll(0, passwordBytes);
    input.setAll(passwordBytes.length, salt);
    
    return digest.process(input);
  }

  static String encrypt(String plainText, String password, Uint8List salt) {
    final key = deriveKey(password, salt);
    final random = Random.secure();
    final iv = Uint8List.fromList(List.generate(12, (_) => random.nextInt(256)));
    
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    final params = pc.AEADParameters(pc.KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(true, params);
    
    final inputBytes = utf8.encode(plainText);
    final cipherText = cipher.process(Uint8List.fromList(inputBytes));
    
    final result = Uint8List(iv.length + cipherText.length);
    result.setAll(0, iv);
    result.setAll(iv.length, cipherText);
    
    return base64.encode(result);
  }

  static String? decrypt(String base64Cipher, String password, Uint8List salt) {
    try {
      final key = deriveKey(password, salt);
      final rawData = base64.decode(base64Cipher);
      
      final iv = rawData.sublist(0, 12);
      final cipherText = rawData.sublist(12);
      
      final cipher = pc.GCMBlockCipher(pc.AESEngine());
      final params = pc.AEADParameters(pc.KeyParameter(key), 128, iv, Uint8List(0));
      cipher.init(false, params);
      
      final decryptedBytes = cipher.process(cipherText);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      return null;
    }
  }

  static String generateSecureString(int length, String chars) {
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const OsirisPassApp());
}

class OsirisPassApp extends StatelessWidget {
  const OsirisPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSIRIS PASS',
      theme: OsirisTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _eyeLines = [
    "⠐⢤⣀⣀⡀⠀⠀⠀⢀⣀⣀⣀⣀⣠⣤⣤⣤⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⠀⠀",
    "⡄⠀⠈⠛⠿⢿⡿⠟⠛⠛⠛⠛⠛⠛⠛⠉⠉⠉⠉⠉⠁⠀⠀⠈⠉⠉⠛⠻⡇",
    "⢹⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣶⣶⣶⣶⣦⣄⠀⠀⠀⠁",
    "⠀⢻⣿⣿⣶⣶⣦⣤⣤⣤⣤⣤⣶⣾⣿⣿⠿⠛⢋⣿⣿⣿⣿⡛⢿⣷⣄⠀⠀",
    "⠀⠀⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣭⣁⡀⠀⠀⠸⣿⣿⣿⣿⠇⠀⣘⣿⣿⣦⡄",
    "⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠿⢿⣿⣿⣶⣶⣿⣿⣿⣿⣶⣿⣿⡿⠿⠿⣇",
    "⠀⠀⠀⠀⠀⠀⠐⣶⣤⡀⠀⠀⠀⠀⠀⠀⠉⠙⠛⣻⣿⣿⣿⡟⠉⠀⠀⠀⠀",
    "⠀⠀⠀⠀⢀⣶⡿⠿⢿⣿⡆⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⢿⣿⡅⢸⠀⠀⠀⠀",
    "⠀⠀⠀⠀⣿⡏⠀⠀⠀⢹⠇⠀⠀⠀⢀⣠⣾⣿⡿⠋⠁⢸⣿⣿⡟⠀⠀⠀⠀",
    "⠀⠀⠀⠀⢿⣷⡀⠀⠔⠋⢀⣀⣤⣶⣿⡿⠛⠁⠀⠀⠀⢸⣿⡟⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠙⠿⠿⣿⣿⡿⠿⠟⠋⠁⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⠿⠆⠀⠀⠀⠀"
  ];

  String _visibleEye = "";
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _animateEye(0);
  }

  void _animateEye(int currentLine) {
    if (currentLine <= _eyeLines.length) {
      setState(() {
        _visibleEye = _eyeLines.sublist(0, currentLine).join("\n");
      });
      Future.delayed(const Duration(milliseconds: 40), () => _animateEye(currentLine + 1));
    } else {
      setState(() => _showText = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                _visibleEye,
                style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 6.8, height: 1.1, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 35),
            if (_showText) ...[
              const Text(">> OSIRIS PASS <<", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("powered by @xrlmop", style: TextStyle(color: Colors.white, fontSize: 13)),
            ]
          ],
        ),
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
  final _storage = const FlutterSecureStorage();
  final _masterController = TextEditingController();
  
  List<String> _accounts = [];
  String _selectedAccount = "SELECT OR CREATE ID";
  bool _obscureMaster = true;

  @override
  void initState() {
    super.initState();
    _loadAccountsList();
  }

  Future<void> _loadAccountsList() async {
    final raw = await _storage.read(key: "osiris_accounts_index");
    if (raw != null && raw.isNotEmpty) {
      setState(() {
        _accounts = List<String>.from(json.decode(raw));
        if (_accounts.isNotEmpty && _selectedAccount == "SELECT OR CREATE ID") {
          _selectedAccount = _accounts.first;
        }
      });
    }
  }

  void _generateNewID() async {
    final random = Random.secure();
    final newId = List.generate(26, (_) => random.nextInt(10).toString()).join();
    
    _accounts.add(newId);
    await _storage.write(key: "osiris_accounts_index", value: json.encode(_accounts));
    
    final salt = List.generate(16, (_) => random.nextInt(256));
    await _storage.write(key: "salt_$newId", value: base64.encode(salt));

    setState(() {
      _selectedAccount = newId;
    });
    Clipboard.setData(ClipboardData(text: newId));
    _showTerminalAlert("NEW ID", "26-DIGIT ID CREATED & COPIED TO CLIPBOARD!");
  }

  void _generateMasterPassword() {
    final pwd = CryptoEngine.generateSecureString(24, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*');
    setState(() {
      _masterController.text = pwd;
      _obscureMaster = false;
    });
    Clipboard.setData(ClipboardData(text: pwd));
    _showTerminalAlert("GENERATOR", "MASTER KEY GENERATED & COPIED!");
  }

  void _attemptLogin() async {
    if (_selectedAccount == "SELECT OR CREATE ID" || _masterController.text.trim().isEmpty) {
      _showTerminalAlert("ACCESS DENIED", "SELECT ID AND ENTER MASTER KEY!");
      return;
    }

    final accId = _selectedAccount;
    final master = _masterController.text.trim();
    
    final encryptedVault = await _storage.read(key: "vault_$accId");
    final rawSalt = await _storage.read(key: "salt_$accId");
    
    if (encryptedVault == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainNavigationHolder(accountId: accId, masterPassword: master, initialData: const {}, saltBase64: rawSalt!)),
      );
    } else {
      final saltBytes = base64.decode(rawSalt!);
      final decrypted = CryptoEngine.decrypt(encryptedVault, master, saltBytes);
      
      if (decrypted == null) {
        _showTerminalAlert("ERROR", "DECRYPTION FAILED! WRONG MASTER KEY.");
      } else {
        final Map<String, dynamic> vaultData = json.decode(decrypted);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainNavigationHolder(accountId: accId, masterPassword: master, initialData: vaultData, saltBase64: rawSalt)),
        );
      }
    }
  }

  void _wipeAccount() async {
    if (_selectedAccount == "SELECT OR CREATE ID") return;
    
    final accId = _selectedAccount;
    _accounts.remove(accId);
    await _storage.write(key: "osiris_accounts_index", value: json.encode(_accounts));
    await _storage.delete(key: "vault_$accId");
    await _storage.delete(key: "salt_$accId");

    setState(() {
      _selectedAccount = _accounts.isNotEmpty ? _accounts.first : "SELECT OR CREATE ID";
    });
    _showTerminalAlert("WIPE SYSTEM", "ACCOUNT WIPED COMPLETELY.");
  }

  void _showTerminalAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: OsirisTheme.background,
        shape: const RoundedRectangleBorder(side: BorderSide(color: OsirisTheme.neonGreen, width: 2)),
        title: Text(">> ${title.toUpperCase()} <<", style: const TextStyle(color: OsirisTheme.neonGreen, fontFamily: 'monospace'), textAlign: TextAlign.center),
        content: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'monospace'), textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("[ OK ]", style: TextStyle(color: OsirisTheme.neonGreen, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: OsirisTheme.neonBox(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    const [
                      "⠐⢤⣀⣀⡀⠀⠀⠀⢀⣀⣀⣀⣀⣠⣤⣤⣤⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⠀⠀",
                      "⡄⠀⠈⠛⠿⢿⡿⠟⠛⠛⠛⠛⠛⠛⠛⠉⠉⠉⠉⠉⠁⠀⠀⠈⠉⠉⠛⠻⡇",
                      "⢹⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣶⣶⣶⣶⣦⣄⠀⠀⠀⠁",
                      "⠀⢻⣿⣿⣶⣶⣦⣤⣤⣤⣤⣤⣶⣾⣿⣿⠿⠛⢋⣿⣿⣿⣿⡛⢿⣷⣄⠀⠀",
                      "⠀⠀⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣭⣁⡀⠀⠀⠸⣿⣿⣿⣿⠇⠀⣘⣿⣿⣦⡄",
                      "⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠿⢿⣿⣿⣶⣶⣿⣿⣿⣿⣶⣿⣿⡿⠿⠿⣇",
                      "⠀⠀⠀⠀⠀⠀⠐⣶⣤⡀⠀⠀⠀⠀⠀⠀⠉⠙⠛⣻⣿⣿⣿⡟⠉⠀⠀⠀⠀",
                      "⠀⠀⠀⠀⢀⣶⡿⠿⢿⣿⡆⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⢿⣿⡅⢸⠀⠀⠀⠀",
                      "⠀⠀⠀⠀⣿⡏⠀⠀⠀⢹⠇⠀⠀⠀⢀⣠⣾⣿⡿⠋⠁⢸⣿⣿⡟⠀⠀⠀⠀",
                      "⠀⠀⠀⠀⢿⣷⡀⠀⠔⠋⢀⣀⣤⣶⣿⡿⠛⠁⠀⠀⠀⢸⣿⡟⠀⠀⠀⠀",
                      "⠀⠀⠀⠀⠀⠙⠿⠿⣿⣿⡿⠿⠟⠋⠁⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀",
                      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠀⠀⠀⠀",
                      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⠿⠆⠀⠀⠀⠀"
                    ].join("\n"),
                    style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 5.5, height: 1.1, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(">> OSIRIS PASS <<", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                const Text("DECENTRALIZED MULTI-VAULT KEEPER", style: TextStyle(color: OsirisTheme.textGray, fontSize: 10)),
                const SizedBox(height: 24),
                
                const Align(alignment: Alignment.centerLeft, child: Text("DIGITAL ACCOUNT ID:", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.bold))),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: OsirisTheme.neonGreen, width: 1.5), color: OsirisTheme.background, borderRadius: BorderRadius.circular(4)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _accounts.contains(_selectedAccount) ? _selectedAccount : null,
                      hint: Text(_selectedAccount, style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 13, fontFamily: 'monospace')),
                      dropdownColor: OsirisTheme.surface,
                      icon: const Icon(Icons.arrow_drop_down, color: OsirisTheme.neonGreen),
                      items: _accounts.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 13, fontFamily: 'monospace')),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setState(() => _selectedAccount = newValue);
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: OsirisTheme.background, side: const BorderSide(color: OsirisTheme.neonGreen, width: 1.5), minimumSize: const Size(double.infinity, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _generateNewID,
                  child: const Text("[ GENERATE NEW DIGITAL ID ]", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text("MASTER-PASSWORD:", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.bold))),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: OsirisTheme.neonGreen, width: 1.5), color: OsirisTheme.background, borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _masterController,
                          obscureText: _obscureMaster,
                          style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 14, fontFamily: 'monospace'),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            hintText: "ENTER MASTER KEY",
                            hintStyle: TextStyle(color: Color(0xFF454554)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Text(_obscureMaster ? "[+]" : "[-]", style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                        onPressed: () => setState(() => _obscureMaster = !_obscureMaster),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: OsirisTheme.background, side: const BorderSide(color: OsirisTheme.neonGreen, width: 1.5), minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _generateMasterPassword,
                  child: const Text("[ GENERATE MASTER PASSWORD ]", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: OsirisTheme.background, side: const BorderSide(color: OsirisTheme.neonGreen, width: 1.5), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _attemptLogin,
                  child: const Text("[ PASS ]", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: OsirisTheme.background, side: const BorderSide(color: OsirisTheme.alertRed, width: 1.5), minimumSize: const Size(double.infinity, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  onPressed: _wipeAccount,
                  child: const Text("[ WIPE / DELETE ACCOUNT ]", style: TextStyle(color: OsirisTheme.alertRed, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class MainNavigationHolder extends StatefulWidget {
  final String accountId;
  final String masterPassword;
  final String saltBase64;
  final Map<String, dynamic> initialData;

  const MainNavigationHolder({
    super.key,
    required this.accountId,
    required this.masterPassword,
    required this.saltBase64,
    required this.initialData,
  });

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  final _storage = const FlutterSecureStorage();
  final _siteController = TextEditingController();
  final _loginController = TextEditingController();
  final _passController = TextEditingController();

  late Map<String, dynamic> _vault;
  final Map<String, bool> _visibilityMap = {};
  bool _obscureInputPass = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _vault = Map<String, dynamic>.from(widget.initialData);
  }

  void _generateRandomRecordPassword() {
    final pwd = CryptoEngine.generateSecureString(16, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*');
    setState(() {
      _passController.text = pwd;
      _obscureInputPass = false;
    });
  }

  void _encryptAndSaveRecord() async {
    final site = _siteController.text.trim().toLowerCase();
    final login = _loginController.text.trim();
    final pwd = _passController.text.trim();

    if (site.isEmpty || login.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ALL TERMINAL FIELDS MUST BE FILLED.")));
      return;
    }

    setState(() {
      _vault[site] = {"login": login, "password": pwd};
    });

    final saltBytes = base64.decode(widget.saltBase64);
    final encryptedStr = CryptoEngine.encrypt(json.encode(_vault), widget.masterPassword, saltBytes);
    await _storage.write(key: "vault_${widget.accountId}", value: encryptedStr);

    _siteController.clear();
    _loginController.clear();
    _passController.clear();
    setState(() {
      _obscureInputPass = true;
      _currentIndex = 1;
    });
  }

  void _deleteRecord(String site) async {
    setState(() {
      _vault.remove(site);
    });
    final saltBytes = base64.decode(widget.saltBase64);
    final encryptedStr = CryptoEngine.encrypt(json.encode(_vault), widget.masterPassword, saltBytes);
    await _storage.write(key: "vault_${widget.accountId}", value: encryptedStr);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildAddRecordPage(),
      _buildRecordsIndexPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: OsirisTheme.surface,
        elevation: 0,
        title: Text(
          "ID: ${widget.accountId.substring(0, min(10, widget.accountId.length))}...",
          style: const TextStyle(color: OsirisTheme.textGray, fontSize: 13, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: const Text("[ LOCK ]", style: TextStyle(color: OsirisTheme.alertRed, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          )
        ],
      ),
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: OsirisTheme.neonGreen, width: 1.5))),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: OsirisTheme.surface,
          selectedItemColor: OsirisTheme.neonGreen,
          unselectedItemColor: OsirisTheme.textGray,
          selectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'monospace'),
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "[ ADD VAULT ]"),
            BottomNavigationBarItem(icon: Icon(Icons.storage), label: "[ SECURED INDEX ]"),
          ],
        ),
      ),
    );
  }

  Widget _buildAddRecordPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: OsirisTheme.neonBox(),
        child: Column(
          children: [
            const Text("ADD RECORD TERMINAL", style: TextStyle(color: OsirisTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace')),
            const SizedBox(height: 16),
            _buildInputField(_siteController, "SITE / APP NAME"),
            _buildInputField(_loginController, "LOGIN / EMAIL"),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: OsirisTheme.neonGreen, width: 1.5), color: OsirisTheme.background, borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passController,
                      obscureText: _obscureInputPass,
                      style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 14, fontFamily: 'monospace'),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), hintText: "PASSWORD", hintStyle: TextStyle(color: Color(0xFF454554)), border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: Text(_obscureInputPass ? "[+]" : "[-]", style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () => setState(() => _obscureInputPass = !_obscureInputPass),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: OsirisTheme.background, side: const BorderSide(color: OsirisTheme.neonGreen, width: 1.5), minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              onPressed: _generateRandomRecordPassword,
              child: const Text("[ GENERATE PASSWORD ]", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: OsirisTheme.background, side: const BorderSide(color: OsirisTheme.neonGreen, width: 1.5), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              onPressed: _encryptAndSaveRecord,
              child: const Text("[ ENCRYPT & SAVE RECORD ]", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRecordsIndexPage() {
    if (_vault.isEmpty) {
      return const Center(child: Text("INDEX EMPTY. ADD RECORD VIA TERMINAL.", style: TextStyle(color: OsirisTheme.textGray, fontSize: 13, fontFamily: 'monospace')));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _vault.keys.length,
      itemBuilder: (context, index) {
        final site = _vault.keys.elementAt(index);
        final creds = _vault[site];
        final isVisible = _visibilityMap[site] ?? false;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(border: Border.all(color: OsirisTheme.neonGreen, width: 1.5), color: OsirisTheme.surface, borderRadius: BorderRadius.circular(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("TARGET: ${site.toUpperCase()}", style: const TextStyle(color: OsirisTheme.neonGreen, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: OsirisTheme.alertRed, size: 22),
                    onPressed: () => _deleteRecord(site),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text("LOGIN:  ${creds['login']}", style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
              const SizedBox(height: 6),
              Text("KEY:    ${isVisible ? creds['password'] : '••••••••••••••••'}", style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: OsirisTheme.neonGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      onPressed: () => setState(() => _visibilityMap[site] = !isVisible),
                      child: Text(isVisible ? "[ HIDE ]" : "[ SHOW ]", style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: OsirisTheme.neonGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      onPressed: () => Clipboard.setData(ClipboardData(text: creds['password'])),
                      child: const Text("[ COPY KEY ]", style: TextStyle(color: OsirisTheme.neonGreen, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: OsirisTheme.neonGreen, width: 1.5), color: OsirisTheme.background, borderRadius: BorderRadius.circular(4)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: OsirisTheme.neonGreen, fontSize: 14, fontFamily: 'monospace'),
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), hintText: hint, hintStyle: const TextStyle(color: Color(0xFF454554)), border: InputBorder.none),
      ),
    );
  }
}
