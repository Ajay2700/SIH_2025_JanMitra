import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/core/config/env_config.dart';

class SupabaseService extends GetxService {
  // Use the global Supabase client since it's initialized in main.dart
  SupabaseClient get _client => Supabase.instance.client;

  // Observable properties for real-time status
  final RxBool isConnected = false.obs;
  final RxBool isRealtimeEnabled = true.obs;
  final RxString connectionStatus = 'Initializing...'.obs;

  Future<SupabaseService> init() async {
    try {
      // Set up connection status monitoring
      _setupConnectionMonitoring();

      if (kDebugMode) {
        print('SupabaseService initialized successfully');
      }

      return this;
    } catch (e) {
      connectionStatus.value = 'Connection failed';
      if (kDebugMode) {
        print('Failed to initialize SupabaseService: $e');
      }
      throw Exception('Failed to initialize SupabaseService: $e');
    }
  }

  // Monitor connection status
  void _setupConnectionMonitoring() {
    isConnected.value = true;
    connectionStatus.value = 'Connected';

    // Listen for auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      if (kDebugMode) {
        print('Auth state changed: ${data.event}');
      }
    });
  }

  SupabaseClient get client => _client;

  // Storage methods
  Future<String> uploadFile(
    String bucketName,
    String path,
    List<int> fileBytes,
    String fileExt,
  ) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final String filePath = '$path/$fileName';

      await _client.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            Uint8List.fromList(fileBytes),
            fileOptions: FileOptions(contentType: 'image/$fileExt'),
          );

      final String fileUrl = _client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String bucketName, String filePath) async {
    try {
      await _client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Database methods
  Future<List<Map<String, dynamic>>> fetchData(
    String table, {
    String? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _client.from(table).select(columns ?? '*');

      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Apply order by if provided
      if (orderBy != null) {
        query = query.order(orderBy);
      }

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      // Apply offset if provided
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch data from $table: $e');
    }
  }

  Future<Map<String, dynamic>> insertData(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select().single();

      return response;
    } catch (e) {
      throw Exception('Failed to insert data to $table: $e');
    }
  }

  Future<Map<String, dynamic>> updateData(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to update data in $table: $e');
    }
  }

  Future<void> deleteData(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete data from $table: $e');
    }
  }

  // Realtime subscriptions
  RealtimeChannel createSubscription(
    String table, {
    String? event,
    String? filter,
  }) {
    if (!isRealtimeEnabled.value) {
      throw Exception('Realtime functionality is disabled');
    }

    String channelName = 'public:$table';
    if (filter != null) {
      channelName += ':$filter';
    }

    final channel = _client.channel(channelName);

    if (kDebugMode) {
      print('Created subscription for $channelName');
    }

    return channel;
  }

  // Subscribe to table changes with PostgresChangeFilter
  RealtimeChannel subscribeToTableChanges(
    String table,
    Function(Map<String, dynamic>) callback, {
    List<String>? eventTypes,
    String? filterColumn,
    dynamic filterValue,
  }) {
    if (!isRealtimeEnabled.value) {
      throw Exception('Realtime functionality is disabled');
    }

    // Create a unique channel name
    final String channelName =
        'table_changes:$table:${DateTime.now().millisecondsSinceEpoch}';
    final channel = _client.channel(channelName);

    // Set up filter if provided
    PostgresChangeFilter? filter;
    if (filterColumn != null && filterValue != null) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: filterColumn,
        value: filterValue,
      );
    }

    // Set up event types
    final events =
        eventTypes
            ?.map(
              (e) => PostgresChangeEvent.values.firstWhere(
                (event) => event.toString() == 'PostgresChangeEvent.$e',
              ),
            )
            .toList() ??
        [PostgresChangeEvent.all];

    // Subscribe to changes
    channel.onPostgresChanges(
      event: events.first, // Use first event type
      schema: 'public',
      table: table,
      filter: filter,
      callback: (payload) {
        if (kDebugMode) {
          print('Received change for $table: ${payload.eventType}');
        }
        callback(payload.newRecord);
      },
    );

    // Subscribe to additional event types if provided
    if (events.length > 1) {
      for (var i = 1; i < events.length; i++) {
        channel.onPostgresChanges(
          event: events[i],
          schema: 'public',
          table: table,
          filter: filter,
          callback: (payload) {
            if (kDebugMode) {
              print('Received change for $table: ${payload.eventType}');
            }
            callback(payload.newRecord);
          },
        );
      }
    }

    // Start listening
    channel.subscribe();

    if (kDebugMode) {
      print('Subscribed to $table changes');
    }

    return channel;
  }
}
