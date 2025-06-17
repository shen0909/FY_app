// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class ChatHistory extends _ChatHistory
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ChatHistory(
    String id,
    String title,
    DateTime createdAt,
    DateTime updatedAt,
    String messagesJson, {
    String? chatUuid,
    String? modelName,
    int messageCount = 0,
    String? lastMessage,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ChatHistory>({
        'messageCount': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'messagesJson', messagesJson);
    RealmObjectBase.set(this, 'chatUuid', chatUuid);
    RealmObjectBase.set(this, 'modelName', modelName);
    RealmObjectBase.set(this, 'messageCount', messageCount);
    RealmObjectBase.set(this, 'lastMessage', lastMessage);
  }

  ChatHistory._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  String get messagesJson =>
      RealmObjectBase.get<String>(this, 'messagesJson') as String;
  @override
  set messagesJson(String value) =>
      RealmObjectBase.set(this, 'messagesJson', value);

  @override
  String? get chatUuid =>
      RealmObjectBase.get<String>(this, 'chatUuid') as String?;
  @override
  set chatUuid(String? value) => RealmObjectBase.set(this, 'chatUuid', value);

  @override
  String? get modelName =>
      RealmObjectBase.get<String>(this, 'modelName') as String?;
  @override
  set modelName(String? value) => RealmObjectBase.set(this, 'modelName', value);

  @override
  int get messageCount => RealmObjectBase.get<int>(this, 'messageCount') as int;
  @override
  set messageCount(int value) =>
      RealmObjectBase.set(this, 'messageCount', value);

  @override
  String? get lastMessage =>
      RealmObjectBase.get<String>(this, 'lastMessage') as String?;
  @override
  set lastMessage(String? value) =>
      RealmObjectBase.set(this, 'lastMessage', value);

  @override
  Stream<RealmObjectChanges<ChatHistory>> get changes =>
      RealmObjectBase.getChanges<ChatHistory>(this);

  @override
  Stream<RealmObjectChanges<ChatHistory>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ChatHistory>(this, keyPaths);

  @override
  ChatHistory freeze() => RealmObjectBase.freezeObject<ChatHistory>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
      'messagesJson': messagesJson.toEJson(),
      'chatUuid': chatUuid.toEJson(),
      'modelName': modelName.toEJson(),
      'messageCount': messageCount.toEJson(),
      'lastMessage': lastMessage.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChatHistory value) => value.toEJson();
  static ChatHistory _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
        'messagesJson': EJsonValue messagesJson,
      } =>
        ChatHistory(
          fromEJson(id),
          fromEJson(title),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          fromEJson(messagesJson),
          chatUuid: fromEJson(ejson['chatUuid']),
          modelName: fromEJson(ejson['modelName']),
          messageCount: fromEJson(ejson['messageCount'], defaultValue: 0),
          lastMessage: fromEJson(ejson['lastMessage']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChatHistory._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ChatHistory, 'ChatHistory', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp),
      SchemaProperty('messagesJson', RealmPropertyType.string),
      SchemaProperty('chatUuid', RealmPropertyType.string, optional: true),
      SchemaProperty('modelName', RealmPropertyType.string, optional: true),
      SchemaProperty('messageCount', RealmPropertyType.int),
      SchemaProperty('lastMessage', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
