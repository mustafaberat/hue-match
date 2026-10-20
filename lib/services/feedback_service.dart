/// Ses ve titreşim yok. Çağrı noktaları duruyor; hiçbir şey çalmaz.
library;

import 'settings_service.dart';

class FeedbackService {
  FeedbackService(SettingsService _);

  void fineTick() {}

  void confirm() {}

  Future<void> result(int _) async {}
}
