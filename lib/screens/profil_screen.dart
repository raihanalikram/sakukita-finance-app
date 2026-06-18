import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfil(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final TextEditingController nameController = TextEditingController(
      text: user?.displayName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  await user?.updateDisplayName(nameController.text.trim());
                  await user?.reload();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil diperbarui!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {});
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui profil: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ubahKataSandi(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Ubah Kata Sandi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Kata Sandi Baru (Min. 6 Karakter)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              if (passwordController.text.length >= 6) {
                try {
                  await user?.updatePassword(passwordController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kata sandi berhasil diubah!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gagal: Sesi terlalu lama. Silakan logout & login kembali.',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi minimal 6 karakter!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String namaUser = user?.displayName ?? 'Pengguna SakuKita';
    final String emailUser = user?.email ?? 'Tidak ada email terhubung';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  namaUser,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  emailUser,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                _buildMenuSection(
                  title: 'Pengaturan Akun',
                  children: [
                    _buildMenuItem(
                      Icons.person_outline,
                      'Edit Profil',
                      Colors.blue,
                      onTap: () => _editProfil(context),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.lock_outline,
                      'Ubah Kata Sandi',
                      Colors.orange,
                      onTap: () => _ubahKataSandi(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildMenuSection(
                  title: 'Umum',
                  children: [
                    _buildMenuItem(
                      Icons.notifications_none,
                      'Notifikasi',
                      Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Notifikasi segera hadir!'),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.security_outlined,
                      'Keamanan Data',
                      Colors.teal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'SakuKita dilindungi oleh Firebase Authentication.',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.help_outline,
                      'Pusat Bantuan',
                      Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hubungi admin SakuKita untuk bantuan.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Keluar Aplikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      backgroundColor: Colors.red.withOpacity(0.05),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'SakuKita v1.0.0',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          elevation: 0.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color color, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 4.0,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }
}
