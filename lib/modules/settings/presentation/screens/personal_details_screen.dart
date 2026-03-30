import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:conta_facil/core/constants/app_colors.dart';
import 'package:conta_facil/modules/settings/domain/models/settings_models.dart';
import 'package:conta_facil/modules/transactions/providers/transaction_provider.dart';
import 'package:conta_facil/modules/auth/providers/auth_provider.dart';
import 'package:conta_facil/core/providers/subscription_provider.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;
  String _selectedProvince = 'Maputo Cidade';

  final List<String> _provincias = [
    'Maputo Cidade',
    'Maputo Província',
    'Gaza',
    'Inhambane',
    'Sofala',
    'Manica',
    'Tete',
    'Zambézia',
    'Nampula',
    'Niassa',
    'Cabo Delgado',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userSettingsProvider).profile;
    _nameController = TextEditingController(text: profile.name);
    _surnameController = TextEditingController(text: profile.surname);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _cityController = TextEditingController(text: profile.city);
    _bioController = TextEditingController(text: profile.bio);
    _selectedProvince = profile.province;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final isPro = ref.read(subscriptionProvider) == SubscriptionPlan.pro;
    
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image == null) return;

      // 1. Validate Format (GIF only for Pro)
      final extension = image.path.split('.').last.toLowerCase();
      if (extension == 'gif' && !isPro) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GIFs de perfil são exclusivos para utilizadores PRO! 💎'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        return;
      }

      // 2. Validate Size (Max 2MB)
      final file = File(image.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 2.0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A imagem deve ter no máximo 2MB.'),
              backgroundColor: AppColors.alert,
            ),
          );
        }
        return;
      }

      // 3. Update Profile
      final currentSettings = ref.read(userSettingsProvider);
      final newProfile = UserProfile(
        name: currentSettings.profile.name,
        surname: currentSettings.profile.surname,
        email: currentSettings.profile.email,
        password: currentSettings.profile.password,
        phone: currentSettings.profile.phone,
        city: currentSettings.profile.city,
        province: currentSettings.profile.province,
        country: currentSettings.profile.country,
        bio: currentSettings.profile.bio,
        photoPath: image.path, // Store local path
      );

      ref.read(userSettingsProvider.notifier).updateSettings(
        UserSettings(
          minMonthlyBalanceBusiness: currentSettings.minMonthlyBalanceBusiness,
          minMonthlyBalancePersonal: currentSettings.minMonthlyBalancePersonal,
          defaultIsBusiness: currentSettings.defaultIsBusiness,
          profile: newProfile,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar imagem: $e')),
        );
      }
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final currentSettings = ref.read(userSettingsProvider);
      final newProfile = UserProfile(
        name: _nameController.text,
        surname: _surnameController.text,
        email: _emailController.text,
        password: currentSettings.profile.password, 
        phone: _phoneController.text,
        city: _cityController.text,
        province: _selectedProvince,
        country: 'Moçambique',
        bio: _bioController.text,
        photoPath: currentSettings.profile.photoPath,
      );

      ref.read(userSettingsProvider.notifier).updateSettings(
        UserSettings(
          minMonthlyBalanceBusiness: currentSettings.minMonthlyBalanceBusiness,
          minMonthlyBalancePersonal: currentSettings.minMonthlyBalancePersonal,
          defaultIsBusiness: currentSettings.defaultIsBusiness,
          profile: newProfile,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados pessoais atualizados com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha Atual'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Nova Senha'),
                validator: (v) => v != newPasswordController.text ? 'As senhas não coincidem' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // In a real app, verify old password here
                final currentSettings = ref.read(userSettingsProvider);
                final updatedProfile = UserProfile(
                  name: currentSettings.profile.name,
                  surname: currentSettings.profile.surname,
                  email: currentSettings.profile.email,
                  password: newPasswordController.text,
                  phone: currentSettings.profile.phone,
                  city: currentSettings.profile.city,
                  province: currentSettings.profile.province,
                  country: currentSettings.profile.country,
                  bio: currentSettings.profile.bio,
                  photoPath: currentSettings.profile.photoPath,
                );
                
                ref.read(userSettingsProvider.notifier).updateSettings(
                  UserSettings(
                    minMonthlyBalanceBusiness: currentSettings.minMonthlyBalanceBusiness,
                    minMonthlyBalancePersonal: currentSettings.minMonthlyBalancePersonal,
                    defaultIsBusiness: currentSettings.defaultIsBusiness,
                    profile: updatedProfile,
                  ),
                );
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha alterada com sucesso!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userSettingsProvider).profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Dados Pessoais')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profile.photoPath != null 
                        ? (profile.photoPath!.startsWith('http') 
                            ? NetworkImage(profile.photoPath!) 
                            : FileImage(File(profile.photoPath!)) as ImageProvider)
                        : null,
                      child: profile.photoPath == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '${profile.name} ${profile.surname}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  profile.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nome', _nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField('Apelido', _surnameController, Icons.badge_outlined),
            const SizedBox(height: 16),
            _buildTextField('Descrição / Bio', _bioController, Icons.description_outlined, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField('Telemóvel', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone, prefixText: '+258 '),
            
            const SizedBox(height: 32),
            const Text('Segurança', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            ListTile(
              onTap: _showChangePasswordDialog,
              leading: const Icon(Icons.lock_reset, color: AppColors.alert),
              title: const Text('Alterar Senha de Acesso'),
              subtitle: const Text('Mantenha sua conta protegida'),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 32),
            const Text('Localização', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            _buildProvinceSelector(),
            const SizedBox(height: 16),
            _buildTextField('Cidade', _cityController, Icons.location_city_outlined),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.alert,
                side: const BorderSide(color: AppColors.alert),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Sair da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, String? prefixText, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildProvinceSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedProvince,
      decoration: InputDecoration(
        labelText: 'Província',
        prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: _provincias.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      onChanged: (val) => setState(() => _selectedProvince = val!),
    );
  }
}
