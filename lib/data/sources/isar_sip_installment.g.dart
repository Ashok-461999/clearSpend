// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_sip_installment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarSipInstallmentCollection on Isar {
  IsarCollection<IsarSipInstallment> get isarSipInstallments =>
      this.collection();
}

const IsarSipInstallmentSchema = CollectionSchema(
  name: r'IsarSipInstallment',
  id: 1330326978199455982,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'investmentId': PropertySchema(
      id: 2,
      name: r'investmentId',
      type: IsarType.long,
    ),
    r'nav': PropertySchema(
      id: 3,
      name: r'nav',
      type: IsarType.double,
    ),
    r'unitsAllotted': PropertySchema(
      id: 4,
      name: r'unitsAllotted',
      type: IsarType.double,
    )
  },
  estimateSize: _isarSipInstallmentEstimateSize,
  serialize: _isarSipInstallmentSerialize,
  deserialize: _isarSipInstallmentDeserialize,
  deserializeProp: _isarSipInstallmentDeserializeProp,
  idName: r'id',
  indexes: {
    r'investmentId': IndexSchema(
      id: -3849362565578961807,
      name: r'investmentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'investmentId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarSipInstallmentGetId,
  getLinks: _isarSipInstallmentGetLinks,
  attach: _isarSipInstallmentAttach,
  version: '3.1.0+1',
);

int _isarSipInstallmentEstimateSize(
  IsarSipInstallment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _isarSipInstallmentSerialize(
  IsarSipInstallment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeLong(offsets[2], object.investmentId);
  writer.writeDouble(offsets[3], object.nav);
  writer.writeDouble(offsets[4], object.unitsAllotted);
}

IsarSipInstallment _isarSipInstallmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarSipInstallment();
  object.amount = reader.readLong(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.id = id;
  object.investmentId = reader.readLong(offsets[2]);
  object.nav = reader.readDoubleOrNull(offsets[3]);
  object.unitsAllotted = reader.readDoubleOrNull(offsets[4]);
  return object;
}

P _isarSipInstallmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarSipInstallmentGetId(IsarSipInstallment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarSipInstallmentGetLinks(
    IsarSipInstallment object) {
  return [];
}

void _isarSipInstallmentAttach(
    IsarCollection<dynamic> col, Id id, IsarSipInstallment object) {
  object.id = id;
}

extension IsarSipInstallmentQueryWhereSort
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QWhere> {
  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhere>
      anyInvestmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'investmentId'),
      );
    });
  }
}

extension IsarSipInstallmentQueryWhere
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QWhereClause> {
  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
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

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
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

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      investmentIdEqualTo(int investmentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'investmentId',
        value: [investmentId],
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      investmentIdNotEqualTo(int investmentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'investmentId',
              lower: [],
              upper: [investmentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'investmentId',
              lower: [investmentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'investmentId',
              lower: [investmentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'investmentId',
              lower: [],
              upper: [investmentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      investmentIdGreaterThan(
    int investmentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'investmentId',
        lower: [investmentId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      investmentIdLessThan(
    int investmentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'investmentId',
        lower: [],
        upper: [investmentId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterWhereClause>
      investmentIdBetween(
    int lowerInvestmentId,
    int upperInvestmentId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'investmentId',
        lower: [lowerInvestmentId],
        includeLower: includeLower,
        upper: [upperInvestmentId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarSipInstallmentQueryFilter
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QFilterCondition> {
  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      amountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      amountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      amountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
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

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
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

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
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

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      investmentIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      investmentIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      investmentIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      investmentIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      navIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nav',
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      navIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nav',
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      navEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nav',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      navGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nav',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      navLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nav',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      navBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nav',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      unitsAllottedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unitsAllotted',
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      unitsAllottedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unitsAllotted',
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      unitsAllottedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitsAllotted',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      unitsAllottedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitsAllotted',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      unitsAllottedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitsAllotted',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterFilterCondition>
      unitsAllottedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitsAllotted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarSipInstallmentQueryObject
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QFilterCondition> {}

extension IsarSipInstallmentQueryLinks
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QFilterCondition> {}

extension IsarSipInstallmentQuerySortBy
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QSortBy> {
  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByInvestmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentId', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByInvestmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentId', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByNav() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nav', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByNavDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nav', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByUnitsAllotted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsAllotted', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      sortByUnitsAllottedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsAllotted', Sort.desc);
    });
  }
}

extension IsarSipInstallmentQuerySortThenBy
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QSortThenBy> {
  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByInvestmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentId', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByInvestmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investmentId', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByNav() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nav', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByNavDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nav', Sort.desc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByUnitsAllotted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsAllotted', Sort.asc);
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QAfterSortBy>
      thenByUnitsAllottedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitsAllotted', Sort.desc);
    });
  }
}

extension IsarSipInstallmentQueryWhereDistinct
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QDistinct> {
  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QDistinct>
      distinctByInvestmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investmentId');
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QDistinct>
      distinctByNav() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nav');
    });
  }

  QueryBuilder<IsarSipInstallment, IsarSipInstallment, QDistinct>
      distinctByUnitsAllotted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitsAllotted');
    });
  }
}

extension IsarSipInstallmentQueryProperty
    on QueryBuilder<IsarSipInstallment, IsarSipInstallment, QQueryProperty> {
  QueryBuilder<IsarSipInstallment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarSipInstallment, int, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<IsarSipInstallment, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<IsarSipInstallment, int, QQueryOperations>
      investmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investmentId');
    });
  }

  QueryBuilder<IsarSipInstallment, double?, QQueryOperations> navProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nav');
    });
  }

  QueryBuilder<IsarSipInstallment, double?, QQueryOperations>
      unitsAllottedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitsAllotted');
    });
  }
}
