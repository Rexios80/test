// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:checks/context.dart';
import 'package:test_api/hooks.dart';

extension FunctionChecks<T> on Subject<T Function()> {
  /// Expects that a function throws synchronously when it is called.
  ///
  /// If the function synchronously throws a value of type [E], return a
  /// [Subject] to check further expectations on the error.
  ///
  /// If the function does not throw synchronously, or if it throws an error
  /// that is not of type [E], this expectation will fail.
  ///
  /// If this function is async and returns a [Future], this expectation will
  /// fail. Instead invoke the function and check the expectation on the
  /// returned [Future].
  Subject<E> throws<E>() {
    return context.nest<E>(() => ['throws an error of type $E'], (actual) {
      try {
        final result = actual();
        return Extracted.rejection(
          actual: prefixFirst('a function that returned ', literal(result)),
          which: ['did not throw'],
        );
      } catch (e) {
        if (e is E) return Extracted.value(e as E);
        return Extracted.rejection(
            actual: prefixFirst('a function that threw error ', literal(e)),
            which: ['did not throw an $E']);
      }
    });
  }

  /// Expects that the function returns without throwing.
  ///
  /// If the function runs without exception, return a [Subject] to check
  /// further expecations on the returned value.
  ///
  /// If the function throws synchronously, this expectation will fail.
  Subject<T> returnsNormally() {
    return context.nest<T>(() => ['returns a value'], (actual) {
      try {
        return Extracted.value(actual());
      } catch (e, st) {
        return Extracted.rejection(actual: [
          'a function that throws'
        ], which: [
          ...prefixFirst('threw ', literal(e)),
          ...st.toString().split('\n')
        ]);
      }
    });
  }

  T Function() isCalled({int times = -1}) {
    T Function()? theFunction;
    context.expectUnawaited(
        () => ['is called${times >= 0 ? ' $times times' : ''}'],
        (actual, reject) {
      final outstandingWork = TestHandle.current.markPending();
      var callCount = 0;
      theFunction = () {
        callCount++;
        if ((times < 0 && callCount == 1) || callCount == times) {
          outstandingWork.complete();
        }
        if (times >= 0 && callCount > times) {
          reject(Rejection(
              which: ['was called $callCount times (more than $times)']));
        }
        return actual();
      };
    });
    // If theFunction is `null` it shouldn't be possible to call the callback
    // because it was used in `describe(it<void Function()>()..isCalled())`
    return theFunction ?? _unusable;
  }

  T Function() neverCalled() {
    T Function()? theFunction;
    context.expectUnawaited(() => ['is never called'], (actual, reject) {
      theFunction = () {
        reject(Rejection(which: ['was called']));
        return actual();
      };
    });
    // If theFunction is `null` it shouldn't be possible to call the callback
    // because it was used in `describe(it<void Function()>()..neverCalled())`
    return theFunction ?? _unusable;
  }

  static Never _unusable() =>
      throw StateError('This function should not be used');
}

extension IsCalled1<R, A> on Subject<R Function(A)> {
  R Function(A) isCalled({int times = -1}) {
    R Function(A)? theFunction;
    context.expectUnawaited(
        () => ['is called${times >= 0 ? ' $times times' : ''}'],
        (actual, reject) {
      final outstandingWork = TestHandle.current.markPending();
      var callCount = 0;
      theFunction = (a) {
        callCount++;
        if ((times < 0 && callCount == 1) || callCount == times) {
          outstandingWork.complete();
        }
        if (times >= 0 && callCount > times) {
          reject(Rejection(
              which: ['was called $callCount times (more than $times)']));
        }
        return actual(a);
      };
    });
    // If theFunction is `null` it shouldn't be possible to call the callback
    // because it was used in `describe(it<void Function()>()..isCalled())`
    return theFunction ?? _unusable;
  }

  R Function(A) neverCalled() {
    R Function(A)? theFunction;
    context.expectUnawaited(() => ['is never called'], (actual, reject) {
      theFunction = (a) {
        reject(Rejection(which: ['was called']));
        return actual(a);
      };
    });
    // If theFunction is `null` it shouldn't be possible to call the callback
    // because it was used in `describe(it<void Function()>()..neverCalled())`
    return theFunction ?? _unusable;
  }

  static Never _unusable(_) =>
      throw StateError('This function should not be used');
}
