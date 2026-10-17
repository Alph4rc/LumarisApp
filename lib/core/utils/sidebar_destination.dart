import 'package:cupertino_ui/cupertino_ui.dart';

class SidebarDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;

  const SidebarDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });
}
