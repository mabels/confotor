// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conferences.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$Conferences on ConferencesBase, Store {
  Computed<bool> _$isEmptyComputed;

  @override
  bool get isEmpty =>
      (_$isEmptyComputed ??= Computed<bool>(() => super.isEmpty)).value;
  Computed<bool> _$isNotEmptyComputed;

  @override
  bool get isNotEmpty =>
      (_$isNotEmptyComputed ??= Computed<bool>(() => super.isNotEmpty)).value;
  Computed<Conference> _$firstComputed;

  @override
  Conference get first =>
      (_$firstComputed ??= Computed<Conference>(() => super.first)).value;
  Computed<Conference> _$lastComputed;

  @override
  Conference get last =>
      (_$lastComputed ??= Computed<Conference>(() => super.last)).value;
  Computed<Iterable<Conference>> _$valuesComputed;

  @override
  Iterable<Conference> get values =>
      (_$valuesComputed ??= Computed<Iterable<Conference>>(() => super.values))
          .value;
  Computed<int> _$lengthComputed;

  @override
  int get length =>
      (_$lengthComputed ??= Computed<int>(() => super.length)).value;

  final _$updateFromUrlAsyncAction = AsyncAction('updateFromUrl');

  @override
  Future updateFromUrl(String url, {BaseClient client}) {
    return _$updateFromUrlAsyncAction
        .run(() => super.updateFromUrl(url, client: client));
  }
}
