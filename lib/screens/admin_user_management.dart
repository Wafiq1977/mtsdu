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

  void _editUser(User user) {
    _showUserDialog(user: user);
  }

  void _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.deleteUser(user.id);
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} deleted')),
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
        title: Text(isEditing ? 'Edit User' : 'Add User'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => name = value!,
                ),
                TextFormField(
                  initialValue: username,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => username = value!,
                ),
                TextFormField(
                  initialValue: password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => password = value!,
                ),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: UserRole.values.map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.toString().split('.').last),
                  )).toList(),
                  onChanged: (value) => role = value!,
                ),
                if (role == UserRole.student) ...[
                  TextFormField(
                    initialValue: className,
                    decoration: const InputDecoration(labelText: 'Class'),
                    onSaved: (value) => className = value ?? '',
                  ),
                  TextFormField(
                    initialValue: major,
                    decoration: const InputDecoration(labelText: 'Major'),
                    onSaved: (value) => major = value ?? '',
                  ),
                ],
                if (role == UserRole.teacher) ...[
                  TextFormField(
                    initialValue: nip,
                    decoration: const InputDecoration(labelText: 'NIP'),
                    onSaved: (value) => nip = value ?? '',
                  ),
                  TextFormField(
                    initialValue: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    onSaved: (value) => subject = value ?? '',
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
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
                  SnackBar(content: Text('${isEditing ? 'Updated' : 'Added'} $name')),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
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
                  label: const Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _users.isEmpty
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
                          'No users found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add User" to create new accounts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
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
                                Text('Class: ${user.className} - Major: ${user.major}'),
                              if (user.role == UserRole.teacher)
                                Text('NIP: ${user.nip} - Subject: ${user.subject}'),
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
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
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
