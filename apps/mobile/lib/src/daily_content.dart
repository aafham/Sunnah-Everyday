import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The only mobile daily-content state available before a verified public
/// bundle reader exists.
///
/// This type intentionally has no identifier, title, source, evidence, grade,
/// translation or body fields. Draft intake models and local staging files are
/// never a runtime content source for the mobile application.
sealed class DailyContentState {
  const DailyContentState();
}

/// No approved daily item is available to render.
final class NoApprovedDailyContent extends DailyContentState {
  const NoApprovedDailyContent();
}

/// Reads a presentation-safe daily-content state.
///
/// A future implementation may read only a verified, immutable public bundle.
/// It must not use draft intake, staging files, local CSV data or an unreviewed
/// network response.
abstract interface class DailyContentReader {
  DailyContentState readToday();

  DailyContentState readDetail();
}

/// The built-in reader fails closed until the publication/bundle gates exist.
class FailClosedDailyContentReader implements DailyContentReader {
  const FailClosedDailyContentReader();

  @override
  DailyContentState readToday() => const NoApprovedDailyContent();

  @override
  DailyContentState readDetail() => const NoApprovedDailyContent();
}

final dailyContentReaderProvider = Provider<DailyContentReader>(
  (ref) => const FailClosedDailyContentReader(),
);

final todayDailyContentProvider = Provider<DailyContentState>(
  (ref) => ref.watch(dailyContentReaderProvider).readToday(),
);

final dailyDetailContentProvider = Provider<DailyContentState>(
  (ref) => ref.watch(dailyContentReaderProvider).readDetail(),
);
