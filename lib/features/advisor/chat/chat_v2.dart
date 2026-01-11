/// Export file for Chat V2 (Local-First Architecture)
///
/// ## How to use
///
/// Replace old imports with:
/// ```dart
/// import 'package:tayseer/features/advisor/chat/chat_v2.dart';
/// ```
///
/// ## Architecture Overview
///
/// ```
/// UI (BlocSelector for efficient updates)
///  ↓
/// ChatMessagesCubitV2
///  ↓
/// ChatRepoV2 (Local-First Strategy)
///  ↓
/// ChatLocalDataSource ←→ Socket (realtime only)
///  ↓
/// SQLite (ChatDatabase)
///  ↓
/// Remote API (background sync)
/// ```
///
/// ## Key Features
///
/// 1. **Local-First Loading**: Messages loaded from SQLite immediately,
///    server sync happens in background
///
/// 2. **Cursor-Based Pagination**: Uses `createdAt` as cursor instead of
///    page numbers for consistent pagination
///
/// 3. **Optimistic UI**: Messages appear instantly with `status=sending`,
///    updated when server confirms
///
/// 4. **Offline Support**: Messages queued when offline, auto-sent on reconnect
///
/// 5. **Cache Cleanup**: Auto-cleanup keeps max 20,000 messages per chat
///
/// 6. **Efficient Updates**: BlocSelector support for updating single messages
///    without rebuilding entire list

// Data Layer
export 'data/local/chat_local_datasource.dart';
export 'data/repo/chat_repo_v2.dart';

// Presentation Layer
export 'presentation/manager/chat_messages_cubit_v2.dart';
export 'presentation/manager/chat_messages_state_v2.dart';
