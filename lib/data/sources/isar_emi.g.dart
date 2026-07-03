// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_emi.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarEmiCollection on Isar {
  IsarCollection<IsarEmi> get isarEmis => this.collection();
}

const IsarEmiSchema = CollectionSchema(
  name: r'IsarEmi',
  id: -8089507739191619762,
  properties: {
    r'categoryIndex': PropertySchema(
      id: 0,
      name: r'categoryIndex',
      type: IsarType.long,
    ),
    r'monthlyAmountMinor': PropertySchema(
      id: 1,
      name: r'monthlyAmountMinor',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'paidMonths': PropertySchema(
      id: 4,
      name: r'paidMonths',
      type: IsarType.long,
    ),
    r'startDate': PropertySchema(
      id: 5,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'totalAmountMinor': PropertySchema(
      id: 6,
      name: r'totalAmountMinor',
      type: IsarType.long,
    ),
    r'totalMonths': PropertySchema(
      id: 7,
      name: r'totalMonths',
      type: IsarType.long,
    )
  },
  estimateSize: _isarEmiEstimateSize,
  serialize: _isarEmiSerialize,
  deserialize: _isarEmiDeserialize,
  deserializeProp: _isarEmiDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarEmiGetId,
  getLinks: _isarEmiGetLinks,
  attach: _isarEmiAttach,
  version: '3.1.0+1',
);

int _isarEmiEstimateSize(
  IsarEmi object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarEmiSerialize(
  IsarEmi object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryIndex);
  writer.writeLong(offsets[1], object.monthlyAmountMinor);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.paidMonths);
  writer.writeDateTime(offsets[5], object.startDate);
  writer.writeLong(offsets[6], object.totalAmountMinor);
  writer.writeLong(offsets[7], object.totalMonths);
}

IsarEmi _isarEmiDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarEmi();
  object.categoryIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.monthlyAmountMinor = reader.readLong(offsets[1]);
  object.name = reader.readString(offsets[2]);
  object.notes = reader.readStringOrNull(offsets[3]);
  object.paidMonths = reader.readLong(offsets[4]);
  object.startDate = reader.readDateTime(offsets[5]);
  object.totalAmountMinor = reader.readLong(offsets[6]);
  object.totalMonths = reader.readLong(offsets[7]);
  return object;
}

P _isarEmiDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarEmiGetId(IsarEmi object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarEmiGetLinks(IsarEmi object) {
  return [];
}

void _isarEmiAttach(IsarCollection<dynamic> col, Id id, IsarEmi object) {
  object.id = id;
}

extension IsarEmiQueryWhereSort on QueryBuilder<IsarEmi, IsarEmi, QWhere> {
  QueryBuilder<IsarEmi, IsarEmi, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarEmiQueryWhere on QueryBuilder<IsarEmi, IsarEmi, QWhereClause> {
  QueryBuilder<IsarEmi, IsarEmi, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterWhereClause> idBetween(
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

extension IsarEmiQueryFilter
    on QueryBuilder<IsarEmi, IsarEmi, QFilterCondition> {
  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> categoryIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> categoryIndexLessThan(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> categoryIndexBetween(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
      monthlyAmountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthlyAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
      monthlyAmountMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthlyAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
      monthlyAmountMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthlyAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
      monthlyAmountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthlyAmountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameContains(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> paidMonthsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> paidMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> paidMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> paidMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> startDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> totalAmountMinorEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
      totalAmountMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition>
      totalAmountMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> totalAmountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> totalMonthsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> totalMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> totalMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterFilterCondition> totalMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarEmiQueryObject
    on QueryBuilder<IsarEmi, IsarEmi, QFilterCondition> {}

extension IsarEmiQueryLinks
    on QueryBuilder<IsarEmi, IsarEmi, QFilterCondition> {}

extension IsarEmiQuerySortBy on QueryBuilder<IsarEmi, IsarEmi, QSortBy> {
  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByCategoryIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByMonthlyAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByMonthlyAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByPaidMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByPaidMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByTotalAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByTotalAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByTotalMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> sortByTotalMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMonths', Sort.desc);
    });
  }
}

extension IsarEmiQuerySortThenBy
    on QueryBuilder<IsarEmi, IsarEmi, QSortThenBy> {
  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByCategoryIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByMonthlyAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByMonthlyAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByPaidMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByPaidMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidMonths', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByTotalAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByTotalAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmountMinor', Sort.desc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByTotalMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMonths', Sort.asc);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QAfterSortBy> thenByTotalMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMonths', Sort.desc);
    });
  }
}

extension IsarEmiQueryWhereDistinct
    on QueryBuilder<IsarEmi, IsarEmi, QDistinct> {
  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByCategoryIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryIndex');
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByMonthlyAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyAmountMinor');
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByPaidMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidMonths');
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByTotalAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmountMinor');
    });
  }

  QueryBuilder<IsarEmi, IsarEmi, QDistinct> distinctByTotalMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMonths');
    });
  }
}

extension IsarEmiQueryProperty
    on QueryBuilder<IsarEmi, IsarEmi, QQueryProperty> {
  QueryBuilder<IsarEmi, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarEmi, int, QQueryOperations> categoryIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryIndex');
    });
  }

  QueryBuilder<IsarEmi, int, QQueryOperations> monthlyAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyAmountMinor');
    });
  }

  QueryBuilder<IsarEmi, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<IsarEmi, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarEmi, int, QQueryOperations> paidMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidMonths');
    });
  }

  QueryBuilder<IsarEmi, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<IsarEmi, int, QQueryOperations> totalAmountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmountMinor');
    });
  }

  QueryBuilder<IsarEmi, int, QQueryOperations> totalMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMonths');
    });
  }
}
