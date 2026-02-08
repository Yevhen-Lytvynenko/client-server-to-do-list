<p align="center">
  <img src="../assets/icon.ico" alt="DoThis Client" width="72" />
</p>

<h1 align="center">DoThis Client</h1>

<p align="center">
  <strong>WPF desktop Kanban board connected via gRPC</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/.NET-8-512BD4?logo=dotnet&logoColor=white" alt=".NET 8" />
  <img src="https://img.shields.io/badge/WPF-Windows-512BD4?logo=windows&logoColor=white" alt="WPF" />
  <img src="https://img.shields.io/badge/gRPC-.NET-244C5A?logo=grpc&logoColor=white" alt="gRPC .NET" />
  <img src="https://img.shields.io/badge/MVVM-CommunityToolkit-512BD4?logo=dotnet&logoColor=white" alt="MVVM Toolkit" />
  <img src="https://img.shields.io/badge/UI-Material_Design-757575?logo=materialdesign&logoColor=white" alt="Material Design" />
</p>

<p align="center">
  <a href="../README.md">Monorepo</a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="#configuration">Configuration</a>
</p>

---

## About

**DoThis Client** is a Windows desktop app built with **WPF** and **Material Design**. It connects to [DoThis Server](../DoThis_Server/README.md) over gRPC, renders a horizontal Kanban board, and stays in sync with other clients through a background `Sync` stream.

---

## Features

| Module | Highlights |
|--------|------------|
| **MainViewModel** | gRPC channel, `GetBoard` on start, `Sync` read loop |
| **ColumnViewModel** | Add/rename/delete columns, per-column task list |
| **TaskViewModel** | Edit dialog, toggle complete, delete |
| **MainWindow** | Drag-and-drop between columns → `MoveTask` |
| **Template selectors** | Separate templates for task cards vs. “+” add buttons |
| **UI** | Material Design 3 theme (Deep Purple / Lime) |

---

## Project layout

```
DoThis_Client/
├── DoThis_Client.sln
└── DoThis_Client/
    ├── DoThis_Client.csproj   # Grpc.Tools proto generation
    ├── proto/todo.proto
    ├── ViewModels/
    │   └── MainViewModel.cs   # Board state + sync
    ├── Models/
    │   ├── ColumnModel.cs     # ColumnViewModel
    │   └── TaskModel.cs       # TaskViewModel
    ├── Views/
    │   ├── MainWindow.xaml    # Kanban UI + drag/drop
    │   ├── EditTaskDialog.xaml
    │   └── NewNameDialog.xaml
    └── Service/
        ├── ColumnAndAddColumnTemplateSelector.cs
        └── TaskAndAddButtonTemplateSelector.cs
```

---

## Requirements

| Tool | Version |
|------|---------|
| .NET SDK | 8.0+ |
| Windows | WPF target (`net8.0-windows`) |
| Running server | [DoThis_Server](../DoThis_Server/README.md) on port `50051` |

NuGet packages (restored automatically):

- `Grpc.Net.Client`, `Grpc.Tools`, `Google.Protobuf`
- `CommunityToolkit.Mvvm`
- `MaterialDesignThemes`

---

## Quick Start

### 1. Start the server

The gRPC server must be running before launching the client. See the [server README](../DoThis_Server/README.md).

### 2. Build & run

From `DoThis_Client/`:

```bash
dotnet restore
dotnet build DoThis_Client/DoThis_Client.csproj -c Release
dotnet run --project DoThis_Client/DoThis_Client.csproj -c Release
```

Or open `DoThis_Client.sln` in Visual Studio 2022 and press **F5**.

### 3. Use the board

- **+** at the end of the column row → add a column
- **+** at the bottom of a column → add a task
- **Checkbox** on a task → toggle Pending / Completed
- **Right-click** column → rename · right-click task → edit
- **Drag** a task card to another column → move
- **×** on a task → delete

Changes propagate to all connected clients instantly.

---

## Configuration

### Server address

In `ViewModels/MainViewModel.cs`:

```csharp
private static string ServerIP = "127.0.0.1"; // Host running DoThis_Server
private static readonly GrpcChannel _channel =
    GrpcChannel.ForAddress($"http://{ServerIP}:50051");
```

| Scenario | `ServerIP` value |
|----------|------------------|
| Server on same PC | `127.0.0.1` |
| Server on LAN | Host machine local IP (e.g. `192.168.1.10`) |
| Remote via VPN | VPN IP of the server host (e.g. Radmin VPN) |

Port `50051` is fixed to match the C++ server.

---

## Architecture (client side)

```
MainWindow (code-behind: drag/drop)
    └── MainViewModel
            ├── GetBoardAsync()     — initial load
            ├── SubscribeToSync()   — await foreach Board on stream
            └── Columns collection
                    ├── ColumnViewModel → Tasks → TaskViewModel
                    └── "Add Column" placeholder

gRPC mutations (AddTask, MoveTask, …) → server broadcast → Sync push → UpdateBoard()
```

`UpdateBoard` clears and rebuilds the observable collection so the UI always mirrors server state.

---

## Proto generation

`DoThis_Client.csproj` includes:

```xml
<Protobuf Include="proto\todo.proto" GrpcServices="Client" />
```

`Grpc.Tools` generates `Todo.cs` and `TodoGrpc.cs` into `obj/` on build. Keep `proto/todo.proto` aligned with the server copy.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Error loading board` on start | Ensure server is running and `ServerIP` is correct |
| `Synchronization error` | Check network/firewall; restart server |
| Build warnings (nullable) | Non-blocking; project builds with warnings |
| UI empty after connect | Server may have started without default columns — restart server |

---

<p align="center">
  <sub><a href="../README.md">← Back to DoThis monorepo</a></sub>
</p>
