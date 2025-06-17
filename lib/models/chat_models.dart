import 'package:realm/realm.dart';
part 'chat_models.realm.dart';

/// Chat history model - simplified design
/// Store all messages as JSON string to avoid complex relationships
@RealmModel()
class _ChatHistory {
  @PrimaryKey()
  late String id;

  late String title;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String messagesJson;

  String? chatUuid;
  String? modelName;
  int messageCount = 0;
  String? lastMessage;
} 