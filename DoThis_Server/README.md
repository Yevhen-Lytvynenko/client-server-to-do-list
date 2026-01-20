<p align="center">
  <img src="../assets/icon.ico" alt="DoThis Server" width="72" />
</p>

<h1 align="center">DoThis Server</h1>

<p align="center">
  <strong>C++ gRPC backend for the shared Kanban board</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/C%2B%2B-17-00599C?logo=c%2B%2B&logoColor=white" alt="C++17" />
  <img src="https://img.shields.io/badge/gRPC-C%2B%2B-244C5A?logo=grpc&logoColor=white" alt="gRPC C++" />
  <img src="https://img.shields.io/badge/Protobuf-proto3-4285F4?logo=google&logoColor=white" alt="Protobuf" />
  <img src="https://img.shields.io/badge/CMake-3.15+-064F8C?logo=cmake&logoColor=white" alt="CMake" />
</p>

<p align="center">
  <a href="../README.md">Monorepo</a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="#api">API</a>
</p>

---

## About

**DoThis Server** is the authoritative backend for the DoThis Kanban app. It stores columns and tasks in memory, exposes a `ToDoService` gRPC API, and pushes board snapshots to all subscribed clients via a server-streaming `Sync` RPC.

On startup the server seeds three default columns: **Planned**, **In Progress**, and **Done**.

---

## Features

- Thread-safe in-memory board (`std::mutex` + `unordered_map`)
- Unary RPCs for column/task CRUD and `MoveTask`
- `Sync` server stream — initial snapshot + live broadcasts
- Dead stream cleanup when a client disconnects
- Listens on `0.0.0.0:50051` (all interfaces)

---

## Project layout

```
DoThis_Server/
├── CMakeLists.txt          # Links gRPC, Protobuf, generated stubs
├── src/
│   └── server.cpp          # ToDoServiceImpl + main()
├── proto/
│   └── todo.proto          # Service contract (source of truth)
└── generated/              # protoc output — committed for out-of-box build
    ├── todo.pb.cc / .h
    └── todo.grpc.pb.cc / .h
```

---

## Requirements

| Tool | Version |
|------|---------|
| CMake | ≥ 3.15 |
| C++ compiler | C++17 (MSVC 2022, g++, or clang) |
| vcpkg packages | `grpc`, `protobuf` (+ transitive deps: openssl, zlib, …) |
| protoc + grpc_cpp_plugin | For regenerating `generated/` after proto changes |

---

## Quick Start

### 1. Install vcpkg dependencies

```bash
git clone https://github.com/microsoft/vcpkg.git C:/vcpkg
cd C:/vcpkg
./bootstrap-vcpkg.bat          # Windows
./vcpkg install grpc:x64-windows protobuf:x64-windows
```

On Linux/macOS replace the triplet (e.g. `x64-linux`, `arm64-osx`).

### 2. Configure & build

From `DoThis_Server/`:

```bash
cmake -B build -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
```

Output: `build/Release/server.exe` (Windows) or `build/server` (Unix).

### 3. Run

```bash
./build/Release/server.exe
```

Expected log:

```
Server listening on 0.0.0.0:50051
```

Keep this process running while WPF clients connect.

---

## Regenerating protobuf stubs

When `proto/todo.proto` changes, regenerate the C++ files into `generated/`:

```bash
protoc -I=proto --cpp_out=generated proto/todo.proto
protoc -I=proto --grpc_out=generated \
  --plugin=protoc-gen-grpc="C:/vcpkg/installed/x64-windows/tools/grpc/grpc_cpp_plugin.exe" \
  proto/todo.proto
```

Adjust plugin paths for your vcpkg install location. Then rebuild with CMake.

> The client project has its own copy of `todo.proto` and auto-generates C# stubs via `Grpc.Tools` on build.

---

## API

`ToDoService` (package `todo`):

| RPC | Type | Description |
|-----|------|-------------|
| `AddColumn` | Unary | Create a column |
| `RenameColumn` | Unary | Rename by ID |
| `DeleteColumn` | Unary | Remove column and its tasks |
| `GetBoard` | Unary | Snapshot of all columns |
| `AddTaskToColumn` | Unary | Add task (server assigns ID) |
| `UpdateTask` | Unary | Edit title, description, state |
| `ToggleTaskState` | Unary | Flip Pending ↔ Completed |
| `MoveTask` | Unary | Move task between columns |
| `DeleteTask` | Unary | Remove task by ID |
| `Sync` | **Server stream** | Initial board + push on every change |

### Data model

```protobuf
message Task   { int32 id; string title; string description; State state; }
message Column { int32 id; string name; repeated Task tasks; }
message Board  { repeated Column columns; }
```

---

## Implementation notes

| Topic | Detail |
|-------|--------|
| Concurrency | Separate mutexes for board data and active stream list |
| Broadcast | Serializes full `Board` to every live `Sync` writer after mutations |
| Errors | `NOT_FOUND`, `INVALID_ARGUMENT`, `INTERNAL` gRPC status codes |
| Security | `InsecureServerCredentials` — local development only |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `find_package(gRPC)` fails | Pass `-DCMAKE_TOOLCHAIN_FILE=.../vcpkg.cmake` |
| Port already in use | Stop other `server.exe` or change port in `server.cpp` |
| Client cannot connect | Check firewall; server binds `0.0.0.0`, client needs reachable IP |
| Link errors after proto regen | Re-run full CMake configure |

---

<p align="center">
  <sub><a href="../README.md">← Back to DoThis monorepo</a></sub>
</p>
