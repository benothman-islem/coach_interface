sealed class UiState<T> {
  const UiState();
}

final class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

final class UiSuccess<T> extends UiState<T> {
  const UiSuccess(this.value);
  final T value;
}

final class UiEmpty<T> extends UiState<T> {
  const UiEmpty();
}

final class UiError<T> extends UiState<T> {
  const UiError(this.error);
  final Object error;
}
