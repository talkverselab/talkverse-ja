// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TurnsTable extends Turns with TableInfo<$TurnsTable, TurnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dialectMeta = const VerificationMeta(
    'dialect',
  );
  @override
  late final GeneratedColumn<String> dialect = GeneratedColumn<String>(
    'dialect',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('north'),
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<String> episodeId = GeneratedColumn<String>(
    'episode_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numMeta = const VerificationMeta('num');
  @override
  late final GeneratedColumn<int> num = GeneratedColumn<int>(
    'num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerMeta = const VerificationMeta(
    'speaker',
  );
  @override
  late final GeneratedColumn<String> speaker = GeneratedColumn<String>(
    'speaker',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jaMeta = const VerificationMeta('ja');
  @override
  late final GeneratedColumn<String> ja = GeneratedColumn<String>(
    'ja',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kanaMeta = const VerificationMeta('kana');
  @override
  late final GeneratedColumn<String> kana = GeneratedColumn<String>(
    'kana',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _romajiMeta = const VerificationMeta('romaji');
  @override
  late final GeneratedColumn<String> romaji = GeneratedColumn<String>(
    'romaji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _koMeta = const VerificationMeta('ko');
  @override
  late final GeneratedColumn<String> ko = GeneratedColumn<String>(
    'ko',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    dialect,
    episodeId,
    num,
    speaker,
    ja,
    kana,
    romaji,
    ko,
    note,
    tagsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<TurnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('dialect')) {
      context.handle(
        _dialectMeta,
        dialect.isAcceptableOrUnknown(data['dialect']!, _dialectMeta),
      );
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('num')) {
      context.handle(
        _numMeta,
        num.isAcceptableOrUnknown(data['num']!, _numMeta),
      );
    } else if (isInserting) {
      context.missing(_numMeta);
    }
    if (data.containsKey('speaker')) {
      context.handle(
        _speakerMeta,
        speaker.isAcceptableOrUnknown(data['speaker']!, _speakerMeta),
      );
    } else if (isInserting) {
      context.missing(_speakerMeta);
    }
    if (data.containsKey('ja')) {
      context.handle(_jaMeta, ja.isAcceptableOrUnknown(data['ja']!, _jaMeta));
    } else if (isInserting) {
      context.missing(_jaMeta);
    }
    if (data.containsKey('kana')) {
      context.handle(
        _kanaMeta,
        kana.isAcceptableOrUnknown(data['kana']!, _kanaMeta),
      );
    }
    if (data.containsKey('romaji')) {
      context.handle(
        _romajiMeta,
        romaji.isAcceptableOrUnknown(data['romaji']!, _romajiMeta),
      );
    }
    if (data.containsKey('ko')) {
      context.handle(_koMeta, ko.isAcceptableOrUnknown(data['ko']!, _koMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      dialect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dialect'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      ),
      num: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}num'],
      )!,
      speaker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker'],
      )!,
      ja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ja'],
      )!,
      kana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kana'],
      ),
      romaji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}romaji'],
      ),
      ko: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ko'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      ),
    );
  }

  @override
  $TurnsTable createAlias(String alias) {
    return $TurnsTable(attachedDatabase, alias);
  }
}

class TurnRow extends DataClass implements Insertable<TurnRow> {
  final int id;
  final String level;
  final String dialect;
  final String? episodeId;
  final int num;
  final String speaker;
  final String ja;
  final String? kana;
  final String? romaji;
  final String? ko;
  final String? note;
  final String? tagsJson;
  const TurnRow({
    required this.id,
    required this.level,
    required this.dialect,
    this.episodeId,
    required this.num,
    required this.speaker,
    required this.ja,
    this.kana,
    this.romaji,
    this.ko,
    this.note,
    this.tagsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['dialect'] = Variable<String>(dialect);
    if (!nullToAbsent || episodeId != null) {
      map['episode_id'] = Variable<String>(episodeId);
    }
    map['num'] = Variable<int>(num);
    map['speaker'] = Variable<String>(speaker);
    map['ja'] = Variable<String>(ja);
    if (!nullToAbsent || kana != null) {
      map['kana'] = Variable<String>(kana);
    }
    if (!nullToAbsent || romaji != null) {
      map['romaji'] = Variable<String>(romaji);
    }
    if (!nullToAbsent || ko != null) {
      map['ko'] = Variable<String>(ko);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tagsJson != null) {
      map['tags_json'] = Variable<String>(tagsJson);
    }
    return map;
  }

  TurnsCompanion toCompanion(bool nullToAbsent) {
    return TurnsCompanion(
      id: Value(id),
      level: Value(level),
      dialect: Value(dialect),
      episodeId: episodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeId),
      num: Value(num),
      speaker: Value(speaker),
      ja: Value(ja),
      kana: kana == null && nullToAbsent ? const Value.absent() : Value(kana),
      romaji: romaji == null && nullToAbsent
          ? const Value.absent()
          : Value(romaji),
      ko: ko == null && nullToAbsent ? const Value.absent() : Value(ko),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
    );
  }

  factory TurnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnRow(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      dialect: serializer.fromJson<String>(json['dialect']),
      episodeId: serializer.fromJson<String?>(json['episodeId']),
      num: serializer.fromJson<int>(json['num']),
      speaker: serializer.fromJson<String>(json['speaker']),
      ja: serializer.fromJson<String>(json['ja']),
      kana: serializer.fromJson<String?>(json['kana']),
      romaji: serializer.fromJson<String?>(json['romaji']),
      ko: serializer.fromJson<String?>(json['ko']),
      note: serializer.fromJson<String?>(json['note']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'dialect': serializer.toJson<String>(dialect),
      'episodeId': serializer.toJson<String?>(episodeId),
      'num': serializer.toJson<int>(num),
      'speaker': serializer.toJson<String>(speaker),
      'ja': serializer.toJson<String>(ja),
      'kana': serializer.toJson<String?>(kana),
      'romaji': serializer.toJson<String?>(romaji),
      'ko': serializer.toJson<String?>(ko),
      'note': serializer.toJson<String?>(note),
      'tagsJson': serializer.toJson<String?>(tagsJson),
    };
  }

  TurnRow copyWith({
    int? id,
    String? level,
    String? dialect,
    Value<String?> episodeId = const Value.absent(),
    int? num,
    String? speaker,
    String? ja,
    Value<String?> kana = const Value.absent(),
    Value<String?> romaji = const Value.absent(),
    Value<String?> ko = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> tagsJson = const Value.absent(),
  }) => TurnRow(
    id: id ?? this.id,
    level: level ?? this.level,
    dialect: dialect ?? this.dialect,
    episodeId: episodeId.present ? episodeId.value : this.episodeId,
    num: num ?? this.num,
    speaker: speaker ?? this.speaker,
    ja: ja ?? this.ja,
    kana: kana.present ? kana.value : this.kana,
    romaji: romaji.present ? romaji.value : this.romaji,
    ko: ko.present ? ko.value : this.ko,
    note: note.present ? note.value : this.note,
    tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
  );
  TurnRow copyWithCompanion(TurnsCompanion data) {
    return TurnRow(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      dialect: data.dialect.present ? data.dialect.value : this.dialect,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      num: data.num.present ? data.num.value : this.num,
      speaker: data.speaker.present ? data.speaker.value : this.speaker,
      ja: data.ja.present ? data.ja.value : this.ja,
      kana: data.kana.present ? data.kana.value : this.kana,
      romaji: data.romaji.present ? data.romaji.value : this.romaji,
      ko: data.ko.present ? data.ko.value : this.ko,
      note: data.note.present ? data.note.value : this.note,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnRow(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('dialect: $dialect, ')
          ..write('episodeId: $episodeId, ')
          ..write('num: $num, ')
          ..write('speaker: $speaker, ')
          ..write('ja: $ja, ')
          ..write('kana: $kana, ')
          ..write('romaji: $romaji, ')
          ..write('ko: $ko, ')
          ..write('note: $note, ')
          ..write('tagsJson: $tagsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    level,
    dialect,
    episodeId,
    num,
    speaker,
    ja,
    kana,
    romaji,
    ko,
    note,
    tagsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnRow &&
          other.id == this.id &&
          other.level == this.level &&
          other.dialect == this.dialect &&
          other.episodeId == this.episodeId &&
          other.num == this.num &&
          other.speaker == this.speaker &&
          other.ja == this.ja &&
          other.kana == this.kana &&
          other.romaji == this.romaji &&
          other.ko == this.ko &&
          other.note == this.note &&
          other.tagsJson == this.tagsJson);
}

class TurnsCompanion extends UpdateCompanion<TurnRow> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> dialect;
  final Value<String?> episodeId;
  final Value<int> num;
  final Value<String> speaker;
  final Value<String> ja;
  final Value<String?> kana;
  final Value<String?> romaji;
  final Value<String?> ko;
  final Value<String?> note;
  final Value<String?> tagsJson;
  const TurnsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.dialect = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.num = const Value.absent(),
    this.speaker = const Value.absent(),
    this.ja = const Value.absent(),
    this.kana = const Value.absent(),
    this.romaji = const Value.absent(),
    this.ko = const Value.absent(),
    this.note = const Value.absent(),
    this.tagsJson = const Value.absent(),
  });
  TurnsCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    this.dialect = const Value.absent(),
    this.episodeId = const Value.absent(),
    required int num,
    required String speaker,
    required String ja,
    this.kana = const Value.absent(),
    this.romaji = const Value.absent(),
    this.ko = const Value.absent(),
    this.note = const Value.absent(),
    this.tagsJson = const Value.absent(),
  }) : level = Value(level),
       num = Value(num),
       speaker = Value(speaker),
       ja = Value(ja);
  static Insertable<TurnRow> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? dialect,
    Expression<String>? episodeId,
    Expression<int>? num,
    Expression<String>? speaker,
    Expression<String>? ja,
    Expression<String>? kana,
    Expression<String>? romaji,
    Expression<String>? ko,
    Expression<String>? note,
    Expression<String>? tagsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (dialect != null) 'dialect': dialect,
      if (episodeId != null) 'episode_id': episodeId,
      if (num != null) 'num': num,
      if (speaker != null) 'speaker': speaker,
      if (ja != null) 'ja': ja,
      if (kana != null) 'kana': kana,
      if (romaji != null) 'romaji': romaji,
      if (ko != null) 'ko': ko,
      if (note != null) 'note': note,
      if (tagsJson != null) 'tags_json': tagsJson,
    });
  }

  TurnsCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? dialect,
    Value<String?>? episodeId,
    Value<int>? num,
    Value<String>? speaker,
    Value<String>? ja,
    Value<String?>? kana,
    Value<String?>? romaji,
    Value<String?>? ko,
    Value<String?>? note,
    Value<String?>? tagsJson,
  }) {
    return TurnsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      dialect: dialect ?? this.dialect,
      episodeId: episodeId ?? this.episodeId,
      num: num ?? this.num,
      speaker: speaker ?? this.speaker,
      ja: ja ?? this.ja,
      kana: kana ?? this.kana,
      romaji: romaji ?? this.romaji,
      ko: ko ?? this.ko,
      note: note ?? this.note,
      tagsJson: tagsJson ?? this.tagsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (dialect.present) {
      map['dialect'] = Variable<String>(dialect.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (num.present) {
      map['num'] = Variable<int>(num.value);
    }
    if (speaker.present) {
      map['speaker'] = Variable<String>(speaker.value);
    }
    if (ja.present) {
      map['ja'] = Variable<String>(ja.value);
    }
    if (kana.present) {
      map['kana'] = Variable<String>(kana.value);
    }
    if (romaji.present) {
      map['romaji'] = Variable<String>(romaji.value);
    }
    if (ko.present) {
      map['ko'] = Variable<String>(ko.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('dialect: $dialect, ')
          ..write('episodeId: $episodeId, ')
          ..write('num: $num, ')
          ..write('speaker: $speaker, ')
          ..write('ja: $ja, ')
          ..write('kana: $kana, ')
          ..write('romaji: $romaji, ')
          ..write('ko: $ko, ')
          ..write('note: $note, ')
          ..write('tagsJson: $tagsJson')
          ..write(')'))
        .toString();
  }
}

class $KanjiTable extends Kanji with TableInfo<$KanjiTable, KanjiRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _charMeta = const VerificationMeta('char');
  @override
  late final GeneratedColumn<String> char = GeneratedColumn<String>(
    'char',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pctMeta = const VerificationMeta('pct');
  @override
  late final GeneratedColumn<double> pct = GeneratedColumn<double>(
    'pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jlptMeta = const VerificationMeta('jlpt');
  @override
  late final GeneratedColumn<int> jlpt = GeneratedColumn<int>(
    'jlpt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strokesMeta = const VerificationMeta(
    'strokes',
  );
  @override
  late final GeneratedColumn<int> strokes = GeneratedColumn<int>(
    'strokes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningKoMeta = const VerificationMeta(
    'meaningKo',
  );
  @override
  late final GeneratedColumn<String> meaningKo = GeneratedColumn<String>(
    'meaning_ko',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningsKoJsonMeta = const VerificationMeta(
    'meaningsKoJson',
  );
  @override
  late final GeneratedColumn<String> meaningsKoJson = GeneratedColumn<String>(
    'meanings_ko_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningsEnMeta = const VerificationMeta(
    'meaningsEn',
  );
  @override
  late final GeneratedColumn<String> meaningsEn = GeneratedColumn<String>(
    'meanings_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onyomiMeta = const VerificationMeta('onyomi');
  @override
  late final GeneratedColumn<String> onyomi = GeneratedColumn<String>(
    'onyomi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kunyomiMeta = const VerificationMeta(
    'kunyomi',
  );
  @override
  late final GeneratedColumn<String> kunyomi = GeneratedColumn<String>(
    'kunyomi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _koHanjaMeta = const VerificationMeta(
    'koHanja',
  );
  @override
  late final GeneratedColumn<String> koHanja = GeneratedColumn<String>(
    'ko_hanja',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    char,
    rank,
    pct,
    jlpt,
    grade,
    strokes,
    meaningKo,
    meaningsKoJson,
    meaningsEn,
    onyomi,
    kunyomi,
    koHanja,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('char')) {
      context.handle(
        _charMeta,
        char.isAcceptableOrUnknown(data['char']!, _charMeta),
      );
    } else if (isInserting) {
      context.missing(_charMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('pct')) {
      context.handle(
        _pctMeta,
        pct.isAcceptableOrUnknown(data['pct']!, _pctMeta),
      );
    }
    if (data.containsKey('jlpt')) {
      context.handle(
        _jlptMeta,
        jlpt.isAcceptableOrUnknown(data['jlpt']!, _jlptMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('strokes')) {
      context.handle(
        _strokesMeta,
        strokes.isAcceptableOrUnknown(data['strokes']!, _strokesMeta),
      );
    }
    if (data.containsKey('meaning_ko')) {
      context.handle(
        _meaningKoMeta,
        meaningKo.isAcceptableOrUnknown(data['meaning_ko']!, _meaningKoMeta),
      );
    }
    if (data.containsKey('meanings_ko_json')) {
      context.handle(
        _meaningsKoJsonMeta,
        meaningsKoJson.isAcceptableOrUnknown(
          data['meanings_ko_json']!,
          _meaningsKoJsonMeta,
        ),
      );
    }
    if (data.containsKey('meanings_en')) {
      context.handle(
        _meaningsEnMeta,
        meaningsEn.isAcceptableOrUnknown(data['meanings_en']!, _meaningsEnMeta),
      );
    }
    if (data.containsKey('onyomi')) {
      context.handle(
        _onyomiMeta,
        onyomi.isAcceptableOrUnknown(data['onyomi']!, _onyomiMeta),
      );
    }
    if (data.containsKey('kunyomi')) {
      context.handle(
        _kunyomiMeta,
        kunyomi.isAcceptableOrUnknown(data['kunyomi']!, _kunyomiMeta),
      );
    }
    if (data.containsKey('ko_hanja')) {
      context.handle(
        _koHanjaMeta,
        koHanja.isAcceptableOrUnknown(data['ko_hanja']!, _koHanjaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {char};
  @override
  KanjiRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiRow(
      char: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      ),
      pct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pct'],
      ),
      jlpt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      strokes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strokes'],
      ),
      meaningKo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_ko'],
      ),
      meaningsKoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings_ko_json'],
      ),
      meaningsEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings_en'],
      ),
      onyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onyomi'],
      ),
      kunyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunyomi'],
      ),
      koHanja: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ko_hanja'],
      ),
    );
  }

  @override
  $KanjiTable createAlias(String alias) {
    return $KanjiTable(attachedDatabase, alias);
  }
}

class KanjiRow extends DataClass implements Insertable<KanjiRow> {
  final String char;
  final int? rank;
  final double? pct;
  final int? jlpt;
  final int? grade;
  final int? strokes;
  final String? meaningKo;
  final String? meaningsKoJson;
  final String? meaningsEn;
  final String? onyomi;
  final String? kunyomi;
  final String? koHanja;
  const KanjiRow({
    required this.char,
    this.rank,
    this.pct,
    this.jlpt,
    this.grade,
    this.strokes,
    this.meaningKo,
    this.meaningsKoJson,
    this.meaningsEn,
    this.onyomi,
    this.kunyomi,
    this.koHanja,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['char'] = Variable<String>(char);
    if (!nullToAbsent || rank != null) {
      map['rank'] = Variable<int>(rank);
    }
    if (!nullToAbsent || pct != null) {
      map['pct'] = Variable<double>(pct);
    }
    if (!nullToAbsent || jlpt != null) {
      map['jlpt'] = Variable<int>(jlpt);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    if (!nullToAbsent || strokes != null) {
      map['strokes'] = Variable<int>(strokes);
    }
    if (!nullToAbsent || meaningKo != null) {
      map['meaning_ko'] = Variable<String>(meaningKo);
    }
    if (!nullToAbsent || meaningsKoJson != null) {
      map['meanings_ko_json'] = Variable<String>(meaningsKoJson);
    }
    if (!nullToAbsent || meaningsEn != null) {
      map['meanings_en'] = Variable<String>(meaningsEn);
    }
    if (!nullToAbsent || onyomi != null) {
      map['onyomi'] = Variable<String>(onyomi);
    }
    if (!nullToAbsent || kunyomi != null) {
      map['kunyomi'] = Variable<String>(kunyomi);
    }
    if (!nullToAbsent || koHanja != null) {
      map['ko_hanja'] = Variable<String>(koHanja);
    }
    return map;
  }

  KanjiCompanion toCompanion(bool nullToAbsent) {
    return KanjiCompanion(
      char: Value(char),
      rank: rank == null && nullToAbsent ? const Value.absent() : Value(rank),
      pct: pct == null && nullToAbsent ? const Value.absent() : Value(pct),
      jlpt: jlpt == null && nullToAbsent ? const Value.absent() : Value(jlpt),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      strokes: strokes == null && nullToAbsent
          ? const Value.absent()
          : Value(strokes),
      meaningKo: meaningKo == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningKo),
      meaningsKoJson: meaningsKoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningsKoJson),
      meaningsEn: meaningsEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningsEn),
      onyomi: onyomi == null && nullToAbsent
          ? const Value.absent()
          : Value(onyomi),
      kunyomi: kunyomi == null && nullToAbsent
          ? const Value.absent()
          : Value(kunyomi),
      koHanja: koHanja == null && nullToAbsent
          ? const Value.absent()
          : Value(koHanja),
    );
  }

  factory KanjiRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiRow(
      char: serializer.fromJson<String>(json['char']),
      rank: serializer.fromJson<int?>(json['rank']),
      pct: serializer.fromJson<double?>(json['pct']),
      jlpt: serializer.fromJson<int?>(json['jlpt']),
      grade: serializer.fromJson<int?>(json['grade']),
      strokes: serializer.fromJson<int?>(json['strokes']),
      meaningKo: serializer.fromJson<String?>(json['meaningKo']),
      meaningsKoJson: serializer.fromJson<String?>(json['meaningsKoJson']),
      meaningsEn: serializer.fromJson<String?>(json['meaningsEn']),
      onyomi: serializer.fromJson<String?>(json['onyomi']),
      kunyomi: serializer.fromJson<String?>(json['kunyomi']),
      koHanja: serializer.fromJson<String?>(json['koHanja']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'char': serializer.toJson<String>(char),
      'rank': serializer.toJson<int?>(rank),
      'pct': serializer.toJson<double?>(pct),
      'jlpt': serializer.toJson<int?>(jlpt),
      'grade': serializer.toJson<int?>(grade),
      'strokes': serializer.toJson<int?>(strokes),
      'meaningKo': serializer.toJson<String?>(meaningKo),
      'meaningsKoJson': serializer.toJson<String?>(meaningsKoJson),
      'meaningsEn': serializer.toJson<String?>(meaningsEn),
      'onyomi': serializer.toJson<String?>(onyomi),
      'kunyomi': serializer.toJson<String?>(kunyomi),
      'koHanja': serializer.toJson<String?>(koHanja),
    };
  }

  KanjiRow copyWith({
    String? char,
    Value<int?> rank = const Value.absent(),
    Value<double?> pct = const Value.absent(),
    Value<int?> jlpt = const Value.absent(),
    Value<int?> grade = const Value.absent(),
    Value<int?> strokes = const Value.absent(),
    Value<String?> meaningKo = const Value.absent(),
    Value<String?> meaningsKoJson = const Value.absent(),
    Value<String?> meaningsEn = const Value.absent(),
    Value<String?> onyomi = const Value.absent(),
    Value<String?> kunyomi = const Value.absent(),
    Value<String?> koHanja = const Value.absent(),
  }) => KanjiRow(
    char: char ?? this.char,
    rank: rank.present ? rank.value : this.rank,
    pct: pct.present ? pct.value : this.pct,
    jlpt: jlpt.present ? jlpt.value : this.jlpt,
    grade: grade.present ? grade.value : this.grade,
    strokes: strokes.present ? strokes.value : this.strokes,
    meaningKo: meaningKo.present ? meaningKo.value : this.meaningKo,
    meaningsKoJson: meaningsKoJson.present
        ? meaningsKoJson.value
        : this.meaningsKoJson,
    meaningsEn: meaningsEn.present ? meaningsEn.value : this.meaningsEn,
    onyomi: onyomi.present ? onyomi.value : this.onyomi,
    kunyomi: kunyomi.present ? kunyomi.value : this.kunyomi,
    koHanja: koHanja.present ? koHanja.value : this.koHanja,
  );
  KanjiRow copyWithCompanion(KanjiCompanion data) {
    return KanjiRow(
      char: data.char.present ? data.char.value : this.char,
      rank: data.rank.present ? data.rank.value : this.rank,
      pct: data.pct.present ? data.pct.value : this.pct,
      jlpt: data.jlpt.present ? data.jlpt.value : this.jlpt,
      grade: data.grade.present ? data.grade.value : this.grade,
      strokes: data.strokes.present ? data.strokes.value : this.strokes,
      meaningKo: data.meaningKo.present ? data.meaningKo.value : this.meaningKo,
      meaningsKoJson: data.meaningsKoJson.present
          ? data.meaningsKoJson.value
          : this.meaningsKoJson,
      meaningsEn: data.meaningsEn.present
          ? data.meaningsEn.value
          : this.meaningsEn,
      onyomi: data.onyomi.present ? data.onyomi.value : this.onyomi,
      kunyomi: data.kunyomi.present ? data.kunyomi.value : this.kunyomi,
      koHanja: data.koHanja.present ? data.koHanja.value : this.koHanja,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiRow(')
          ..write('char: $char, ')
          ..write('rank: $rank, ')
          ..write('pct: $pct, ')
          ..write('jlpt: $jlpt, ')
          ..write('grade: $grade, ')
          ..write('strokes: $strokes, ')
          ..write('meaningKo: $meaningKo, ')
          ..write('meaningsKoJson: $meaningsKoJson, ')
          ..write('meaningsEn: $meaningsEn, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('koHanja: $koHanja')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    char,
    rank,
    pct,
    jlpt,
    grade,
    strokes,
    meaningKo,
    meaningsKoJson,
    meaningsEn,
    onyomi,
    kunyomi,
    koHanja,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiRow &&
          other.char == this.char &&
          other.rank == this.rank &&
          other.pct == this.pct &&
          other.jlpt == this.jlpt &&
          other.grade == this.grade &&
          other.strokes == this.strokes &&
          other.meaningKo == this.meaningKo &&
          other.meaningsKoJson == this.meaningsKoJson &&
          other.meaningsEn == this.meaningsEn &&
          other.onyomi == this.onyomi &&
          other.kunyomi == this.kunyomi &&
          other.koHanja == this.koHanja);
}

class KanjiCompanion extends UpdateCompanion<KanjiRow> {
  final Value<String> char;
  final Value<int?> rank;
  final Value<double?> pct;
  final Value<int?> jlpt;
  final Value<int?> grade;
  final Value<int?> strokes;
  final Value<String?> meaningKo;
  final Value<String?> meaningsKoJson;
  final Value<String?> meaningsEn;
  final Value<String?> onyomi;
  final Value<String?> kunyomi;
  final Value<String?> koHanja;
  final Value<int> rowid;
  const KanjiCompanion({
    this.char = const Value.absent(),
    this.rank = const Value.absent(),
    this.pct = const Value.absent(),
    this.jlpt = const Value.absent(),
    this.grade = const Value.absent(),
    this.strokes = const Value.absent(),
    this.meaningKo = const Value.absent(),
    this.meaningsKoJson = const Value.absent(),
    this.meaningsEn = const Value.absent(),
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.koHanja = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanjiCompanion.insert({
    required String char,
    this.rank = const Value.absent(),
    this.pct = const Value.absent(),
    this.jlpt = const Value.absent(),
    this.grade = const Value.absent(),
    this.strokes = const Value.absent(),
    this.meaningKo = const Value.absent(),
    this.meaningsKoJson = const Value.absent(),
    this.meaningsEn = const Value.absent(),
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.koHanja = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : char = Value(char);
  static Insertable<KanjiRow> custom({
    Expression<String>? char,
    Expression<int>? rank,
    Expression<double>? pct,
    Expression<int>? jlpt,
    Expression<int>? grade,
    Expression<int>? strokes,
    Expression<String>? meaningKo,
    Expression<String>? meaningsKoJson,
    Expression<String>? meaningsEn,
    Expression<String>? onyomi,
    Expression<String>? kunyomi,
    Expression<String>? koHanja,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (char != null) 'char': char,
      if (rank != null) 'rank': rank,
      if (pct != null) 'pct': pct,
      if (jlpt != null) 'jlpt': jlpt,
      if (grade != null) 'grade': grade,
      if (strokes != null) 'strokes': strokes,
      if (meaningKo != null) 'meaning_ko': meaningKo,
      if (meaningsKoJson != null) 'meanings_ko_json': meaningsKoJson,
      if (meaningsEn != null) 'meanings_en': meaningsEn,
      if (onyomi != null) 'onyomi': onyomi,
      if (kunyomi != null) 'kunyomi': kunyomi,
      if (koHanja != null) 'ko_hanja': koHanja,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanjiCompanion copyWith({
    Value<String>? char,
    Value<int?>? rank,
    Value<double?>? pct,
    Value<int?>? jlpt,
    Value<int?>? grade,
    Value<int?>? strokes,
    Value<String?>? meaningKo,
    Value<String?>? meaningsKoJson,
    Value<String?>? meaningsEn,
    Value<String?>? onyomi,
    Value<String?>? kunyomi,
    Value<String?>? koHanja,
    Value<int>? rowid,
  }) {
    return KanjiCompanion(
      char: char ?? this.char,
      rank: rank ?? this.rank,
      pct: pct ?? this.pct,
      jlpt: jlpt ?? this.jlpt,
      grade: grade ?? this.grade,
      strokes: strokes ?? this.strokes,
      meaningKo: meaningKo ?? this.meaningKo,
      meaningsKoJson: meaningsKoJson ?? this.meaningsKoJson,
      meaningsEn: meaningsEn ?? this.meaningsEn,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      koHanja: koHanja ?? this.koHanja,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (char.present) {
      map['char'] = Variable<String>(char.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (pct.present) {
      map['pct'] = Variable<double>(pct.value);
    }
    if (jlpt.present) {
      map['jlpt'] = Variable<int>(jlpt.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (strokes.present) {
      map['strokes'] = Variable<int>(strokes.value);
    }
    if (meaningKo.present) {
      map['meaning_ko'] = Variable<String>(meaningKo.value);
    }
    if (meaningsKoJson.present) {
      map['meanings_ko_json'] = Variable<String>(meaningsKoJson.value);
    }
    if (meaningsEn.present) {
      map['meanings_en'] = Variable<String>(meaningsEn.value);
    }
    if (onyomi.present) {
      map['onyomi'] = Variable<String>(onyomi.value);
    }
    if (kunyomi.present) {
      map['kunyomi'] = Variable<String>(kunyomi.value);
    }
    if (koHanja.present) {
      map['ko_hanja'] = Variable<String>(koHanja.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiCompanion(')
          ..write('char: $char, ')
          ..write('rank: $rank, ')
          ..write('pct: $pct, ')
          ..write('jlpt: $jlpt, ')
          ..write('grade: $grade, ')
          ..write('strokes: $strokes, ')
          ..write('meaningKo: $meaningKo, ')
          ..write('meaningsKoJson: $meaningsKoJson, ')
          ..write('meaningsEn: $meaningsEn, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('koHanja: $koHanja, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KanjiReadingsTable extends KanjiReadings
    with TableInfo<$KanjiReadingsTable, KanjiReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _charMeta = const VerificationMeta('char');
  @override
  late final GeneratedColumn<String> char = GeneratedColumn<String>(
    'char',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kanji (char)',
    ),
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseMeta = const VerificationMeta('base');
  @override
  late final GeneratedColumn<String> base = GeneratedColumn<String>(
    'base',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _glossMeta = const VerificationMeta('gloss');
  @override
  late final GeneratedColumn<String> gloss = GeneratedColumn<String>(
    'gloss',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, char, reading, base, kind, gloss];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiReadingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('char')) {
      context.handle(
        _charMeta,
        char.isAcceptableOrUnknown(data['char']!, _charMeta),
      );
    } else if (isInserting) {
      context.missing(_charMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('base')) {
      context.handle(
        _baseMeta,
        base.isAcceptableOrUnknown(data['base']!, _baseMeta),
      );
    } else if (isInserting) {
      context.missing(_baseMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('gloss')) {
      context.handle(
        _glossMeta,
        gloss.isAcceptableOrUnknown(data['gloss']!, _glossMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KanjiReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiReadingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      char: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      base: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      gloss: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gloss'],
      ),
    );
  }

  @override
  $KanjiReadingsTable createAlias(String alias) {
    return $KanjiReadingsTable(attachedDatabase, alias);
  }
}

class KanjiReadingRow extends DataClass implements Insertable<KanjiReadingRow> {
  final int id;
  final String char;
  final String reading;
  final String base;
  final String kind;
  final String? gloss;
  const KanjiReadingRow({
    required this.id,
    required this.char,
    required this.reading,
    required this.base,
    required this.kind,
    this.gloss,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['char'] = Variable<String>(char);
    map['reading'] = Variable<String>(reading);
    map['base'] = Variable<String>(base);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || gloss != null) {
      map['gloss'] = Variable<String>(gloss);
    }
    return map;
  }

  KanjiReadingsCompanion toCompanion(bool nullToAbsent) {
    return KanjiReadingsCompanion(
      id: Value(id),
      char: Value(char),
      reading: Value(reading),
      base: Value(base),
      kind: Value(kind),
      gloss: gloss == null && nullToAbsent
          ? const Value.absent()
          : Value(gloss),
    );
  }

  factory KanjiReadingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiReadingRow(
      id: serializer.fromJson<int>(json['id']),
      char: serializer.fromJson<String>(json['char']),
      reading: serializer.fromJson<String>(json['reading']),
      base: serializer.fromJson<String>(json['base']),
      kind: serializer.fromJson<String>(json['kind']),
      gloss: serializer.fromJson<String?>(json['gloss']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'char': serializer.toJson<String>(char),
      'reading': serializer.toJson<String>(reading),
      'base': serializer.toJson<String>(base),
      'kind': serializer.toJson<String>(kind),
      'gloss': serializer.toJson<String?>(gloss),
    };
  }

  KanjiReadingRow copyWith({
    int? id,
    String? char,
    String? reading,
    String? base,
    String? kind,
    Value<String?> gloss = const Value.absent(),
  }) => KanjiReadingRow(
    id: id ?? this.id,
    char: char ?? this.char,
    reading: reading ?? this.reading,
    base: base ?? this.base,
    kind: kind ?? this.kind,
    gloss: gloss.present ? gloss.value : this.gloss,
  );
  KanjiReadingRow copyWithCompanion(KanjiReadingsCompanion data) {
    return KanjiReadingRow(
      id: data.id.present ? data.id.value : this.id,
      char: data.char.present ? data.char.value : this.char,
      reading: data.reading.present ? data.reading.value : this.reading,
      base: data.base.present ? data.base.value : this.base,
      kind: data.kind.present ? data.kind.value : this.kind,
      gloss: data.gloss.present ? data.gloss.value : this.gloss,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiReadingRow(')
          ..write('id: $id, ')
          ..write('char: $char, ')
          ..write('reading: $reading, ')
          ..write('base: $base, ')
          ..write('kind: $kind, ')
          ..write('gloss: $gloss')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, char, reading, base, kind, gloss);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiReadingRow &&
          other.id == this.id &&
          other.char == this.char &&
          other.reading == this.reading &&
          other.base == this.base &&
          other.kind == this.kind &&
          other.gloss == this.gloss);
}

class KanjiReadingsCompanion extends UpdateCompanion<KanjiReadingRow> {
  final Value<int> id;
  final Value<String> char;
  final Value<String> reading;
  final Value<String> base;
  final Value<String> kind;
  final Value<String?> gloss;
  const KanjiReadingsCompanion({
    this.id = const Value.absent(),
    this.char = const Value.absent(),
    this.reading = const Value.absent(),
    this.base = const Value.absent(),
    this.kind = const Value.absent(),
    this.gloss = const Value.absent(),
  });
  KanjiReadingsCompanion.insert({
    this.id = const Value.absent(),
    required String char,
    required String reading,
    required String base,
    required String kind,
    this.gloss = const Value.absent(),
  }) : char = Value(char),
       reading = Value(reading),
       base = Value(base),
       kind = Value(kind);
  static Insertable<KanjiReadingRow> custom({
    Expression<int>? id,
    Expression<String>? char,
    Expression<String>? reading,
    Expression<String>? base,
    Expression<String>? kind,
    Expression<String>? gloss,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (char != null) 'char': char,
      if (reading != null) 'reading': reading,
      if (base != null) 'base': base,
      if (kind != null) 'kind': kind,
      if (gloss != null) 'gloss': gloss,
    });
  }

  KanjiReadingsCompanion copyWith({
    Value<int>? id,
    Value<String>? char,
    Value<String>? reading,
    Value<String>? base,
    Value<String>? kind,
    Value<String?>? gloss,
  }) {
    return KanjiReadingsCompanion(
      id: id ?? this.id,
      char: char ?? this.char,
      reading: reading ?? this.reading,
      base: base ?? this.base,
      kind: kind ?? this.kind,
      gloss: gloss ?? this.gloss,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (char.present) {
      map['char'] = Variable<String>(char.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (base.present) {
      map['base'] = Variable<String>(base.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (gloss.present) {
      map['gloss'] = Variable<String>(gloss.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiReadingsCompanion(')
          ..write('id: $id, ')
          ..write('char: $char, ')
          ..write('reading: $reading, ')
          ..write('base: $base, ')
          ..write('kind: $kind, ')
          ..write('gloss: $gloss')
          ..write(')'))
        .toString();
  }
}

class $JlptWordsTable extends JlptWords
    with TableInfo<$JlptWordsTable, JlptWordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JlptWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surfaceMeta = const VerificationMeta(
    'surface',
  );
  @override
  late final GeneratedColumn<String> surface = GeneratedColumn<String>(
    'surface',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kanaMeta = const VerificationMeta('kana');
  @override
  late final GeneratedColumn<String> kana = GeneratedColumn<String>(
    'kana',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jlptMeta = const VerificationMeta('jlpt');
  @override
  late final GeneratedColumn<int> jlpt = GeneratedColumn<int>(
    'jlpt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enMeta = const VerificationMeta('en');
  @override
  late final GeneratedColumn<String> en = GeneratedColumn<String>(
    'en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _koMeta = const VerificationMeta('ko');
  @override
  late final GeneratedColumn<String> ko = GeneratedColumn<String>(
    'ko',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _srcMeta = const VerificationMeta('src');
  @override
  late final GeneratedColumn<String> src = GeneratedColumn<String>(
    'src',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _segsJsonMeta = const VerificationMeta(
    'segsJson',
  );
  @override
  late final GeneratedColumn<String> segsJson = GeneratedColumn<String>(
    'segs_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surface,
    kana,
    jlpt,
    en,
    ko,
    rank,
    src,
    segsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jlpt_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<JlptWordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surface')) {
      context.handle(
        _surfaceMeta,
        surface.isAcceptableOrUnknown(data['surface']!, _surfaceMeta),
      );
    } else if (isInserting) {
      context.missing(_surfaceMeta);
    }
    if (data.containsKey('kana')) {
      context.handle(
        _kanaMeta,
        kana.isAcceptableOrUnknown(data['kana']!, _kanaMeta),
      );
    } else if (isInserting) {
      context.missing(_kanaMeta);
    }
    if (data.containsKey('jlpt')) {
      context.handle(
        _jlptMeta,
        jlpt.isAcceptableOrUnknown(data['jlpt']!, _jlptMeta),
      );
    }
    if (data.containsKey('en')) {
      context.handle(_enMeta, en.isAcceptableOrUnknown(data['en']!, _enMeta));
    }
    if (data.containsKey('ko')) {
      context.handle(_koMeta, ko.isAcceptableOrUnknown(data['ko']!, _koMeta));
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('src')) {
      context.handle(
        _srcMeta,
        src.isAcceptableOrUnknown(data['src']!, _srcMeta),
      );
    }
    if (data.containsKey('segs_json')) {
      context.handle(
        _segsJsonMeta,
        segsJson.isAcceptableOrUnknown(data['segs_json']!, _segsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JlptWordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JlptWordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surface: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface'],
      )!,
      kana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kana'],
      )!,
      jlpt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jlpt'],
      ),
      en: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}en'],
      ),
      ko: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ko'],
      ),
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      ),
      src: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src'],
      ),
      segsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segs_json'],
      ),
    );
  }

  @override
  $JlptWordsTable createAlias(String alias) {
    return $JlptWordsTable(attachedDatabase, alias);
  }
}

class JlptWordRow extends DataClass implements Insertable<JlptWordRow> {
  final int id;
  final String surface;
  final String kana;
  final int? jlpt;
  final String? en;
  final String? ko;
  final int? rank;
  final String? src;
  final String? segsJson;
  const JlptWordRow({
    required this.id,
    required this.surface,
    required this.kana,
    this.jlpt,
    this.en,
    this.ko,
    this.rank,
    this.src,
    this.segsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surface'] = Variable<String>(surface);
    map['kana'] = Variable<String>(kana);
    if (!nullToAbsent || jlpt != null) {
      map['jlpt'] = Variable<int>(jlpt);
    }
    if (!nullToAbsent || en != null) {
      map['en'] = Variable<String>(en);
    }
    if (!nullToAbsent || ko != null) {
      map['ko'] = Variable<String>(ko);
    }
    if (!nullToAbsent || rank != null) {
      map['rank'] = Variable<int>(rank);
    }
    if (!nullToAbsent || src != null) {
      map['src'] = Variable<String>(src);
    }
    if (!nullToAbsent || segsJson != null) {
      map['segs_json'] = Variable<String>(segsJson);
    }
    return map;
  }

  JlptWordsCompanion toCompanion(bool nullToAbsent) {
    return JlptWordsCompanion(
      id: Value(id),
      surface: Value(surface),
      kana: Value(kana),
      jlpt: jlpt == null && nullToAbsent ? const Value.absent() : Value(jlpt),
      en: en == null && nullToAbsent ? const Value.absent() : Value(en),
      ko: ko == null && nullToAbsent ? const Value.absent() : Value(ko),
      rank: rank == null && nullToAbsent ? const Value.absent() : Value(rank),
      src: src == null && nullToAbsent ? const Value.absent() : Value(src),
      segsJson: segsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(segsJson),
    );
  }

  factory JlptWordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JlptWordRow(
      id: serializer.fromJson<int>(json['id']),
      surface: serializer.fromJson<String>(json['surface']),
      kana: serializer.fromJson<String>(json['kana']),
      jlpt: serializer.fromJson<int?>(json['jlpt']),
      en: serializer.fromJson<String?>(json['en']),
      ko: serializer.fromJson<String?>(json['ko']),
      rank: serializer.fromJson<int?>(json['rank']),
      src: serializer.fromJson<String?>(json['src']),
      segsJson: serializer.fromJson<String?>(json['segsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surface': serializer.toJson<String>(surface),
      'kana': serializer.toJson<String>(kana),
      'jlpt': serializer.toJson<int?>(jlpt),
      'en': serializer.toJson<String?>(en),
      'ko': serializer.toJson<String?>(ko),
      'rank': serializer.toJson<int?>(rank),
      'src': serializer.toJson<String?>(src),
      'segsJson': serializer.toJson<String?>(segsJson),
    };
  }

  JlptWordRow copyWith({
    int? id,
    String? surface,
    String? kana,
    Value<int?> jlpt = const Value.absent(),
    Value<String?> en = const Value.absent(),
    Value<String?> ko = const Value.absent(),
    Value<int?> rank = const Value.absent(),
    Value<String?> src = const Value.absent(),
    Value<String?> segsJson = const Value.absent(),
  }) => JlptWordRow(
    id: id ?? this.id,
    surface: surface ?? this.surface,
    kana: kana ?? this.kana,
    jlpt: jlpt.present ? jlpt.value : this.jlpt,
    en: en.present ? en.value : this.en,
    ko: ko.present ? ko.value : this.ko,
    rank: rank.present ? rank.value : this.rank,
    src: src.present ? src.value : this.src,
    segsJson: segsJson.present ? segsJson.value : this.segsJson,
  );
  JlptWordRow copyWithCompanion(JlptWordsCompanion data) {
    return JlptWordRow(
      id: data.id.present ? data.id.value : this.id,
      surface: data.surface.present ? data.surface.value : this.surface,
      kana: data.kana.present ? data.kana.value : this.kana,
      jlpt: data.jlpt.present ? data.jlpt.value : this.jlpt,
      en: data.en.present ? data.en.value : this.en,
      ko: data.ko.present ? data.ko.value : this.ko,
      rank: data.rank.present ? data.rank.value : this.rank,
      src: data.src.present ? data.src.value : this.src,
      segsJson: data.segsJson.present ? data.segsJson.value : this.segsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JlptWordRow(')
          ..write('id: $id, ')
          ..write('surface: $surface, ')
          ..write('kana: $kana, ')
          ..write('jlpt: $jlpt, ')
          ..write('en: $en, ')
          ..write('ko: $ko, ')
          ..write('rank: $rank, ')
          ..write('src: $src, ')
          ..write('segsJson: $segsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, surface, kana, jlpt, en, ko, rank, src, segsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JlptWordRow &&
          other.id == this.id &&
          other.surface == this.surface &&
          other.kana == this.kana &&
          other.jlpt == this.jlpt &&
          other.en == this.en &&
          other.ko == this.ko &&
          other.rank == this.rank &&
          other.src == this.src &&
          other.segsJson == this.segsJson);
}

class JlptWordsCompanion extends UpdateCompanion<JlptWordRow> {
  final Value<int> id;
  final Value<String> surface;
  final Value<String> kana;
  final Value<int?> jlpt;
  final Value<String?> en;
  final Value<String?> ko;
  final Value<int?> rank;
  final Value<String?> src;
  final Value<String?> segsJson;
  const JlptWordsCompanion({
    this.id = const Value.absent(),
    this.surface = const Value.absent(),
    this.kana = const Value.absent(),
    this.jlpt = const Value.absent(),
    this.en = const Value.absent(),
    this.ko = const Value.absent(),
    this.rank = const Value.absent(),
    this.src = const Value.absent(),
    this.segsJson = const Value.absent(),
  });
  JlptWordsCompanion.insert({
    this.id = const Value.absent(),
    required String surface,
    required String kana,
    this.jlpt = const Value.absent(),
    this.en = const Value.absent(),
    this.ko = const Value.absent(),
    this.rank = const Value.absent(),
    this.src = const Value.absent(),
    this.segsJson = const Value.absent(),
  }) : surface = Value(surface),
       kana = Value(kana);
  static Insertable<JlptWordRow> custom({
    Expression<int>? id,
    Expression<String>? surface,
    Expression<String>? kana,
    Expression<int>? jlpt,
    Expression<String>? en,
    Expression<String>? ko,
    Expression<int>? rank,
    Expression<String>? src,
    Expression<String>? segsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surface != null) 'surface': surface,
      if (kana != null) 'kana': kana,
      if (jlpt != null) 'jlpt': jlpt,
      if (en != null) 'en': en,
      if (ko != null) 'ko': ko,
      if (rank != null) 'rank': rank,
      if (src != null) 'src': src,
      if (segsJson != null) 'segs_json': segsJson,
    });
  }

  JlptWordsCompanion copyWith({
    Value<int>? id,
    Value<String>? surface,
    Value<String>? kana,
    Value<int?>? jlpt,
    Value<String?>? en,
    Value<String?>? ko,
    Value<int?>? rank,
    Value<String?>? src,
    Value<String?>? segsJson,
  }) {
    return JlptWordsCompanion(
      id: id ?? this.id,
      surface: surface ?? this.surface,
      kana: kana ?? this.kana,
      jlpt: jlpt ?? this.jlpt,
      en: en ?? this.en,
      ko: ko ?? this.ko,
      rank: rank ?? this.rank,
      src: src ?? this.src,
      segsJson: segsJson ?? this.segsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surface.present) {
      map['surface'] = Variable<String>(surface.value);
    }
    if (kana.present) {
      map['kana'] = Variable<String>(kana.value);
    }
    if (jlpt.present) {
      map['jlpt'] = Variable<int>(jlpt.value);
    }
    if (en.present) {
      map['en'] = Variable<String>(en.value);
    }
    if (ko.present) {
      map['ko'] = Variable<String>(ko.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (src.present) {
      map['src'] = Variable<String>(src.value);
    }
    if (segsJson.present) {
      map['segs_json'] = Variable<String>(segsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JlptWordsCompanion(')
          ..write('id: $id, ')
          ..write('surface: $surface, ')
          ..write('kana: $kana, ')
          ..write('jlpt: $jlpt, ')
          ..write('en: $en, ')
          ..write('ko: $ko, ')
          ..write('rank: $rank, ')
          ..write('src: $src, ')
          ..write('segsJson: $segsJson')
          ..write(')'))
        .toString();
  }
}

class $WordSegmentsTable extends WordSegments
    with TableInfo<$WordSegmentsTable, WordSegmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jlpt_words (id)',
    ),
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segTextMeta = const VerificationMeta(
    'segText',
  );
  @override
  late final GeneratedColumn<String> segText = GeneratedColumn<String>(
    'seg_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _charMeta = const VerificationMeta('char');
  @override
  late final GeneratedColumn<String> char = GeneratedColumn<String>(
    'char',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    idx,
    segText,
    reading,
    char,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordSegmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('seg_text')) {
      context.handle(
        _segTextMeta,
        segText.isAcceptableOrUnknown(data['seg_text']!, _segTextMeta),
      );
    } else if (isInserting) {
      context.missing(_segTextMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    }
    if (data.containsKey('char')) {
      context.handle(
        _charMeta,
        char.isAcceptableOrUnknown(data['char']!, _charMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordSegmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordSegmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      segText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seg_text'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      ),
      char: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char'],
      ),
    );
  }

  @override
  $WordSegmentsTable createAlias(String alias) {
    return $WordSegmentsTable(attachedDatabase, alias);
  }
}

class WordSegmentRow extends DataClass implements Insertable<WordSegmentRow> {
  final int id;
  final int wordId;
  final int idx;
  final String segText;
  final String? reading;
  final String? char;
  const WordSegmentRow({
    required this.id,
    required this.wordId,
    required this.idx,
    required this.segText,
    this.reading,
    this.char,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['idx'] = Variable<int>(idx);
    map['seg_text'] = Variable<String>(segText);
    if (!nullToAbsent || reading != null) {
      map['reading'] = Variable<String>(reading);
    }
    if (!nullToAbsent || char != null) {
      map['char'] = Variable<String>(char);
    }
    return map;
  }

  WordSegmentsCompanion toCompanion(bool nullToAbsent) {
    return WordSegmentsCompanion(
      id: Value(id),
      wordId: Value(wordId),
      idx: Value(idx),
      segText: Value(segText),
      reading: reading == null && nullToAbsent
          ? const Value.absent()
          : Value(reading),
      char: char == null && nullToAbsent ? const Value.absent() : Value(char),
    );
  }

  factory WordSegmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordSegmentRow(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      idx: serializer.fromJson<int>(json['idx']),
      segText: serializer.fromJson<String>(json['segText']),
      reading: serializer.fromJson<String?>(json['reading']),
      char: serializer.fromJson<String?>(json['char']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'idx': serializer.toJson<int>(idx),
      'segText': serializer.toJson<String>(segText),
      'reading': serializer.toJson<String?>(reading),
      'char': serializer.toJson<String?>(char),
    };
  }

  WordSegmentRow copyWith({
    int? id,
    int? wordId,
    int? idx,
    String? segText,
    Value<String?> reading = const Value.absent(),
    Value<String?> char = const Value.absent(),
  }) => WordSegmentRow(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    idx: idx ?? this.idx,
    segText: segText ?? this.segText,
    reading: reading.present ? reading.value : this.reading,
    char: char.present ? char.value : this.char,
  );
  WordSegmentRow copyWithCompanion(WordSegmentsCompanion data) {
    return WordSegmentRow(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      idx: data.idx.present ? data.idx.value : this.idx,
      segText: data.segText.present ? data.segText.value : this.segText,
      reading: data.reading.present ? data.reading.value : this.reading,
      char: data.char.present ? data.char.value : this.char,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordSegmentRow(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('idx: $idx, ')
          ..write('segText: $segText, ')
          ..write('reading: $reading, ')
          ..write('char: $char')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, wordId, idx, segText, reading, char);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordSegmentRow &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.idx == this.idx &&
          other.segText == this.segText &&
          other.reading == this.reading &&
          other.char == this.char);
}

class WordSegmentsCompanion extends UpdateCompanion<WordSegmentRow> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<int> idx;
  final Value<String> segText;
  final Value<String?> reading;
  final Value<String?> char;
  const WordSegmentsCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.idx = const Value.absent(),
    this.segText = const Value.absent(),
    this.reading = const Value.absent(),
    this.char = const Value.absent(),
  });
  WordSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required int idx,
    required String segText,
    this.reading = const Value.absent(),
    this.char = const Value.absent(),
  }) : wordId = Value(wordId),
       idx = Value(idx),
       segText = Value(segText);
  static Insertable<WordSegmentRow> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<int>? idx,
    Expression<String>? segText,
    Expression<String>? reading,
    Expression<String>? char,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (idx != null) 'idx': idx,
      if (segText != null) 'seg_text': segText,
      if (reading != null) 'reading': reading,
      if (char != null) 'char': char,
    });
  }

  WordSegmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<int>? idx,
    Value<String>? segText,
    Value<String?>? reading,
    Value<String?>? char,
  }) {
    return WordSegmentsCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      idx: idx ?? this.idx,
      segText: segText ?? this.segText,
      reading: reading ?? this.reading,
      char: char ?? this.char,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (segText.present) {
      map['seg_text'] = Variable<String>(segText.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (char.present) {
      map['char'] = Variable<String>(char.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('idx: $idx, ')
          ..write('segText: $segText, ')
          ..write('reading: $reading, ')
          ..write('char: $char')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, WordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _freqMeta = const VerificationMeta('freq');
  @override
  late final GeneratedColumn<double> freq = GeneratedColumn<double>(
    'freq',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cumPctMeta = const VerificationMeta('cumPct');
  @override
  late final GeneratedColumn<double> cumPct = GeneratedColumn<double>(
    'cum_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [rank, word, freq, cumPct, region];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('freq')) {
      context.handle(
        _freqMeta,
        freq.isAcceptableOrUnknown(data['freq']!, _freqMeta),
      );
    }
    if (data.containsKey('cum_pct')) {
      context.handle(
        _cumPctMeta,
        cumPct.isAcceptableOrUnknown(data['cum_pct']!, _cumPctMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rank};
  @override
  WordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordRow(
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      freq: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}freq'],
      ),
      cumPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cum_pct'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class WordRow extends DataClass implements Insertable<WordRow> {
  final int rank;
  final String word;
  final double? freq;
  final double? cumPct;
  final String? region;
  const WordRow({
    required this.rank,
    required this.word,
    this.freq,
    this.cumPct,
    this.region,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rank'] = Variable<int>(rank);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || freq != null) {
      map['freq'] = Variable<double>(freq);
    }
    if (!nullToAbsent || cumPct != null) {
      map['cum_pct'] = Variable<double>(cumPct);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      rank: Value(rank),
      word: Value(word),
      freq: freq == null && nullToAbsent ? const Value.absent() : Value(freq),
      cumPct: cumPct == null && nullToAbsent
          ? const Value.absent()
          : Value(cumPct),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
    );
  }

  factory WordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordRow(
      rank: serializer.fromJson<int>(json['rank']),
      word: serializer.fromJson<String>(json['word']),
      freq: serializer.fromJson<double?>(json['freq']),
      cumPct: serializer.fromJson<double?>(json['cumPct']),
      region: serializer.fromJson<String?>(json['region']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rank': serializer.toJson<int>(rank),
      'word': serializer.toJson<String>(word),
      'freq': serializer.toJson<double?>(freq),
      'cumPct': serializer.toJson<double?>(cumPct),
      'region': serializer.toJson<String?>(region),
    };
  }

  WordRow copyWith({
    int? rank,
    String? word,
    Value<double?> freq = const Value.absent(),
    Value<double?> cumPct = const Value.absent(),
    Value<String?> region = const Value.absent(),
  }) => WordRow(
    rank: rank ?? this.rank,
    word: word ?? this.word,
    freq: freq.present ? freq.value : this.freq,
    cumPct: cumPct.present ? cumPct.value : this.cumPct,
    region: region.present ? region.value : this.region,
  );
  WordRow copyWithCompanion(WordsCompanion data) {
    return WordRow(
      rank: data.rank.present ? data.rank.value : this.rank,
      word: data.word.present ? data.word.value : this.word,
      freq: data.freq.present ? data.freq.value : this.freq,
      cumPct: data.cumPct.present ? data.cumPct.value : this.cumPct,
      region: data.region.present ? data.region.value : this.region,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordRow(')
          ..write('rank: $rank, ')
          ..write('word: $word, ')
          ..write('freq: $freq, ')
          ..write('cumPct: $cumPct, ')
          ..write('region: $region')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rank, word, freq, cumPct, region);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordRow &&
          other.rank == this.rank &&
          other.word == this.word &&
          other.freq == this.freq &&
          other.cumPct == this.cumPct &&
          other.region == this.region);
}

class WordsCompanion extends UpdateCompanion<WordRow> {
  final Value<int> rank;
  final Value<String> word;
  final Value<double?> freq;
  final Value<double?> cumPct;
  final Value<String?> region;
  const WordsCompanion({
    this.rank = const Value.absent(),
    this.word = const Value.absent(),
    this.freq = const Value.absent(),
    this.cumPct = const Value.absent(),
    this.region = const Value.absent(),
  });
  WordsCompanion.insert({
    this.rank = const Value.absent(),
    required String word,
    this.freq = const Value.absent(),
    this.cumPct = const Value.absent(),
    this.region = const Value.absent(),
  }) : word = Value(word);
  static Insertable<WordRow> custom({
    Expression<int>? rank,
    Expression<String>? word,
    Expression<double>? freq,
    Expression<double>? cumPct,
    Expression<String>? region,
  }) {
    return RawValuesInsertable({
      if (rank != null) 'rank': rank,
      if (word != null) 'word': word,
      if (freq != null) 'freq': freq,
      if (cumPct != null) 'cum_pct': cumPct,
      if (region != null) 'region': region,
    });
  }

  WordsCompanion copyWith({
    Value<int>? rank,
    Value<String>? word,
    Value<double?>? freq,
    Value<double?>? cumPct,
    Value<String?>? region,
  }) {
    return WordsCompanion(
      rank: rank ?? this.rank,
      word: word ?? this.word,
      freq: freq ?? this.freq,
      cumPct: cumPct ?? this.cumPct,
      region: region ?? this.region,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (freq.present) {
      map['freq'] = Variable<double>(freq.value);
    }
    if (cumPct.present) {
      map['cum_pct'] = Variable<double>(cumPct.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('rank: $rank, ')
          ..write('word: $word, ')
          ..write('freq: $freq, ')
          ..write('cumPct: $cumPct, ')
          ..write('region: $region')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, UserProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _turnIdMeta = const VerificationMeta('turnId');
  @override
  late final GeneratedColumn<int> turnId = GeneratedColumn<int>(
    'turn_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES turns (id)',
    ),
  );
  static const VerificationMeta _learnedMeta = const VerificationMeta(
    'learned',
  );
  @override
  late final GeneratedColumn<bool> learned = GeneratedColumn<bool>(
    'learned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("learned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastReviewedMeta = const VerificationMeta(
    'lastReviewed',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewed = GeneratedColumn<DateTime>(
    'last_reviewed',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    turnId,
    learned,
    favorite,
    lastReviewed,
    reviewCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('turn_id')) {
      context.handle(
        _turnIdMeta,
        turnId.isAcceptableOrUnknown(data['turn_id']!, _turnIdMeta),
      );
    }
    if (data.containsKey('learned')) {
      context.handle(
        _learnedMeta,
        learned.isAcceptableOrUnknown(data['learned']!, _learnedMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('last_reviewed')) {
      context.handle(
        _lastReviewedMeta,
        lastReviewed.isAcceptableOrUnknown(
          data['last_reviewed']!,
          _lastReviewedMeta,
        ),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {turnId};
  @override
  UserProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressRow(
      turnId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}turn_id'],
      )!,
      learned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}learned'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      lastReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed'],
      ),
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressRow extends DataClass implements Insertable<UserProgressRow> {
  final int turnId;
  final bool learned;
  final bool favorite;
  final DateTime? lastReviewed;
  final int reviewCount;
  const UserProgressRow({
    required this.turnId,
    required this.learned,
    required this.favorite,
    this.lastReviewed,
    required this.reviewCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['turn_id'] = Variable<int>(turnId);
    map['learned'] = Variable<bool>(learned);
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || lastReviewed != null) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed);
    }
    map['review_count'] = Variable<int>(reviewCount);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      turnId: Value(turnId),
      learned: Value(learned),
      favorite: Value(favorite),
      lastReviewed: lastReviewed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewed),
      reviewCount: Value(reviewCount),
    );
  }

  factory UserProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressRow(
      turnId: serializer.fromJson<int>(json['turnId']),
      learned: serializer.fromJson<bool>(json['learned']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      lastReviewed: serializer.fromJson<DateTime?>(json['lastReviewed']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'turnId': serializer.toJson<int>(turnId),
      'learned': serializer.toJson<bool>(learned),
      'favorite': serializer.toJson<bool>(favorite),
      'lastReviewed': serializer.toJson<DateTime?>(lastReviewed),
      'reviewCount': serializer.toJson<int>(reviewCount),
    };
  }

  UserProgressRow copyWith({
    int? turnId,
    bool? learned,
    bool? favorite,
    Value<DateTime?> lastReviewed = const Value.absent(),
    int? reviewCount,
  }) => UserProgressRow(
    turnId: turnId ?? this.turnId,
    learned: learned ?? this.learned,
    favorite: favorite ?? this.favorite,
    lastReviewed: lastReviewed.present ? lastReviewed.value : this.lastReviewed,
    reviewCount: reviewCount ?? this.reviewCount,
  );
  UserProgressRow copyWithCompanion(UserProgressCompanion data) {
    return UserProgressRow(
      turnId: data.turnId.present ? data.turnId.value : this.turnId,
      learned: data.learned.present ? data.learned.value : this.learned,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      lastReviewed: data.lastReviewed.present
          ? data.lastReviewed.value
          : this.lastReviewed,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressRow(')
          ..write('turnId: $turnId, ')
          ..write('learned: $learned, ')
          ..write('favorite: $favorite, ')
          ..write('lastReviewed: $lastReviewed, ')
          ..write('reviewCount: $reviewCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(turnId, learned, favorite, lastReviewed, reviewCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressRow &&
          other.turnId == this.turnId &&
          other.learned == this.learned &&
          other.favorite == this.favorite &&
          other.lastReviewed == this.lastReviewed &&
          other.reviewCount == this.reviewCount);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressRow> {
  final Value<int> turnId;
  final Value<bool> learned;
  final Value<bool> favorite;
  final Value<DateTime?> lastReviewed;
  final Value<int> reviewCount;
  const UserProgressCompanion({
    this.turnId = const Value.absent(),
    this.learned = const Value.absent(),
    this.favorite = const Value.absent(),
    this.lastReviewed = const Value.absent(),
    this.reviewCount = const Value.absent(),
  });
  UserProgressCompanion.insert({
    this.turnId = const Value.absent(),
    this.learned = const Value.absent(),
    this.favorite = const Value.absent(),
    this.lastReviewed = const Value.absent(),
    this.reviewCount = const Value.absent(),
  });
  static Insertable<UserProgressRow> custom({
    Expression<int>? turnId,
    Expression<bool>? learned,
    Expression<bool>? favorite,
    Expression<DateTime>? lastReviewed,
    Expression<int>? reviewCount,
  }) {
    return RawValuesInsertable({
      if (turnId != null) 'turn_id': turnId,
      if (learned != null) 'learned': learned,
      if (favorite != null) 'favorite': favorite,
      if (lastReviewed != null) 'last_reviewed': lastReviewed,
      if (reviewCount != null) 'review_count': reviewCount,
    });
  }

  UserProgressCompanion copyWith({
    Value<int>? turnId,
    Value<bool>? learned,
    Value<bool>? favorite,
    Value<DateTime?>? lastReviewed,
    Value<int>? reviewCount,
  }) {
    return UserProgressCompanion(
      turnId: turnId ?? this.turnId,
      learned: learned ?? this.learned,
      favorite: favorite ?? this.favorite,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (turnId.present) {
      map['turn_id'] = Variable<int>(turnId.value);
    }
    if (learned.present) {
      map['learned'] = Variable<bool>(learned.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (lastReviewed.present) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('turnId: $turnId, ')
          ..write('learned: $learned, ')
          ..write('favorite: $favorite, ')
          ..write('lastReviewed: $lastReviewed, ')
          ..write('reviewCount: $reviewCount')
          ..write(')'))
        .toString();
  }
}

class $KanjiProgressTable extends KanjiProgress
    with TableInfo<$KanjiProgressTable, KanjiProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _charMeta = const VerificationMeta('char');
  @override
  late final GeneratedColumn<String> char = GeneratedColumn<String>(
    'char',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kanji (char)',
    ),
  );
  static const VerificationMeta _knownMeta = const VerificationMeta('known');
  @override
  late final GeneratedColumn<bool> known = GeneratedColumn<bool>(
    'known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("known" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _exposureCountMeta = const VerificationMeta(
    'exposureCount',
  );
  @override
  late final GeneratedColumn<int> exposureCount = GeneratedColumn<int>(
    'exposure_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewedMeta = const VerificationMeta(
    'lastReviewed',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewed = GeneratedColumn<DateTime>(
    'last_reviewed',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    char,
    known,
    exposureCount,
    lastReviewed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('char')) {
      context.handle(
        _charMeta,
        char.isAcceptableOrUnknown(data['char']!, _charMeta),
      );
    } else if (isInserting) {
      context.missing(_charMeta);
    }
    if (data.containsKey('known')) {
      context.handle(
        _knownMeta,
        known.isAcceptableOrUnknown(data['known']!, _knownMeta),
      );
    }
    if (data.containsKey('exposure_count')) {
      context.handle(
        _exposureCountMeta,
        exposureCount.isAcceptableOrUnknown(
          data['exposure_count']!,
          _exposureCountMeta,
        ),
      );
    }
    if (data.containsKey('last_reviewed')) {
      context.handle(
        _lastReviewedMeta,
        lastReviewed.isAcceptableOrUnknown(
          data['last_reviewed']!,
          _lastReviewedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {char};
  @override
  KanjiProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiProgressRow(
      char: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char'],
      )!,
      known: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}known'],
      )!,
      exposureCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exposure_count'],
      )!,
      lastReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed'],
      ),
    );
  }

  @override
  $KanjiProgressTable createAlias(String alias) {
    return $KanjiProgressTable(attachedDatabase, alias);
  }
}

class KanjiProgressRow extends DataClass
    implements Insertable<KanjiProgressRow> {
  final String char;
  final bool known;
  final int exposureCount;
  final DateTime? lastReviewed;
  const KanjiProgressRow({
    required this.char,
    required this.known,
    required this.exposureCount,
    this.lastReviewed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['char'] = Variable<String>(char);
    map['known'] = Variable<bool>(known);
    map['exposure_count'] = Variable<int>(exposureCount);
    if (!nullToAbsent || lastReviewed != null) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed);
    }
    return map;
  }

  KanjiProgressCompanion toCompanion(bool nullToAbsent) {
    return KanjiProgressCompanion(
      char: Value(char),
      known: Value(known),
      exposureCount: Value(exposureCount),
      lastReviewed: lastReviewed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewed),
    );
  }

  factory KanjiProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiProgressRow(
      char: serializer.fromJson<String>(json['char']),
      known: serializer.fromJson<bool>(json['known']),
      exposureCount: serializer.fromJson<int>(json['exposureCount']),
      lastReviewed: serializer.fromJson<DateTime?>(json['lastReviewed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'char': serializer.toJson<String>(char),
      'known': serializer.toJson<bool>(known),
      'exposureCount': serializer.toJson<int>(exposureCount),
      'lastReviewed': serializer.toJson<DateTime?>(lastReviewed),
    };
  }

  KanjiProgressRow copyWith({
    String? char,
    bool? known,
    int? exposureCount,
    Value<DateTime?> lastReviewed = const Value.absent(),
  }) => KanjiProgressRow(
    char: char ?? this.char,
    known: known ?? this.known,
    exposureCount: exposureCount ?? this.exposureCount,
    lastReviewed: lastReviewed.present ? lastReviewed.value : this.lastReviewed,
  );
  KanjiProgressRow copyWithCompanion(KanjiProgressCompanion data) {
    return KanjiProgressRow(
      char: data.char.present ? data.char.value : this.char,
      known: data.known.present ? data.known.value : this.known,
      exposureCount: data.exposureCount.present
          ? data.exposureCount.value
          : this.exposureCount,
      lastReviewed: data.lastReviewed.present
          ? data.lastReviewed.value
          : this.lastReviewed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiProgressRow(')
          ..write('char: $char, ')
          ..write('known: $known, ')
          ..write('exposureCount: $exposureCount, ')
          ..write('lastReviewed: $lastReviewed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(char, known, exposureCount, lastReviewed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiProgressRow &&
          other.char == this.char &&
          other.known == this.known &&
          other.exposureCount == this.exposureCount &&
          other.lastReviewed == this.lastReviewed);
}

class KanjiProgressCompanion extends UpdateCompanion<KanjiProgressRow> {
  final Value<String> char;
  final Value<bool> known;
  final Value<int> exposureCount;
  final Value<DateTime?> lastReviewed;
  final Value<int> rowid;
  const KanjiProgressCompanion({
    this.char = const Value.absent(),
    this.known = const Value.absent(),
    this.exposureCount = const Value.absent(),
    this.lastReviewed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanjiProgressCompanion.insert({
    required String char,
    this.known = const Value.absent(),
    this.exposureCount = const Value.absent(),
    this.lastReviewed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : char = Value(char);
  static Insertable<KanjiProgressRow> custom({
    Expression<String>? char,
    Expression<bool>? known,
    Expression<int>? exposureCount,
    Expression<DateTime>? lastReviewed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (char != null) 'char': char,
      if (known != null) 'known': known,
      if (exposureCount != null) 'exposure_count': exposureCount,
      if (lastReviewed != null) 'last_reviewed': lastReviewed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanjiProgressCompanion copyWith({
    Value<String>? char,
    Value<bool>? known,
    Value<int>? exposureCount,
    Value<DateTime?>? lastReviewed,
    Value<int>? rowid,
  }) {
    return KanjiProgressCompanion(
      char: char ?? this.char,
      known: known ?? this.known,
      exposureCount: exposureCount ?? this.exposureCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (char.present) {
      map['char'] = Variable<String>(char.value);
    }
    if (known.present) {
      map['known'] = Variable<bool>(known.value);
    }
    if (exposureCount.present) {
      map['exposure_count'] = Variable<int>(exposureCount.value);
    }
    if (lastReviewed.present) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiProgressCompanion(')
          ..write('char: $char, ')
          ..write('known: $known, ')
          ..write('exposureCount: $exposureCount, ')
          ..write('lastReviewed: $lastReviewed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StageResultsTable extends StageResults
    with TableInfo<$StageResultsTable, StageResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StageResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<int> stage = GeneratedColumn<int>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestPctMeta = const VerificationMeta(
    'bestPct',
  );
  @override
  late final GeneratedColumn<int> bestPct = GeneratedColumn<int>(
    'best_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stage,
    correct,
    total,
    bestPct,
    lastPlayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stage_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<StageResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('best_pct')) {
      context.handle(
        _bestPctMeta,
        bestPct.isAcceptableOrUnknown(data['best_pct']!, _bestPctMeta),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stage};
  @override
  StageResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StageResultRow(
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stage'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      bestPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_pct'],
      )!,
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
    );
  }

  @override
  $StageResultsTable createAlias(String alias) {
    return $StageResultsTable(attachedDatabase, alias);
  }
}

class StageResultRow extends DataClass implements Insertable<StageResultRow> {
  final int stage;
  final int correct;
  final int total;
  final int bestPct;
  final DateTime? lastPlayed;
  const StageResultRow({
    required this.stage,
    required this.correct,
    required this.total,
    required this.bestPct,
    this.lastPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stage'] = Variable<int>(stage);
    map['correct'] = Variable<int>(correct);
    map['total'] = Variable<int>(total);
    map['best_pct'] = Variable<int>(bestPct);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    return map;
  }

  StageResultsCompanion toCompanion(bool nullToAbsent) {
    return StageResultsCompanion(
      stage: Value(stage),
      correct: Value(correct),
      total: Value(total),
      bestPct: Value(bestPct),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
    );
  }

  factory StageResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StageResultRow(
      stage: serializer.fromJson<int>(json['stage']),
      correct: serializer.fromJson<int>(json['correct']),
      total: serializer.fromJson<int>(json['total']),
      bestPct: serializer.fromJson<int>(json['bestPct']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stage': serializer.toJson<int>(stage),
      'correct': serializer.toJson<int>(correct),
      'total': serializer.toJson<int>(total),
      'bestPct': serializer.toJson<int>(bestPct),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
    };
  }

  StageResultRow copyWith({
    int? stage,
    int? correct,
    int? total,
    int? bestPct,
    Value<DateTime?> lastPlayed = const Value.absent(),
  }) => StageResultRow(
    stage: stage ?? this.stage,
    correct: correct ?? this.correct,
    total: total ?? this.total,
    bestPct: bestPct ?? this.bestPct,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
  );
  StageResultRow copyWithCompanion(StageResultsCompanion data) {
    return StageResultRow(
      stage: data.stage.present ? data.stage.value : this.stage,
      correct: data.correct.present ? data.correct.value : this.correct,
      total: data.total.present ? data.total.value : this.total,
      bestPct: data.bestPct.present ? data.bestPct.value : this.bestPct,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StageResultRow(')
          ..write('stage: $stage, ')
          ..write('correct: $correct, ')
          ..write('total: $total, ')
          ..write('bestPct: $bestPct, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stage, correct, total, bestPct, lastPlayed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StageResultRow &&
          other.stage == this.stage &&
          other.correct == this.correct &&
          other.total == this.total &&
          other.bestPct == this.bestPct &&
          other.lastPlayed == this.lastPlayed);
}

class StageResultsCompanion extends UpdateCompanion<StageResultRow> {
  final Value<int> stage;
  final Value<int> correct;
  final Value<int> total;
  final Value<int> bestPct;
  final Value<DateTime?> lastPlayed;
  const StageResultsCompanion({
    this.stage = const Value.absent(),
    this.correct = const Value.absent(),
    this.total = const Value.absent(),
    this.bestPct = const Value.absent(),
    this.lastPlayed = const Value.absent(),
  });
  StageResultsCompanion.insert({
    this.stage = const Value.absent(),
    this.correct = const Value.absent(),
    this.total = const Value.absent(),
    this.bestPct = const Value.absent(),
    this.lastPlayed = const Value.absent(),
  });
  static Insertable<StageResultRow> custom({
    Expression<int>? stage,
    Expression<int>? correct,
    Expression<int>? total,
    Expression<int>? bestPct,
    Expression<DateTime>? lastPlayed,
  }) {
    return RawValuesInsertable({
      if (stage != null) 'stage': stage,
      if (correct != null) 'correct': correct,
      if (total != null) 'total': total,
      if (bestPct != null) 'best_pct': bestPct,
      if (lastPlayed != null) 'last_played': lastPlayed,
    });
  }

  StageResultsCompanion copyWith({
    Value<int>? stage,
    Value<int>? correct,
    Value<int>? total,
    Value<int>? bestPct,
    Value<DateTime?>? lastPlayed,
  }) {
    return StageResultsCompanion(
      stage: stage ?? this.stage,
      correct: correct ?? this.correct,
      total: total ?? this.total,
      bestPct: bestPct ?? this.bestPct,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stage.present) {
      map['stage'] = Variable<int>(stage.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (bestPct.present) {
      map['best_pct'] = Variable<int>(bestPct.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StageResultsCompanion(')
          ..write('stage: $stage, ')
          ..write('correct: $correct, ')
          ..write('total: $total, ')
          ..write('bestPct: $bestPct, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }
}

class $UserMemosTable extends UserMemos
    with TableInfo<$UserMemosTable, UserMemoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMemosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, context, body, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_memos';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMemoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserMemoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMemoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserMemosTable createAlias(String alias) {
    return $UserMemosTable(attachedDatabase, alias);
  }
}

class UserMemoRow extends DataClass implements Insertable<UserMemoRow> {
  final int id;
  final String context;
  final String body;
  final DateTime createdAt;
  const UserMemoRow({
    required this.id,
    required this.context,
    required this.body,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['context'] = Variable<String>(context);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserMemosCompanion toCompanion(bool nullToAbsent) {
    return UserMemosCompanion(
      id: Value(id),
      context: Value(context),
      body: Value(body),
      createdAt: Value(createdAt),
    );
  }

  factory UserMemoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMemoRow(
      id: serializer.fromJson<int>(json['id']),
      context: serializer.fromJson<String>(json['context']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'context': serializer.toJson<String>(context),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserMemoRow copyWith({
    int? id,
    String? context,
    String? body,
    DateTime? createdAt,
  }) => UserMemoRow(
    id: id ?? this.id,
    context: context ?? this.context,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
  );
  UserMemoRow copyWithCompanion(UserMemosCompanion data) {
    return UserMemoRow(
      id: data.id.present ? data.id.value : this.id,
      context: data.context.present ? data.context.value : this.context,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMemoRow(')
          ..write('id: $id, ')
          ..write('context: $context, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, context, body, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMemoRow &&
          other.id == this.id &&
          other.context == this.context &&
          other.body == this.body &&
          other.createdAt == this.createdAt);
}

class UserMemosCompanion extends UpdateCompanion<UserMemoRow> {
  final Value<int> id;
  final Value<String> context;
  final Value<String> body;
  final Value<DateTime> createdAt;
  const UserMemosCompanion({
    this.id = const Value.absent(),
    this.context = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserMemosCompanion.insert({
    this.id = const Value.absent(),
    required String context,
    required String body,
    this.createdAt = const Value.absent(),
  }) : context = Value(context),
       body = Value(body);
  static Insertable<UserMemoRow> custom({
    Expression<int>? id,
    Expression<String>? context,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (context != null) 'context': context,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserMemosCompanion copyWith({
    Value<int>? id,
    Value<String>? context,
    Value<String>? body,
    Value<DateTime>? createdAt,
  }) {
    return UserMemosCompanion(
      id: id ?? this.id,
      context: context ?? this.context,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMemosCompanion(')
          ..write('id: $id, ')
          ..write('context: $context, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TurnsTable turns = $TurnsTable(this);
  late final $KanjiTable kanji = $KanjiTable(this);
  late final $KanjiReadingsTable kanjiReadings = $KanjiReadingsTable(this);
  late final $JlptWordsTable jlptWords = $JlptWordsTable(this);
  late final $WordSegmentsTable wordSegments = $WordSegmentsTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $KanjiProgressTable kanjiProgress = $KanjiProgressTable(this);
  late final $StageResultsTable stageResults = $StageResultsTable(this);
  late final $UserMemosTable userMemos = $UserMemosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    turns,
    kanji,
    kanjiReadings,
    jlptWords,
    wordSegments,
    words,
    userProgress,
    kanjiProgress,
    stageResults,
    userMemos,
  ];
}

typedef $$TurnsTableCreateCompanionBuilder =
    TurnsCompanion Function({
      Value<int> id,
      required String level,
      Value<String> dialect,
      Value<String?> episodeId,
      required int num,
      required String speaker,
      required String ja,
      Value<String?> kana,
      Value<String?> romaji,
      Value<String?> ko,
      Value<String?> note,
      Value<String?> tagsJson,
    });
typedef $$TurnsTableUpdateCompanionBuilder =
    TurnsCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> dialect,
      Value<String?> episodeId,
      Value<int> num,
      Value<String> speaker,
      Value<String> ja,
      Value<String?> kana,
      Value<String?> romaji,
      Value<String?> ko,
      Value<String?> note,
      Value<String?> tagsJson,
    });

final class $$TurnsTableReferences
    extends BaseReferences<_$AppDatabase, $TurnsTable, TurnRow> {
  $$TurnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProgressTable, List<UserProgressRow>>
  _userProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProgress,
    aliasName: $_aliasNameGenerator(db.turns.id, db.userProgress.turnId),
  );

  $$UserProgressTableProcessedTableManager get userProgressRefs {
    final manager = $$UserProgressTableTableManager(
      $_db,
      $_db.userProgress,
    ).filter((f) => f.turnId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TurnsTableFilterComposer extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dialect => $composableBuilder(
    column: $table.dialect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get num => $composableBuilder(
    column: $table.num,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ja => $composableBuilder(
    column: $table.ja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get romaji => $composableBuilder(
    column: $table.romaji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ko => $composableBuilder(
    column: $table.ko,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userProgressRefs(
    Expression<bool> Function($$UserProgressTableFilterComposer f) f,
  ) {
    final $$UserProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgress,
      getReferencedColumn: (t) => t.turnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgressTableFilterComposer(
            $db: $db,
            $table: $db.userProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dialect => $composableBuilder(
    column: $table.dialect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get num => $composableBuilder(
    column: $table.num,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speaker => $composableBuilder(
    column: $table.speaker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ja => $composableBuilder(
    column: $table.ja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get romaji => $composableBuilder(
    column: $table.romaji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ko => $composableBuilder(
    column: $table.ko,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get dialect =>
      $composableBuilder(column: $table.dialect, builder: (column) => column);

  GeneratedColumn<String> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<int> get num =>
      $composableBuilder(column: $table.num, builder: (column) => column);

  GeneratedColumn<String> get speaker =>
      $composableBuilder(column: $table.speaker, builder: (column) => column);

  GeneratedColumn<String> get ja =>
      $composableBuilder(column: $table.ja, builder: (column) => column);

  GeneratedColumn<String> get kana =>
      $composableBuilder(column: $table.kana, builder: (column) => column);

  GeneratedColumn<String> get romaji =>
      $composableBuilder(column: $table.romaji, builder: (column) => column);

  GeneratedColumn<String> get ko =>
      $composableBuilder(column: $table.ko, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  Expression<T> userProgressRefs<T extends Object>(
    Expression<T> Function($$UserProgressTableAnnotationComposer a) f,
  ) {
    final $$UserProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgress,
      getReferencedColumn: (t) => t.turnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TurnsTable,
          TurnRow,
          $$TurnsTableFilterComposer,
          $$TurnsTableOrderingComposer,
          $$TurnsTableAnnotationComposer,
          $$TurnsTableCreateCompanionBuilder,
          $$TurnsTableUpdateCompanionBuilder,
          (TurnRow, $$TurnsTableReferences),
          TurnRow,
          PrefetchHooks Function({bool userProgressRefs})
        > {
  $$TurnsTableTableManager(_$AppDatabase db, $TurnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> dialect = const Value.absent(),
                Value<String?> episodeId = const Value.absent(),
                Value<int> num = const Value.absent(),
                Value<String> speaker = const Value.absent(),
                Value<String> ja = const Value.absent(),
                Value<String?> kana = const Value.absent(),
                Value<String?> romaji = const Value.absent(),
                Value<String?> ko = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tagsJson = const Value.absent(),
              }) => TurnsCompanion(
                id: id,
                level: level,
                dialect: dialect,
                episodeId: episodeId,
                num: num,
                speaker: speaker,
                ja: ja,
                kana: kana,
                romaji: romaji,
                ko: ko,
                note: note,
                tagsJson: tagsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                Value<String> dialect = const Value.absent(),
                Value<String?> episodeId = const Value.absent(),
                required int num,
                required String speaker,
                required String ja,
                Value<String?> kana = const Value.absent(),
                Value<String?> romaji = const Value.absent(),
                Value<String?> ko = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tagsJson = const Value.absent(),
              }) => TurnsCompanion.insert(
                id: id,
                level: level,
                dialect: dialect,
                episodeId: episodeId,
                num: num,
                speaker: speaker,
                ja: ja,
                kana: kana,
                romaji: romaji,
                ko: ko,
                note: note,
                tagsJson: tagsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TurnsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({userProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userProgressRefs) db.userProgress],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userProgressRefs)
                    await $_getPrefetchedData<
                      TurnRow,
                      $TurnsTable,
                      UserProgressRow
                    >(
                      currentTable: table,
                      referencedTable: $$TurnsTableReferences
                          ._userProgressRefsTable(db),
                      managerFromTypedResult: (p0) => $$TurnsTableReferences(
                        db,
                        table,
                        p0,
                      ).userProgressRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.turnId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TurnsTable,
      TurnRow,
      $$TurnsTableFilterComposer,
      $$TurnsTableOrderingComposer,
      $$TurnsTableAnnotationComposer,
      $$TurnsTableCreateCompanionBuilder,
      $$TurnsTableUpdateCompanionBuilder,
      (TurnRow, $$TurnsTableReferences),
      TurnRow,
      PrefetchHooks Function({bool userProgressRefs})
    >;
typedef $$KanjiTableCreateCompanionBuilder =
    KanjiCompanion Function({
      required String char,
      Value<int?> rank,
      Value<double?> pct,
      Value<int?> jlpt,
      Value<int?> grade,
      Value<int?> strokes,
      Value<String?> meaningKo,
      Value<String?> meaningsKoJson,
      Value<String?> meaningsEn,
      Value<String?> onyomi,
      Value<String?> kunyomi,
      Value<String?> koHanja,
      Value<int> rowid,
    });
typedef $$KanjiTableUpdateCompanionBuilder =
    KanjiCompanion Function({
      Value<String> char,
      Value<int?> rank,
      Value<double?> pct,
      Value<int?> jlpt,
      Value<int?> grade,
      Value<int?> strokes,
      Value<String?> meaningKo,
      Value<String?> meaningsKoJson,
      Value<String?> meaningsEn,
      Value<String?> onyomi,
      Value<String?> kunyomi,
      Value<String?> koHanja,
      Value<int> rowid,
    });

final class $$KanjiTableReferences
    extends BaseReferences<_$AppDatabase, $KanjiTable, KanjiRow> {
  $$KanjiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$KanjiReadingsTable, List<KanjiReadingRow>>
  _kanjiReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.kanjiReadings,
    aliasName: $_aliasNameGenerator(db.kanji.char, db.kanjiReadings.char),
  );

  $$KanjiReadingsTableProcessedTableManager get kanjiReadingsRefs {
    final manager = $$KanjiReadingsTableTableManager(
      $_db,
      $_db.kanjiReadings,
    ).filter((f) => f.char.char.sqlEquals($_itemColumn<String>('char')!));

    final cache = $_typedResult.readTableOrNull(_kanjiReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$KanjiProgressTable, List<KanjiProgressRow>>
  _kanjiProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.kanjiProgress,
    aliasName: $_aliasNameGenerator(db.kanji.char, db.kanjiProgress.char),
  );

  $$KanjiProgressTableProcessedTableManager get kanjiProgressRefs {
    final manager = $$KanjiProgressTableTableManager(
      $_db,
      $_db.kanjiProgress,
    ).filter((f) => f.char.char.sqlEquals($_itemColumn<String>('char')!));

    final cache = $_typedResult.readTableOrNull(_kanjiProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$KanjiTableFilterComposer extends Composer<_$AppDatabase, $KanjiTable> {
  $$KanjiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlpt => $composableBuilder(
    column: $table.jlpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokes => $composableBuilder(
    column: $table.strokes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningKo => $composableBuilder(
    column: $table.meaningKo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningsKoJson => $composableBuilder(
    column: $table.meaningsKoJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningsEn => $composableBuilder(
    column: $table.meaningsEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get koHanja => $composableBuilder(
    column: $table.koHanja,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> kanjiReadingsRefs(
    Expression<bool> Function($$KanjiReadingsTableFilterComposer f) f,
  ) {
    final $$KanjiReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanjiReadings,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiReadingsTableFilterComposer(
            $db: $db,
            $table: $db.kanjiReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> kanjiProgressRefs(
    Expression<bool> Function($$KanjiProgressTableFilterComposer f) f,
  ) {
    final $$KanjiProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanjiProgress,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiProgressTableFilterComposer(
            $db: $db,
            $table: $db.kanjiProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KanjiTableOrderingComposer
    extends Composer<_$AppDatabase, $KanjiTable> {
  $$KanjiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pct => $composableBuilder(
    column: $table.pct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlpt => $composableBuilder(
    column: $table.jlpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokes => $composableBuilder(
    column: $table.strokes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningKo => $composableBuilder(
    column: $table.meaningKo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningsKoJson => $composableBuilder(
    column: $table.meaningsKoJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningsEn => $composableBuilder(
    column: $table.meaningsEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get koHanja => $composableBuilder(
    column: $table.koHanja,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanjiTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanjiTable> {
  $$KanjiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get char =>
      $composableBuilder(column: $table.char, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<double> get pct =>
      $composableBuilder(column: $table.pct, builder: (column) => column);

  GeneratedColumn<int> get jlpt =>
      $composableBuilder(column: $table.jlpt, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get strokes =>
      $composableBuilder(column: $table.strokes, builder: (column) => column);

  GeneratedColumn<String> get meaningKo =>
      $composableBuilder(column: $table.meaningKo, builder: (column) => column);

  GeneratedColumn<String> get meaningsKoJson => $composableBuilder(
    column: $table.meaningsKoJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaningsEn => $composableBuilder(
    column: $table.meaningsEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onyomi =>
      $composableBuilder(column: $table.onyomi, builder: (column) => column);

  GeneratedColumn<String> get kunyomi =>
      $composableBuilder(column: $table.kunyomi, builder: (column) => column);

  GeneratedColumn<String> get koHanja =>
      $composableBuilder(column: $table.koHanja, builder: (column) => column);

  Expression<T> kanjiReadingsRefs<T extends Object>(
    Expression<T> Function($$KanjiReadingsTableAnnotationComposer a) f,
  ) {
    final $$KanjiReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanjiReadings,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.kanjiReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> kanjiProgressRefs<T extends Object>(
    Expression<T> Function($$KanjiProgressTableAnnotationComposer a) f,
  ) {
    final $$KanjiProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanjiProgress,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.kanjiProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KanjiTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanjiTable,
          KanjiRow,
          $$KanjiTableFilterComposer,
          $$KanjiTableOrderingComposer,
          $$KanjiTableAnnotationComposer,
          $$KanjiTableCreateCompanionBuilder,
          $$KanjiTableUpdateCompanionBuilder,
          (KanjiRow, $$KanjiTableReferences),
          KanjiRow,
          PrefetchHooks Function({
            bool kanjiReadingsRefs,
            bool kanjiProgressRefs,
          })
        > {
  $$KanjiTableTableManager(_$AppDatabase db, $KanjiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> char = const Value.absent(),
                Value<int?> rank = const Value.absent(),
                Value<double?> pct = const Value.absent(),
                Value<int?> jlpt = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<int?> strokes = const Value.absent(),
                Value<String?> meaningKo = const Value.absent(),
                Value<String?> meaningsKoJson = const Value.absent(),
                Value<String?> meaningsEn = const Value.absent(),
                Value<String?> onyomi = const Value.absent(),
                Value<String?> kunyomi = const Value.absent(),
                Value<String?> koHanja = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiCompanion(
                char: char,
                rank: rank,
                pct: pct,
                jlpt: jlpt,
                grade: grade,
                strokes: strokes,
                meaningKo: meaningKo,
                meaningsKoJson: meaningsKoJson,
                meaningsEn: meaningsEn,
                onyomi: onyomi,
                kunyomi: kunyomi,
                koHanja: koHanja,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String char,
                Value<int?> rank = const Value.absent(),
                Value<double?> pct = const Value.absent(),
                Value<int?> jlpt = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<int?> strokes = const Value.absent(),
                Value<String?> meaningKo = const Value.absent(),
                Value<String?> meaningsKoJson = const Value.absent(),
                Value<String?> meaningsEn = const Value.absent(),
                Value<String?> onyomi = const Value.absent(),
                Value<String?> kunyomi = const Value.absent(),
                Value<String?> koHanja = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiCompanion.insert(
                char: char,
                rank: rank,
                pct: pct,
                jlpt: jlpt,
                grade: grade,
                strokes: strokes,
                meaningKo: meaningKo,
                meaningsKoJson: meaningsKoJson,
                meaningsEn: meaningsEn,
                onyomi: onyomi,
                kunyomi: kunyomi,
                koHanja: koHanja,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$KanjiTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({kanjiReadingsRefs = false, kanjiProgressRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (kanjiReadingsRefs) db.kanjiReadings,
                    if (kanjiProgressRefs) db.kanjiProgress,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (kanjiReadingsRefs)
                        await $_getPrefetchedData<
                          KanjiRow,
                          $KanjiTable,
                          KanjiReadingRow
                        >(
                          currentTable: table,
                          referencedTable: $$KanjiTableReferences
                              ._kanjiReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KanjiTableReferences(
                                db,
                                table,
                                p0,
                              ).kanjiReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.char == item.char,
                              ),
                          typedResults: items,
                        ),
                      if (kanjiProgressRefs)
                        await $_getPrefetchedData<
                          KanjiRow,
                          $KanjiTable,
                          KanjiProgressRow
                        >(
                          currentTable: table,
                          referencedTable: $$KanjiTableReferences
                              ._kanjiProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KanjiTableReferences(
                                db,
                                table,
                                p0,
                              ).kanjiProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.char == item.char,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$KanjiTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanjiTable,
      KanjiRow,
      $$KanjiTableFilterComposer,
      $$KanjiTableOrderingComposer,
      $$KanjiTableAnnotationComposer,
      $$KanjiTableCreateCompanionBuilder,
      $$KanjiTableUpdateCompanionBuilder,
      (KanjiRow, $$KanjiTableReferences),
      KanjiRow,
      PrefetchHooks Function({bool kanjiReadingsRefs, bool kanjiProgressRefs})
    >;
typedef $$KanjiReadingsTableCreateCompanionBuilder =
    KanjiReadingsCompanion Function({
      Value<int> id,
      required String char,
      required String reading,
      required String base,
      required String kind,
      Value<String?> gloss,
    });
typedef $$KanjiReadingsTableUpdateCompanionBuilder =
    KanjiReadingsCompanion Function({
      Value<int> id,
      Value<String> char,
      Value<String> reading,
      Value<String> base,
      Value<String> kind,
      Value<String?> gloss,
    });

final class $$KanjiReadingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $KanjiReadingsTable, KanjiReadingRow> {
  $$KanjiReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $KanjiTable _charTable(_$AppDatabase db) => db.kanji.createAlias(
    $_aliasNameGenerator(db.kanjiReadings.char, db.kanji.char),
  );

  $$KanjiTableProcessedTableManager get char {
    final $_column = $_itemColumn<String>('char')!;

    final manager = $$KanjiTableTableManager(
      $_db,
      $_db.kanji,
    ).filter((f) => f.char.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_charTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$KanjiReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $KanjiReadingsTable> {
  $$KanjiReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gloss => $composableBuilder(
    column: $table.gloss,
    builder: (column) => ColumnFilters(column),
  );

  $$KanjiTableFilterComposer get char {
    final $$KanjiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanji,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiTableFilterComposer(
            $db: $db,
            $table: $db.kanji,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KanjiReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $KanjiReadingsTable> {
  $$KanjiReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get base => $composableBuilder(
    column: $table.base,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gloss => $composableBuilder(
    column: $table.gloss,
    builder: (column) => ColumnOrderings(column),
  );

  $$KanjiTableOrderingComposer get char {
    final $$KanjiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanji,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiTableOrderingComposer(
            $db: $db,
            $table: $db.kanji,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KanjiReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanjiReadingsTable> {
  $$KanjiReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get base =>
      $composableBuilder(column: $table.base, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get gloss =>
      $composableBuilder(column: $table.gloss, builder: (column) => column);

  $$KanjiTableAnnotationComposer get char {
    final $$KanjiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanji,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiTableAnnotationComposer(
            $db: $db,
            $table: $db.kanji,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KanjiReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanjiReadingsTable,
          KanjiReadingRow,
          $$KanjiReadingsTableFilterComposer,
          $$KanjiReadingsTableOrderingComposer,
          $$KanjiReadingsTableAnnotationComposer,
          $$KanjiReadingsTableCreateCompanionBuilder,
          $$KanjiReadingsTableUpdateCompanionBuilder,
          (KanjiReadingRow, $$KanjiReadingsTableReferences),
          KanjiReadingRow,
          PrefetchHooks Function({bool char})
        > {
  $$KanjiReadingsTableTableManager(_$AppDatabase db, $KanjiReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> char = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> base = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> gloss = const Value.absent(),
              }) => KanjiReadingsCompanion(
                id: id,
                char: char,
                reading: reading,
                base: base,
                kind: kind,
                gloss: gloss,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String char,
                required String reading,
                required String base,
                required String kind,
                Value<String?> gloss = const Value.absent(),
              }) => KanjiReadingsCompanion.insert(
                id: id,
                char: char,
                reading: reading,
                base: base,
                kind: kind,
                gloss: gloss,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$KanjiReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({char = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (char) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.char,
                                referencedTable: $$KanjiReadingsTableReferences
                                    ._charTable(db),
                                referencedColumn: $$KanjiReadingsTableReferences
                                    ._charTable(db)
                                    .char,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$KanjiReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanjiReadingsTable,
      KanjiReadingRow,
      $$KanjiReadingsTableFilterComposer,
      $$KanjiReadingsTableOrderingComposer,
      $$KanjiReadingsTableAnnotationComposer,
      $$KanjiReadingsTableCreateCompanionBuilder,
      $$KanjiReadingsTableUpdateCompanionBuilder,
      (KanjiReadingRow, $$KanjiReadingsTableReferences),
      KanjiReadingRow,
      PrefetchHooks Function({bool char})
    >;
typedef $$JlptWordsTableCreateCompanionBuilder =
    JlptWordsCompanion Function({
      Value<int> id,
      required String surface,
      required String kana,
      Value<int?> jlpt,
      Value<String?> en,
      Value<String?> ko,
      Value<int?> rank,
      Value<String?> src,
      Value<String?> segsJson,
    });
typedef $$JlptWordsTableUpdateCompanionBuilder =
    JlptWordsCompanion Function({
      Value<int> id,
      Value<String> surface,
      Value<String> kana,
      Value<int?> jlpt,
      Value<String?> en,
      Value<String?> ko,
      Value<int?> rank,
      Value<String?> src,
      Value<String?> segsJson,
    });

final class $$JlptWordsTableReferences
    extends BaseReferences<_$AppDatabase, $JlptWordsTable, JlptWordRow> {
  $$JlptWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordSegmentsTable, List<WordSegmentRow>>
  _wordSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordSegments,
    aliasName: $_aliasNameGenerator(db.jlptWords.id, db.wordSegments.wordId),
  );

  $$WordSegmentsTableProcessedTableManager get wordSegmentsRefs {
    final manager = $$WordSegmentsTableTableManager(
      $_db,
      $_db.wordSegments,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordSegmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JlptWordsTableFilterComposer
    extends Composer<_$AppDatabase, $JlptWordsTable> {
  $$JlptWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jlpt => $composableBuilder(
    column: $table.jlpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get en => $composableBuilder(
    column: $table.en,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ko => $composableBuilder(
    column: $table.ko,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segsJson => $composableBuilder(
    column: $table.segsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordSegmentsRefs(
    Expression<bool> Function($$WordSegmentsTableFilterComposer f) f,
  ) {
    final $$WordSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordSegments,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.wordSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JlptWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $JlptWordsTable> {
  $$JlptWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surface => $composableBuilder(
    column: $table.surface,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jlpt => $composableBuilder(
    column: $table.jlpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get en => $composableBuilder(
    column: $table.en,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ko => $composableBuilder(
    column: $table.ko,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segsJson => $composableBuilder(
    column: $table.segsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JlptWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JlptWordsTable> {
  $$JlptWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get surface =>
      $composableBuilder(column: $table.surface, builder: (column) => column);

  GeneratedColumn<String> get kana =>
      $composableBuilder(column: $table.kana, builder: (column) => column);

  GeneratedColumn<int> get jlpt =>
      $composableBuilder(column: $table.jlpt, builder: (column) => column);

  GeneratedColumn<String> get en =>
      $composableBuilder(column: $table.en, builder: (column) => column);

  GeneratedColumn<String> get ko =>
      $composableBuilder(column: $table.ko, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get src =>
      $composableBuilder(column: $table.src, builder: (column) => column);

  GeneratedColumn<String> get segsJson =>
      $composableBuilder(column: $table.segsJson, builder: (column) => column);

  Expression<T> wordSegmentsRefs<T extends Object>(
    Expression<T> Function($$WordSegmentsTableAnnotationComposer a) f,
  ) {
    final $$WordSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordSegments,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JlptWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JlptWordsTable,
          JlptWordRow,
          $$JlptWordsTableFilterComposer,
          $$JlptWordsTableOrderingComposer,
          $$JlptWordsTableAnnotationComposer,
          $$JlptWordsTableCreateCompanionBuilder,
          $$JlptWordsTableUpdateCompanionBuilder,
          (JlptWordRow, $$JlptWordsTableReferences),
          JlptWordRow,
          PrefetchHooks Function({bool wordSegmentsRefs})
        > {
  $$JlptWordsTableTableManager(_$AppDatabase db, $JlptWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JlptWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JlptWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JlptWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> surface = const Value.absent(),
                Value<String> kana = const Value.absent(),
                Value<int?> jlpt = const Value.absent(),
                Value<String?> en = const Value.absent(),
                Value<String?> ko = const Value.absent(),
                Value<int?> rank = const Value.absent(),
                Value<String?> src = const Value.absent(),
                Value<String?> segsJson = const Value.absent(),
              }) => JlptWordsCompanion(
                id: id,
                surface: surface,
                kana: kana,
                jlpt: jlpt,
                en: en,
                ko: ko,
                rank: rank,
                src: src,
                segsJson: segsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String surface,
                required String kana,
                Value<int?> jlpt = const Value.absent(),
                Value<String?> en = const Value.absent(),
                Value<String?> ko = const Value.absent(),
                Value<int?> rank = const Value.absent(),
                Value<String?> src = const Value.absent(),
                Value<String?> segsJson = const Value.absent(),
              }) => JlptWordsCompanion.insert(
                id: id,
                surface: surface,
                kana: kana,
                jlpt: jlpt,
                en: en,
                ko: ko,
                rank: rank,
                src: src,
                segsJson: segsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JlptWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordSegmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordSegmentsRefs) db.wordSegments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordSegmentsRefs)
                    await $_getPrefetchedData<
                      JlptWordRow,
                      $JlptWordsTable,
                      WordSegmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$JlptWordsTableReferences
                          ._wordSegmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$JlptWordsTableReferences(
                            db,
                            table,
                            p0,
                          ).wordSegmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JlptWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JlptWordsTable,
      JlptWordRow,
      $$JlptWordsTableFilterComposer,
      $$JlptWordsTableOrderingComposer,
      $$JlptWordsTableAnnotationComposer,
      $$JlptWordsTableCreateCompanionBuilder,
      $$JlptWordsTableUpdateCompanionBuilder,
      (JlptWordRow, $$JlptWordsTableReferences),
      JlptWordRow,
      PrefetchHooks Function({bool wordSegmentsRefs})
    >;
typedef $$WordSegmentsTableCreateCompanionBuilder =
    WordSegmentsCompanion Function({
      Value<int> id,
      required int wordId,
      required int idx,
      required String segText,
      Value<String?> reading,
      Value<String?> char,
    });
typedef $$WordSegmentsTableUpdateCompanionBuilder =
    WordSegmentsCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<int> idx,
      Value<String> segText,
      Value<String?> reading,
      Value<String?> char,
    });

final class $$WordSegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $WordSegmentsTable, WordSegmentRow> {
  $$WordSegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JlptWordsTable _wordIdTable(_$AppDatabase db) =>
      db.jlptWords.createAlias(
        $_aliasNameGenerator(db.wordSegments.wordId, db.jlptWords.id),
      );

  $$JlptWordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$JlptWordsTableTableManager(
      $_db,
      $_db.jlptWords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $WordSegmentsTable> {
  $$WordSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segText => $composableBuilder(
    column: $table.segText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnFilters(column),
  );

  $$JlptWordsTableFilterComposer get wordId {
    final $$JlptWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.jlptWords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JlptWordsTableFilterComposer(
            $db: $db,
            $table: $db.jlptWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordSegmentsTable> {
  $$WordSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segText => $composableBuilder(
    column: $table.segText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnOrderings(column),
  );

  $$JlptWordsTableOrderingComposer get wordId {
    final $$JlptWordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.jlptWords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JlptWordsTableOrderingComposer(
            $db: $db,
            $table: $db.jlptWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordSegmentsTable> {
  $$WordSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<String> get segText =>
      $composableBuilder(column: $table.segText, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get char =>
      $composableBuilder(column: $table.char, builder: (column) => column);

  $$JlptWordsTableAnnotationComposer get wordId {
    final $$JlptWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.jlptWords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JlptWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.jlptWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordSegmentsTable,
          WordSegmentRow,
          $$WordSegmentsTableFilterComposer,
          $$WordSegmentsTableOrderingComposer,
          $$WordSegmentsTableAnnotationComposer,
          $$WordSegmentsTableCreateCompanionBuilder,
          $$WordSegmentsTableUpdateCompanionBuilder,
          (WordSegmentRow, $$WordSegmentsTableReferences),
          WordSegmentRow,
          PrefetchHooks Function({bool wordId})
        > {
  $$WordSegmentsTableTableManager(_$AppDatabase db, $WordSegmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<String> segText = const Value.absent(),
                Value<String?> reading = const Value.absent(),
                Value<String?> char = const Value.absent(),
              }) => WordSegmentsCompanion(
                id: id,
                wordId: wordId,
                idx: idx,
                segText: segText,
                reading: reading,
                char: char,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required int idx,
                required String segText,
                Value<String?> reading = const Value.absent(),
                Value<String?> char = const Value.absent(),
              }) => WordSegmentsCompanion.insert(
                id: id,
                wordId: wordId,
                idx: idx,
                segText: segText,
                reading: reading,
                char: char,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordSegmentsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordSegmentsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordSegmentsTable,
      WordSegmentRow,
      $$WordSegmentsTableFilterComposer,
      $$WordSegmentsTableOrderingComposer,
      $$WordSegmentsTableAnnotationComposer,
      $$WordSegmentsTableCreateCompanionBuilder,
      $$WordSegmentsTableUpdateCompanionBuilder,
      (WordSegmentRow, $$WordSegmentsTableReferences),
      WordSegmentRow,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> rank,
      required String word,
      Value<double?> freq,
      Value<double?> cumPct,
      Value<String?> region,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> rank,
      Value<String> word,
      Value<double?> freq,
      Value<double?> cumPct,
      Value<String?> region,
    });

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cumPct => $composableBuilder(
    column: $table.cumPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cumPct => $composableBuilder(
    column: $table.cumPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<double> get freq =>
      $composableBuilder(column: $table.freq, builder: (column) => column);

  GeneratedColumn<double> get cumPct =>
      $composableBuilder(column: $table.cumPct, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          WordRow,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (WordRow, BaseReferences<_$AppDatabase, $WordsTable, WordRow>),
          WordRow,
          PrefetchHooks Function()
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rank = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<double?> freq = const Value.absent(),
                Value<double?> cumPct = const Value.absent(),
                Value<String?> region = const Value.absent(),
              }) => WordsCompanion(
                rank: rank,
                word: word,
                freq: freq,
                cumPct: cumPct,
                region: region,
              ),
          createCompanionCallback:
              ({
                Value<int> rank = const Value.absent(),
                required String word,
                Value<double?> freq = const Value.absent(),
                Value<double?> cumPct = const Value.absent(),
                Value<String?> region = const Value.absent(),
              }) => WordsCompanion.insert(
                rank: rank,
                word: word,
                freq: freq,
                cumPct: cumPct,
                region: region,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      WordRow,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (WordRow, BaseReferences<_$AppDatabase, $WordsTable, WordRow>),
      WordRow,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> turnId,
      Value<bool> learned,
      Value<bool> favorite,
      Value<DateTime?> lastReviewed,
      Value<int> reviewCount,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> turnId,
      Value<bool> learned,
      Value<bool> favorite,
      Value<DateTime?> lastReviewed,
      Value<int> reviewCount,
    });

final class $$UserProgressTableReferences
    extends BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressRow> {
  $$UserProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TurnsTable _turnIdTable(_$AppDatabase db) => db.turns.createAlias(
    $_aliasNameGenerator(db.userProgress.turnId, db.turns.id),
  );

  $$TurnsTableProcessedTableManager get turnId {
    final $_column = $_itemColumn<int>('turn_id')!;

    final manager = $$TurnsTableTableManager(
      $_db,
      $_db.turns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_turnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get learned => $composableBuilder(
    column: $table.learned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  $$TurnsTableFilterComposer get turnId {
    final $$TurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableFilterComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get learned => $composableBuilder(
    column: $table.learned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$TurnsTableOrderingComposer get turnId {
    final $$TurnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableOrderingComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get learned =>
      $composableBuilder(column: $table.learned, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  $$TurnsTableAnnotationComposer get turnId {
    final $$TurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.turnId,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          UserProgressRow,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (UserProgressRow, $$UserProgressTableReferences),
          UserProgressRow,
          PrefetchHooks Function({bool turnId})
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> turnId = const Value.absent(),
                Value<bool> learned = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> lastReviewed = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
              }) => UserProgressCompanion(
                turnId: turnId,
                learned: learned,
                favorite: favorite,
                lastReviewed: lastReviewed,
                reviewCount: reviewCount,
              ),
          createCompanionCallback:
              ({
                Value<int> turnId = const Value.absent(),
                Value<bool> learned = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> lastReviewed = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
              }) => UserProgressCompanion.insert(
                turnId: turnId,
                learned: learned,
                favorite: favorite,
                lastReviewed: lastReviewed,
                reviewCount: reviewCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({turnId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (turnId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.turnId,
                                referencedTable: $$UserProgressTableReferences
                                    ._turnIdTable(db),
                                referencedColumn: $$UserProgressTableReferences
                                    ._turnIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      UserProgressRow,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (UserProgressRow, $$UserProgressTableReferences),
      UserProgressRow,
      PrefetchHooks Function({bool turnId})
    >;
typedef $$KanjiProgressTableCreateCompanionBuilder =
    KanjiProgressCompanion Function({
      required String char,
      Value<bool> known,
      Value<int> exposureCount,
      Value<DateTime?> lastReviewed,
      Value<int> rowid,
    });
typedef $$KanjiProgressTableUpdateCompanionBuilder =
    KanjiProgressCompanion Function({
      Value<String> char,
      Value<bool> known,
      Value<int> exposureCount,
      Value<DateTime?> lastReviewed,
      Value<int> rowid,
    });

final class $$KanjiProgressTableReferences
    extends
        BaseReferences<_$AppDatabase, $KanjiProgressTable, KanjiProgressRow> {
  $$KanjiProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $KanjiTable _charTable(_$AppDatabase db) => db.kanji.createAlias(
    $_aliasNameGenerator(db.kanjiProgress.char, db.kanji.char),
  );

  $$KanjiTableProcessedTableManager get char {
    final $_column = $_itemColumn<String>('char')!;

    final manager = $$KanjiTableTableManager(
      $_db,
      $_db.kanji,
    ).filter((f) => f.char.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_charTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$KanjiProgressTableFilterComposer
    extends Composer<_$AppDatabase, $KanjiProgressTable> {
  $$KanjiProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get known => $composableBuilder(
    column: $table.known,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exposureCount => $composableBuilder(
    column: $table.exposureCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => ColumnFilters(column),
  );

  $$KanjiTableFilterComposer get char {
    final $$KanjiTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanji,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiTableFilterComposer(
            $db: $db,
            $table: $db.kanji,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KanjiProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $KanjiProgressTable> {
  $$KanjiProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get known => $composableBuilder(
    column: $table.known,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exposureCount => $composableBuilder(
    column: $table.exposureCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  $$KanjiTableOrderingComposer get char {
    final $$KanjiTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanji,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiTableOrderingComposer(
            $db: $db,
            $table: $db.kanji,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KanjiProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanjiProgressTable> {
  $$KanjiProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get known =>
      $composableBuilder(column: $table.known, builder: (column) => column);

  GeneratedColumn<int> get exposureCount => $composableBuilder(
    column: $table.exposureCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewed => $composableBuilder(
    column: $table.lastReviewed,
    builder: (column) => column,
  );

  $$KanjiTableAnnotationComposer get char {
    final $$KanjiTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.char,
      referencedTable: $db.kanji,
      getReferencedColumn: (t) => t.char,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KanjiTableAnnotationComposer(
            $db: $db,
            $table: $db.kanji,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KanjiProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanjiProgressTable,
          KanjiProgressRow,
          $$KanjiProgressTableFilterComposer,
          $$KanjiProgressTableOrderingComposer,
          $$KanjiProgressTableAnnotationComposer,
          $$KanjiProgressTableCreateCompanionBuilder,
          $$KanjiProgressTableUpdateCompanionBuilder,
          (KanjiProgressRow, $$KanjiProgressTableReferences),
          KanjiProgressRow,
          PrefetchHooks Function({bool char})
        > {
  $$KanjiProgressTableTableManager(_$AppDatabase db, $KanjiProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> char = const Value.absent(),
                Value<bool> known = const Value.absent(),
                Value<int> exposureCount = const Value.absent(),
                Value<DateTime?> lastReviewed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiProgressCompanion(
                char: char,
                known: known,
                exposureCount: exposureCount,
                lastReviewed: lastReviewed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String char,
                Value<bool> known = const Value.absent(),
                Value<int> exposureCount = const Value.absent(),
                Value<DateTime?> lastReviewed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanjiProgressCompanion.insert(
                char: char,
                known: known,
                exposureCount: exposureCount,
                lastReviewed: lastReviewed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$KanjiProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({char = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (char) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.char,
                                referencedTable: $$KanjiProgressTableReferences
                                    ._charTable(db),
                                referencedColumn: $$KanjiProgressTableReferences
                                    ._charTable(db)
                                    .char,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$KanjiProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanjiProgressTable,
      KanjiProgressRow,
      $$KanjiProgressTableFilterComposer,
      $$KanjiProgressTableOrderingComposer,
      $$KanjiProgressTableAnnotationComposer,
      $$KanjiProgressTableCreateCompanionBuilder,
      $$KanjiProgressTableUpdateCompanionBuilder,
      (KanjiProgressRow, $$KanjiProgressTableReferences),
      KanjiProgressRow,
      PrefetchHooks Function({bool char})
    >;
typedef $$StageResultsTableCreateCompanionBuilder =
    StageResultsCompanion Function({
      Value<int> stage,
      Value<int> correct,
      Value<int> total,
      Value<int> bestPct,
      Value<DateTime?> lastPlayed,
    });
typedef $$StageResultsTableUpdateCompanionBuilder =
    StageResultsCompanion Function({
      Value<int> stage,
      Value<int> correct,
      Value<int> total,
      Value<int> bestPct,
      Value<DateTime?> lastPlayed,
    });

class $$StageResultsTableFilterComposer
    extends Composer<_$AppDatabase, $StageResultsTable> {
  $$StageResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestPct => $composableBuilder(
    column: $table.bestPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StageResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $StageResultsTable> {
  $$StageResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestPct => $composableBuilder(
    column: $table.bestPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StageResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StageResultsTable> {
  $$StageResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get bestPct =>
      $composableBuilder(column: $table.bestPct, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );
}

class $$StageResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StageResultsTable,
          StageResultRow,
          $$StageResultsTableFilterComposer,
          $$StageResultsTableOrderingComposer,
          $$StageResultsTableAnnotationComposer,
          $$StageResultsTableCreateCompanionBuilder,
          $$StageResultsTableUpdateCompanionBuilder,
          (
            StageResultRow,
            BaseReferences<_$AppDatabase, $StageResultsTable, StageResultRow>,
          ),
          StageResultRow,
          PrefetchHooks Function()
        > {
  $$StageResultsTableTableManager(_$AppDatabase db, $StageResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StageResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StageResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StageResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> stage = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> bestPct = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
              }) => StageResultsCompanion(
                stage: stage,
                correct: correct,
                total: total,
                bestPct: bestPct,
                lastPlayed: lastPlayed,
              ),
          createCompanionCallback:
              ({
                Value<int> stage = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> bestPct = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
              }) => StageResultsCompanion.insert(
                stage: stage,
                correct: correct,
                total: total,
                bestPct: bestPct,
                lastPlayed: lastPlayed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StageResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StageResultsTable,
      StageResultRow,
      $$StageResultsTableFilterComposer,
      $$StageResultsTableOrderingComposer,
      $$StageResultsTableAnnotationComposer,
      $$StageResultsTableCreateCompanionBuilder,
      $$StageResultsTableUpdateCompanionBuilder,
      (
        StageResultRow,
        BaseReferences<_$AppDatabase, $StageResultsTable, StageResultRow>,
      ),
      StageResultRow,
      PrefetchHooks Function()
    >;
typedef $$UserMemosTableCreateCompanionBuilder =
    UserMemosCompanion Function({
      Value<int> id,
      required String context,
      required String body,
      Value<DateTime> createdAt,
    });
typedef $$UserMemosTableUpdateCompanionBuilder =
    UserMemosCompanion Function({
      Value<int> id,
      Value<String> context,
      Value<String> body,
      Value<DateTime> createdAt,
    });

class $$UserMemosTableFilterComposer
    extends Composer<_$AppDatabase, $UserMemosTable> {
  $$UserMemosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMemosTableOrderingComposer
    extends Composer<_$AppDatabase, $UserMemosTable> {
  $$UserMemosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMemosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserMemosTable> {
  $$UserMemosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserMemosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserMemosTable,
          UserMemoRow,
          $$UserMemosTableFilterComposer,
          $$UserMemosTableOrderingComposer,
          $$UserMemosTableAnnotationComposer,
          $$UserMemosTableCreateCompanionBuilder,
          $$UserMemosTableUpdateCompanionBuilder,
          (
            UserMemoRow,
            BaseReferences<_$AppDatabase, $UserMemosTable, UserMemoRow>,
          ),
          UserMemoRow,
          PrefetchHooks Function()
        > {
  $$UserMemosTableTableManager(_$AppDatabase db, $UserMemosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMemosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMemosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserMemosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserMemosCompanion(
                id: id,
                context: context,
                body: body,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String context,
                required String body,
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserMemosCompanion.insert(
                id: id,
                context: context,
                body: body,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMemosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserMemosTable,
      UserMemoRow,
      $$UserMemosTableFilterComposer,
      $$UserMemosTableOrderingComposer,
      $$UserMemosTableAnnotationComposer,
      $$UserMemosTableCreateCompanionBuilder,
      $$UserMemosTableUpdateCompanionBuilder,
      (
        UserMemoRow,
        BaseReferences<_$AppDatabase, $UserMemosTable, UserMemoRow>,
      ),
      UserMemoRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TurnsTableTableManager get turns =>
      $$TurnsTableTableManager(_db, _db.turns);
  $$KanjiTableTableManager get kanji =>
      $$KanjiTableTableManager(_db, _db.kanji);
  $$KanjiReadingsTableTableManager get kanjiReadings =>
      $$KanjiReadingsTableTableManager(_db, _db.kanjiReadings);
  $$JlptWordsTableTableManager get jlptWords =>
      $$JlptWordsTableTableManager(_db, _db.jlptWords);
  $$WordSegmentsTableTableManager get wordSegments =>
      $$WordSegmentsTableTableManager(_db, _db.wordSegments);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$KanjiProgressTableTableManager get kanjiProgress =>
      $$KanjiProgressTableTableManager(_db, _db.kanjiProgress);
  $$StageResultsTableTableManager get stageResults =>
      $$StageResultsTableTableManager(_db, _db.stageResults);
  $$UserMemosTableTableManager get userMemos =>
      $$UserMemosTableTableManager(_db, _db.userMemos);
}
