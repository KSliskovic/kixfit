import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardDisplayMode { consumed, remaining }

class DashboardDisplayModeNotifier extends Notifier<DashboardDisplayMode> {
  @override
  DashboardDisplayMode build() => DashboardDisplayMode.consumed;

  void toggle() {
    state = state == DashboardDisplayMode.consumed 
        ? DashboardDisplayMode.remaining 
        : DashboardDisplayMode.consumed;
  }
}

final dashboardDisplayModeProvider = NotifierProvider<DashboardDisplayModeNotifier, DashboardDisplayMode>(() {
  return DashboardDisplayModeNotifier();
});
