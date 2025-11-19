import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  List<User> _users = [];
  bool _isLoading = true;
  UserRole? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final users = await authProvider.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _addUser() {
    _showUserDialog();
  }

  List<User> get filteredUsers {
    if (_selectedRoleFilter == null) {
      return _users;
    }
    return _users.where((user) => user.role == _selectedRoleFilter).toList();
  }

  void _editUser(User user) {
    _showUserDialog(user: user);
  }

  void _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.name}? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.deleteUser(user.id);
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} berhasil dihapus')),
      );
    }
  }

  void _resetPassword(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Reset password for ${user.name} to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final updatedUser = user.copyWith(password: '123456'); // Default password
      await authProvider.updateUser(updatedUser);
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset to 123456')),
      );
    }
  }

  void _showUserDialog({User? user}) {
    final isEditing = user != null;
    final formKey = GlobalKey<FormState>();
    String name = user?.name ?? '';
    String username = user?.username ?? '';
    String password = user?.password ?? '';
    UserRole role = user?.role ?? UserRole.student;
    String className = user?.className ?? '';
    String major = user?.major ?? '';
    String nip = user?.nip ?? '';
    String subject = user?.subject ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit User' : 'Tambah User'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Masukkan username',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator: (value) => value!.isEmpty ? 'Username wajib diisi' : null,
                  onSaved: (value) => username = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: password,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: 'Peran',
                    prefixIcon: Icon(Icons.group),
                  ),
                  items: UserRole.values.map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => setState(() => role = value!),
                ),
                const SizedBox(height: 16),
                if (role == UserRole.student) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Informasi Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: className,
                            decoration: const InputDecoration(
                              labelText: 'Kelas',
                              hintText: 'Contoh: 10A',
                              prefixIcon: Icon(Icons.class_),
                            ),
                            onSaved: (value) => className = value ?? '',
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: major,
                            decoration: const InputDecoration(
                              labelText: 'Jurusan',
                              hintText: 'Contoh: IPA',
                              prefixIcon: Icon(Icons.school),
                            ),
                            onSaved: (value) => major = value ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (role == UserRole.teacher) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Informasi Guru', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: nip,
                            decoration: const InputDecoration(
                              labelText: 'NIP',
                              hintText: 'Masukkan NIP',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            onSaved: (value) => nip = value ?? '',
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: subject,
                            decoration: const InputDecoration(
                              labelText: 'Mata Pelajaran',
                              hintText: 'Contoh: Matematika',
                              prefixIcon: Icon(Icons.book),
                            ),
                            onSaved: (value) => subject = value ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);

                final newUser = User(
                  id: isEditing ? user!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  username: username,
                  password: password,
                  role: role,
                  name: name,
                  className: className,
                  major: major,
                  nip: nip,
                  subject: subject,
                );

                if (isEditing) {
                  await authProvider.updateUser(newUser);
                } else {
                  await authProvider.register(newUser);
                }

                _loadUsers();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isEditing ? 'User berhasil diperbarui' : 'User berhasil ditambahkan'}')),
                );
              }
            },
            child: Text(isEditing ? 'Perbarui' : 'Tambah'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header with Add User button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addUser,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Filter by role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter berdasarkan Peran:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRoleFilter = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRoleFilter == null ? const Color(0xFF667EEA) : Colors.grey[300],
                        foregroundColor: _selectedRoleFilter == null ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Semua'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRoleFilter = UserRole.student;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRoleFilter == UserRole.student ? const Color(0xFF667EEA) : Colors.grey[300],
                        foregroundColor: _selectedRoleFilter == UserRole.student ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Student'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRoleFilter = UserRole.teacher;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRoleFilter == UserRole.teacher ? const Color(0xFF667EEA) : Colors.grey[300],
                        foregroundColor: _selectedRoleFilter == UserRole.teacher ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Teacher'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRoleFilter = UserRole.admin;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRoleFilter == UserRole.admin ? const Color(0xFF667EEA) : Colors.grey[300],
                        foregroundColor: _selectedRoleFilter == UserRole.admin ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Admin'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada user ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tekan "Tambah User" untuk membuat akun baru',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getRoleColor(user.role),
                            child: Icon(
                              _getRoleIcon(user.role),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${user.role.toString().split('.').last} - ${user.username}'),
                              if (user.role == UserRole.student)
                                Text('Kelas: ${user.className} - Jurusan: ${user.major}'),
                              if (user.role == UserRole.teacher)
                                Text('NIP: ${user.nip} - Mata Pelajaran: ${user.subject}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _editUser(user);
                                  break;
                                case 'delete':
                                  _deleteUser(user);
                                  break;
                                case 'reset':
                                  _resetPassword(user);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'reset', child: Text('Reset Password')),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.green;
      case UserRole.teacher:
        return Colors.orange;
      case UserRole.admin:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.teacher:
        return Icons.person;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
