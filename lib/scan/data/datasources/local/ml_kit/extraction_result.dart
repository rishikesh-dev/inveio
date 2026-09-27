class ExtractionResult<T> {
  const ExtractionResult(this.value, this.isHighConfidence);

  final T? value;
  final bool isHighConfidence;
}
