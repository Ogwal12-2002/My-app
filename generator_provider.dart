import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GeneratorMode { text, url }

class GeneratorState {
  final GeneratorMode mode;
  final String input;

  const GeneratorState({this.mode = GeneratorMode.text, this.input = ''});

  GeneratorState copyWith({GeneratorMode? mode, String? input}) {
    return GeneratorState(
      mode: mode ?? this.mode,
      input: input ?? this.input,
    );
  }

  bool get isValid => input.trim().isNotEmpty;

  /// The actual string encoded into the QR. For URL mode, prepends
  /// https:// if the user didn't type a scheme, so generated QR codes
  /// always produce a clickable link when scanned.
  String get encodedValue {
    final trimmed = input.trim();
    if (mode == GeneratorMode.url &&
        !trimmed.startsWith('http://') &&
        !trimmed.startsWith('https://') &&
        trimmed.isNotEmpty) {
      return 'https://$trimmed';
    }
    return trimmed;
  }
}

class GeneratorNotifier extends StateNotifier<GeneratorState> {
  GeneratorNotifier() : super(const GeneratorState());

  void setMode(GeneratorMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setInput(String input) {
    state = state.copyWith(input: input);
  }

  void reset() {
    state = const GeneratorState();
  }
}

final generatorProvider = StateNotifierProvider<GeneratorNotifier, GeneratorState>(
  (ref) => GeneratorNotifier(),
);
