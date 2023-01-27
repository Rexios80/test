// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';

import '../test_shared.dart';

Iterable<int> get _testIterable => Iterable.generate(2, (i) => i);

void main() {
  test('length', () {
    checkThat(_testIterable).length.equals(2);
  });
  test('first', () {
    checkThat(_testIterable).first.equals(0);
  });
  test('last', () {
    checkThat(_testIterable).last.equals(1);
  });
  test('single', () {
    checkThat([42]).single.equals(42);
  });

  test('isEmpty', () {
    checkThat([]).isEmpty();
    checkThat(_testIterable)
        .isRejectedBy(it()..isEmpty(), which: ['is not empty']);
  });

  test('isNotEmpty', () {
    checkThat(_testIterable).isNotEmpty();
    checkThat(Iterable<int>.empty())
        .isRejectedBy(it()..isNotEmpty(), which: ['is not empty']);
  });

  test('contains', () {
    checkThat(_testIterable).contains(0);
    checkThat(_testIterable)
        .isRejectedBy(it()..contains(2), which: ['does not contain <2>']);
  });
  test('any', () {
    checkThat(_testIterable).any(it()..equals(1));
    checkThat(_testIterable).isRejectedBy(it()..any(it()..equals(2)),
        which: ['Contains no matching element']);
  });

  group('containsInOrder', () {
    test('succeeds for happy case', () {
      checkThat([0, 1, 0, 2, 0, 3]).containsInOrder([1, 2, 3]);
    });
    test('can use Condition<dynamic>', () {
      checkThat([0, 1]).containsInOrder([it()..isA<int>().isGreaterThan(0)]);
    });
    test('can use Condition<T>', () {
      checkThat([0, 1]).containsInOrder([it<int>()..isGreaterThan(0)]);
    });
    test('fails for not found elements by equality', () async {
      checkThat([0]).isRejectedBy(it()..containsInOrder([1]), which: [
        'did not have an element matching the expectation at index 0 <1>'
      ]);
    });
    test('fails for not found elements by condition', () async {
      checkThat([0]).isRejectedBy(
          it()..containsInOrder([it()..isA<int>().isGreaterThan(0)]),
          which: [
            'did not have an element matching the expectation at index 0 '
                '<A value that:',
            '  is a int',
            '  is greater than <0>>'
          ]);
    });
    test('can be described', () {
      checkThat(it<Iterable>()..containsInOrder([1, 2, 3]))
          .description
          .deepEquals(['  contains, in order: [1, 2, 3]']);
      checkThat(it<Iterable>()..containsInOrder([1, it()..equals(2)]))
          .description
          .deepEquals([
        '  contains, in order: [1,',
        '  A value that:',
        '    equals <2>]'
      ]);
    });
  });
  group('every', () {
    test('succeeds for the happy path', () {
      checkThat(_testIterable).every(it()..isGreaterOrEqual(-1));
    });

    test('includes details of first failing element', () async {
      checkThat(_testIterable)
          .isRejectedBy(it()..every(it()..isLessThan(0)), which: [
        'has an element at index 0 that:',
        '  Actual: <0>',
        '  Which: is not less than <0>',
      ]);
    });
  });

  group('unorderedEquals', () {
    test('success for happy case', () {
      checkThat(_testIterable).unorderedEquals(_testIterable.toList().reversed);
    });

    test('reports unmatched elements', () {
      checkThat(_testIterable).isRejectedBy(
          it()..unorderedEquals(_testIterable.followedBy([42, 100])),
          which: [
            'has no element equal to the expected element at index 2: <42>',
            'or 1 other elements'
          ]);
    });

    test('reports unexpected elements', () {
      checkThat(_testIterable.followedBy([42, 100]))
          .isRejectedBy(it()..unorderedEquals(_testIterable), which: [
        'has an unexpected element at index 2: <42>',
        'and 1 other unexpected elements'
      ]);
    });
  });

  group('unorderedMatches', () {
    test('success for happy case', () {
      checkThat(_testIterable).unorderedMatches(
          _testIterable.toList().reversed.map((i) => it()..equals(i)));
    });

    test('reports unmatched elements', () {
      checkThat(_testIterable).isRejectedBy(
          it()
            ..unorderedMatches(_testIterable
                .followedBy([42, 100]).map((i) => it()..equals(i))),
          which: [
            'has no element matching the condition at index 2:',
            '  equals <42>',
            'or 1 other conditions'
          ]);
    });

    test('reports unexpected elements', () {
      checkThat(_testIterable.followedBy([42, 100])).isRejectedBy(
          it()..unorderedMatches(_testIterable.map((i) => it()..equals(i))),
          which: [
            'has an unmatched element at index 2: <42>',
            'and 1 other unmatched elements'
          ]);
    });
  });

  group('pairwiseComparesTo', () {
    test('succeeds for the happy path', () {
      checkThat(_testIterable).pairwiseComparesTo(
          [1, 2], (expected) => it()..isLessThan(expected), 'is less than');
    });
    test('fails for mismatched element', () async {
      checkThat(_testIterable).isRejectedBy(
          it()
            ..pairwiseComparesTo([1, 1],
                (expected) => it()..isLessThan(expected), 'is less than'),
          which: [
            'does not have an element at index 1 that:',
            '  is less than <1>',
            'Actual element at index 1: <1>',
            'Which: is not less than <1>'
          ]);
    });
    test('fails for too few elements', () {
      checkThat(_testIterable).isRejectedBy(
          it()
            ..pairwiseComparesTo([1, 2, 3],
                (expected) => it()..isLessThan(expected), 'is less than'),
          which: [
            'has too few elements, there is no element to match at index 2'
          ]);
    });
    test('fails for too many elements', () {
      checkThat(_testIterable).isRejectedBy(
          it()
            ..pairwiseComparesTo(
                [1], (expected) => it()..isLessThan(expected), 'is less than'),
          which: ['has too many elements, expected exactly 1']);
    });
  });
}
