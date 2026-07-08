// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_category_budget.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarCategoryBudgetCollection on Isar {
  IsarCollection<IsarCategoryBudget> get isarCategoryBudgets =>
      this.collection();
}

const IsarCategoryBudgetSchema = CollectionSchema(
  name: r'IsarCategoryBudget',
  id: -3272857232250791657,
  properties: {
    r'categoryIndex': PropertySchema(
      id: 0,
      name: r'categoryIndex',
      type: IsarType.long,
    ),
    r'monthlyLimit': PropertySchema(
      id: 1,
      name: r'monthlyLimit',
      type: IsarType.long,
    ),
    r'yearMonth': PropertySchema(
      id: 2,
      name: r'yearMonth',
      type: IsarType.long,
    )
  },
  estimateSize: _isarCategoryBudgetEstimateSize,
  serialize: _isarCategoryBudgetSerialize,
  deserialize: _isarCategoryBudgetDeserialize,
  deserializeProp: _isarCategoryBudgetDeserializeProp,
  idName: r'id',
  indexes: {
    r'yearMonth': IndexSchema(
      id: 5465596700411800841,
      name: r'yearMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'yearMonth',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarCategoryBudgetGetId,
  getLinks: _isarCategoryBudgetGetLinks,
  attach: _isarCategoryBudgetAttach,
  version: '3.1.0+1',
);

int _isarCategoryBudgetEstimateSize(
  IsarCategoryBudget object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _isarCategoryBudgetSerialize(
  IsarCategoryBudget object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryIndex);
  writer.writeLong(offsets[1], object.monthlyLimit);
  writer.writeLong(offsets[2], object.yearMonth);
}

IsarCategoryBudget _isarCategoryBudgetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCategoryBudget();
  object.categoryIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.monthlyLimit = reader.readLong(offsets[1]);
  object.yearMonth = reader.readLong(offsets[2]);
  return object;
}

P _isarCategoryBudgetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCategoryBudgetGetId(IsarCategoryBudget object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCategoryBudgetGetLinks(
    IsarCategoryBudget object) {
  return [];
}

void _isarCategoryBudgetAttach(
    IsarCollection<dynamic> col, Id id, IsarCategoryBudget object) {
  object.id = id;
}

extension IsarCategoryBudgetQueryWhereSort
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QWhere> {
  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhere>
      anyYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'yearMonth'),
      );
    });
  }
}

extension IsarCategoryBudgetQueryWhere
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QWhereClause> {
  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      yearMonthEqualTo(int yearMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'yearMonth',
        value: [yearMonth],
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      yearMonthNotEqualTo(int yearMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [],
              upper: [yearMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [yearMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [yearMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'yearMonth',
              lower: [],
              upper: [yearMonth],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      yearMonthGreaterThan(
    int yearMonth, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'yearMonth',
        lower: [yearMonth],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      yearMonthLessThan(
    int yearMonth, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'yearMonth',
        lower: [],
        upper: [yearMonth],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterWhereClause>
      yearMonthBetween(
    int lowerYearMonth,
    int upperYearMonth, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'yearMonth',
        lower: [lowerYearMonth],
        includeLower: includeLower,
        upper: [upperYearMonth],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarCategoryBudgetQueryFilter
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QFilterCondition> {
  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      categoryIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      categoryIndexGreaterThan(
    int value, {
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      categoryIndexLessThan(
    int value, {
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      categoryIndexBetween(
    int lower,
    int upper, {
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      monthlyLimitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthlyLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      monthlyLimitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthlyLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      monthlyLimitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthlyLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      monthlyLimitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthlyLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      yearMonthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      yearMonthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'yearMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      yearMonthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'yearMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterFilterCondition>
      yearMonthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'yearMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarCategoryBudgetQueryObject
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QFilterCondition> {}

extension IsarCategoryBudgetQueryLinks
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QFilterCondition> {}

extension IsarCategoryBudgetQuerySortBy
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QSortBy> {
  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      sortByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      sortByCategoryIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      sortByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      sortByMonthlyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.desc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      sortByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      sortByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension IsarCategoryBudgetQuerySortThenBy
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QSortThenBy> {
  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByCategoryIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByMonthlyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.desc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.asc);
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QAfterSortBy>
      thenByYearMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearMonth', Sort.desc);
    });
  }
}

extension IsarCategoryBudgetQueryWhereDistinct
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QDistinct> {
  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QDistinct>
      distinctByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryIndex');
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QDistinct>
      distinctByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyLimit');
    });
  }

  QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QDistinct>
      distinctByYearMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearMonth');
    });
  }
}

extension IsarCategoryBudgetQueryProperty
    on QueryBuilder<IsarCategoryBudget, IsarCategoryBudget, QQueryProperty> {
  QueryBuilder<IsarCategoryBudget, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCategoryBudget, int, QQueryOperations>
      categoryIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryIndex');
    });
  }

  QueryBuilder<IsarCategoryBudget, int, QQueryOperations>
      monthlyLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyLimit');
    });
  }

  QueryBuilder<IsarCategoryBudget, int, QQueryOperations> yearMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearMonth');
    });
  }
}
