<p align="center">
  <img src="assets/icon.ico" alt="DoThis" width="96" />
</p>

<h1 align="center">DoThis</h1>

<p align="center">
  <strong>Collaborative Kanban to-do board</strong><br/>
  C++ gRPC server · C# WPF client · real-time sync · drag-and-drop
</p>

<p align="center">
  <img src="https://img.shields.io/badge/C%2B%2B-17-00599C?logo=c%2B%2B&logoColor=white" alt="C++17" />
  <img src="https://img.shields.io/badge/gRPC-Protocol_Buffers-244C5A?logo=grpc&logoColor=white" alt="gRPC" />
  <img src="https://img.shields.io/badge/.NET-8-512BD4?logo=dotnet&logoColor=white" alt=".NET 8" />
  <img src="https://img.shields.io/badge/WPF-Desktop-512BD4?logo=windows&logoColor=white" alt="WPF" />
  <img src="https://img.shields.io/badge/Material_Design-5.2-757575?logo=materialdesign&logoColor=white" alt="Material Design" />
  <img src="https://img.shields.io/badge/CMake-3.15+-064F8C?logo=cmake&logoColor=white" alt="CMake" />
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> ·
  <a href="#architecture">Architecture</a> ·
  <a href="DoThis_Server/README.md">Server</a> ·
  <a href="DoThis_Client/README.md">Client</a>
</p>

---

## About

**DoThis** is a client–server Kanban to-do application. A **C++ gRPC server** holds the shared board in memory and broadcasts changes to all connected clients. A **C# WPF desktop client** provides a Material Design UI with columns, tasks, drag-and-drop, and live synchronization — no manual refresh required.

Key capabilities:

- Kanban board with customizable columns (default: Planned · In Progress · Done)
- Create, edit, toggle, move, and delete tasks
- Drag-and-drop tasks between columns
- Server-streaming `Sync` RPC — all clients update instantly
- Shared `todo.proto` contract between server and client
- In-memory storage on the server (no database setup)

> Educational / portfolio project demonstrating gRPC, Protocol Buffers, and a classic client–server desktop architecture.

---

## Features

| Area | Highlights |
|------|------------|
| **Server** | CRUD for columns & tasks, `GetBoard`, bidirectional state toggle, `MoveTask`, gRPC server streaming |
| **Client UI** | Horizontal Kanban layout, Material Design cards, context menus |
| **Real-time sync** | `Sync` stream pushes full board snapshot on every mutation |
| **Drag & drop** | WPF `DragDrop` → `MoveTask` gRPC call |
| **MVVM** | CommunityToolkit.Mvvm view models, template selectors for add-buttons |

---

## Architecture

```
                    +---------------------------+
                    |   DoThis_Server (C++)     |
                    |   ToDoServiceImpl         |
                    |   in-memory Board         |
                    +-------------+-------------+
                                  |
                         gRPC :50051 (HTTP/2)
                    +-------------+-------------+
                    |  AddColumn · GetBoard     |
                    |  AddTask · UpdateTask     |
                    |  MoveTask · Delete*       |
                    |  Sync (server stream)     |
                    +------+--------------+-----+
                           |              |
              +------------+              +------------+
              |                                        |
              v                                        v
    +-------------------+                  +-------------------+
    |  WPF Client #1    |                  |  WPF Client #2    |
    |  MainViewModel    |                  |  MainViewModel    |
    |  Sync loop        |                  |  Sync loop        |
    +-------------------+                  +-------------------+

    proto/todo.proto  ── shared contract (Board · Column · Task)
```

### Sync flow

1. Client opens a long-lived `Sync` stream to the server
2. Server sends the current board immediately, then registers the stream
3. Any RPC mutation (`AddTask`, `MoveTask`, etc.) calls `BroadcastBoard()`
4. All active stream writers receive the updated `Board` message
5. Client `MainViewModel` rebuilds column/task view models on each push

### Project layout

```
client-server-to-do-list/
├── assets/                    # Repo icon
├── DoThis_Server/             # C++ gRPC server
│   ├── src/server.cpp
│   ├── proto/todo.proto
│   ├── generated/             # protoc output (C++)
│   └── CMakeLists.txt
├── DoThis_Client/             # C# WPF client
│   └── DoThis_Client/
│       ├── ViewModels/
│       ├── Models/
│       ├── Views/
│       ├── Service/           # DataTemplate selectors
│       └── proto/todo.proto
└── README.md
```

---

## Tech Stack

| Layer | Technologies |
|-------|----------------|
| **Server** | C++17, gRPC, Protocol Buffers, CMake, vcpkg |
| **Client** | .NET 8, WPF, Grpc.Net.Client, CommunityToolkit.Mvvm, MaterialDesignThemes |
| **Contract** | `proto3` — `Board`, `Column`, `Task`, `ToDoService` |
| **Transport** | gRPC over HTTP/2, port `50051`, insecure credentials (dev/local) |

---

## Quick Start

### Prerequisites

- **Windows** (primary target; server also builds on Linux/macOS with vcpkg)
- **Visual Studio 2022** with *Desktop development with C++* and *.NET desktop development*
- **CMake** ≥ 3.15
- **[vcpkg](https://github.com/microsoft/vcpkg)** with `grpc` and `protobuf` installed
- **.NET 8 SDK**

### 1. Clone

```bash
git clone https://github.com/Yevhen-Lytvynenko/client-server-to-do-list.git
cd client-server-to-do-list
```

### 2. Start the server

See **[DoThis_Server/README.md](./DoThis_Server/README.md)** for vcpkg setup and CMake build steps.

```bash
cd DoThis_Server
cmake -B build -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
./build/Release/server.exe    # Windows
```

The server listens on `0.0.0.0:50051`.

### 3. Run the client

See **[DoThis_Client/README.md](./DoThis_Client/README.md)** for details.

```bash
cd DoThis_Client
dotnet run --project DoThis_Client/DoThis_Client.csproj -c Release
```

Set the server address in `MainViewModel.cs` if the host is not on localhost:

```csharp
private static string ServerIP = "127.0.0.1"; // or your LAN / VPN IP
```

### 4. Multi-client demo

1. Start **one** server instance
2. Launch **two or more** WPF clients (same `ServerIP`)
3. Add or move a task in one window — the other updates automatically

| Command | Description |
|---------|-------------|
| `cmake --build build --config Release` | Build C++ server |
| `dotnet build DoThis_Client/DoThis_Client.csproj` | Build WPF client |
| `dotnet run --project DoThis_Client/DoThis_Client.csproj` | Run client |

---

## Environment & config

<details>
<summary><b>Server address</b> — <code>MainViewModel.cs</code></summary>

| Item | Default | Description |
|------|---------|-------------|
| `ServerIP` | `127.0.0.1` | IP of the machine running `server.exe` |
| Port | `50051` | Hardcoded in server (`server.cpp`) and client |
| Credentials | Insecure | Suitable for local/LAN development only |

</details>

<details>
<summary><b>Proto contract</b> — keep server &amp; client in sync</summary>

Both projects include a copy of `todo.proto`. After editing the schema:

- **Server:** regenerate into `DoThis_Server/generated/` (see server README)
- **Client:** `Grpc.Tools` regenerates on `dotnet build`

</details>

---

## Design decisions

| Decision | Rationale |
|----------|-----------|
| Full-board broadcast | Simple correctness; board size fits in memory for a demo |
| Server streaming for sync | Push model avoids client polling |
| Pre-generated C++ stubs | CMake project links `generated/*.cc` directly — no protoc hook in CMake yet |
| In-memory storage | Zero setup; matches original technical requirements |
| WPF + Material Design | Rich desktop UX with minimal custom styling |

---

## License

Built for **portfolio and educational purposes**. Free to study and fork; commercial reuse at your own discretion.

---

<p align="center">
  <sub>DoThis · Yevhen Lytvynenko</sub>
</p>
