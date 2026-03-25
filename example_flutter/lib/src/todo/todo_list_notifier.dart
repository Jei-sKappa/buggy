import 'package:flutter/foundation.dart';

/// A single todo item
@immutable
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    this.done = false,
  });

  final String id;
  final String title;
  final bool done;

  /// Creates a copy with the given fields replaced
  TodoItem copyWith({String? id, String? title, bool? done}) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TodoItem(id: $id, title: $title, done: $done)';
}

/// A ChangeNotifier that manages a list of todo items (intentionally untested)
class TodoListNotifier extends ChangeNotifier {
  final List<TodoItem> _items = [];

  /// All current items
  List<TodoItem> get items => List.unmodifiable(_items);

  /// Total item count
  int get count => _items.length;

  /// Number of completed items
  int get doneCount => _items.where((item) => item.done).length;

  /// Number of pending items
  int get pendingCount => count - doneCount;

  /// Add a new item
  void add(TodoItem item) {
    if (_items.any((existing) => existing.id == item.id)) {
      throw ArgumentError('Item with id ${item.id} already exists');
    }
    _items.add(item);
    notifyListeners();
  }

  /// Remove an item by id
  bool remove(String id) {
    final removed = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length < removed) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Toggle an item's done status
  void toggle(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(done: !_items[index].done);
    notifyListeners();
  }

  /// Clear all items
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
