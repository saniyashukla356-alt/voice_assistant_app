
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatHistoryService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> saveConversation({
    required String? conversationId,
    required List<ChatMessage> messages,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to save chat history.');
    }

    final serializedMessages = messages.map((message) {
      return {
        'message': message.message,
        'is_user': message.isUser,
      };
    }).toList();

    final firstUserMessage = messages
        .where((message) => message.isUser)
        .map((message) => message.message.trim())
        .firstWhere(
          (message) => message.isNotEmpty,
          orElse: () => 'New chat',
        );

    final title = firstUserMessage.length > 45
        ? '${firstUserMessage.substring(0, 45)}...'
        : firstUserMessage;

    final now = DateTime.now().toUtc().toIso8601String();

    if (conversationId == null) {
      final result = await _client
          .from('chat_history')
          .insert({
            'user_id': user.id,
            'title': title,
            'messages': serializedMessages,
            'updated_at': now,
          })
          .select('id')
          .single();

      return result['id'].toString();
    }

    await _client
        .from('chat_history')
        .update({
          'title': title,
          'messages': serializedMessages,
          'updated_at': now,
        })
        .eq('id', conversationId)
        .eq('user_id', user.id);

    return conversationId;
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to view chat history.');
    }

    final result = await _client
        .from('chat_history')
        .select('id, title, messages, created_at, updated_at')
        .eq('user_id', user.id)
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> deleteConversation(String id) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to delete chat history.');
    }

    await _client
        .from('chat_history')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
