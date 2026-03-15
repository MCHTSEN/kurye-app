import 'package:flutter/material.dart';

import '../../app/router/custom_route.dart';
import '../widgets/responsive_scaffold.dart';

/// Navigation items for operasyon role.
const operasyonNavItems = <NavItem>[
  NavItem(
    icon: Icons.dashboard,
    label: 'Dashboard',
    route: CustomRoute.operasyonDashboard,
  ),
  NavItem(
    icon: Icons.assignment,
    label: 'Operasyon Ekranı',
    route: CustomRoute.operasyonEkran,
  ),
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
    icon: Icons.location_on,
    label: 'Uğrama Yönetimi',
    route: CustomRoute.ugramaYonetim,
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
];
