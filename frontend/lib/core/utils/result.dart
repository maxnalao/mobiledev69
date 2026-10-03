/// A simple Result type so the data layer never throws past the repository โ€”
/// ViewModels branch on [Ok]/[Err] instead of using try/catch everywhere.
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}
