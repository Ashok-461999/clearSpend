// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_trade.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarTradeCollection on Isar {
  IsarCollection<IsarTrade> get isarTrades => this.collection();
}

const IsarTradeSchema = CollectionSchema(
  name: r'IsarTrade',
  id: 5397773260770461601,
  properties: {
    r'brokerage': PropertySchema(
      id: 0,
      name: r'brokerage',
      type: IsarType.long,
    ),
    r'entryDate': PropertySchema(
      id: 1,
      name: r'entryDate',
      type: IsarType.dateTime,
    ),
    r'entryPrice': PropertySchema(
      id: 2,
      name: r'entryPrice',
      type: IsarType.long,
    ),
    r'exitDate': PropertySchema(
      id: 3,
      name: r'exitDate',
      type: IsarType.dateTime,
    ),
    r'exitPrice': PropertySchema(
      id: 4,
      name: r'exitPrice',
      type: IsarType.long,
    ),
    r'instrumentName': PropertySchema(
      id: 5,
      name: r'instrumentName',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 6,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'statusIndex': PropertySchema(
      id: 7,
      name: r'statusIndex',
      type: IsarType.long,
    ),
    r'tradeTypeIndex': PropertySchema(
      id: 8,
      name: r'tradeTypeIndex',
      type: IsarType.long,
    )
  },
  estimateSize: _isarTradeEstimateSize,
  serialize: _isarTradeSerialize,
  deserialize: _isarTradeDeserialize,
  deserializeProp: _isarTradeDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarTradeGetId,
  getLinks: _isarTradeGetLinks,
  attach: _isarTradeAttach,
  version: '3.1.0+1',
);

int _isarTradeEstimateSize(
  IsarTrade object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.instrumentName.length * 3;
  return bytesCount;
}

void _isarTradeSerialize(
  IsarTrade object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.brokerage);
  writer.writeDateTime(offsets[1], object.entryDate);
  writer.writeLong(offsets[2], object.entryPrice);
  writer.writeDateTime(offsets[3], object.exitDate);
  writer.writeLong(offsets[4], object.exitPrice);
  writer.writeString(offsets[5], object.instrumentName);
  writer.writeDouble(offsets[6], object.quantity);
  writer.writeLong(offsets[7], object.statusIndex);
  writer.writeLong(offsets[8], object.tradeTypeIndex);
}

IsarTrade _isarTradeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarTrade();
  object.brokerage = reader.readLong(offsets[0]);
  object.entryDate = reader.readDateTime(offsets[1]);
  object.entryPrice = reader.readLong(offsets[2]);
  object.exitDate = reader.readDateTimeOrNull(offsets[3]);
  object.exitPrice = reader.readLongOrNull(offsets[4]);
  object.id = id;
  object.instrumentName = reader.readString(offsets[5]);
  object.quantity = reader.readDouble(offsets[6]);
  object.statusIndex = reader.readLong(offsets[7]);
  object.tradeTypeIndex = reader.readLong(offsets[8]);
  return object;
}

P _isarTradeDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarTradeGetId(IsarTrade object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarTradeGetLinks(IsarTrade object) {
  return [];
}

void _isarTradeAttach(IsarCollection<dynamic> col, Id id, IsarTrade object) {
  object.id = id;
}

extension IsarTradeQueryWhereSort
    on QueryBuilder<IsarTrade, IsarTrade, QWhere> {
  QueryBuilder<IsarTrade, IsarTrade, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarTradeQueryWhere
    on QueryBuilder<IsarTrade, IsarTrade, QWhereClause> {
  QueryBuilder<IsarTrade, IsarTrade, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarTrade, IsarTrade, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterWhereClause> idBetween(
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

extension IsarTradeQueryFilter
    on QueryBuilder<IsarTrade, IsarTrade, QFilterCondition> {
  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> brokerageEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brokerage',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      brokerageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brokerage',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> brokerageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brokerage',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> brokerageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brokerage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> entryDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      entryDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> entryDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> entryDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> entryPriceEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryPrice',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      entryPriceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entryPrice',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> entryPriceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entryPrice',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> entryPriceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entryPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'exitDate',
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      exitDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'exitDate',
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exitDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitPriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'exitPrice',
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      exitPriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'exitPrice',
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitPriceEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exitPrice',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      exitPriceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exitPrice',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitPriceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exitPrice',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> exitPriceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exitPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instrumentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'instrumentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'instrumentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'instrumentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'instrumentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'instrumentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'instrumentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'instrumentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instrumentName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      instrumentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'instrumentName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> quantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> quantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> quantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> quantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> statusIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      statusIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> statusIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition> statusIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      tradeTypeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tradeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      tradeTypeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tradeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      tradeTypeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tradeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterFilterCondition>
      tradeTypeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tradeTypeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarTradeQueryObject
    on QueryBuilder<IsarTrade, IsarTrade, QFilterCondition> {}

extension IsarTradeQueryLinks
    on QueryBuilder<IsarTrade, IsarTrade, QFilterCondition> {}

extension IsarTradeQuerySortBy on QueryBuilder<IsarTrade, IsarTrade, QSortBy> {
  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByBrokerage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerage', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByBrokerageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerage', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByEntryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryDate', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByEntryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryDate', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByEntryPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryPrice', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByEntryPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryPrice', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByExitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByExitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByExitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitPrice', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByExitPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitPrice', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByInstrumentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instrumentName', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByInstrumentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instrumentName', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByStatusIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByStatusIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByTradeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tradeTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> sortByTradeTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tradeTypeIndex', Sort.desc);
    });
  }
}

extension IsarTradeQuerySortThenBy
    on QueryBuilder<IsarTrade, IsarTrade, QSortThenBy> {
  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByBrokerage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerage', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByBrokerageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brokerage', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByEntryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryDate', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByEntryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryDate', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByEntryPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryPrice', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByEntryPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryPrice', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByExitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByExitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitDate', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByExitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitPrice', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByExitPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exitPrice', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByInstrumentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instrumentName', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByInstrumentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instrumentName', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByStatusIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByStatusIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByTradeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tradeTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QAfterSortBy> thenByTradeTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tradeTypeIndex', Sort.desc);
    });
  }
}

extension IsarTradeQueryWhereDistinct
    on QueryBuilder<IsarTrade, IsarTrade, QDistinct> {
  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByBrokerage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brokerage');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByEntryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryDate');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByEntryPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryPrice');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByExitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exitDate');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByExitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exitPrice');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByInstrumentName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instrumentName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByStatusIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusIndex');
    });
  }

  QueryBuilder<IsarTrade, IsarTrade, QDistinct> distinctByTradeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tradeTypeIndex');
    });
  }
}

extension IsarTradeQueryProperty
    on QueryBuilder<IsarTrade, IsarTrade, QQueryProperty> {
  QueryBuilder<IsarTrade, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarTrade, int, QQueryOperations> brokerageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brokerage');
    });
  }

  QueryBuilder<IsarTrade, DateTime, QQueryOperations> entryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryDate');
    });
  }

  QueryBuilder<IsarTrade, int, QQueryOperations> entryPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryPrice');
    });
  }

  QueryBuilder<IsarTrade, DateTime?, QQueryOperations> exitDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exitDate');
    });
  }

  QueryBuilder<IsarTrade, int?, QQueryOperations> exitPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exitPrice');
    });
  }

  QueryBuilder<IsarTrade, String, QQueryOperations> instrumentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instrumentName');
    });
  }

  QueryBuilder<IsarTrade, double, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<IsarTrade, int, QQueryOperations> statusIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusIndex');
    });
  }

  QueryBuilder<IsarTrade, int, QQueryOperations> tradeTypeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tradeTypeIndex');
    });
  }
}
