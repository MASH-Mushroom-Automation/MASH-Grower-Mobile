import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/recent_accounts_service.dart';
import '../../providers/auth_provider.dart';

/// Widget to display recently logged-in accounts for quick sign-in
/// Similar to Facebook's "Recently Logged In" feature
class RecentAccountsWidget extends StatefulWidget {
  final Function(String email)? onAccountSelected;

  const RecentAccountsWidget({
    super.key,
    this.onAccountSelected,
  });

  @override
  State<RecentAccountsWidget> createState() => _RecentAccountsWidgetState();
}

class _RecentAccountsWidgetState extends State<RecentAccountsWidget> {
  final RecentAccountsService _recentAccountsService = RecentAccountsService();
  List<RecentAccount> _recentAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentAccounts();
  }

  Future<void> _loadRecentAccounts() async {
    await _recentAccountsService.initialize();
    final accounts = await _recentAccountsService.getRecentAccounts();
    setState(() {
      _recentAccounts = accounts;
      _isLoading = false;
    });
  }

  Future<void> _removeAccount(String email) async {
    await _recentAccountsService.removeRecentAccount(email);
    await _loadRecentAccounts();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_recentAccounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Recently Logged In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5F4C),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...(_recentAccounts.map((account) => _buildAccountCard(account))),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleAccountTap(RecentAccount account) async {
    if (account.hasPasswordSaved) {
      // Auto-login with saved password
      final password = await _recentAccountsService.getSavedPassword(account.email);
      if (password != null && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.signInWithEmail(
          account.email,
          password,
          rememberPassword: true,
        );
        
        if (!success && mounted && authProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Just fill email field
      widget.onAccountSelected?.call(account.email);
    }
  }

  Widget _buildAccountCard(RecentAccount account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleAccountTap(account),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Profile Avatar with password indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF2D5F4C),
                      backgroundImage: account.profileImageUrl != null
                          ? NetworkImage(account.profileImageUrl!)
                          : null,
                      child: account.profileImageUrl == null
                          ? Text(
                              account.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    if (account.hasPasswordSaved)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Account Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (account.hasPasswordSaved)
                        const SizedBox(height: 2),
                      if (account.hasPasswordSaved)
                        Text(
                          'Password saved',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Remove Button
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () => _showRemoveDialog(account),
                  tooltip: 'Remove account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(RecentAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Account'),
        content: Text(
          'Remove ${account.displayName} from recent accounts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeAccount(account.email);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
