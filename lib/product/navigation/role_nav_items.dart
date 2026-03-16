import 'package:flutter/material.dart';

import '../../app/router/custom_route.dart';
import '../widgets/responsive_scaffold.dart';

/// Navigation items for operasyon role.
const operasyonDesktopNavItems = <NavItem>[
  NavItem(
    icon: Icons.assignment,
    label: 'Operasyon Ekranı',
    route: CustomRoute.operasyonEkran,
    section: 'Ana',
  ),
  NavItem(
    icon: Icons.bar_chart_rounded,
    label: 'Raporlar',
    route: CustomRoute.operasyonDashboard,
    section: 'Raporlama',
  ),
  NavItem(
    icon: Icons.business,
    label: 'Müşteri Kayıt',
    route: CustomRoute.musteriKayit,
    section: 'Yönetim',
  ),
  NavItem(
    icon: Icons.people,
    label: 'Personel Kayıt',
    route: CustomRoute.musteriPersonelKayit,
    section: 'Yönetim',
  ),
  NavItem(
    icon: Icons.location_on,
    label: 'Uğrama Yönetimi',
    route: CustomRoute.ugramaYonetim,
    section: 'Operasyon',
  ),
  NavItem(
    icon: Icons.playlist_add_check,
    label: 'Uğrama Talepleri',
    route: CustomRoute.ugramaTalepYonetim,
    section: 'Operasyon',
  ),
  NavItem(
    icon: Icons.two_wheeler,
    label: 'Kurye Yönetimi',
    route: CustomRoute.kuryeYonetim,
    section: 'Yönetim',
  ),
  NavItem(
    icon: Icons.how_to_reg,
    label: 'Rol Onayları',
    route: CustomRoute.rolOnay,
    section: 'Yönetim',
  ),
  NavItem(
    icon: Icons.history,
    label: 'Geçmiş Siparişler',
    route: CustomRoute.operasyonGecmis,
    section: 'Operasyon',
  ),
];

const List<NavItem> operasyonNavItems = operasyonDesktopNavItems;

/// Primary mobile tabs for operasyon role.
const operasyonPrimaryMobileNavItems = <NavItem>[
  NavItem(
    icon: Icons.assignment_rounded,
    label: 'Operasyon',
    route: CustomRoute.operasyonEkran,
  ),
  NavItem(
    icon: Icons.location_on_rounded,
    label: 'Uğrama',
    route: CustomRoute.ugramaYonetim,
  ),
  NavItem(
    icon: Icons.bar_chart_rounded,
    label: 'Raporlar',
    route: CustomRoute.operasyonDashboard,
  ),
  NavItem(
    icon: Icons.settings_rounded,
    label: 'Ayarlar',
    route: CustomRoute.operasyonAyarlar,
  ),
];

/// Secondary settings destinations grouped under the operasyon settings tab.
const operasyonSettingsNavItems = <NavItem>[
  NavItem(
    icon: Icons.business,
    label: 'Müşteri Kayıt',
    route: CustomRoute.musteriKayit,
  ),
  NavItem(
    icon: Icons.people,
    label: 'Personel Kayıt',
    route: CustomRoute.musteriPersonelKayit,
  ),
  NavItem(
    icon: Icons.playlist_add_check,
    label: 'Uğrama Talepleri',
    route: CustomRoute.ugramaTalepYonetim,
  ),
  NavItem(
    icon: Icons.two_wheeler,
    label: 'Kurye Yönetimi',
    route: CustomRoute.kuryeYonetim,
  ),
  NavItem(
    icon: Icons.how_to_reg,
    label: 'Rol Onayları',
    route: CustomRoute.rolOnay,
  ),
  NavItem(
    icon: Icons.history,
    label: 'Geçmiş Siparişler',
    route: CustomRoute.operasyonGecmis,
  ),
];

/// Navigation items for müşteri (personel) role.
const musteriNavItems = <NavItem>[
  NavItem(
    icon: Icons.add_shopping_cart,
    label: 'Sipariş Oluştur',
    route: CustomRoute.musteriSiparis,
  ),
  NavItem(
    icon: Icons.history,
    label: 'Geçmiş Siparişler',
    route: CustomRoute.musteriGecmis,
  ),
  NavItem(
    icon: Icons.add_location_alt,
    label: 'Uğrama Talebi',
    route: CustomRoute.musteriUgramaTalep,
  ),
];
