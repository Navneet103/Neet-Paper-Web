// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _questionTextMeta =
      const VerificationMeta('questionText');
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
      'question_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE');
  static const VerificationMeta _optionAMeta =
      const VerificationMeta('optionA');
  @override
  late final GeneratedColumn<String> optionA = GeneratedColumn<String>(
      'option_a', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionBMeta =
      const VerificationMeta('optionB');
  @override
  late final GeneratedColumn<String> optionB = GeneratedColumn<String>(
      'option_b', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionCMeta =
      const VerificationMeta('optionC');
  @override
  late final GeneratedColumn<String> optionC = GeneratedColumn<String>(
      'option_c', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionDMeta =
      const VerificationMeta('optionD');
  @override
  late final GeneratedColumn<String> optionD = GeneratedColumn<String>(
      'option_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctAnswerMeta =
      const VerificationMeta('correctAnswer');
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
      'correct_answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marksMeta = const VerificationMeta('marks');
  @override
  late final GeneratedColumn<double> marks = GeneratedColumn<double>(
      'marks', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _negativeMarksMeta =
      const VerificationMeta('negativeMarks');
  @override
  late final GeneratedColumn<double> negativeMarks = GeneratedColumn<double>(
      'negative_marks', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questionText,
        optionA,
        optionB,
        optionC,
        optionD,
        correctAnswer,
        marks,
        negativeMarks,
        subject,
        topic,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(Insertable<Question> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_text')) {
      context.handle(
          _questionTextMeta,
          questionText.isAcceptableOrUnknown(
              data['question_text']!, _questionTextMeta));
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('option_a')) {
      context.handle(_optionAMeta,
          optionA.isAcceptableOrUnknown(data['option_a']!, _optionAMeta));
    } else if (isInserting) {
      context.missing(_optionAMeta);
    }
    if (data.containsKey('option_b')) {
      context.handle(_optionBMeta,
          optionB.isAcceptableOrUnknown(data['option_b']!, _optionBMeta));
    } else if (isInserting) {
      context.missing(_optionBMeta);
    }
    if (data.containsKey('option_c')) {
      context.handle(_optionCMeta,
          optionC.isAcceptableOrUnknown(data['option_c']!, _optionCMeta));
    } else if (isInserting) {
      context.missing(_optionCMeta);
    }
    if (data.containsKey('option_d')) {
      context.handle(_optionDMeta,
          optionD.isAcceptableOrUnknown(data['option_d']!, _optionDMeta));
    } else if (isInserting) {
      context.missing(_optionDMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
          _correctAnswerMeta,
          correctAnswer.isAcceptableOrUnknown(
              data['correct_answer']!, _correctAnswerMeta));
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('marks')) {
      context.handle(
          _marksMeta, marks.isAcceptableOrUnknown(data['marks']!, _marksMeta));
    } else if (isInserting) {
      context.missing(_marksMeta);
    }
    if (data.containsKey('negative_marks')) {
      context.handle(
          _negativeMarksMeta,
          negativeMarks.isAcceptableOrUnknown(
              data['negative_marks']!, _negativeMarksMeta));
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      questionText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_text'])!,
      optionA: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_a'])!,
      optionB: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_b'])!,
      optionC: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_c'])!,
      optionD: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}option_d'])!,
      correctAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct_answer'])!,
      marks: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}marks'])!,
      negativeMarks: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}negative_marks'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject']),
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final int id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final double marks;
  final double negativeMarks;
  final String? subject;
  final String? topic;
  final DateTime createdAt;
  const Question(
      {required this.id,
      required this.questionText,
      required this.optionA,
      required this.optionB,
      required this.optionC,
      required this.optionD,
      required this.correctAnswer,
      required this.marks,
      required this.negativeMarks,
      this.subject,
      this.topic,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_text'] = Variable<String>(questionText);
    map['option_a'] = Variable<String>(optionA);
    map['option_b'] = Variable<String>(optionB);
    map['option_c'] = Variable<String>(optionC);
    map['option_d'] = Variable<String>(optionD);
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['marks'] = Variable<double>(marks);
    map['negative_marks'] = Variable<double>(negativeMarks);
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      questionText: Value(questionText),
      optionA: Value(optionA),
      optionB: Value(optionB),
      optionC: Value(optionC),
      optionD: Value(optionD),
      correctAnswer: Value(correctAnswer),
      marks: Value(marks),
      negativeMarks: Value(negativeMarks),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      createdAt: Value(createdAt),
    );
  }

  factory Question.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<int>(json['id']),
      questionText: serializer.fromJson<String>(json['questionText']),
      optionA: serializer.fromJson<String>(json['optionA']),
      optionB: serializer.fromJson<String>(json['optionB']),
      optionC: serializer.fromJson<String>(json['optionC']),
      optionD: serializer.fromJson<String>(json['optionD']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      marks: serializer.fromJson<double>(json['marks']),
      negativeMarks: serializer.fromJson<double>(json['negativeMarks']),
      subject: serializer.fromJson<String?>(json['subject']),
      topic: serializer.fromJson<String?>(json['topic']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionText': serializer.toJson<String>(questionText),
      'optionA': serializer.toJson<String>(optionA),
      'optionB': serializer.toJson<String>(optionB),
      'optionC': serializer.toJson<String>(optionC),
      'optionD': serializer.toJson<String>(optionD),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'marks': serializer.toJson<double>(marks),
      'negativeMarks': serializer.toJson<double>(negativeMarks),
      'subject': serializer.toJson<String?>(subject),
      'topic': serializer.toJson<String?>(topic),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Question copyWith(
          {int? id,
          String? questionText,
          String? optionA,
          String? optionB,
          String? optionC,
          String? optionD,
          String? correctAnswer,
          double? marks,
          double? negativeMarks,
          Value<String?> subject = const Value.absent(),
          Value<String?> topic = const Value.absent(),
          DateTime? createdAt}) =>
      Question(
        id: id ?? this.id,
        questionText: questionText ?? this.questionText,
        optionA: optionA ?? this.optionA,
        optionB: optionB ?? this.optionB,
        optionC: optionC ?? this.optionC,
        optionD: optionD ?? this.optionD,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        marks: marks ?? this.marks,
        negativeMarks: negativeMarks ?? this.negativeMarks,
        subject: subject.present ? subject.value : this.subject,
        topic: topic.present ? topic.value : this.topic,
        createdAt: createdAt ?? this.createdAt,
      );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      optionA: data.optionA.present ? data.optionA.value : this.optionA,
      optionB: data.optionB.present ? data.optionB.value : this.optionB,
      optionC: data.optionC.present ? data.optionC.value : this.optionC,
      optionD: data.optionD.present ? data.optionD.value : this.optionD,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      marks: data.marks.present ? data.marks.value : this.marks,
      negativeMarks: data.negativeMarks.present
          ? data.negativeMarks.value
          : this.negativeMarks,
      subject: data.subject.present ? data.subject.value : this.subject,
      topic: data.topic.present ? data.topic.value : this.topic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('questionText: $questionText, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('marks: $marks, ')
          ..write('negativeMarks: $negativeMarks, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionText, optionA, optionB, optionC,
      optionD, correctAnswer, marks, negativeMarks, subject, topic, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.questionText == this.questionText &&
          other.optionA == this.optionA &&
          other.optionB == this.optionB &&
          other.optionC == this.optionC &&
          other.optionD == this.optionD &&
          other.correctAnswer == this.correctAnswer &&
          other.marks == this.marks &&
          other.negativeMarks == this.negativeMarks &&
          other.subject == this.subject &&
          other.topic == this.topic &&
          other.createdAt == this.createdAt);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<int> id;
  final Value<String> questionText;
  final Value<String> optionA;
  final Value<String> optionB;
  final Value<String> optionC;
  final Value<String> optionD;
  final Value<String> correctAnswer;
  final Value<double> marks;
  final Value<double> negativeMarks;
  final Value<String?> subject;
  final Value<String?> topic;
  final Value<DateTime> createdAt;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.questionText = const Value.absent(),
    this.optionA = const Value.absent(),
    this.optionB = const Value.absent(),
    this.optionC = const Value.absent(),
    this.optionD = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.marks = const Value.absent(),
    this.negativeMarks = const Value.absent(),
    this.subject = const Value.absent(),
    this.topic = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuestionsCompanion.insert({
    this.id = const Value.absent(),
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    required double marks,
    this.negativeMarks = const Value.absent(),
    this.subject = const Value.absent(),
    this.topic = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : questionText = Value(questionText),
        optionA = Value(optionA),
        optionB = Value(optionB),
        optionC = Value(optionC),
        optionD = Value(optionD),
        correctAnswer = Value(correctAnswer),
        marks = Value(marks);
  static Insertable<Question> custom({
    Expression<int>? id,
    Expression<String>? questionText,
    Expression<String>? optionA,
    Expression<String>? optionB,
    Expression<String>? optionC,
    Expression<String>? optionD,
    Expression<String>? correctAnswer,
    Expression<double>? marks,
    Expression<double>? negativeMarks,
    Expression<String>? subject,
    Expression<String>? topic,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionText != null) 'question_text': questionText,
      if (optionA != null) 'option_a': optionA,
      if (optionB != null) 'option_b': optionB,
      if (optionC != null) 'option_c': optionC,
      if (optionD != null) 'option_d': optionD,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (marks != null) 'marks': marks,
      if (negativeMarks != null) 'negative_marks': negativeMarks,
      if (subject != null) 'subject': subject,
      if (topic != null) 'topic': topic,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuestionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? questionText,
      Value<String>? optionA,
      Value<String>? optionB,
      Value<String>? optionC,
      Value<String>? optionD,
      Value<String>? correctAnswer,
      Value<double>? marks,
      Value<double>? negativeMarks,
      Value<String?>? subject,
      Value<String?>? topic,
      Value<DateTime>? createdAt}) {
    return QuestionsCompanion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      marks: marks ?? this.marks,
      negativeMarks: negativeMarks ?? this.negativeMarks,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (optionA.present) {
      map['option_a'] = Variable<String>(optionA.value);
    }
    if (optionB.present) {
      map['option_b'] = Variable<String>(optionB.value);
    }
    if (optionC.present) {
      map['option_c'] = Variable<String>(optionC.value);
    }
    if (optionD.present) {
      map['option_d'] = Variable<String>(optionD.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (marks.present) {
      map['marks'] = Variable<double>(marks.value);
    }
    if (negativeMarks.present) {
      map['negative_marks'] = Variable<double>(negativeMarks.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('questionText: $questionText, ')
          ..write('optionA: $optionA, ')
          ..write('optionB: $optionB, ')
          ..write('optionC: $optionC, ')
          ..write('optionD: $optionD, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('marks: $marks, ')
          ..write('negativeMarks: $negativeMarks, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TestsTable extends Tests with TableInfo<$TestsTable, Test> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalMarksMeta =
      const VerificationMeta('totalMarks');
  @override
  late final GeneratedColumn<double> totalMarks = GeneratedColumn<double>(
      'total_marks', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _positiveMarkingMeta =
      const VerificationMeta('positiveMarking');
  @override
  late final GeneratedColumn<double> positiveMarking = GeneratedColumn<double>(
      'positive_marking', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _negativeMarkingMeta =
      const VerificationMeta('negativeMarking');
  @override
  late final GeneratedColumn<double> negativeMarking = GeneratedColumn<double>(
      'negative_marking', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        totalQuestions,
        totalMarks,
        durationMinutes,
        positiveMarking,
        negativeMarking,
        createdAt,
        startedAt,
        completedAt,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tests';
  @override
  VerificationContext validateIntegrity(Insertable<Test> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('total_marks')) {
      context.handle(
          _totalMarksMeta,
          totalMarks.isAcceptableOrUnknown(
              data['total_marks']!, _totalMarksMeta));
    } else if (isInserting) {
      context.missing(_totalMarksMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('positive_marking')) {
      context.handle(
          _positiveMarkingMeta,
          positiveMarking.isAcceptableOrUnknown(
              data['positive_marking']!, _positiveMarkingMeta));
    } else if (isInserting) {
      context.missing(_positiveMarkingMeta);
    }
    if (data.containsKey('negative_marking')) {
      context.handle(
          _negativeMarkingMeta,
          negativeMarking.isAcceptableOrUnknown(
              data['negative_marking']!, _negativeMarkingMeta));
    } else if (isInserting) {
      context.missing(_negativeMarkingMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Test map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Test(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      totalMarks: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_marks'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      positiveMarking: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}positive_marking'])!,
      negativeMarking: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}negative_marking'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $TestsTable createAlias(String alias) {
    return $TestsTable(attachedDatabase, alias);
  }
}

class Test extends DataClass implements Insertable<Test> {
  final int id;
  final String name;
  final int totalQuestions;
  final double totalMarks;
  final int durationMinutes;
  final double positiveMarking;
  final double negativeMarking;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String status;
  const Test(
      {required this.id,
      required this.name,
      required this.totalQuestions,
      required this.totalMarks,
      required this.durationMinutes,
      required this.positiveMarking,
      required this.negativeMarking,
      required this.createdAt,
      this.startedAt,
      this.completedAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['total_marks'] = Variable<double>(totalMarks);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['positive_marking'] = Variable<double>(positiveMarking);
    map['negative_marking'] = Variable<double>(negativeMarking);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  TestsCompanion toCompanion(bool nullToAbsent) {
    return TestsCompanion(
      id: Value(id),
      name: Value(name),
      totalQuestions: Value(totalQuestions),
      totalMarks: Value(totalMarks),
      durationMinutes: Value(durationMinutes),
      positiveMarking: Value(positiveMarking),
      negativeMarking: Value(negativeMarking),
      createdAt: Value(createdAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
    );
  }

  factory Test.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Test(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      totalMarks: serializer.fromJson<double>(json['totalMarks']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      positiveMarking: serializer.fromJson<double>(json['positiveMarking']),
      negativeMarking: serializer.fromJson<double>(json['negativeMarking']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'totalMarks': serializer.toJson<double>(totalMarks),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'positiveMarking': serializer.toJson<double>(positiveMarking),
      'negativeMarking': serializer.toJson<double>(negativeMarking),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  Test copyWith(
          {int? id,
          String? name,
          int? totalQuestions,
          double? totalMarks,
          int? durationMinutes,
          double? positiveMarking,
          double? negativeMarking,
          DateTime? createdAt,
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          String? status}) =>
      Test(
        id: id ?? this.id,
        name: name ?? this.name,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        totalMarks: totalMarks ?? this.totalMarks,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        positiveMarking: positiveMarking ?? this.positiveMarking,
        negativeMarking: negativeMarking ?? this.negativeMarking,
        createdAt: createdAt ?? this.createdAt,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        status: status ?? this.status,
      );
  Test copyWithCompanion(TestsCompanion data) {
    return Test(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      totalMarks:
          data.totalMarks.present ? data.totalMarks.value : this.totalMarks,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      positiveMarking: data.positiveMarking.present
          ? data.positiveMarking.value
          : this.positiveMarking,
      negativeMarking: data.negativeMarking.present
          ? data.negativeMarking.value
          : this.negativeMarking,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Test(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('totalMarks: $totalMarks, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('positiveMarking: $positiveMarking, ')
          ..write('negativeMarking: $negativeMarking, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      totalQuestions,
      totalMarks,
      durationMinutes,
      positiveMarking,
      negativeMarking,
      createdAt,
      startedAt,
      completedAt,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Test &&
          other.id == this.id &&
          other.name == this.name &&
          other.totalQuestions == this.totalQuestions &&
          other.totalMarks == this.totalMarks &&
          other.durationMinutes == this.durationMinutes &&
          other.positiveMarking == this.positiveMarking &&
          other.negativeMarking == this.negativeMarking &&
          other.createdAt == this.createdAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status);
}

class TestsCompanion extends UpdateCompanion<Test> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> totalQuestions;
  final Value<double> totalMarks;
  final Value<int> durationMinutes;
  final Value<double> positiveMarking;
  final Value<double> negativeMarking;
  final Value<DateTime> createdAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String> status;
  const TestsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.totalMarks = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.positiveMarking = const Value.absent(),
    this.negativeMarking = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  TestsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int totalQuestions,
    required double totalMarks,
    required int durationMinutes,
    required double positiveMarking,
    required double negativeMarking,
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
  })  : name = Value(name),
        totalQuestions = Value(totalQuestions),
        totalMarks = Value(totalMarks),
        durationMinutes = Value(durationMinutes),
        positiveMarking = Value(positiveMarking),
        negativeMarking = Value(negativeMarking);
  static Insertable<Test> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? totalQuestions,
    Expression<double>? totalMarks,
    Expression<int>? durationMinutes,
    Expression<double>? positiveMarking,
    Expression<double>? negativeMarking,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (totalMarks != null) 'total_marks': totalMarks,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (positiveMarking != null) 'positive_marking': positiveMarking,
      if (negativeMarking != null) 'negative_marking': negativeMarking,
      if (createdAt != null) 'created_at': createdAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
    });
  }

  TestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? totalQuestions,
      Value<double>? totalMarks,
      Value<int>? durationMinutes,
      Value<double>? positiveMarking,
      Value<double>? negativeMarking,
      Value<DateTime>? createdAt,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? completedAt,
      Value<String>? status}) {
    return TestsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalMarks: totalMarks ?? this.totalMarks,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      positiveMarking: positiveMarking ?? this.positiveMarking,
      negativeMarking: negativeMarking ?? this.negativeMarking,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (totalMarks.present) {
      map['total_marks'] = Variable<double>(totalMarks.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (positiveMarking.present) {
      map['positive_marking'] = Variable<double>(positiveMarking.value);
    }
    if (negativeMarking.present) {
      map['negative_marking'] = Variable<double>(negativeMarking.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('totalMarks: $totalMarks, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('positiveMarking: $positiveMarking, ')
          ..write('negativeMarking: $negativeMarking, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TestQuestionsTable extends TestQuestions
    with TableInfo<$TestQuestionsTable, TestQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _testIdMeta = const VerificationMeta('testId');
  @override
  late final GeneratedColumn<int> testId = GeneratedColumn<int>(
      'test_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tests (id)'));
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES questions (id)'));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, testId, questionId, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_questions';
  @override
  VerificationContext validateIntegrity(Insertable<TestQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_id')) {
      context.handle(_testIdMeta,
          testId.isAcceptableOrUnknown(data['test_id']!, _testIdMeta));
    } else if (isInserting) {
      context.missing(_testIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      testId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}test_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $TestQuestionsTable createAlias(String alias) {
    return $TestQuestionsTable(attachedDatabase, alias);
  }
}

class TestQuestion extends DataClass implements Insertable<TestQuestion> {
  final int id;
  final int testId;
  final int questionId;
  final int orderIndex;
  const TestQuestion(
      {required this.id,
      required this.testId,
      required this.questionId,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_id'] = Variable<int>(testId);
    map['question_id'] = Variable<int>(questionId);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  TestQuestionsCompanion toCompanion(bool nullToAbsent) {
    return TestQuestionsCompanion(
      id: Value(id),
      testId: Value(testId),
      questionId: Value(questionId),
      orderIndex: Value(orderIndex),
    );
  }

  factory TestQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestQuestion(
      id: serializer.fromJson<int>(json['id']),
      testId: serializer.fromJson<int>(json['testId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testId': serializer.toJson<int>(testId),
      'questionId': serializer.toJson<int>(questionId),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  TestQuestion copyWith(
          {int? id, int? testId, int? questionId, int? orderIndex}) =>
      TestQuestion(
        id: id ?? this.id,
        testId: testId ?? this.testId,
        questionId: questionId ?? this.questionId,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  TestQuestion copyWithCompanion(TestQuestionsCompanion data) {
    return TestQuestion(
      id: data.id.present ? data.id.value : this.id,
      testId: data.testId.present ? data.testId.value : this.testId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestQuestion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('questionId: $questionId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, testId, questionId, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestQuestion &&
          other.id == this.id &&
          other.testId == this.testId &&
          other.questionId == this.questionId &&
          other.orderIndex == this.orderIndex);
}

class TestQuestionsCompanion extends UpdateCompanion<TestQuestion> {
  final Value<int> id;
  final Value<int> testId;
  final Value<int> questionId;
  final Value<int> orderIndex;
  const TestQuestionsCompanion({
    this.id = const Value.absent(),
    this.testId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  TestQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int testId,
    required int questionId,
    required int orderIndex,
  })  : testId = Value(testId),
        questionId = Value(questionId),
        orderIndex = Value(orderIndex);
  static Insertable<TestQuestion> custom({
    Expression<int>? id,
    Expression<int>? testId,
    Expression<int>? questionId,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testId != null) 'test_id': testId,
      if (questionId != null) 'question_id': questionId,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  TestQuestionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? testId,
      Value<int>? questionId,
      Value<int>? orderIndex}) {
    return TestQuestionsCompanion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      questionId: questionId ?? this.questionId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testId.present) {
      map['test_id'] = Variable<int>(testId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('questionId: $questionId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $UserAnswersTable extends UserAnswers
    with TableInfo<$UserAnswersTable, UserAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _testIdMeta = const VerificationMeta('testId');
  @override
  late final GeneratedColumn<int> testId = GeneratedColumn<int>(
      'test_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tests (id)'));
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES questions (id)'));
  static const VerificationMeta _selectedOptionMeta =
      const VerificationMeta('selectedOption');
  @override
  late final GeneratedColumn<String> selectedOption = GeneratedColumn<String>(
      'selected_option', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isMarkedForReviewMeta =
      const VerificationMeta('isMarkedForReview');
  @override
  late final GeneratedColumn<bool> isMarkedForReview = GeneratedColumn<bool>(
      'is_marked_for_review', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_marked_for_review" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, testId, questionId, selectedOption, isMarkedForReview, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_answers';
  @override
  VerificationContext validateIntegrity(Insertable<UserAnswer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_id')) {
      context.handle(_testIdMeta,
          testId.isAcceptableOrUnknown(data['test_id']!, _testIdMeta));
    } else if (isInserting) {
      context.missing(_testIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_option')) {
      context.handle(
          _selectedOptionMeta,
          selectedOption.isAcceptableOrUnknown(
              data['selected_option']!, _selectedOptionMeta));
    }
    if (data.containsKey('is_marked_for_review')) {
      context.handle(
          _isMarkedForReviewMeta,
          isMarkedForReview.isAcceptableOrUnknown(
              data['is_marked_for_review']!, _isMarkedForReviewMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {testId, questionId},
      ];
  @override
  UserAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAnswer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      testId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}test_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id'])!,
      selectedOption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selected_option']),
      isMarkedForReview: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_marked_for_review'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserAnswersTable createAlias(String alias) {
    return $UserAnswersTable(attachedDatabase, alias);
  }
}

class UserAnswer extends DataClass implements Insertable<UserAnswer> {
  final int id;
  final int testId;
  final int questionId;
  final String? selectedOption;
  final bool isMarkedForReview;
  final DateTime updatedAt;
  const UserAnswer(
      {required this.id,
      required this.testId,
      required this.questionId,
      this.selectedOption,
      required this.isMarkedForReview,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_id'] = Variable<int>(testId);
    map['question_id'] = Variable<int>(questionId);
    if (!nullToAbsent || selectedOption != null) {
      map['selected_option'] = Variable<String>(selectedOption);
    }
    map['is_marked_for_review'] = Variable<bool>(isMarkedForReview);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserAnswersCompanion toCompanion(bool nullToAbsent) {
    return UserAnswersCompanion(
      id: Value(id),
      testId: Value(testId),
      questionId: Value(questionId),
      selectedOption: selectedOption == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedOption),
      isMarkedForReview: Value(isMarkedForReview),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserAnswer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAnswer(
      id: serializer.fromJson<int>(json['id']),
      testId: serializer.fromJson<int>(json['testId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      selectedOption: serializer.fromJson<String?>(json['selectedOption']),
      isMarkedForReview: serializer.fromJson<bool>(json['isMarkedForReview']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testId': serializer.toJson<int>(testId),
      'questionId': serializer.toJson<int>(questionId),
      'selectedOption': serializer.toJson<String?>(selectedOption),
      'isMarkedForReview': serializer.toJson<bool>(isMarkedForReview),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserAnswer copyWith(
          {int? id,
          int? testId,
          int? questionId,
          Value<String?> selectedOption = const Value.absent(),
          bool? isMarkedForReview,
          DateTime? updatedAt}) =>
      UserAnswer(
        id: id ?? this.id,
        testId: testId ?? this.testId,
        questionId: questionId ?? this.questionId,
        selectedOption:
            selectedOption.present ? selectedOption.value : this.selectedOption,
        isMarkedForReview: isMarkedForReview ?? this.isMarkedForReview,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserAnswer copyWithCompanion(UserAnswersCompanion data) {
    return UserAnswer(
      id: data.id.present ? data.id.value : this.id,
      testId: data.testId.present ? data.testId.value : this.testId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      selectedOption: data.selectedOption.present
          ? data.selectedOption.value
          : this.selectedOption,
      isMarkedForReview: data.isMarkedForReview.present
          ? data.isMarkedForReview.value
          : this.isMarkedForReview,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAnswer(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOption: $selectedOption, ')
          ..write('isMarkedForReview: $isMarkedForReview, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, testId, questionId, selectedOption, isMarkedForReview, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAnswer &&
          other.id == this.id &&
          other.testId == this.testId &&
          other.questionId == this.questionId &&
          other.selectedOption == this.selectedOption &&
          other.isMarkedForReview == this.isMarkedForReview &&
          other.updatedAt == this.updatedAt);
}

class UserAnswersCompanion extends UpdateCompanion<UserAnswer> {
  final Value<int> id;
  final Value<int> testId;
  final Value<int> questionId;
  final Value<String?> selectedOption;
  final Value<bool> isMarkedForReview;
  final Value<DateTime> updatedAt;
  const UserAnswersCompanion({
    this.id = const Value.absent(),
    this.testId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedOption = const Value.absent(),
    this.isMarkedForReview = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int testId,
    required int questionId,
    this.selectedOption = const Value.absent(),
    this.isMarkedForReview = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : testId = Value(testId),
        questionId = Value(questionId);
  static Insertable<UserAnswer> custom({
    Expression<int>? id,
    Expression<int>? testId,
    Expression<int>? questionId,
    Expression<String>? selectedOption,
    Expression<bool>? isMarkedForReview,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testId != null) 'test_id': testId,
      if (questionId != null) 'question_id': questionId,
      if (selectedOption != null) 'selected_option': selectedOption,
      if (isMarkedForReview != null) 'is_marked_for_review': isMarkedForReview,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserAnswersCompanion copyWith(
      {Value<int>? id,
      Value<int>? testId,
      Value<int>? questionId,
      Value<String?>? selectedOption,
      Value<bool>? isMarkedForReview,
      Value<DateTime>? updatedAt}) {
    return UserAnswersCompanion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      questionId: questionId ?? this.questionId,
      selectedOption: selectedOption ?? this.selectedOption,
      isMarkedForReview: isMarkedForReview ?? this.isMarkedForReview,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testId.present) {
      map['test_id'] = Variable<int>(testId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (selectedOption.present) {
      map['selected_option'] = Variable<String>(selectedOption.value);
    }
    if (isMarkedForReview.present) {
      map['is_marked_for_review'] = Variable<bool>(isMarkedForReview.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAnswersCompanion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOption: $selectedOption, ')
          ..write('isMarkedForReview: $isMarkedForReview, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TestResultsTable extends TestResults
    with TableInfo<$TestResultsTable, TestResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _testIdMeta = const VerificationMeta('testId');
  @override
  late final GeneratedColumn<int> testId = GeneratedColumn<int>(
      'test_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('UNIQUE REFERENCES tests (id)'));
  static const VerificationMeta _attemptedCountMeta =
      const VerificationMeta('attemptedCount');
  @override
  late final GeneratedColumn<int> attemptedCount = GeneratedColumn<int>(
      'attempted_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _correctCountMeta =
      const VerificationMeta('correctCount');
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
      'correct_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wrongCountMeta =
      const VerificationMeta('wrongCount');
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
      'wrong_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _finalScoreMeta =
      const VerificationMeta('finalScore');
  @override
  late final GeneratedColumn<double> finalScore = GeneratedColumn<double>(
      'final_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timeTakenSecondsMeta =
      const VerificationMeta('timeTakenSeconds');
  @override
  late final GeneratedColumn<int> timeTakenSeconds = GeneratedColumn<int>(
      'time_taken_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        testId,
        attemptedCount,
        correctCount,
        wrongCount,
        finalScore,
        accuracy,
        timeTakenSeconds,
        generatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results';
  @override
  VerificationContext validateIntegrity(Insertable<TestResult> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_id')) {
      context.handle(_testIdMeta,
          testId.isAcceptableOrUnknown(data['test_id']!, _testIdMeta));
    } else if (isInserting) {
      context.missing(_testIdMeta);
    }
    if (data.containsKey('attempted_count')) {
      context.handle(
          _attemptedCountMeta,
          attemptedCount.isAcceptableOrUnknown(
              data['attempted_count']!, _attemptedCountMeta));
    } else if (isInserting) {
      context.missing(_attemptedCountMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
          _correctCountMeta,
          correctCount.isAcceptableOrUnknown(
              data['correct_count']!, _correctCountMeta));
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
          _wrongCountMeta,
          wrongCount.isAcceptableOrUnknown(
              data['wrong_count']!, _wrongCountMeta));
    } else if (isInserting) {
      context.missing(_wrongCountMeta);
    }
    if (data.containsKey('final_score')) {
      context.handle(
          _finalScoreMeta,
          finalScore.isAcceptableOrUnknown(
              data['final_score']!, _finalScoreMeta));
    } else if (isInserting) {
      context.missing(_finalScoreMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('time_taken_seconds')) {
      context.handle(
          _timeTakenSecondsMeta,
          timeTakenSeconds.isAcceptableOrUnknown(
              data['time_taken_seconds']!, _timeTakenSecondsMeta));
    } else if (isInserting) {
      context.missing(_timeTakenSecondsMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResult(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      testId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}test_id'])!,
      attemptedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempted_count'])!,
      correctCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_count'])!,
      wrongCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wrong_count'])!,
      finalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}final_score'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      timeTakenSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}time_taken_seconds'])!,
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
    );
  }

  @override
  $TestResultsTable createAlias(String alias) {
    return $TestResultsTable(attachedDatabase, alias);
  }
}

class TestResult extends DataClass implements Insertable<TestResult> {
  final int id;
  final int testId;
  final int attemptedCount;
  final int correctCount;
  final int wrongCount;
  final double finalScore;
  final double accuracy;
  final int timeTakenSeconds;
  final DateTime generatedAt;
  const TestResult(
      {required this.id,
      required this.testId,
      required this.attemptedCount,
      required this.correctCount,
      required this.wrongCount,
      required this.finalScore,
      required this.accuracy,
      required this.timeTakenSeconds,
      required this.generatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_id'] = Variable<int>(testId);
    map['attempted_count'] = Variable<int>(attemptedCount);
    map['correct_count'] = Variable<int>(correctCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['final_score'] = Variable<double>(finalScore);
    map['accuracy'] = Variable<double>(accuracy);
    map['time_taken_seconds'] = Variable<int>(timeTakenSeconds);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  TestResultsCompanion toCompanion(bool nullToAbsent) {
    return TestResultsCompanion(
      id: Value(id),
      testId: Value(testId),
      attemptedCount: Value(attemptedCount),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      finalScore: Value(finalScore),
      accuracy: Value(accuracy),
      timeTakenSeconds: Value(timeTakenSeconds),
      generatedAt: Value(generatedAt),
    );
  }

  factory TestResult.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResult(
      id: serializer.fromJson<int>(json['id']),
      testId: serializer.fromJson<int>(json['testId']),
      attemptedCount: serializer.fromJson<int>(json['attemptedCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      finalScore: serializer.fromJson<double>(json['finalScore']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      timeTakenSeconds: serializer.fromJson<int>(json['timeTakenSeconds']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testId': serializer.toJson<int>(testId),
      'attemptedCount': serializer.toJson<int>(attemptedCount),
      'correctCount': serializer.toJson<int>(correctCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'finalScore': serializer.toJson<double>(finalScore),
      'accuracy': serializer.toJson<double>(accuracy),
      'timeTakenSeconds': serializer.toJson<int>(timeTakenSeconds),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  TestResult copyWith(
          {int? id,
          int? testId,
          int? attemptedCount,
          int? correctCount,
          int? wrongCount,
          double? finalScore,
          double? accuracy,
          int? timeTakenSeconds,
          DateTime? generatedAt}) =>
      TestResult(
        id: id ?? this.id,
        testId: testId ?? this.testId,
        attemptedCount: attemptedCount ?? this.attemptedCount,
        correctCount: correctCount ?? this.correctCount,
        wrongCount: wrongCount ?? this.wrongCount,
        finalScore: finalScore ?? this.finalScore,
        accuracy: accuracy ?? this.accuracy,
        timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
        generatedAt: generatedAt ?? this.generatedAt,
      );
  TestResult copyWithCompanion(TestResultsCompanion data) {
    return TestResult(
      id: data.id.present ? data.id.value : this.id,
      testId: data.testId.present ? data.testId.value : this.testId,
      attemptedCount: data.attemptedCount.present
          ? data.attemptedCount.value
          : this.attemptedCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      wrongCount:
          data.wrongCount.present ? data.wrongCount.value : this.wrongCount,
      finalScore:
          data.finalScore.present ? data.finalScore.value : this.finalScore,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      timeTakenSeconds: data.timeTakenSeconds.present
          ? data.timeTakenSeconds.value
          : this.timeTakenSeconds,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResult(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('attemptedCount: $attemptedCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('finalScore: $finalScore, ')
          ..write('accuracy: $accuracy, ')
          ..write('timeTakenSeconds: $timeTakenSeconds, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, testId, attemptedCount, correctCount,
      wrongCount, finalScore, accuracy, timeTakenSeconds, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResult &&
          other.id == this.id &&
          other.testId == this.testId &&
          other.attemptedCount == this.attemptedCount &&
          other.correctCount == this.correctCount &&
          other.wrongCount == this.wrongCount &&
          other.finalScore == this.finalScore &&
          other.accuracy == this.accuracy &&
          other.timeTakenSeconds == this.timeTakenSeconds &&
          other.generatedAt == this.generatedAt);
}

class TestResultsCompanion extends UpdateCompanion<TestResult> {
  final Value<int> id;
  final Value<int> testId;
  final Value<int> attemptedCount;
  final Value<int> correctCount;
  final Value<int> wrongCount;
  final Value<double> finalScore;
  final Value<double> accuracy;
  final Value<int> timeTakenSeconds;
  final Value<DateTime> generatedAt;
  const TestResultsCompanion({
    this.id = const Value.absent(),
    this.testId = const Value.absent(),
    this.attemptedCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.finalScore = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.timeTakenSeconds = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  TestResultsCompanion.insert({
    this.id = const Value.absent(),
    required int testId,
    required int attemptedCount,
    required int correctCount,
    required int wrongCount,
    required double finalScore,
    required double accuracy,
    required int timeTakenSeconds,
    this.generatedAt = const Value.absent(),
  })  : testId = Value(testId),
        attemptedCount = Value(attemptedCount),
        correctCount = Value(correctCount),
        wrongCount = Value(wrongCount),
        finalScore = Value(finalScore),
        accuracy = Value(accuracy),
        timeTakenSeconds = Value(timeTakenSeconds);
  static Insertable<TestResult> custom({
    Expression<int>? id,
    Expression<int>? testId,
    Expression<int>? attemptedCount,
    Expression<int>? correctCount,
    Expression<int>? wrongCount,
    Expression<double>? finalScore,
    Expression<double>? accuracy,
    Expression<int>? timeTakenSeconds,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testId != null) 'test_id': testId,
      if (attemptedCount != null) 'attempted_count': attemptedCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (finalScore != null) 'final_score': finalScore,
      if (accuracy != null) 'accuracy': accuracy,
      if (timeTakenSeconds != null) 'time_taken_seconds': timeTakenSeconds,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  TestResultsCompanion copyWith(
      {Value<int>? id,
      Value<int>? testId,
      Value<int>? attemptedCount,
      Value<int>? correctCount,
      Value<int>? wrongCount,
      Value<double>? finalScore,
      Value<double>? accuracy,
      Value<int>? timeTakenSeconds,
      Value<DateTime>? generatedAt}) {
    return TestResultsCompanion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      attemptedCount: attemptedCount ?? this.attemptedCount,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      finalScore: finalScore ?? this.finalScore,
      accuracy: accuracy ?? this.accuracy,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testId.present) {
      map['test_id'] = Variable<int>(testId.value);
    }
    if (attemptedCount.present) {
      map['attempted_count'] = Variable<int>(attemptedCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (finalScore.present) {
      map['final_score'] = Variable<double>(finalScore.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (timeTakenSeconds.present) {
      map['time_taken_seconds'] = Variable<int>(timeTakenSeconds.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsCompanion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('attemptedCount: $attemptedCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('finalScore: $finalScore, ')
          ..write('accuracy: $accuracy, ')
          ..write('timeTakenSeconds: $timeTakenSeconds, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $TestsTable tests = $TestsTable(this);
  late final $TestQuestionsTable testQuestions = $TestQuestionsTable(this);
  late final $UserAnswersTable userAnswers = $UserAnswersTable(this);
  late final $TestResultsTable testResults = $TestResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [questions, tests, testQuestions, userAnswers, testResults];
}

typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  Value<int> id,
  required String questionText,
  required String optionA,
  required String optionB,
  required String optionC,
  required String optionD,
  required String correctAnswer,
  required double marks,
  Value<double> negativeMarks,
  Value<String?> subject,
  Value<String?> topic,
  Value<DateTime> createdAt,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<int> id,
  Value<String> questionText,
  Value<String> optionA,
  Value<String> optionB,
  Value<String> optionC,
  Value<String> optionD,
  Value<String> correctAnswer,
  Value<double> marks,
  Value<double> negativeMarks,
  Value<String?> subject,
  Value<String?> topic,
  Value<DateTime> createdAt,
});

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TestQuestionsTable, List<TestQuestion>>
      _testQuestionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.testQuestions,
              aliasName: $_aliasNameGenerator(
                  db.questions.id, db.testQuestions.questionId));

  $$TestQuestionsTableProcessedTableManager get testQuestionsRefs {
    final manager = $$TestQuestionsTableTableManager($_db, $_db.testQuestions)
        .filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_testQuestionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserAnswersTable, List<UserAnswer>>
      _userAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userAnswers,
          aliasName:
              $_aliasNameGenerator(db.questions.id, db.userAnswers.questionId));

  $$UserAnswersTableProcessedTableManager get userAnswersRefs {
    final manager = $$UserAnswersTableTableManager($_db, $_db.userAnswers)
        .filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userAnswersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionA => $composableBuilder(
      column: $table.optionA, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionB => $composableBuilder(
      column: $table.optionB, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionC => $composableBuilder(
      column: $table.optionC, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionD => $composableBuilder(
      column: $table.optionD, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get marks => $composableBuilder(
      column: $table.marks, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get negativeMarks => $composableBuilder(
      column: $table.negativeMarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> testQuestionsRefs(
      Expression<bool> Function($$TestQuestionsTableFilterComposer f) f) {
    final $$TestQuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.testQuestions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestQuestionsTableFilterComposer(
              $db: $db,
              $table: $db.testQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> userAnswersRefs(
      Expression<bool> Function($$UserAnswersTableFilterComposer f) f) {
    final $$UserAnswersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userAnswers,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserAnswersTableFilterComposer(
              $db: $db,
              $table: $db.userAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionText => $composableBuilder(
      column: $table.questionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionA => $composableBuilder(
      column: $table.optionA, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionB => $composableBuilder(
      column: $table.optionB, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionC => $composableBuilder(
      column: $table.optionC, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionD => $composableBuilder(
      column: $table.optionD, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get marks => $composableBuilder(
      column: $table.marks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get negativeMarks => $composableBuilder(
      column: $table.negativeMarks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => column);

  GeneratedColumn<String> get optionA =>
      $composableBuilder(column: $table.optionA, builder: (column) => column);

  GeneratedColumn<String> get optionB =>
      $composableBuilder(column: $table.optionB, builder: (column) => column);

  GeneratedColumn<String> get optionC =>
      $composableBuilder(column: $table.optionC, builder: (column) => column);

  GeneratedColumn<String> get optionD =>
      $composableBuilder(column: $table.optionD, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => column);

  GeneratedColumn<double> get marks =>
      $composableBuilder(column: $table.marks, builder: (column) => column);

  GeneratedColumn<double> get negativeMarks => $composableBuilder(
      column: $table.negativeMarks, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> testQuestionsRefs<T extends Object>(
      Expression<T> Function($$TestQuestionsTableAnnotationComposer a) f) {
    final $$TestQuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.testQuestions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestQuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.testQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> userAnswersRefs<T extends Object>(
      Expression<T> Function($$UserAnswersTableAnnotationComposer a) f) {
    final $$UserAnswersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userAnswers,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserAnswersTableAnnotationComposer(
              $db: $db,
              $table: $db.userAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, $$QuestionsTableReferences),
    Question,
    PrefetchHooks Function({bool testQuestionsRefs, bool userAnswersRefs})> {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> questionText = const Value.absent(),
            Value<String> optionA = const Value.absent(),
            Value<String> optionB = const Value.absent(),
            Value<String> optionC = const Value.absent(),
            Value<String> optionD = const Value.absent(),
            Value<String> correctAnswer = const Value.absent(),
            Value<double> marks = const Value.absent(),
            Value<double> negativeMarks = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              QuestionsCompanion(
            id: id,
            questionText: questionText,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctAnswer: correctAnswer,
            marks: marks,
            negativeMarks: negativeMarks,
            subject: subject,
            topic: topic,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String questionText,
            required String optionA,
            required String optionB,
            required String optionC,
            required String optionD,
            required String correctAnswer,
            required double marks,
            Value<double> negativeMarks = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              QuestionsCompanion.insert(
            id: id,
            questionText: questionText,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctAnswer: correctAnswer,
            marks: marks,
            negativeMarks: negativeMarks,
            subject: subject,
            topic: topic,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {testQuestionsRefs = false, userAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (testQuestionsRefs) db.testQuestions,
                if (userAnswersRefs) db.userAnswers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testQuestionsRefs)
                    await $_getPrefetchedData<Question, $QuestionsTable,
                            TestQuestion>(
                        currentTable: table,
                        referencedTable: $$QuestionsTableReferences
                            ._testQuestionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuestionsTableReferences(db, table, p0)
                                .testQuestionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.questionId == item.id),
                        typedResults: items),
                  if (userAnswersRefs)
                    await $_getPrefetchedData<Question, $QuestionsTable,
                            UserAnswer>(
                        currentTable: table,
                        referencedTable: $$QuestionsTableReferences
                            ._userAnswersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuestionsTableReferences(db, table, p0)
                                .userAnswersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.questionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$QuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, $$QuestionsTableReferences),
    Question,
    PrefetchHooks Function({bool testQuestionsRefs, bool userAnswersRefs})>;
typedef $$TestsTableCreateCompanionBuilder = TestsCompanion Function({
  Value<int> id,
  required String name,
  required int totalQuestions,
  required double totalMarks,
  required int durationMinutes,
  required double positiveMarking,
  required double negativeMarking,
  Value<DateTime> createdAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<String> status,
});
typedef $$TestsTableUpdateCompanionBuilder = TestsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> totalQuestions,
  Value<double> totalMarks,
  Value<int> durationMinutes,
  Value<double> positiveMarking,
  Value<double> negativeMarking,
  Value<DateTime> createdAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<String> status,
});

final class $$TestsTableReferences
    extends BaseReferences<_$AppDatabase, $TestsTable, Test> {
  $$TestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TestQuestionsTable, List<TestQuestion>>
      _testQuestionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.testQuestions,
              aliasName:
                  $_aliasNameGenerator(db.tests.id, db.testQuestions.testId));

  $$TestQuestionsTableProcessedTableManager get testQuestionsRefs {
    final manager = $$TestQuestionsTableTableManager($_db, $_db.testQuestions)
        .filter((f) => f.testId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_testQuestionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserAnswersTable, List<UserAnswer>>
      _userAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userAnswers,
          aliasName: $_aliasNameGenerator(db.tests.id, db.userAnswers.testId));

  $$UserAnswersTableProcessedTableManager get userAnswersRefs {
    final manager = $$UserAnswersTableTableManager($_db, $_db.userAnswers)
        .filter((f) => f.testId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userAnswersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TestResultsTable, List<TestResult>>
      _testResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.testResults,
          aliasName: $_aliasNameGenerator(db.tests.id, db.testResults.testId));

  $$TestResultsTableProcessedTableManager get testResultsRefs {
    final manager = $$TestResultsTableTableManager($_db, $_db.testResults)
        .filter((f) => f.testId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_testResultsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TestsTableFilterComposer extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalMarks => $composableBuilder(
      column: $table.totalMarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get positiveMarking => $composableBuilder(
      column: $table.positiveMarking,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get negativeMarking => $composableBuilder(
      column: $table.negativeMarking,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  Expression<bool> testQuestionsRefs(
      Expression<bool> Function($$TestQuestionsTableFilterComposer f) f) {
    final $$TestQuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.testQuestions,
        getReferencedColumn: (t) => t.testId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestQuestionsTableFilterComposer(
              $db: $db,
              $table: $db.testQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> userAnswersRefs(
      Expression<bool> Function($$UserAnswersTableFilterComposer f) f) {
    final $$UserAnswersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userAnswers,
        getReferencedColumn: (t) => t.testId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserAnswersTableFilterComposer(
              $db: $db,
              $table: $db.userAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> testResultsRefs(
      Expression<bool> Function($$TestResultsTableFilterComposer f) f) {
    final $$TestResultsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.testResults,
        getReferencedColumn: (t) => t.testId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestResultsTableFilterComposer(
              $db: $db,
              $table: $db.testResults,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TestsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalMarks => $composableBuilder(
      column: $table.totalMarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get positiveMarking => $composableBuilder(
      column: $table.positiveMarking,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get negativeMarking => $composableBuilder(
      column: $table.negativeMarking,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$TestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions, builder: (column) => column);

  GeneratedColumn<double> get totalMarks => $composableBuilder(
      column: $table.totalMarks, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<double> get positiveMarking => $composableBuilder(
      column: $table.positiveMarking, builder: (column) => column);

  GeneratedColumn<double> get negativeMarking => $composableBuilder(
      column: $table.negativeMarking, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> testQuestionsRefs<T extends Object>(
      Expression<T> Function($$TestQuestionsTableAnnotationComposer a) f) {
    final $$TestQuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.testQuestions,
        getReferencedColumn: (t) => t.testId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestQuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.testQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> userAnswersRefs<T extends Object>(
      Expression<T> Function($$UserAnswersTableAnnotationComposer a) f) {
    final $$UserAnswersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userAnswers,
        getReferencedColumn: (t) => t.testId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserAnswersTableAnnotationComposer(
              $db: $db,
              $table: $db.userAnswers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> testResultsRefs<T extends Object>(
      Expression<T> Function($$TestResultsTableAnnotationComposer a) f) {
    final $$TestResultsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.testResults,
        getReferencedColumn: (t) => t.testId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestResultsTableAnnotationComposer(
              $db: $db,
              $table: $db.testResults,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestsTable,
    Test,
    $$TestsTableFilterComposer,
    $$TestsTableOrderingComposer,
    $$TestsTableAnnotationComposer,
    $$TestsTableCreateCompanionBuilder,
    $$TestsTableUpdateCompanionBuilder,
    (Test, $$TestsTableReferences),
    Test,
    PrefetchHooks Function(
        {bool testQuestionsRefs, bool userAnswersRefs, bool testResultsRefs})> {
  $$TestsTableTableManager(_$AppDatabase db, $TestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<double> totalMarks = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<double> positiveMarking = const Value.absent(),
            Value<double> negativeMarking = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              TestsCompanion(
            id: id,
            name: name,
            totalQuestions: totalQuestions,
            totalMarks: totalMarks,
            durationMinutes: durationMinutes,
            positiveMarking: positiveMarking,
            negativeMarking: negativeMarking,
            createdAt: createdAt,
            startedAt: startedAt,
            completedAt: completedAt,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int totalQuestions,
            required double totalMarks,
            required int durationMinutes,
            required double positiveMarking,
            required double negativeMarking,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
          }) =>
              TestsCompanion.insert(
            id: id,
            name: name,
            totalQuestions: totalQuestions,
            totalMarks: totalMarks,
            durationMinutes: durationMinutes,
            positiveMarking: positiveMarking,
            negativeMarking: negativeMarking,
            createdAt: createdAt,
            startedAt: startedAt,
            completedAt: completedAt,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TestsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {testQuestionsRefs = false,
              userAnswersRefs = false,
              testResultsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (testQuestionsRefs) db.testQuestions,
                if (userAnswersRefs) db.userAnswers,
                if (testResultsRefs) db.testResults
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testQuestionsRefs)
                    await $_getPrefetchedData<Test, $TestsTable, TestQuestion>(
                        currentTable: table,
                        referencedTable:
                            $$TestsTableReferences._testQuestionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TestsTableReferences(db, table, p0)
                                .testQuestionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.testId == item.id),
                        typedResults: items),
                  if (userAnswersRefs)
                    await $_getPrefetchedData<Test, $TestsTable, UserAnswer>(
                        currentTable: table,
                        referencedTable:
                            $$TestsTableReferences._userAnswersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TestsTableReferences(db, table, p0)
                                .userAnswersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.testId == item.id),
                        typedResults: items),
                  if (testResultsRefs)
                    await $_getPrefetchedData<Test, $TestsTable, TestResult>(
                        currentTable: table,
                        referencedTable:
                            $$TestsTableReferences._testResultsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TestsTableReferences(db, table, p0)
                                .testResultsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.testId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TestsTable,
    Test,
    $$TestsTableFilterComposer,
    $$TestsTableOrderingComposer,
    $$TestsTableAnnotationComposer,
    $$TestsTableCreateCompanionBuilder,
    $$TestsTableUpdateCompanionBuilder,
    (Test, $$TestsTableReferences),
    Test,
    PrefetchHooks Function(
        {bool testQuestionsRefs, bool userAnswersRefs, bool testResultsRefs})>;
typedef $$TestQuestionsTableCreateCompanionBuilder = TestQuestionsCompanion
    Function({
  Value<int> id,
  required int testId,
  required int questionId,
  required int orderIndex,
});
typedef $$TestQuestionsTableUpdateCompanionBuilder = TestQuestionsCompanion
    Function({
  Value<int> id,
  Value<int> testId,
  Value<int> questionId,
  Value<int> orderIndex,
});

final class $$TestQuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $TestQuestionsTable, TestQuestion> {
  $$TestQuestionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TestsTable _testIdTable(_$AppDatabase db) => db.tests
      .createAlias($_aliasNameGenerator(db.testQuestions.testId, db.tests.id));

  $$TestsTableProcessedTableManager get testId {
    final $_column = $_itemColumn<int>('test_id')!;

    final manager = $$TestsTableTableManager($_db, $_db.tests)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_testIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
          $_aliasNameGenerator(db.testQuestions.questionId, db.questions.id));

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TestQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $TestQuestionsTable> {
  $$TestQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$TestsTableFilterComposer get testId {
    final $$TestsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableFilterComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestQuestionsTable> {
  $$TestQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$TestsTableOrderingComposer get testId {
    final $$TestsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableOrderingComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableOrderingComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestQuestionsTable> {
  $$TestQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$TestsTableAnnotationComposer get testId {
    final $$TestsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableAnnotationComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestQuestionsTable,
    TestQuestion,
    $$TestQuestionsTableFilterComposer,
    $$TestQuestionsTableOrderingComposer,
    $$TestQuestionsTableAnnotationComposer,
    $$TestQuestionsTableCreateCompanionBuilder,
    $$TestQuestionsTableUpdateCompanionBuilder,
    (TestQuestion, $$TestQuestionsTableReferences),
    TestQuestion,
    PrefetchHooks Function({bool testId, bool questionId})> {
  $$TestQuestionsTableTableManager(_$AppDatabase db, $TestQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> testId = const Value.absent(),
            Value<int> questionId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              TestQuestionsCompanion(
            id: id,
            testId: testId,
            questionId: questionId,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int testId,
            required int questionId,
            required int orderIndex,
          }) =>
              TestQuestionsCompanion.insert(
            id: id,
            testId: testId,
            questionId: questionId,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TestQuestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({testId = false, questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (testId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.testId,
                    referencedTable:
                        $$TestQuestionsTableReferences._testIdTable(db),
                    referencedColumn:
                        $$TestQuestionsTableReferences._testIdTable(db).id,
                  ) as T;
                }
                if (questionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.questionId,
                    referencedTable:
                        $$TestQuestionsTableReferences._questionIdTable(db),
                    referencedColumn:
                        $$TestQuestionsTableReferences._questionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TestQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TestQuestionsTable,
    TestQuestion,
    $$TestQuestionsTableFilterComposer,
    $$TestQuestionsTableOrderingComposer,
    $$TestQuestionsTableAnnotationComposer,
    $$TestQuestionsTableCreateCompanionBuilder,
    $$TestQuestionsTableUpdateCompanionBuilder,
    (TestQuestion, $$TestQuestionsTableReferences),
    TestQuestion,
    PrefetchHooks Function({bool testId, bool questionId})>;
typedef $$UserAnswersTableCreateCompanionBuilder = UserAnswersCompanion
    Function({
  Value<int> id,
  required int testId,
  required int questionId,
  Value<String?> selectedOption,
  Value<bool> isMarkedForReview,
  Value<DateTime> updatedAt,
});
typedef $$UserAnswersTableUpdateCompanionBuilder = UserAnswersCompanion
    Function({
  Value<int> id,
  Value<int> testId,
  Value<int> questionId,
  Value<String?> selectedOption,
  Value<bool> isMarkedForReview,
  Value<DateTime> updatedAt,
});

final class $$UserAnswersTableReferences
    extends BaseReferences<_$AppDatabase, $UserAnswersTable, UserAnswer> {
  $$UserAnswersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TestsTable _testIdTable(_$AppDatabase db) => db.tests
      .createAlias($_aliasNameGenerator(db.userAnswers.testId, db.tests.id));

  $$TestsTableProcessedTableManager get testId {
    final $_column = $_itemColumn<int>('test_id')!;

    final manager = $$TestsTableTableManager($_db, $_db.tests)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_testIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
          $_aliasNameGenerator(db.userAnswers.questionId, db.questions.id));

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $UserAnswersTable> {
  $$UserAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedOption => $composableBuilder(
      column: $table.selectedOption,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMarkedForReview => $composableBuilder(
      column: $table.isMarkedForReview,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TestsTableFilterComposer get testId {
    final $$TestsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableFilterComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAnswersTable> {
  $$UserAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedOption => $composableBuilder(
      column: $table.selectedOption,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMarkedForReview => $composableBuilder(
      column: $table.isMarkedForReview,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TestsTableOrderingComposer get testId {
    final $$TestsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableOrderingComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableOrderingComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAnswersTable> {
  $$UserAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selectedOption => $composableBuilder(
      column: $table.selectedOption, builder: (column) => column);

  GeneratedColumn<bool> get isMarkedForReview => $composableBuilder(
      column: $table.isMarkedForReview, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TestsTableAnnotationComposer get testId {
    final $$TestsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableAnnotationComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserAnswersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserAnswersTable,
    UserAnswer,
    $$UserAnswersTableFilterComposer,
    $$UserAnswersTableOrderingComposer,
    $$UserAnswersTableAnnotationComposer,
    $$UserAnswersTableCreateCompanionBuilder,
    $$UserAnswersTableUpdateCompanionBuilder,
    (UserAnswer, $$UserAnswersTableReferences),
    UserAnswer,
    PrefetchHooks Function({bool testId, bool questionId})> {
  $$UserAnswersTableTableManager(_$AppDatabase db, $UserAnswersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> testId = const Value.absent(),
            Value<int> questionId = const Value.absent(),
            Value<String?> selectedOption = const Value.absent(),
            Value<bool> isMarkedForReview = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserAnswersCompanion(
            id: id,
            testId: testId,
            questionId: questionId,
            selectedOption: selectedOption,
            isMarkedForReview: isMarkedForReview,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int testId,
            required int questionId,
            Value<String?> selectedOption = const Value.absent(),
            Value<bool> isMarkedForReview = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserAnswersCompanion.insert(
            id: id,
            testId: testId,
            questionId: questionId,
            selectedOption: selectedOption,
            isMarkedForReview: isMarkedForReview,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserAnswersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({testId = false, questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (testId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.testId,
                    referencedTable:
                        $$UserAnswersTableReferences._testIdTable(db),
                    referencedColumn:
                        $$UserAnswersTableReferences._testIdTable(db).id,
                  ) as T;
                }
                if (questionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.questionId,
                    referencedTable:
                        $$UserAnswersTableReferences._questionIdTable(db),
                    referencedColumn:
                        $$UserAnswersTableReferences._questionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserAnswersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserAnswersTable,
    UserAnswer,
    $$UserAnswersTableFilterComposer,
    $$UserAnswersTableOrderingComposer,
    $$UserAnswersTableAnnotationComposer,
    $$UserAnswersTableCreateCompanionBuilder,
    $$UserAnswersTableUpdateCompanionBuilder,
    (UserAnswer, $$UserAnswersTableReferences),
    UserAnswer,
    PrefetchHooks Function({bool testId, bool questionId})>;
typedef $$TestResultsTableCreateCompanionBuilder = TestResultsCompanion
    Function({
  Value<int> id,
  required int testId,
  required int attemptedCount,
  required int correctCount,
  required int wrongCount,
  required double finalScore,
  required double accuracy,
  required int timeTakenSeconds,
  Value<DateTime> generatedAt,
});
typedef $$TestResultsTableUpdateCompanionBuilder = TestResultsCompanion
    Function({
  Value<int> id,
  Value<int> testId,
  Value<int> attemptedCount,
  Value<int> correctCount,
  Value<int> wrongCount,
  Value<double> finalScore,
  Value<double> accuracy,
  Value<int> timeTakenSeconds,
  Value<DateTime> generatedAt,
});

final class $$TestResultsTableReferences
    extends BaseReferences<_$AppDatabase, $TestResultsTable, TestResult> {
  $$TestResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TestsTable _testIdTable(_$AppDatabase db) => db.tests
      .createAlias($_aliasNameGenerator(db.testResults.testId, db.tests.id));

  $$TestsTableProcessedTableManager get testId {
    final $_column = $_itemColumn<int>('test_id')!;

    final manager = $$TestsTableTableManager($_db, $_db.tests)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_testIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptedCount => $composableBuilder(
      column: $table.attemptedCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wrongCount => $composableBuilder(
      column: $table.wrongCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeTakenSeconds => $composableBuilder(
      column: $table.timeTakenSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnFilters(column));

  $$TestsTableFilterComposer get testId {
    final $$TestsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableFilterComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptedCount => $composableBuilder(
      column: $table.attemptedCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctCount => $composableBuilder(
      column: $table.correctCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wrongCount => $composableBuilder(
      column: $table.wrongCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeTakenSeconds => $composableBuilder(
      column: $table.timeTakenSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnOrderings(column));

  $$TestsTableOrderingComposer get testId {
    final $$TestsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableOrderingComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get attemptedCount => $composableBuilder(
      column: $table.attemptedCount, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => column);

  GeneratedColumn<int> get wrongCount => $composableBuilder(
      column: $table.wrongCount, builder: (column) => column);

  GeneratedColumn<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get timeTakenSeconds => $composableBuilder(
      column: $table.timeTakenSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => column);

  $$TestsTableAnnotationComposer get testId {
    final $$TestsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.testId,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableAnnotationComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestResultsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestResultsTable,
    TestResult,
    $$TestResultsTableFilterComposer,
    $$TestResultsTableOrderingComposer,
    $$TestResultsTableAnnotationComposer,
    $$TestResultsTableCreateCompanionBuilder,
    $$TestResultsTableUpdateCompanionBuilder,
    (TestResult, $$TestResultsTableReferences),
    TestResult,
    PrefetchHooks Function({bool testId})> {
  $$TestResultsTableTableManager(_$AppDatabase db, $TestResultsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> testId = const Value.absent(),
            Value<int> attemptedCount = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> wrongCount = const Value.absent(),
            Value<double> finalScore = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<int> timeTakenSeconds = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
          }) =>
              TestResultsCompanion(
            id: id,
            testId: testId,
            attemptedCount: attemptedCount,
            correctCount: correctCount,
            wrongCount: wrongCount,
            finalScore: finalScore,
            accuracy: accuracy,
            timeTakenSeconds: timeTakenSeconds,
            generatedAt: generatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int testId,
            required int attemptedCount,
            required int correctCount,
            required int wrongCount,
            required double finalScore,
            required double accuracy,
            required int timeTakenSeconds,
            Value<DateTime> generatedAt = const Value.absent(),
          }) =>
              TestResultsCompanion.insert(
            id: id,
            testId: testId,
            attemptedCount: attemptedCount,
            correctCount: correctCount,
            wrongCount: wrongCount,
            finalScore: finalScore,
            accuracy: accuracy,
            timeTakenSeconds: timeTakenSeconds,
            generatedAt: generatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TestResultsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({testId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (testId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.testId,
                    referencedTable:
                        $$TestResultsTableReferences._testIdTable(db),
                    referencedColumn:
                        $$TestResultsTableReferences._testIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TestResultsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TestResultsTable,
    TestResult,
    $$TestResultsTableFilterComposer,
    $$TestResultsTableOrderingComposer,
    $$TestResultsTableAnnotationComposer,
    $$TestResultsTableCreateCompanionBuilder,
    $$TestResultsTableUpdateCompanionBuilder,
    (TestResult, $$TestResultsTableReferences),
    TestResult,
    PrefetchHooks Function({bool testId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$TestsTableTableManager get tests =>
      $$TestsTableTableManager(_db, _db.tests);
  $$TestQuestionsTableTableManager get testQuestions =>
      $$TestQuestionsTableTableManager(_db, _db.testQuestions);
  $$UserAnswersTableTableManager get userAnswers =>
      $$UserAnswersTableTableManager(_db, _db.userAnswers);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db, _db.testResults);
}
