import 'package:flutter/material.dart';

// =====================================================================
// IDENTITAS PEMBUAT TUGAS  -->  GANTI DENGAN DATA ANDA
// =====================================================================
class Creator {
  static const String nama = 'Galuh Pauline Nugraha';
  static const String nim = '5520124008';
  static const String kelas = 'Teknik Informatika - Kelas A';
}

// Warna tema
const Color kGreenDark = Color(0xFF075E54); // AppBar
const Color kGreenLight = Color(0xFF25D366); // FAB / aksen
const Color kChatBg = Color(0xFFECE5DD); // background chat detail
const Color kBubbleMe = Color(0xFFDCF8C6); // bubble pesan sendiri

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGreenDark,
          primary: kGreenDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kGreenDark,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: kGreenLight.withAlpha(90),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kGreenLight,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// =====================================================================
// MODEL & DATA DUMMY
// =====================================================================
class Message {
  final String text;
  final bool isMe;
  final String time;
  final String? sender; // nama pengirim (untuk chat grup)
  const Message(this.text, this.isMe, this.time, {this.sender});
}

class ChatItem {
  final String name;
  final Color color;
  final List<Message> messages; // isi percakapan
  final int unread;
  final String day; // '' = hari ini
  final bool isGroup;
  const ChatItem(
    this.name,
    this.color,
    this.messages, {
    this.unread = 0,
    this.day = '',
    this.isGroup = false,
  });

  Message get last => messages.last;

  // Teks pratinjau di daftar chat = pesan terakhir di isi chat
  String get preview {
    final m = last;
    if (m.isMe) return 'Kamu: ${m.text}';
    if (isGroup && m.sender != null) return '${m.sender}: ${m.text}';
    return m.text;
  }

  String get listTime => day.isEmpty ? last.time : day;
}

class NavDest {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const NavDest(this.icon, this.selectedIcon, this.label);
}

class CallItem {
  final ChatItem chat;
  final IconData icon;
  final Color color;
  final String when;
  const CallItem(this.chat, this.icon, this.color, this.when);
}

const List<ChatItem> dummyChats = [
  ChatItem('Fawwaz Ramadhan', Colors.teal, [
    Message('Pauline, tugas Flutter udah selesai belum?', false, '10:30'),
    Message('Udah, tinggal rapihin NavigationBar', true, '10:35'),
    Message('Kirim dong kodenya nanti malam', false, '10:38'),
    Message('Oke, nanti aku kirim lewat grup ya', true, '10:40'),
    Message('Oke siap Pauline', false, '10:42'),
  ], unread: 2),
  ChatItem('Siti Aminah', Colors.pink, [
    Message('Pauline, kamu udah kumpulin tugas Flutter?', false, '09:10'),
    Message('Udah tadi pagi, kamu gimana?', true, '09:12'),
    Message('Aku masih benerin Drawer-nya 😅', false, '09:15'),
  ]),
  ChatItem('Grup Kelas A', Colors.indigo, [
    Message('Selamat pagi, mohon dicek informasi berikut.', false, '08:20',
        sender: 'Pak Hendra'),
    Message('Kuis dimajukan hari Jumat, materi navigasi Flutter.', false, '08:30',
        sender: 'Pak Hendra'),
    Message('Siap Pak, noted!', true, '08:31'),
    Message('Terima kasih infonya, Pak', false, '08:33', sender: 'Rina'),
  ], unread: 5, isGroup: true),
  ChatItem('Andi Pratama', Colors.orange, [
    Message('Ndi, file desain UI-nya udah ada?', true, '19:40'),
    Message('Udah, nanti saya kirim filenya', false, '19:52'),
  ], day: 'Kemarin'),
  ChatItem('Rina Wulandari', Colors.purple, [
    Message('Pauline, boleh pinjam catatan kuliah kemarin?', false, '15:05'),
    Message('Boleh, udah aku kirim ke WhatsApp ya', true, '15:10'),
    Message('Terima kasih banyak ya 🙏', false, '15:12'),
  ], unread: 1, day: 'Kemarin'),
  ChatItem('Dewi Lestari', Colors.brown, [
    Message('Besok kamu masuk kelas jam berapa?', true, '16:20'),
    Message('Jam 8 kayaknya, kamu?', false, '16:25'),
    Message('Sama, sampai ketemu di kampus!', true, '16:26'),
    Message('Sampai ketemu di kampus!', false, '16:27'),
  ], day: 'Senin'),
  ChatItem('Fajar Nugroho', Colors.blueGrey, [
    Message('Tadi hujan deras ya di jalan', false, '18:10'),
    Message('Iya, aku sempat neduh dulu', true, '18:20'),
    Message('Sudah sampai rumah?', false, '18:45'),
  ], day: 'Senin'),
  ChatItem('Mama', Colors.red, [
    Message('Nak, hari ini pulang jam berapa?', false, '11:00'),
    Message('Sore Ma, habis kelas', true, '11:05'),
    Message('Jangan lupa makan ya nak', false, '11:06'),
  ], unread: 3, day: 'Minggu'),
];

// =====================================================================
// MAIN SCREEN (Scaffold: AppBar, Drawer, EndDrawer, NavigationBar)
// =====================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // State untuk EndDrawer
  bool _onlyUnread = false;
  bool _notifications = true;
  bool _readReceipts = true;

  static const _titles = ['ChatApp', 'Updates', 'Calls'];

  static const List<NavDest> _destinations = [
    NavDest(Icons.chat_outlined, Icons.chat, 'Chats'),
    NavDest(Icons.update_outlined, Icons.update, 'Updates'),
    NavDest(Icons.call_outlined, Icons.call, 'Calls'),
  ];

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const UpdatesTab();
      case 2:
        return const CallsTab();
      default:
        final chats =
            _onlyUnread ? dummyChats.where((c) => c.unread > 0).toList() : dummyChats;
        return ChatsTab(chats: chats);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // ------------------------- AppBar -------------------------
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cari',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Fitur pencarian'))),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Kamera',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Membuka kamera'))),
          ),
          // Tombol pembuka EndDrawer
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Pengaturan cepat',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),

      // ------------------------- Drawer (kiri) -------------------------
      drawer: _buildDrawer(context),

      // ------------------------- EndDrawer (kanan) -------------------------
      endDrawer: _buildEndDrawer(context),

      // ------------------------- Body -------------------------
      body: _buildBody(),

      // ------------------------- NavigationBar (bawah) -------------------------
      // Chats | Updates | Calls  --> SELALU tampil
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          _selectedIndex == 0
              ? Icons.message
              : _selectedIndex == 1
                  ? Icons.edit
                  : Icons.add_call,
        ),
      ),
    );
  }

  // ===================== DRAWER KIRI =====================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ProfileHeader: Nama, NIM, Kelas pembuat tugas
          Container(
            width: double.infinity,
            color: kGreenDark,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 48, color: kGreenDark),
                ),
                SizedBox(height: 14),
                Text(
                  Creator.nama,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('NIM: ${Creator.nim}',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 2),
                Text('Kelas/Prodi: ${Creator.kelas}',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Profil Pembuat Tugas'),
            subtitle: const Text('Lihat detail identitas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Account'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingDetailScreen(
                    title: 'Account',
                    icon: Icons.key_outlined,
                    items: ['Ubah nomor telepon', 'Keamanan', 'Hapus akun'],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingDetailScreen(
                    title: 'Privacy',
                    icon: Icons.lock_outline,
                    items: ['Terakhir dilihat', 'Foto profil', 'Info', 'Status'],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ===================== END DRAWER (KANAN) =====================
  Widget _buildEndDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: StatefulBuilder(
          builder: (context, setDrawerState) => ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: kGreenDark,
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: [
                    Icon(Icons.tune, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Pengaturan Cepat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Filter Chat',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SwitchListTile(
                activeColor: kGreenLight,
                title: const Text('Hanya belum dibaca'),
                secondary: const Icon(Icons.mark_chat_unread_outlined),
                value: _onlyUnread,
                onChanged: (v) {
                  setState(() => _onlyUnread = v);
                  setDrawerState(() {});
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Preferensi',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SwitchListTile(
                activeColor: kGreenLight,
                title: const Text('Notifikasi'),
                secondary: const Icon(Icons.notifications_outlined),
                value: _notifications,
                onChanged: (v) {
                  setState(() => _notifications = v);
                  setDrawerState(() {});
                },
              ),
              SwitchListTile(
                activeColor: kGreenLight,
                title: const Text('Read receipts'),
                secondary: const Icon(Icons.done_all),
                value: _readReceipts,
                onChanged: (v) {
                  setState(() => _readReceipts = v);
                  setDrawerState(() {});
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Tutup'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TAB: CHATS  (ListView -> Navigator.push ke ChatDetailScreen)
// =====================================================================
class ChatsTab extends StatelessWidget {
  final List<ChatItem> chats;
  const ChatsTab({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return const Center(child: Text('Tidak ada chat yang belum dibaca'));
    }
    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, i) {
        final chat = chats[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: chat.color,
            child: Text(
              chat.name[0],
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(chat.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(chat.preview,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat.listTime,
                style: TextStyle(
                  fontSize: 12,
                  color: chat.unread > 0 ? kGreenLight : Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              if (chat.unread > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: kGreenLight,
                  child: Text('${chat.unread}',
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ],
          ),
          // Stack Navigation
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatDetailScreen(chat: chat)),
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// TAB: UPDATES
// =====================================================================
class UpdatesTab extends StatelessWidget {
  const UpdatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: kGreenLight,
                  child: Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          title: Text('Status saya', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Ketuk untuk menambahkan status'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Pembaruan terbaru',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        for (final c in dummyChats.take(5))
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kGreenLight, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: c.color,
                child: Text(c.name[0],
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(c.day.isEmpty ? 'Hari ini, ${c.last.time}' : '${c.day}, ${c.last.time}'),
          ),
      ],
    );
  }
}

// =====================================================================
// TAB: CALLS
// =====================================================================
class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = <CallItem>[
      CallItem(dummyChats[0], Icons.call_received, Colors.green, 'Hari ini, 10:10'),
      CallItem(dummyChats[1], Icons.call_made, Colors.green, 'Hari ini, 08:45'),
      CallItem(dummyChats[3], Icons.call_missed, Colors.red, 'Kemarin, 20:30'),
      CallItem(dummyChats[7], Icons.call_received, Colors.green, 'Kemarin, 18:02'),
      CallItem(dummyChats[4], Icons.call_missed, Colors.red, 'Senin, 14:15'),
    ];
    return ListView(
      children: [
        for (final c in calls)
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: c.chat.color,
              child: Text(c.chat.name[0],
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(c.chat.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: c.color == Colors.red ? Colors.red : null,
                )),
            subtitle: Row(
              children: [
                Icon(c.icon, size: 16, color: c.color),
                const SizedBox(width: 4),
                Text(c.when),
              ],
            ),
            trailing: const Icon(Icons.call, color: kGreenDark),
          ),
      ],
    );
  }
}

// =====================================================================
// CHAT DETAIL SCREEN (di-push ke Stack Navigation)
// =====================================================================
class ChatDetailScreen extends StatefulWidget {
  final ChatItem chat;
  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final List<Message> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List<Message>.of(widget.chat.messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = TimeOfDay.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() => _messages.add(Message(text, true, time)));
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tombol back otomatis dari Navigator
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.chat.color,
              child: Text(widget.chat.name[0],
                  style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const Text('online',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Container(
        color: kChatBg,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _Bubble(message: _messages[i]),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: kGreenDark,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final me = message.isMe;
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: me ? kBubbleMe : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(me ? 12 : 0),
            bottomRight: Radius.circular(me ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!me && message.sender != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(message.sender!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kGreenDark)),
              ),
            Text(message.text, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                if (me) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 15, color: Colors.blue),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// PROFILE SCREEN (identitas pembuat tugas)
// =====================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pembuat Tugas')),
      body: ListView(
        children: [
          Container(
            color: kGreenDark,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 72, color: kGreenDark),
                ),
                SizedBox(height: 14),
                Text(Creator.nama,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Mahasiswa / Pembuat Tugas',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const _InfoTile(icon: Icons.person_outline, label: 'Nama', value: Creator.nama),
          const _InfoTile(icon: Icons.badge_outlined, label: 'NIM / NIS', value: Creator.nim),
          const _InfoTile(icon: Icons.school_outlined, label: 'Kelas / Prodi', value: Creator.kelas),
          const _InfoTile(icon: Icons.apps, label: 'Aplikasi', value: 'ChatApp (Flutter)'),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kGreenDark),
      title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}

// =====================================================================
// LAYAR DETAIL PENGATURAN (Account / Privacy)
// =====================================================================
class SettingDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  const SettingDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [
          for (final item in items)
            ListTile(
              leading: Icon(icon, color: kGreenDark),
              title: Text(item),
              trailing: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }
}