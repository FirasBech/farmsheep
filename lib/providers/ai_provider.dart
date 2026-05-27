import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/manual_log.dart';
import '../models/farm.dart';
import '../services/ai_service.dart';

class AiProvider extends ChangeNotifier {
  final AiService _service;

  AiProvider({required AiService service}) : _service = service;

  String? _herdSummary;
  bool _summaryLoading = false;
  DateTime? _summaryGeneratedAt;
  String? _summaryError;

  String? get herdSummary => _herdSummary;
  bool get summaryLoading => _summaryLoading;
  DateTime? get summaryGeneratedAt => _summaryGeneratedAt;
  String? get summaryError => _summaryError;

  Future<void> refreshHerdSummary({
    required Farm farm,
    required List<Animal> animals,
    required List<ManualLog> recentLogs,
  }) async {
    _summaryLoading = true;
    _summaryError = null;
    notifyListeners();
    try {
      _herdSummary = await _service.generateHerdSummary(
        farm: farm,
        animals: animals,
        recentLogs: recentLogs,
      );
      _summaryGeneratedAt = DateTime.now();
    } catch (e) {
      _summaryError = e.toString();
    } finally {
      _summaryLoading = false;
      notifyListeners();
    }
  }

  void clearSummary() {
    _herdSummary = null;
    _summaryGeneratedAt = null;
    _summaryError = null;
    notifyListeners();
  }
}
