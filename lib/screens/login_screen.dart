import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/school.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/school_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  School? _selectedSchool;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) return;
    if (_selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectSchool)),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      schoolId: _selectedSchool!.id,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.appSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // 学校选择器
                    SchoolSelector(
                      selectedSchool: _selectedSchool,
                      onSchoolSelected: (school) {
                        setState(() => _selectedSchool = school);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 已选学校信息
                    if (_selectedSchool != null) _buildSelectedSchoolInfo(l10n),
                    const SizedBox(height: 20),

                    // 用户名
                    TextFormField(
                      controller: _usernameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.username,
                        hintText: l10n.usernameHint,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.usernameRequired : null,
                    ),
                    const SizedBox(height: 16),

                    // 密码
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        hintText: l10n.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.length < 3 ? l10n.passwordTooShort : null,
                    ),
                    const SizedBox(height: 8),

                    // 错误提示
                    if (auth.status == AuthStatus.error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _errorText(l10n, auth.errorCode),
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 登录按钮
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.login, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _errorText(AppLocalizations l10n, ApiErrorCode? code) {
    switch (code) {
      case ApiErrorCode.schoolNotFound:
        return l10n.schoolNotFound;
      case ApiErrorCode.invalidCredentials:
        return l10n.invalidCredentials;
      case ApiErrorCode.networkError:
        return l10n.loginFailed;
      default:
        return l10n.loginFailed;
    }
  }

  Widget _buildSelectedSchoolInfo(AppLocalizations l10n) {
    if (_selectedSchool == null) return const SizedBox.shrink();
    final school = _selectedSchool!;
    final isAdvanced = school.supportLevel == SupportLevel.advanced;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdvanced ? Colors.amber.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAdvanced ? Colors.amber.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAdvanced ? Icons.star : Icons.info_outline,
            size: 20,
            color: isAdvanced ? Colors.amber.shade700 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAdvanced
                  ? l10n.supportLevelAdvancedInfo(school.name)
                  : l10n.supportLevelBasicInfo(school.name),
              style: TextStyle(
                fontSize: 13,
                color: isAdvanced
                    ? Colors.amber.shade900
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
