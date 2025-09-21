import 'package:supabase_flutter/supabase_flutter.dart';

/// A simple script to test the connection to Supabase
/// Run this script with:
/// dart run supabase/test_connection.dart
///
/// Make sure to replace the URL and anon key with your own

void main() async {
  print('Testing Supabase connection...');

  // Replace with your Supabase URL and anon key
  const supabaseUrl = 'YOUR_SUPABASE_URL';
  const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  try {
    // Initialize Supabase
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    print('Supabase initialized successfully');

    // Get the client
    final client = Supabase.instance.client;

    // Test querying the tickets table
    print('Fetching tickets...');
    final response = await client.from('tickets').select().limit(5);

    print('Tickets found: ${response.length}');

    if (response.isEmpty) {
      print('No tickets found. You may need to run the sample data SQL.');
    } else {
      print('First ticket:');
      print('  Title: ${response[0]['title']}');
      print('  Status: ${response[0]['status']}');
    }

    // Test querying the ticket_comments table
    print('\nFetching comments...');
    final commentsResponse = await client
        .from('ticket_comments')
        .select()
        .limit(5);

    print('Comments found: ${commentsResponse.length}');

    if (commentsResponse.isEmpty) {
      print('No comments found. You may need to run the sample data SQL.');
    } else {
      print('First comment:');
      print('  Content: ${commentsResponse[0]['content']}');
    }

    print('\nConnection test completed successfully!');
  } catch (e) {
    print('Error connecting to Supabase: $e');
    print('\nPlease check your Supabase URL and anon key.');
  }
}
