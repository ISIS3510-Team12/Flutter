import 'dart:async';

Future<(A, B)> waitBoth<A, B>(Future<A> first, Future<B> second) async {
  try {
    return await (first, second).wait;
  } on ParallelWaitError<(A?, B?), (AsyncError?, AsyncError?)> catch (error) {
    final failure = error.errors.$1 ?? error.errors.$2!;
    Error.throwWithStackTrace(failure.error, failure.stackTrace);
  }
}
