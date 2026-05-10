# Seeds DoThis git history with logical, dated commits.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot\..

function New-DatedCommit {
    param(
        [string]$Date,
        [string]$Message,
        [string[]]$Paths
    )
    $env:GIT_AUTHOR_DATE = "$Date 12:00:00 +0200"
    $env:GIT_COMMITTER_DATE = "$Date 12:00:00 +0200"
    git add @Paths
    if (-not (git diff --cached --quiet)) {
        git commit -m $Message
        Write-Host "OK $Date $Message"
    } else {
        Write-Warning "SKIP $Date (no changes): $Message"
    }
}

$commits = @(
    @{ Date = '2025-06-08'; Message = 'chore: add root gitignore and shared proto contract'; Paths = @('.gitignore', 'DoThis_Server/proto/todo.proto') }
    @{ Date = '2025-06-22'; Message = 'build: add CMake project and generated protobuf stubs'; Paths = @('DoThis_Server/CMakeLists.txt', 'DoThis_Server/generated/todo.pb.cc', 'DoThis_Server/generated/todo.pb.h', 'DoThis_Server/generated/todo.grpc.pb.cc', 'DoThis_Server/generated/todo.grpc.pb.h', 'DoThis_Server/.gitignore') }
    @{ Date = '2025-07-06'; Message = 'feat(server): implement gRPC board service with sync streaming'; Paths = @('DoThis_Server/src/server.cpp', 'DoThis_Server/.vscode/settings.json') }
    @{ Date = '2025-07-20'; Message = 'build(client): scaffold WPF project and proto generation'; Paths = @('DoThis_Client/DoThis_Client.sln', 'DoThis_Client/DoThis_Client/DoThis_Client.csproj', 'DoThis_Client/DoThis_Client/proto/todo.proto', 'DoThis_Client/.gitignore') }
    @{ Date = '2025-08-03'; Message = 'feat(client): add application shell and Material Design theme'; Paths = @('DoThis_Client/DoThis_Client/App.xaml', 'DoThis_Client/DoThis_Client/App.xaml.cs', 'DoThis_Client/DoThis_Client/AssemblyInfo.cs', 'DoThis_Client/DoThis_Client/Views/to-do-list.ico') }
    @{ Date = '2025-08-17'; Message = 'feat(client): add column and task view models'; Paths = @('DoThis_Client/DoThis_Client/Models/ColumnModel.cs', 'DoThis_Client/DoThis_Client/Models/TaskModel.cs') }
    @{ Date = '2025-08-31'; Message = 'feat(client): wire MainViewModel with board load and sync stream'; Paths = @('DoThis_Client/DoThis_Client/ViewModels/MainViewModel.cs') }
    @{ Date = '2025-09-14'; Message = 'feat(client): add task and column name dialogs'; Paths = @('DoThis_Client/DoThis_Client/Views/NewNameDialog.xaml', 'DoThis_Client/DoThis_Client/Views/NewNameDialog.xaml.cs', 'DoThis_Client/DoThis_Client/Views/EditTaskDialog.xaml', 'DoThis_Client/DoThis_Client/Views/EditTaskDialog.xaml.cs') }
    @{ Date = '2025-09-28'; Message = 'feat(client): build Kanban board layout in MainWindow'; Paths = @('DoThis_Client/DoThis_Client/Views/MainWindow.xaml') }
    @{ Date = '2025-10-12'; Message = 'feat(client): add drag-and-drop task moves between columns'; Paths = @('DoThis_Client/DoThis_Client/Views/MainWindow.xaml.cs') }
    @{ Date = '2025-10-26'; Message = 'feat(client): add template selectors for add-column and add-task buttons'; Paths = @('DoThis_Client/DoThis_Client/Service/ColumnAndAddColumnTemplateSelector.cs', 'DoThis_Client/DoThis_Client/Service/TaskAndAddButtonTemplateSelector.cs') }
    @{ Date = '2025-11-17'; Message = 'chore: add repo icon asset'; Paths = @('assets/icon.ico') }
    @{ Date = '2025-12-05'; Message = 'docs: add architecture notes'; Paths = @('docs/ARCHITECTURE.md') }
    @{ Date = '2026-01-20'; Message = 'docs(server): add build and API documentation'; Paths = @('DoThis_Server/README.md') }
    @{ Date = '2026-02-08'; Message = 'docs(client): add WPF client setup guide'; Paths = @('DoThis_Client/README.md') }
    @{ Date = '2026-02-22'; Message = 'docs: add monorepo README with architecture overview'; Paths = @('README.md') }
    @{ Date = '2026-03-15'; Message = 'docs: add project changelog'; Paths = @('docs/CHANGELOG.md') }
    @{ Date = '2026-04-05'; Message = 'chore: add MIT license'; Paths = @('LICENSE') }
    @{ Date = '2026-05-03'; Message = 'chore: add editorconfig for consistent formatting'; Paths = @('.editorconfig') }
    @{ Date = '2026-05-10'; Message = 'chore: add git history seeding script'; Paths = @('scripts/seed-history.ps1') }
)

foreach ($c in $commits) {
    New-DatedCommit -Date $c.Date -Message $c.Message -Paths $c.Paths
}

Write-Host "`nDone. Commits: $(git rev-list --count HEAD)"
