# Architecture Notes

DoThis uses a single gRPC service (`ToDoService`) backed by an in-memory Kanban board.

- **Server:** C++17, `BroadcastBoard()` after every mutation
- **Client:** WPF MVVM, `Sync` stream rebuilds UI collections
- **Contract:** `proto/todo.proto` shared by both projects

See the root [README](../README.md) for the full diagram.
