enum ArchiveMode {
  renameInPlace,
  copyToFolder,
  moveToFolder,
}

class AppSettings {
  final String apiKey;
  final String modelName;
  final String regexPattern;
  final double cropWidthRatio;
  final double cropHeightRatio;
  final ArchiveMode archiveMode;
  final String destinationFolder;
  final bool fallbackToProOnError;

  const AppSettings({
    this.apiKey = '',
    this.modelName = 'gemini-1.5-flash',
    this.regexPattern = r'^[A-Z]{2,3}[0-9]{3,4}[A-Z]?$',
    this.cropWidthRatio = 0.35,
    this.cropHeightRatio = 0.25,
    this.archiveMode = ArchiveMode.renameInPlace,
    this.destinationFolder = '',
    this.fallbackToProOnError = true,
  });

  AppSettings copyWith({
    String? apiKey,
    String? modelName,
    String? regexPattern,
    double? cropWidthRatio,
    double? cropHeightRatio,
    ArchiveMode? archiveMode,
    String? destinationFolder,
    bool? fallbackToProOnError,
  }) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      regexPattern: regexPattern ?? this.regexPattern,
      cropWidthRatio: cropWidthRatio ?? this.cropWidthRatio,
      cropHeightRatio: cropHeightRatio ?? this.cropHeightRatio,
      archiveMode: archiveMode ?? this.archiveMode,
      destinationFolder: destinationFolder ?? this.destinationFolder,
      fallbackToProOnError: fallbackToProOnError ?? this.fallbackToProOnError,
    );
  }
}

