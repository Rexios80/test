// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test.runner.load_exception_suite;

import '../backend/invoker.dart';
import '../backend/metadata.dart';
import '../backend/suite.dart';
import 'load_exception.dart';

/// A test suite generated from a load exception.
///
/// Load exceptions are exposed as test suites so that they can be presented
/// alongside successful tests.
class LoadExceptionSuite extends Suite {
  /// The exception that this suite exposes.
  final LoadException exception;

  LoadExceptionSuite(LoadException exception)
      : exception = exception,
        super([
          new LocalTest("load error", new Metadata(), () => throw exception)
        ], path: exception.path);
}
