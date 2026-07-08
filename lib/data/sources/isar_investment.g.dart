// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_investment.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarInvestmentCollection on Isar {
  IsarCollection<IsarInvestment> get isarInvestments => this.collection();
}

const IsarInvestmentSchema = CollectionSchema(
  name: r'IsarInvestment',
  id: 2006766343607449152,
  properties: {
    r'assetTypeIndex': PropertySchema(
      id: 0,
      name: r'assetTypeIndex',
      type: IsarType.long,
    ),
    r'buyPricePerUnit': PropertySchema(
      id: 1,
      name: r'buyPricePerUnit',
      type: IsarType.long,
    ),
    r'currentPricePerUnit': PropertySchema(
      id: 2,
      name: r'currentPricePerUnit',
      type: IsarType.long,
    ),
    r'folioNumber': PropertySchema(
      id: 3,
      name: r'folioNumber',
      type: IsarType.string,
    ),
    r'interestRate': PropertySchema(
      id: 4,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'investedDate': PropertySchema(
      id: 5,
      name: r'investedDate',
      type: IsarType.dateTime,
    ),
    r'isSip': PropertySchema(
      id: 6,
      name: r'isSip',
      type: IsarType.bool,
    ),
    r'lastUpdatedAt': PropertySchema(
      id: 7,
      name: r'lastUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'maturityDate': PropertySchema(
      id: 8,
      name: r'maturityDate',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'sipAmount': PropertySchema(
      id: 10,
      name: r'sipAmount',
      type: IsarType.long,
    ),
    r'sipEndDate': PropertySchema(
      id: 11,
      name: r'sipEndDate',
      type: IsarType.dateTime,
    ),
    r'sipFrequency': PropertySchema(
      id: 12,
      name: r'sipFrequency',
      type: IsarType.string,
    ),
    r'sipStartDate': PropertySchema(
      id: 13,
      name: r'sipStartDate',
      type: IsarType.dateTime,
    ),
    r'units': PropertySchema(
      id: 14,
      name: r'units',
      type: IsarType.double,
    )
  },
  estimateSize: _isarInvestmentEstimateSize,
  serialize: _isarInvestmentSerialize,
  deserialize: _isarInvestmentDeserialize,
  deserializeProp: _isarInvestmentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarInvestmentGetId,
  getLinks: _isarInvestmentGetLinks,
  attach: _isarInvestmentAttach,
  version: '3.1.0+1',
);

int _isarInvestmentEstimateSize(
  IsarInvestment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.folioNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.sipFrequency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarInvestmentSerialize(
  IsarInvestment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.assetTypeIndex);
  writer.writeLong(offsets[1], object.buyPricePerUnit);
  writer.writeLong(offsets[2], object.currentPricePerUnit);
  writer.writeString(offsets[3], object.folioNumber);
  writer.writeDouble(offsets[4], object.interestRate);
  writer.writeDateTime(offsets[5], object.investedDate);
  writer.writeBool(offsets[6], object.isSip);
  writer.writeDateTime(offsets[7], object.lastUpdatedAt);
  writer.writeDateTime(offsets[8], object.maturityDate);
  writer.writeString(offsets[9], object.name);
  writer.writeLong(offsets[10], object.sipAmount);
  writer.writeDateTime(offsets[11], object.sipEndDate);
  writer.writeString(offsets[12], object.sipFrequency);
  writer.writeDateTime(offsets[13], object.sipStartDate);
  writer.writeDouble(offsets[14], object.units);
}

IsarInvestment _isarInvestmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarInvestment();
  object.assetTypeIndex = reader.readLong(offsets[0]);
  object.buyPricePerUnit = reader.readLong(offsets[1]);
  object.currentPricePerUnit = reader.readLong(offsets[2]);
  object.folioNumber = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.interestRate = reader.readDoubleOrNull(offsets[4]);
  object.investedDate = reader.readDateTime(offsets[5]);
  object.isSip = reader.readBool(offsets[6]);
  object.lastUpdatedAt = reader.readDateTimeOrNull(offsets[7]);
  object.maturityDate = reader.readDateTimeOrNull(offsets[8]);
  object.name = reader.readString(offsets[9]);
  object.sipAmount = reader.readLongOrNull(offsets[10]);
  object.sipEndDate = reader.readDateTimeOrNull(offsets[11]);
  object.sipFrequency = reader.readStringOrNull(offsets[12]);
  object.sipStartDate = reader.readDateTimeOrNull(offsets[13]);
  object.units = reader.readDouble(offsets[14]);
  return object;
}

P _isarInvestmentDeserializeProp<P>(
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
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarInvestmentGetId(IsarInvestment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarInvestmentGetLinks(IsarInvestment object) {
  return [];
}

void _isarInvestmentAttach(
    IsarCollection<dynamic> col, Id id, IsarInvestment object) {
  object.id = id;
}

extension IsarInvestmentQueryWhereSort
    on QueryBuilder<IsarInvestment, IsarInvestment, QWhere> {
  QueryBuilder<IsarInvestment, IsarInvestment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarInvestmentQueryWhere
    on QueryBuilder<IsarInvestment, IsarInvestment, QWhereClause> {
  QueryBuilder<IsarInvestment, IsarInvestment, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterWhereClause> idBetween(
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

extension IsarInvestmentQueryFilter
    on QueryBuilder<IsarInvestment, IsarInvestment, QFilterCondition> {
  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      assetTypeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      assetTypeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      assetTypeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      assetTypeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetTypeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      buyPricePerUnitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buyPricePerUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      buyPricePerUnitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'buyPricePerUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      buyPricePerUnitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'buyPricePerUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      buyPricePerUnitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'buyPricePerUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      currentPricePerUnitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentPricePerUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      currentPricePerUnitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentPricePerUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      currentPricePerUnitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentPricePerUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      currentPricePerUnitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentPricePerUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'folioNumber',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'folioNumber',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'folioNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'folioNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'folioNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'folioNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'folioNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'folioNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'folioNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'folioNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'folioNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      folioNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'folioNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      interestRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'interestRate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      interestRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'interestRate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      interestRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      interestRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      interestRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      interestRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interestRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      investedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      investedDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      investedDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      investedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      isSipEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSip',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      lastUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdatedAt',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      lastUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdatedAt',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      lastUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      lastUpdatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      lastUpdatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      lastUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      maturityDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maturityDate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      maturityDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maturityDate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      maturityDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maturityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      maturityDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maturityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      maturityDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maturityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      maturityDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maturityDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sipAmount',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sipAmount',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipAmountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sipAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipAmountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sipAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipAmountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sipAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipAmountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sipAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sipEndDate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sipEndDate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipEndDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sipEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipEndDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sipEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipEndDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sipEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipEndDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sipEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sipFrequency',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sipFrequency',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sipFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sipFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sipFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sipFrequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sipFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sipFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sipFrequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sipFrequency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sipFrequency',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipFrequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sipFrequency',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sipStartDate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sipStartDate',
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipStartDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sipStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sipStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sipStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      sipStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sipStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      unitsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'units',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      unitsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'units',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      unitsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'units',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterFilterCondition>
      unitsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'units',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension IsarInvestmentQueryObject
    on QueryBuilder<IsarInvestment, IsarInvestment, QFilterCondition> {}

extension IsarInvestmentQueryLinks
    on QueryBuilder<IsarInvestment, IsarInvestment, QFilterCondition> {}

extension IsarInvestmentQuerySortBy
    on QueryBuilder<IsarInvestment, IsarInvestment, QSortBy> {
  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByAssetTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByAssetTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByBuyPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPricePerUnit', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByBuyPricePerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPricePerUnit', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByCurrentPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPricePerUnit', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByCurrentPricePerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPricePerUnit', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByFolioNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folioNumber', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByFolioNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folioNumber', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByInvestedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByInvestedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortByIsSip() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSip', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortByIsSipDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSip', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByMaturityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortByMaturityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortBySipAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipEndDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipEndDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipFrequency', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipFrequency', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipStartDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      sortBySipStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipStartDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> sortByUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.desc);
    });
  }
}

extension IsarInvestmentQuerySortThenBy
    on QueryBuilder<IsarInvestment, IsarInvestment, QSortThenBy> {
  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByAssetTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByAssetTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByBuyPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPricePerUnit', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByBuyPricePerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buyPricePerUnit', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByCurrentPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPricePerUnit', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByCurrentPricePerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentPricePerUnit', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByFolioNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folioNumber', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByFolioNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folioNumber', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByInvestedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByInvestedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByIsSip() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSip', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByIsSipDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSip', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByMaturityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenByMaturityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maturityDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenBySipAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipAmount', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipEndDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipEndDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipFrequency', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipFrequency', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipStartDate', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy>
      thenBySipStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sipStartDate', Sort.desc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.asc);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QAfterSortBy> thenByUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.desc);
    });
  }
}

extension IsarInvestmentQueryWhereDistinct
    on QueryBuilder<IsarInvestment, IsarInvestment, QDistinct> {
  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByAssetTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetTypeIndex');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByBuyPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'buyPricePerUnit');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByCurrentPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentPricePerUnit');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct> distinctByFolioNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folioNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestRate');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByInvestedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investedDate');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct> distinctByIsSip() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSip');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedAt');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctByMaturityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maturityDate');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctBySipAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sipAmount');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctBySipEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sipEndDate');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctBySipFrequency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sipFrequency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct>
      distinctBySipStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sipStartDate');
    });
  }

  QueryBuilder<IsarInvestment, IsarInvestment, QDistinct> distinctByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'units');
    });
  }
}

extension IsarInvestmentQueryProperty
    on QueryBuilder<IsarInvestment, IsarInvestment, QQueryProperty> {
  QueryBuilder<IsarInvestment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarInvestment, int, QQueryOperations> assetTypeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetTypeIndex');
    });
  }

  QueryBuilder<IsarInvestment, int, QQueryOperations>
      buyPricePerUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'buyPricePerUnit');
    });
  }

  QueryBuilder<IsarInvestment, int, QQueryOperations>
      currentPricePerUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentPricePerUnit');
    });
  }

  QueryBuilder<IsarInvestment, String?, QQueryOperations>
      folioNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folioNumber');
    });
  }

  QueryBuilder<IsarInvestment, double?, QQueryOperations>
      interestRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestRate');
    });
  }

  QueryBuilder<IsarInvestment, DateTime, QQueryOperations>
      investedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investedDate');
    });
  }

  QueryBuilder<IsarInvestment, bool, QQueryOperations> isSipProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSip');
    });
  }

  QueryBuilder<IsarInvestment, DateTime?, QQueryOperations>
      lastUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedAt');
    });
  }

  QueryBuilder<IsarInvestment, DateTime?, QQueryOperations>
      maturityDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maturityDate');
    });
  }

  QueryBuilder<IsarInvestment, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarInvestment, int?, QQueryOperations> sipAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sipAmount');
    });
  }

  QueryBuilder<IsarInvestment, DateTime?, QQueryOperations>
      sipEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sipEndDate');
    });
  }

  QueryBuilder<IsarInvestment, String?, QQueryOperations>
      sipFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sipFrequency');
    });
  }

  QueryBuilder<IsarInvestment, DateTime?, QQueryOperations>
      sipStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sipStartDate');
    });
  }

  QueryBuilder<IsarInvestment, double, QQueryOperations> unitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'units');
    });
  }
}
