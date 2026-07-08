// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarGoalCollection on Isar {
  IsarCollection<IsarGoal> get isarGoals => this.collection();
}

const IsarGoalSchema = CollectionSchema(
  name: r'IsarGoal',
  id: -4348511956834917587,
  properties: {
    r'categoryIndex': PropertySchema(
      id: 0,
      name: r'categoryIndex',
      type: IsarType.long,
    ),
    r'currentAmount': PropertySchema(
      id: 1,
      name: r'currentAmount',
      type: IsarType.long,
    ),
    r'deadline': PropertySchema(
      id: 2,
      name: r'deadline',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'targetAmount': PropertySchema(
      id: 4,
      name: r'targetAmount',
      type: IsarType.long,
    )
  },
  estimateSize: _isarGoalEstimateSize,
  serialize: _isarGoalSerialize,
  deserialize: _isarGoalDeserialize,
  deserializeProp: _isarGoalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarGoalGetId,
  getLinks: _isarGoalGetLinks,
  attach: _isarGoalAttach,
  version: '3.1.0+1',
);

int _isarGoalEstimateSize(
  IsarGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _isarGoalSerialize(
  IsarGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryIndex);
  writer.writeLong(offsets[1], object.currentAmount);
  writer.writeDateTime(offsets[2], object.deadline);
  writer.writeString(offsets[3], object.name);
  writer.writeLong(offsets[4], object.targetAmount);
}

IsarGoal _isarGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarGoal();
  object.categoryIndex = reader.readLongOrNull(offsets[0]);
  object.currentAmount = reader.readLong(offsets[1]);
  object.deadline = reader.readDateTime(offsets[2]);
  object.id = id;
  object.name = reader.readString(offsets[3]);
  object.targetAmount = reader.readLong(offsets[4]);
  return object;
}

P _isarGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarGoalGetId(IsarGoal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarGoalGetLinks(IsarGoal object) {
  return [];
}

void _isarGoalAttach(IsarCollection<dynamic> col, Id id, IsarGoal object) {
  object.id = id;
}

extension IsarGoalQueryWhereSort on QueryBuilder<IsarGoal, IsarGoal, QWhere> {
  QueryBuilder<IsarGoal, IsarGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarGoalQueryWhere on QueryBuilder<IsarGoal, IsarGoal, QWhereClause> {
  QueryBuilder<IsarGoal, IsarGoal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarGoalQueryFilter
    on QueryBuilder<IsarGoal, IsarGoal, QFilterCondition> {
  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition>
      categoryIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryIndex',
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition>
      categoryIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryIndex',
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> categoryIndexEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition>
      categoryIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> categoryIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> categoryIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> currentAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition>
      currentAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> currentAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> currentAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> deadlineEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> deadlineGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> deadlineLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> deadlineBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deadline',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> targetAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition>
      targetAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> targetAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterFilterCondition> targetAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarGoalQueryObject
    on QueryBuilder<IsarGoal, IsarGoal, QFilterCondition> {}

extension IsarGoalQueryLinks
    on QueryBuilder<IsarGoal, IsarGoal, QFilterCondition> {}

extension IsarGoalQuerySortBy on QueryBuilder<IsarGoal, IsarGoal, QSortBy> {
  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByCategoryIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByCurrentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }
}

extension IsarGoalQuerySortThenBy
    on QueryBuilder<IsarGoal, IsarGoal, QSortThenBy> {
  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByCategoryIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByCurrentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QAfterSortBy> thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }
}

extension IsarGoalQueryWhereDistinct
    on QueryBuilder<IsarGoal, IsarGoal, QDistinct> {
  QueryBuilder<IsarGoal, IsarGoal, QDistinct> distinctByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryIndex');
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QDistinct> distinctByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentAmount');
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QDistinct> distinctByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deadline');
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarGoal, IsarGoal, QDistinct> distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetAmount');
    });
  }
}

extension IsarGoalQueryProperty
    on QueryBuilder<IsarGoal, IsarGoal, QQueryProperty> {
  QueryBuilder<IsarGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarGoal, int?, QQueryOperations> categoryIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryIndex');
    });
  }

  QueryBuilder<IsarGoal, int, QQueryOperations> currentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentAmount');
    });
  }

  QueryBuilder<IsarGoal, DateTime, QQueryOperations> deadlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deadline');
    });
  }

  QueryBuilder<IsarGoal, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarGoal, int, QQueryOperations> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetAmount');
    });
  }
}
