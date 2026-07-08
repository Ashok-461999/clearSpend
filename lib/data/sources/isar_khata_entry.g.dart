// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_khata_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarKhataEntryCollection on Isar {
  IsarCollection<IsarKhataEntry> get isarKhataEntrys => this.collection();
}

const IsarKhataEntrySchema = CollectionSchema(
  name: r'IsarKhataEntry',
  id: 2202827348491950434,
  properties: {
    r'amountMinor': PropertySchema(
      id: 0,
      name: r'amountMinor',
      type: IsarType.long,
    ),
    r'dateUtc': PropertySchema(
      id: 1,
      name: r'dateUtc',
      type: IsarType.dateTime,
    ),
    r'dueDate': PropertySchema(
      id: 2,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'personName': PropertySchema(
      id: 4,
      name: r'personName',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 5,
      name: r'phone',
      type: IsarType.string,
    ),
    r'typeIndex': PropertySchema(
      id: 6,
      name: r'typeIndex',
      type: IsarType.long,
    )
  },
  estimateSize: _isarKhataEntryEstimateSize,
  serialize: _isarKhataEntrySerialize,
  deserialize: _isarKhataEntryDeserialize,
  deserializeProp: _isarKhataEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'dateUtc': IndexSchema(
      id: 6496663728332232188,
      name: r'dateUtc',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateUtc',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarKhataEntryGetId,
  getLinks: _isarKhataEntryGetLinks,
  attach: _isarKhataEntryAttach,
  version: '3.1.0+1',
);

int _isarKhataEntryEstimateSize(
  IsarKhataEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.personName.length * 3;
  {
    final value = object.phone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarKhataEntrySerialize(
  IsarKhataEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amountMinor);
  writer.writeDateTime(offsets[1], object.dateUtc);
  writer.writeDateTime(offsets[2], object.dueDate);
  writer.writeString(offsets[3], object.notes);
  writer.writeString(offsets[4], object.personName);
  writer.writeString(offsets[5], object.phone);
  writer.writeLong(offsets[6], object.typeIndex);
}

IsarKhataEntry _isarKhataEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarKhataEntry();
  object.amountMinor = reader.readLong(offsets[0]);
  object.dateUtc = reader.readDateTime(offsets[1]);
  object.dueDate = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[3]);
  object.personName = reader.readString(offsets[4]);
  object.phone = reader.readStringOrNull(offsets[5]);
  object.typeIndex = reader.readLong(offsets[6]);
  return object;
}

P _isarKhataEntryDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarKhataEntryGetId(IsarKhataEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarKhataEntryGetLinks(IsarKhataEntry object) {
  return [];
}

void _isarKhataEntryAttach(
    IsarCollection<dynamic> col, Id id, IsarKhataEntry object) {
  object.id = id;
}

extension IsarKhataEntryQueryWhereSort
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QWhere> {
  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhere> anyDateUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateUtc'),
      );
    });
  }
}

extension IsarKhataEntryQueryWhere
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QWhereClause> {
  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause>
      dateUtcEqualTo(DateTime dateUtc) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateUtc',
        value: [dateUtc],
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause>
      dateUtcNotEqualTo(DateTime dateUtc) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateUtc',
              lower: [],
              upper: [dateUtc],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateUtc',
              lower: [dateUtc],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateUtc',
              lower: [dateUtc],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateUtc',
              lower: [],
              upper: [dateUtc],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause>
      dateUtcGreaterThan(
    DateTime dateUtc, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateUtc',
        lower: [dateUtc],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause>
      dateUtcLessThan(
    DateTime dateUtc, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateUtc',
        lower: [],
        upper: [dateUtc],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterWhereClause>
      dateUtcBetween(
    DateTime lowerDateUtc,
    DateTime upperDateUtc, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateUtc',
        lower: [lowerDateUtc],
        includeLower: includeLower,
        upper: [upperDateUtc],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarKhataEntryQueryFilter
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QFilterCondition> {
  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      amountMinorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      amountMinorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      amountMinorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountMinor',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      amountMinorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountMinor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dateUtcEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateUtc',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dateUtcGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateUtc',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dateUtcLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateUtc',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dateUtcBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateUtc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dueDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      dueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesEqualTo(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesGreaterThan(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesLessThan(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesBetween(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesStartsWith(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesEndsWith(
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

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      typeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      typeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'typeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      typeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'typeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterFilterCondition>
      typeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'typeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarKhataEntryQueryObject
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QFilterCondition> {}

extension IsarKhataEntryQueryLinks
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QFilterCondition> {}

extension IsarKhataEntryQuerySortBy
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QSortBy> {
  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByDateUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateUtc', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByDateUtcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateUtc', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> sortByTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      sortByTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.desc);
    });
  }
}

extension IsarKhataEntryQuerySortThenBy
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QSortThenBy> {
  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByAmountMinorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountMinor', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByDateUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateUtc', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByDateUtcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateUtc', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy> thenByTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QAfterSortBy>
      thenByTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeIndex', Sort.desc);
    });
  }
}

extension IsarKhataEntryQueryWhereDistinct
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct> {
  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct>
      distinctByAmountMinor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountMinor');
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct> distinctByDateUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateUtc');
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct> distinctByPersonName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarKhataEntry, IsarKhataEntry, QDistinct>
      distinctByTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typeIndex');
    });
  }
}

extension IsarKhataEntryQueryProperty
    on QueryBuilder<IsarKhataEntry, IsarKhataEntry, QQueryProperty> {
  QueryBuilder<IsarKhataEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarKhataEntry, int, QQueryOperations> amountMinorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountMinor');
    });
  }

  QueryBuilder<IsarKhataEntry, DateTime, QQueryOperations> dateUtcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateUtc');
    });
  }

  QueryBuilder<IsarKhataEntry, DateTime?, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<IsarKhataEntry, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<IsarKhataEntry, String, QQueryOperations> personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personName');
    });
  }

  QueryBuilder<IsarKhataEntry, String?, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<IsarKhataEntry, int, QQueryOperations> typeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typeIndex');
    });
  }
}
