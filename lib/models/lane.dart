

List<String> fromString(String range) {
  if (range == null) {
    return null;
  }  
  final result = [
      range.substring(0, 1).toUpperCase(),
      range.substring(range.length - 1, range.length).toUpperCase()
  ];
  result.sort();
  return result;
}

fromStringToStart(String range) {
  final result = fromString(range);
  return result == null ? null : result.first;
}

fromStringToEnd(String range) {
  final result = fromString(range);
  return result == null ? null : result.last;
}

class Lane {
  final String start;
  final String end;
  Lane(String range):
    start = fromStringToStart(range),
    end = fromStringToEnd(range);

  @override
  bool operator ==(o) {
    return o is Lane && o.start == start && o.end == end;
  }

  @override
  String toString() {
    return '$start-$end';
  }

  static Lane fromJson(dynamic json) {
    return Lane(json);
  }

  bool isNameInLane(String name) {
    final s = [start, name.toUpperCase().substring(0, 1), end];
    s.sort();
    // print('isNameInLane:${s.first}:$start:$end:${s.last}:$name');
    return s.first == start && end == s.last;
  }

  String toJson() {
    if (end == null || start == null) {
      return null;
    }
    return toString();
  }

}
