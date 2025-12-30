import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// 1. PROVIDER - Simple immutable value that doesn't change
// Use case: Configuration values, constants, or simple computed values
// ============================================================================
final appThemeProvider = Provider<ThemeData>((ref) {
  // This provider returns a ThemeData object
  // It's read-only and doesn't change during app lifecycle
  return ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );
});

// ============================================================================
// 2. STATE PROVIDER - Simple mutable state (like useState in React)
// Use case: Simple values that need to change (counters, toggles, etc.)
// ============================================================================
final counterProvider = StateProvider<int>((ref) {
  // StateProvider is the simplest way to manage mutable state
  // It automatically exposes a .state property that can be modified
  return 0; // Initial value
});

// ============================================================================
// 3. FUTURE PROVIDER - Async data fetching (returns Future)
// Use case: API calls, database queries, any async operation
// ============================================================================
final userDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // FutureProvider automatically handles loading/error/data states
  // It executes the async function and caches the result
  await Future.delayed(Duration(seconds: 2)); // Simulating API call

  return {
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
  };
});

// ============================================================================
// 4. STREAM PROVIDER - Continuous stream of data
// Use case: Real-time data, WebSocket connections, timer updates
// ============================================================================
final timerProvider = StreamProvider<int>((ref) {
  // StreamProvider listens to a stream and rebuilds UI on each new value
  // Useful for real-time data updates
  return Stream.periodic(
    Duration(seconds: 1),
        (count) => count, // Emits 0, 1, 2, 3... every second
  );
});

// ============================================================================
// 5. STATE NOTIFIER PROVIDER - Complex state with business logic
// Use case: Complex state management with multiple operations
// ============================================================================

// First, define the state class (immutable)
class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodoState({
    required this.todos,
    this.isLoading = false,
    this.error,
  });

  // Copy method for immutable updates
  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Todo copyWith({String? title, bool? completed}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

// StateNotifier - Contains business logic for state manipulation
class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState(todos: []));

  // Add a new todo
  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );

    // StateNotifier requires creating a new state object (immutable pattern)
    state = state.copyWith(
      todos: [...state.todos, newTodo],
    );
  }

  // Toggle todo completion
  void toggleTodo(String id) {
    state = state.copyWith(
      todos: state.todos.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(completed: !todo.completed);
        }
        return todo;
      }).toList(),
    );
  }

  // Remove a todo
  void removeTodo(String id) {
    state = state.copyWith(
      todos: state.todos.where((todo) => todo.id != id).toList(),
    );
  }

  // Simulate async operation
  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      todos: [
        Todo(id: '1', title: 'Learn Riverpod'),
        Todo(id: '2', title: 'Build an app'),
      ],
    );
  }
}

// StateNotifierProvider exposes the StateNotifier
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});

// ============================================================================
// 6. CHANGE NOTIFIER PROVIDER - For ChangeNotifier classes (Flutter legacy)
// Use case: Migrating from Provider package, using existing ChangeNotifier
// ============================================================================
class CartNotifier extends ChangeNotifier {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  void addItem(String item) {
    _items.add(item);
    notifyListeners(); // Must manually call notifyListeners()
  }

  void removeItem(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  return CartNotifier();
});

// ============================================================================
// 7. FAMILY MODIFIER - Create providers with parameters
// Use case: Creating multiple instances of a provider with different arguments
// ============================================================================
final userByIdProvider = FutureProvider.family<String, int>((ref, userId) async {
  // .family allows passing parameters to providers
  // Creates a separate provider instance for each unique parameter
  await Future.delayed(Duration(seconds: 1));
  return 'User data for ID: $userId';
});

// ============================================================================
// 8. AUTO DISPOSE MODIFIER - Automatically dispose when not used
// Use case: Cleanup resources when widget is removed from tree
// ============================================================================
final searchQueryProvider = StateProvider.autoDispose<String>((ref) {
  // .autoDispose automatically cleans up state when no longer listened to
  // Useful for search queries, filters, temporary data
  return '';
});

final searchResultsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  // Simulating search API call
  await Future.delayed(Duration(milliseconds: 500));

  if (query.isEmpty) return [];

  return ['Result 1 for $query', 'Result 2 for $query', 'Result 3 for $query'];
});

// ============================================================================
// 9. COMBINING MODIFIERS - Family + AutoDispose
// ============================================================================
final productByIdProvider = FutureProvider.autoDispose.family<String, int>(
      (ref, productId) async {
    // Combines both modifiers
    // Creates parameterized provider that auto-disposes
    await Future.delayed(Duration(seconds: 1));
    return 'Product details for ID: $productId';
  },
);

// ============================================================================
// 10. COMPUTED PROVIDERS - Derive state from other providers
// Use case: Calculate values based on other providers
// ============================================================================
final completedTodosProvider = Provider<List<Todo>>((ref) {
  // This provider watches another provider and computes a derived value
  final todoState = ref.watch(todoProvider);
  return todoState.todos.where((todo) => todo.completed).toList();
});

final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todoState = ref.watch(todoProvider);
  final completed = todoState.todos.where((t) => t.completed).length;
  final pending = todoState.todos.length - completed;

  return {
    'total': todoState.todos.length,
    'completed': completed,
    'pending': pending,
  };
});

// ============================================================================
// MAIN APP - Demonstrating all provider types
// ============================================================================



//_________________________started ui to be built________________________________

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Riverpod 2.0 Examples'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Simple State'),
              Tab(text: 'Async Data'),
              Tab(text: 'Todo List'),
              Tab(text: 'Cart'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SimpleStateTab(),
            AsyncDataTab(),
            TodoListTab(),
            CartTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: Simple State (StateProvider)
// ============================================================================
class SimpleStateTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() rebuilds widget when provider value changes
    final counter = ref.watch(counterProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'StateProvider Example',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Counter: $counter', style: TextStyle(fontSize: 32)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // ref.read() - use for one-time reads or calling methods
                  ref.read(counterProvider.notifier).state++;
                },
                child: Text('Increment'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ref.read(counterProvider.notifier).state--;
                },
                child: Text('Decrement'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ref.read(counterProvider.notifier).state = 0;
                },
                child: Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 2: Async Data (FutureProvider & StreamProvider)
// ============================================================================
class AsyncDataTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FutureProvider provides AsyncValue<T> with loading/error/data states
    final userData = ref.watch(userDataProvider);
    final timer = ref.watch(timerProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FutureProvider Example',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // AsyncValue provides when() method for pattern matching
          userData.when(
            loading: () => CircularProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
            data: (data) => Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${data['name']}'),
                    Text('Email: ${data['email']}'),
                    Text('Age: ${data['age']}'),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'StreamProvider Example',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          timer.when(
            loading: () => Text('Waiting for timer...'),
            error: (err, stack) => Text('Error: $err'),
            data: (count) => Text(
              'Timer: $count seconds',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 3: Todo List (StateNotifierProvider)
// ============================================================================
class TodoListTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<TodoListTab> createState() => _TodoListTabState();
}

class _TodoListTabState extends ConsumerState<TodoListTab> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial todos
    Future.microtask(() => ref.read(todoProvider.notifier).loadTodos());
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoProvider);
    final stats = ref.watch(todoStatsProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter todo title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        ref.read(todoProvider.notifier).addTodo(_controller.text);
                        _controller.clear();
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Total: ${stats['total']}'),
                      Text('Completed: ${stats['completed']}'),
                      Text('Pending: ${stats['pending']}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (todoState.isLoading)
          CircularProgressIndicator()
        else
          Expanded(
            child: ListView.builder(
              itemCount: todoState.todos.length,
              itemBuilder: (context, index) {
                final todo = todoState.todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (_) {
                      ref.read(todoProvider.notifier).toggleTodo(todo.id);
                    },
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      ref.read(todoProvider.notifier).removeTodo(todo.id);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ============================================================================
// TAB 4: Cart (ChangeNotifierProvider)
// ============================================================================
class CartTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items in cart: ${cart.itemCount}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: cart.itemCount > 0
                    ? () => ref.read(cartProvider).clear()
                    : null,
                child: Text('Clear Cart'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    ref.read(cartProvider).removeItem(item);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              final item = 'Item ${cart.itemCount + 1}';
              ref.read(cartProvider).addItem(item);
            },
            child: Text('Add Item to Cart'),
          ),
        ),
      ],
    );
  }
}