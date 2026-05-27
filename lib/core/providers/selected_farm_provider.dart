import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/farm.dart';

// Holds the currently selected Farm. Updated by farm selection UI via
// ref.read(selectedFarmProvider.notifier).state = farm;
// Also bridged from the legacy FarmProvider in AuthWrapper / FarmListScreen.
final selectedFarmProvider = StateProvider<Farm?>((ref) => null);
