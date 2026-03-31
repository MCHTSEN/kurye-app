enum UgramaResolutionType {
  existingExact('existing_exact'),
  ambiguousName('ambiguous_name'),
  existingSelected('existing_selected'),
  createdNew('created_new'),
  notFound('not_found');

  const UgramaResolutionType(this.value);

  final String value;

  static UgramaResolutionType fromValue(String value) {
    return UgramaResolutionType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => UgramaResolutionType.notFound,
    );
  }
}

enum UgramaResolutionStrategy {
  auto('auto'),
  useExisting('use_existing'),
  createNew('create_new');

  const UgramaResolutionStrategy(this.value);

  final String value;
}

class UgramaResolutionCandidate {
  const UgramaResolutionCandidate({
    required this.id,
    required this.ugramaAdi,
    this.adres,
  });

  factory UgramaResolutionCandidate.fromJson(Map<String, dynamic> json) {
    return UgramaResolutionCandidate(
      id: json['id'] as String,
      ugramaAdi: json['ugrama_adi'] as String,
      adres: json['adres'] as String?,
    );
  }

  final String id;
  final String ugramaAdi;
  final String? adres;

  Map<String, dynamic> toJson() => {
    'id': id,
    'ugrama_adi': ugramaAdi,
    'adres': adres,
  };
}

class UgramaResolutionResult {
  const UgramaResolutionResult({
    required this.resolutionType,
    this.resolvedUgramaId,
    this.candidates = const <UgramaResolutionCandidate>[],
  });

  factory UgramaResolutionResult.fromJson(Map<String, dynamic> json) {
    final rawCandidates = json['candidates'];
    final candidates = rawCandidates is List
        ? rawCandidates
              .whereType<Map<String, dynamic>>()
              .map(UgramaResolutionCandidate.fromJson)
              .toList()
        : const <UgramaResolutionCandidate>[];

    return UgramaResolutionResult(
      resolutionType: UgramaResolutionType.fromValue(
        json['resolution_type'] as String? ??
            UgramaResolutionType.notFound.value,
      ),
      resolvedUgramaId: json['resolved_ugrama_id'] as String?,
      candidates: candidates,
    );
  }

  final UgramaResolutionType resolutionType;
  final String? resolvedUgramaId;
  final List<UgramaResolutionCandidate> candidates;

  Map<String, dynamic> toJson() => {
    'resolution_type': resolutionType.value,
    'resolved_ugrama_id': resolvedUgramaId,
    'candidates': candidates.map((item) => item.toJson()).toList(),
  };
}
