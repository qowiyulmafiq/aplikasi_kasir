// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BarangTable extends Barang with TableInfo<$BarangTable, BarangData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarangTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
      'nama', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _kategoriMeta =
      const VerificationMeta('kategori');
  @override
  late final GeneratedColumn<String> kategori = GeneratedColumn<String>(
      'kategori', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hargaMeta = const VerificationMeta('harga');
  @override
  late final GeneratedColumn<int> harga = GeneratedColumn<int>(
      'harga', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gambarPathMeta =
      const VerificationMeta('gambarPath');
  @override
  late final GeneratedColumn<String> gambarPath = GeneratedColumn<String>(
      'gambar_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stokMeta = const VerificationMeta('stok');
  @override
  late final GeneratedColumn<int> stok = GeneratedColumn<int>(
      'stok', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stokMinimalMeta =
      const VerificationMeta('stokMinimal');
  @override
  late final GeneratedColumn<int> stokMinimal = GeneratedColumn<int>(
      'stok_minimal', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _kelolaStokMeta =
      const VerificationMeta('kelolaStok');
  @override
  late final GeneratedColumn<bool> kelolaStok = GeneratedColumn<bool>(
      'kelola_stok', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("kelola_stok" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nama,
        kategori,
        harga,
        gambarPath,
        stok,
        stokMinimal,
        kelolaStok,
        isSynced,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barang';
  @override
  VerificationContext validateIntegrity(Insertable<BarangData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
          _namaMeta, nama.isAcceptableOrUnknown(data['nama']!, _namaMeta));
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('kategori')) {
      context.handle(_kategoriMeta,
          kategori.isAcceptableOrUnknown(data['kategori']!, _kategoriMeta));
    } else if (isInserting) {
      context.missing(_kategoriMeta);
    }
    if (data.containsKey('harga')) {
      context.handle(
          _hargaMeta, harga.isAcceptableOrUnknown(data['harga']!, _hargaMeta));
    } else if (isInserting) {
      context.missing(_hargaMeta);
    }
    if (data.containsKey('gambar_path')) {
      context.handle(
          _gambarPathMeta,
          gambarPath.isAcceptableOrUnknown(
              data['gambar_path']!, _gambarPathMeta));
    }
    if (data.containsKey('stok')) {
      context.handle(
          _stokMeta, stok.isAcceptableOrUnknown(data['stok']!, _stokMeta));
    }
    if (data.containsKey('stok_minimal')) {
      context.handle(
          _stokMinimalMeta,
          stokMinimal.isAcceptableOrUnknown(
              data['stok_minimal']!, _stokMinimalMeta));
    }
    if (data.containsKey('kelola_stok')) {
      context.handle(
          _kelolaStokMeta,
          kelolaStok.isAcceptableOrUnknown(
              data['kelola_stok']!, _kelolaStokMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
  BarangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarangData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nama: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama'])!,
      kategori: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kategori'])!,
      harga: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}harga'])!,
      gambarPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gambar_path']),
      stok: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stok'])!,
      stokMinimal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stok_minimal'])!,
      kelolaStok: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}kelola_stok'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BarangTable createAlias(String alias) {
    return $BarangTable(attachedDatabase, alias);
  }
}

class BarangData extends DataClass implements Insertable<BarangData> {
  final int id;
  final String nama;
  final String kategori;
  final int harga;
  final String? gambarPath;
  final int stok;
  final int stokMinimal;
  final bool kelolaStok;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BarangData(
      {required this.id,
      required this.nama,
      required this.kategori,
      required this.harga,
      this.gambarPath,
      required this.stok,
      required this.stokMinimal,
      required this.kelolaStok,
      required this.isSynced,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama'] = Variable<String>(nama);
    map['kategori'] = Variable<String>(kategori);
    map['harga'] = Variable<int>(harga);
    if (!nullToAbsent || gambarPath != null) {
      map['gambar_path'] = Variable<String>(gambarPath);
    }
    map['stok'] = Variable<int>(stok);
    map['stok_minimal'] = Variable<int>(stokMinimal);
    map['kelola_stok'] = Variable<bool>(kelolaStok);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BarangCompanion toCompanion(bool nullToAbsent) {
    return BarangCompanion(
      id: Value(id),
      nama: Value(nama),
      kategori: Value(kategori),
      harga: Value(harga),
      gambarPath: gambarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(gambarPath),
      stok: Value(stok),
      stokMinimal: Value(stokMinimal),
      kelolaStok: Value(kelolaStok),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BarangData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarangData(
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      kategori: serializer.fromJson<String>(json['kategori']),
      harga: serializer.fromJson<int>(json['harga']),
      gambarPath: serializer.fromJson<String?>(json['gambarPath']),
      stok: serializer.fromJson<int>(json['stok']),
      stokMinimal: serializer.fromJson<int>(json['stokMinimal']),
      kelolaStok: serializer.fromJson<bool>(json['kelolaStok']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String>(nama),
      'kategori': serializer.toJson<String>(kategori),
      'harga': serializer.toJson<int>(harga),
      'gambarPath': serializer.toJson<String?>(gambarPath),
      'stok': serializer.toJson<int>(stok),
      'stokMinimal': serializer.toJson<int>(stokMinimal),
      'kelolaStok': serializer.toJson<bool>(kelolaStok),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BarangData copyWith(
          {int? id,
          String? nama,
          String? kategori,
          int? harga,
          Value<String?> gambarPath = const Value.absent(),
          int? stok,
          int? stokMinimal,
          bool? kelolaStok,
          bool? isSynced,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BarangData(
        id: id ?? this.id,
        nama: nama ?? this.nama,
        kategori: kategori ?? this.kategori,
        harga: harga ?? this.harga,
        gambarPath: gambarPath.present ? gambarPath.value : this.gambarPath,
        stok: stok ?? this.stok,
        stokMinimal: stokMinimal ?? this.stokMinimal,
        kelolaStok: kelolaStok ?? this.kelolaStok,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BarangData copyWithCompanion(BarangCompanion data) {
    return BarangData(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      kategori: data.kategori.present ? data.kategori.value : this.kategori,
      harga: data.harga.present ? data.harga.value : this.harga,
      gambarPath:
          data.gambarPath.present ? data.gambarPath.value : this.gambarPath,
      stok: data.stok.present ? data.stok.value : this.stok,
      stokMinimal:
          data.stokMinimal.present ? data.stokMinimal.value : this.stokMinimal,
      kelolaStok:
          data.kelolaStok.present ? data.kelolaStok.value : this.kelolaStok,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarangData(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('kategori: $kategori, ')
          ..write('harga: $harga, ')
          ..write('gambarPath: $gambarPath, ')
          ..write('stok: $stok, ')
          ..write('stokMinimal: $stokMinimal, ')
          ..write('kelolaStok: $kelolaStok, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama, kategori, harga, gambarPath, stok,
      stokMinimal, kelolaStok, isSynced, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarangData &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.kategori == this.kategori &&
          other.harga == this.harga &&
          other.gambarPath == this.gambarPath &&
          other.stok == this.stok &&
          other.stokMinimal == this.stokMinimal &&
          other.kelolaStok == this.kelolaStok &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BarangCompanion extends UpdateCompanion<BarangData> {
  final Value<int> id;
  final Value<String> nama;
  final Value<String> kategori;
  final Value<int> harga;
  final Value<String?> gambarPath;
  final Value<int> stok;
  final Value<int> stokMinimal;
  final Value<bool> kelolaStok;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BarangCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.kategori = const Value.absent(),
    this.harga = const Value.absent(),
    this.gambarPath = const Value.absent(),
    this.stok = const Value.absent(),
    this.stokMinimal = const Value.absent(),
    this.kelolaStok = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BarangCompanion.insert({
    this.id = const Value.absent(),
    required String nama,
    required String kategori,
    required int harga,
    this.gambarPath = const Value.absent(),
    this.stok = const Value.absent(),
    this.stokMinimal = const Value.absent(),
    this.kelolaStok = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : nama = Value(nama),
        kategori = Value(kategori),
        harga = Value(harga);
  static Insertable<BarangData> custom({
    Expression<int>? id,
    Expression<String>? nama,
    Expression<String>? kategori,
    Expression<int>? harga,
    Expression<String>? gambarPath,
    Expression<int>? stok,
    Expression<int>? stokMinimal,
    Expression<bool>? kelolaStok,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (kategori != null) 'kategori': kategori,
      if (harga != null) 'harga': harga,
      if (gambarPath != null) 'gambar_path': gambarPath,
      if (stok != null) 'stok': stok,
      if (stokMinimal != null) 'stok_minimal': stokMinimal,
      if (kelolaStok != null) 'kelola_stok': kelolaStok,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BarangCompanion copyWith(
      {Value<int>? id,
      Value<String>? nama,
      Value<String>? kategori,
      Value<int>? harga,
      Value<String?>? gambarPath,
      Value<int>? stok,
      Value<int>? stokMinimal,
      Value<bool>? kelolaStok,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BarangCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      gambarPath: gambarPath ?? this.gambarPath,
      stok: stok ?? this.stok,
      stokMinimal: stokMinimal ?? this.stokMinimal,
      kelolaStok: kelolaStok ?? this.kelolaStok,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (kategori.present) {
      map['kategori'] = Variable<String>(kategori.value);
    }
    if (harga.present) {
      map['harga'] = Variable<int>(harga.value);
    }
    if (gambarPath.present) {
      map['gambar_path'] = Variable<String>(gambarPath.value);
    }
    if (stok.present) {
      map['stok'] = Variable<int>(stok.value);
    }
    if (stokMinimal.present) {
      map['stok_minimal'] = Variable<int>(stokMinimal.value);
    }
    if (kelolaStok.present) {
      map['kelola_stok'] = Variable<bool>(kelolaStok.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarangCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('kategori: $kategori, ')
          ..write('harga: $harga, ')
          ..write('gambarPath: $gambarPath, ')
          ..write('stok: $stok, ')
          ..write('stokMinimal: $stokMinimal, ')
          ..write('kelolaStok: $kelolaStok, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransaksiTable extends Transaksi
    with TableInfo<$TransaksiTable, TransaksiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _totalHargaMeta =
      const VerificationMeta('totalHarga');
  @override
  late final GeneratedColumn<int> totalHarga = GeneratedColumn<int>(
      'total_harga', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tanggalTransaksiMeta =
      const VerificationMeta('tanggalTransaksi');
  @override
  late final GeneratedColumn<DateTime> tanggalTransaksi =
      GeneratedColumn<DateTime>('tanggal_transaksi', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, totalHarga, tanggalTransaksi, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaksi';
  @override
  VerificationContext validateIntegrity(Insertable<TransaksiData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_harga')) {
      context.handle(
          _totalHargaMeta,
          totalHarga.isAcceptableOrUnknown(
              data['total_harga']!, _totalHargaMeta));
    } else if (isInserting) {
      context.missing(_totalHargaMeta);
    }
    if (data.containsKey('tanggal_transaksi')) {
      context.handle(
          _tanggalTransaksiMeta,
          tanggalTransaksi.isAcceptableOrUnknown(
              data['tanggal_transaksi']!, _tanggalTransaksiMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransaksiData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransaksiData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      totalHarga: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_harga'])!,
      tanggalTransaksi: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}tanggal_transaksi'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $TransaksiTable createAlias(String alias) {
    return $TransaksiTable(attachedDatabase, alias);
  }
}

class TransaksiData extends DataClass implements Insertable<TransaksiData> {
  final int id;
  final int totalHarga;
  final DateTime tanggalTransaksi;
  final bool isSynced;
  const TransaksiData(
      {required this.id,
      required this.totalHarga,
      required this.tanggalTransaksi,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_harga'] = Variable<int>(totalHarga);
    map['tanggal_transaksi'] = Variable<DateTime>(tanggalTransaksi);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  TransaksiCompanion toCompanion(bool nullToAbsent) {
    return TransaksiCompanion(
      id: Value(id),
      totalHarga: Value(totalHarga),
      tanggalTransaksi: Value(tanggalTransaksi),
      isSynced: Value(isSynced),
    );
  }

  factory TransaksiData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransaksiData(
      id: serializer.fromJson<int>(json['id']),
      totalHarga: serializer.fromJson<int>(json['totalHarga']),
      tanggalTransaksi: serializer.fromJson<DateTime>(json['tanggalTransaksi']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalHarga': serializer.toJson<int>(totalHarga),
      'tanggalTransaksi': serializer.toJson<DateTime>(tanggalTransaksi),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  TransaksiData copyWith(
          {int? id,
          int? totalHarga,
          DateTime? tanggalTransaksi,
          bool? isSynced}) =>
      TransaksiData(
        id: id ?? this.id,
        totalHarga: totalHarga ?? this.totalHarga,
        tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
        isSynced: isSynced ?? this.isSynced,
      );
  TransaksiData copyWithCompanion(TransaksiCompanion data) {
    return TransaksiData(
      id: data.id.present ? data.id.value : this.id,
      totalHarga:
          data.totalHarga.present ? data.totalHarga.value : this.totalHarga,
      tanggalTransaksi: data.tanggalTransaksi.present
          ? data.tanggalTransaksi.value
          : this.tanggalTransaksi,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransaksiData(')
          ..write('id: $id, ')
          ..write('totalHarga: $totalHarga, ')
          ..write('tanggalTransaksi: $tanggalTransaksi, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, totalHarga, tanggalTransaksi, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransaksiData &&
          other.id == this.id &&
          other.totalHarga == this.totalHarga &&
          other.tanggalTransaksi == this.tanggalTransaksi &&
          other.isSynced == this.isSynced);
}

class TransaksiCompanion extends UpdateCompanion<TransaksiData> {
  final Value<int> id;
  final Value<int> totalHarga;
  final Value<DateTime> tanggalTransaksi;
  final Value<bool> isSynced;
  const TransaksiCompanion({
    this.id = const Value.absent(),
    this.totalHarga = const Value.absent(),
    this.tanggalTransaksi = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  TransaksiCompanion.insert({
    this.id = const Value.absent(),
    required int totalHarga,
    this.tanggalTransaksi = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : totalHarga = Value(totalHarga);
  static Insertable<TransaksiData> custom({
    Expression<int>? id,
    Expression<int>? totalHarga,
    Expression<DateTime>? tanggalTransaksi,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalHarga != null) 'total_harga': totalHarga,
      if (tanggalTransaksi != null) 'tanggal_transaksi': tanggalTransaksi,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  TransaksiCompanion copyWith(
      {Value<int>? id,
      Value<int>? totalHarga,
      Value<DateTime>? tanggalTransaksi,
      Value<bool>? isSynced}) {
    return TransaksiCompanion(
      id: id ?? this.id,
      totalHarga: totalHarga ?? this.totalHarga,
      tanggalTransaksi: tanggalTransaksi ?? this.tanggalTransaksi,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalHarga.present) {
      map['total_harga'] = Variable<int>(totalHarga.value);
    }
    if (tanggalTransaksi.present) {
      map['tanggal_transaksi'] = Variable<DateTime>(tanggalTransaksi.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaksiCompanion(')
          ..write('id: $id, ')
          ..write('totalHarga: $totalHarga, ')
          ..write('tanggalTransaksi: $tanggalTransaksi, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $DetailTransaksiTable extends DetailTransaksi
    with TableInfo<$DetailTransaksiTable, DetailTransaksiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetailTransaksiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idTransaksiMeta =
      const VerificationMeta('idTransaksi');
  @override
  late final GeneratedColumn<int> idTransaksi = GeneratedColumn<int>(
      'id_transaksi', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transaksi (id)'));
  static const VerificationMeta _idBarangMeta =
      const VerificationMeta('idBarang');
  @override
  late final GeneratedColumn<int> idBarang = GeneratedColumn<int>(
      'id_barang', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES barang (id)'));
  static const VerificationMeta _kuantitasMeta =
      const VerificationMeta('kuantitas');
  @override
  late final GeneratedColumn<int> kuantitas = GeneratedColumn<int>(
      'kuantitas', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hargaSatuanMeta =
      const VerificationMeta('hargaSatuan');
  @override
  late final GeneratedColumn<int> hargaSatuan = GeneratedColumn<int>(
      'harga_satuan', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<int> subtotal = GeneratedColumn<int>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, idTransaksi, idBarang, kuantitas, hargaSatuan, subtotal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detail_transaksi';
  @override
  VerificationContext validateIntegrity(
      Insertable<DetailTransaksiData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_transaksi')) {
      context.handle(
          _idTransaksiMeta,
          idTransaksi.isAcceptableOrUnknown(
              data['id_transaksi']!, _idTransaksiMeta));
    } else if (isInserting) {
      context.missing(_idTransaksiMeta);
    }
    if (data.containsKey('id_barang')) {
      context.handle(_idBarangMeta,
          idBarang.isAcceptableOrUnknown(data['id_barang']!, _idBarangMeta));
    } else if (isInserting) {
      context.missing(_idBarangMeta);
    }
    if (data.containsKey('kuantitas')) {
      context.handle(_kuantitasMeta,
          kuantitas.isAcceptableOrUnknown(data['kuantitas']!, _kuantitasMeta));
    } else if (isInserting) {
      context.missing(_kuantitasMeta);
    }
    if (data.containsKey('harga_satuan')) {
      context.handle(
          _hargaSatuanMeta,
          hargaSatuan.isAcceptableOrUnknown(
              data['harga_satuan']!, _hargaSatuanMeta));
    } else if (isInserting) {
      context.missing(_hargaSatuanMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetailTransaksiData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetailTransaksiData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      idTransaksi: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id_transaksi'])!,
      idBarang: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id_barang'])!,
      kuantitas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kuantitas'])!,
      hargaSatuan: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}harga_satuan'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtotal'])!,
    );
  }

  @override
  $DetailTransaksiTable createAlias(String alias) {
    return $DetailTransaksiTable(attachedDatabase, alias);
  }
}

class DetailTransaksiData extends DataClass
    implements Insertable<DetailTransaksiData> {
  final int id;
  final int idTransaksi;
  final int idBarang;
  final int kuantitas;
  final int hargaSatuan;
  final int subtotal;
  const DetailTransaksiData(
      {required this.id,
      required this.idTransaksi,
      required this.idBarang,
      required this.kuantitas,
      required this.hargaSatuan,
      required this.subtotal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_transaksi'] = Variable<int>(idTransaksi);
    map['id_barang'] = Variable<int>(idBarang);
    map['kuantitas'] = Variable<int>(kuantitas);
    map['harga_satuan'] = Variable<int>(hargaSatuan);
    map['subtotal'] = Variable<int>(subtotal);
    return map;
  }

  DetailTransaksiCompanion toCompanion(bool nullToAbsent) {
    return DetailTransaksiCompanion(
      id: Value(id),
      idTransaksi: Value(idTransaksi),
      idBarang: Value(idBarang),
      kuantitas: Value(kuantitas),
      hargaSatuan: Value(hargaSatuan),
      subtotal: Value(subtotal),
    );
  }

  factory DetailTransaksiData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetailTransaksiData(
      id: serializer.fromJson<int>(json['id']),
      idTransaksi: serializer.fromJson<int>(json['idTransaksi']),
      idBarang: serializer.fromJson<int>(json['idBarang']),
      kuantitas: serializer.fromJson<int>(json['kuantitas']),
      hargaSatuan: serializer.fromJson<int>(json['hargaSatuan']),
      subtotal: serializer.fromJson<int>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idTransaksi': serializer.toJson<int>(idTransaksi),
      'idBarang': serializer.toJson<int>(idBarang),
      'kuantitas': serializer.toJson<int>(kuantitas),
      'hargaSatuan': serializer.toJson<int>(hargaSatuan),
      'subtotal': serializer.toJson<int>(subtotal),
    };
  }

  DetailTransaksiData copyWith(
          {int? id,
          int? idTransaksi,
          int? idBarang,
          int? kuantitas,
          int? hargaSatuan,
          int? subtotal}) =>
      DetailTransaksiData(
        id: id ?? this.id,
        idTransaksi: idTransaksi ?? this.idTransaksi,
        idBarang: idBarang ?? this.idBarang,
        kuantitas: kuantitas ?? this.kuantitas,
        hargaSatuan: hargaSatuan ?? this.hargaSatuan,
        subtotal: subtotal ?? this.subtotal,
      );
  DetailTransaksiData copyWithCompanion(DetailTransaksiCompanion data) {
    return DetailTransaksiData(
      id: data.id.present ? data.id.value : this.id,
      idTransaksi:
          data.idTransaksi.present ? data.idTransaksi.value : this.idTransaksi,
      idBarang: data.idBarang.present ? data.idBarang.value : this.idBarang,
      kuantitas: data.kuantitas.present ? data.kuantitas.value : this.kuantitas,
      hargaSatuan:
          data.hargaSatuan.present ? data.hargaSatuan.value : this.hargaSatuan,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetailTransaksiData(')
          ..write('id: $id, ')
          ..write('idTransaksi: $idTransaksi, ')
          ..write('idBarang: $idBarang, ')
          ..write('kuantitas: $kuantitas, ')
          ..write('hargaSatuan: $hargaSatuan, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, idTransaksi, idBarang, kuantitas, hargaSatuan, subtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetailTransaksiData &&
          other.id == this.id &&
          other.idTransaksi == this.idTransaksi &&
          other.idBarang == this.idBarang &&
          other.kuantitas == this.kuantitas &&
          other.hargaSatuan == this.hargaSatuan &&
          other.subtotal == this.subtotal);
}

class DetailTransaksiCompanion extends UpdateCompanion<DetailTransaksiData> {
  final Value<int> id;
  final Value<int> idTransaksi;
  final Value<int> idBarang;
  final Value<int> kuantitas;
  final Value<int> hargaSatuan;
  final Value<int> subtotal;
  const DetailTransaksiCompanion({
    this.id = const Value.absent(),
    this.idTransaksi = const Value.absent(),
    this.idBarang = const Value.absent(),
    this.kuantitas = const Value.absent(),
    this.hargaSatuan = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  DetailTransaksiCompanion.insert({
    this.id = const Value.absent(),
    required int idTransaksi,
    required int idBarang,
    required int kuantitas,
    required int hargaSatuan,
    required int subtotal,
  })  : idTransaksi = Value(idTransaksi),
        idBarang = Value(idBarang),
        kuantitas = Value(kuantitas),
        hargaSatuan = Value(hargaSatuan),
        subtotal = Value(subtotal);
  static Insertable<DetailTransaksiData> custom({
    Expression<int>? id,
    Expression<int>? idTransaksi,
    Expression<int>? idBarang,
    Expression<int>? kuantitas,
    Expression<int>? hargaSatuan,
    Expression<int>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idTransaksi != null) 'id_transaksi': idTransaksi,
      if (idBarang != null) 'id_barang': idBarang,
      if (kuantitas != null) 'kuantitas': kuantitas,
      if (hargaSatuan != null) 'harga_satuan': hargaSatuan,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  DetailTransaksiCompanion copyWith(
      {Value<int>? id,
      Value<int>? idTransaksi,
      Value<int>? idBarang,
      Value<int>? kuantitas,
      Value<int>? hargaSatuan,
      Value<int>? subtotal}) {
    return DetailTransaksiCompanion(
      id: id ?? this.id,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      idBarang: idBarang ?? this.idBarang,
      kuantitas: kuantitas ?? this.kuantitas,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idTransaksi.present) {
      map['id_transaksi'] = Variable<int>(idTransaksi.value);
    }
    if (idBarang.present) {
      map['id_barang'] = Variable<int>(idBarang.value);
    }
    if (kuantitas.present) {
      map['kuantitas'] = Variable<int>(kuantitas.value);
    }
    if (hargaSatuan.present) {
      map['harga_satuan'] = Variable<int>(hargaSatuan.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<int>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetailTransaksiCompanion(')
          ..write('id: $id, ')
          ..write('idTransaksi: $idTransaksi, ')
          ..write('idBarang: $idBarang, ')
          ..write('kuantitas: $kuantitas, ')
          ..write('hargaSatuan: $hargaSatuan, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $KategoriTable extends Kategori
    with TableInfo<$KategoriTable, KategoriData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KategoriTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
      'nama', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, nama];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kategori';
  @override
  VerificationContext validateIntegrity(Insertable<KategoriData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
          _namaMeta, nama.isAcceptableOrUnknown(data['nama']!, _namaMeta));
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KategoriData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KategoriData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nama: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama'])!,
    );
  }

  @override
  $KategoriTable createAlias(String alias) {
    return $KategoriTable(attachedDatabase, alias);
  }
}

class KategoriData extends DataClass implements Insertable<KategoriData> {
  final int id;
  final String nama;
  const KategoriData({required this.id, required this.nama});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nama'] = Variable<String>(nama);
    return map;
  }

  KategoriCompanion toCompanion(bool nullToAbsent) {
    return KategoriCompanion(
      id: Value(id),
      nama: Value(nama),
    );
  }

  factory KategoriData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KategoriData(
      id: serializer.fromJson<int>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nama': serializer.toJson<String>(nama),
    };
  }

  KategoriData copyWith({int? id, String? nama}) => KategoriData(
        id: id ?? this.id,
        nama: nama ?? this.nama,
      );
  KategoriData copyWithCompanion(KategoriCompanion data) {
    return KategoriData(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KategoriData(')
          ..write('id: $id, ')
          ..write('nama: $nama')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KategoriData && other.id == this.id && other.nama == this.nama);
}

class KategoriCompanion extends UpdateCompanion<KategoriData> {
  final Value<int> id;
  final Value<String> nama;
  const KategoriCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
  });
  KategoriCompanion.insert({
    this.id = const Value.absent(),
    required String nama,
  }) : nama = Value(nama);
  static Insertable<KategoriData> custom({
    Expression<int>? id,
    Expression<String>? nama,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
    });
  }

  KategoriCompanion copyWith({Value<int>? id, Value<String>? nama}) {
    return KategoriCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KategoriCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama')
          ..write(')'))
        .toString();
  }
}

class $DeletedBarangTable extends DeletedBarang
    with TableInfo<$DeletedBarangTable, DeletedBarangData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeletedBarangTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barangIdMeta =
      const VerificationMeta('barangId');
  @override
  late final GeneratedColumn<int> barangId = GeneratedColumn<int>(
      'barang_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, barangId, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deleted_barang';
  @override
  VerificationContext validateIntegrity(Insertable<DeletedBarangData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barang_id')) {
      context.handle(_barangIdMeta,
          barangId.isAcceptableOrUnknown(data['barang_id']!, _barangIdMeta));
    } else if (isInserting) {
      context.missing(_barangIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeletedBarangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeletedBarangData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barangId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}barang_id'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at'])!,
    );
  }

  @override
  $DeletedBarangTable createAlias(String alias) {
    return $DeletedBarangTable(attachedDatabase, alias);
  }
}

class DeletedBarangData extends DataClass
    implements Insertable<DeletedBarangData> {
  final int id;
  final int barangId;
  final DateTime deletedAt;
  const DeletedBarangData(
      {required this.id, required this.barangId, required this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barang_id'] = Variable<int>(barangId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  DeletedBarangCompanion toCompanion(bool nullToAbsent) {
    return DeletedBarangCompanion(
      id: Value(id),
      barangId: Value(barangId),
      deletedAt: Value(deletedAt),
    );
  }

  factory DeletedBarangData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeletedBarangData(
      id: serializer.fromJson<int>(json['id']),
      barangId: serializer.fromJson<int>(json['barangId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barangId': serializer.toJson<int>(barangId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  DeletedBarangData copyWith({int? id, int? barangId, DateTime? deletedAt}) =>
      DeletedBarangData(
        id: id ?? this.id,
        barangId: barangId ?? this.barangId,
        deletedAt: deletedAt ?? this.deletedAt,
      );
  DeletedBarangData copyWithCompanion(DeletedBarangCompanion data) {
    return DeletedBarangData(
      id: data.id.present ? data.id.value : this.id,
      barangId: data.barangId.present ? data.barangId.value : this.barangId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeletedBarangData(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, barangId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeletedBarangData &&
          other.id == this.id &&
          other.barangId == this.barangId &&
          other.deletedAt == this.deletedAt);
}

class DeletedBarangCompanion extends UpdateCompanion<DeletedBarangData> {
  final Value<int> id;
  final Value<int> barangId;
  final Value<DateTime> deletedAt;
  const DeletedBarangCompanion({
    this.id = const Value.absent(),
    this.barangId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DeletedBarangCompanion.insert({
    this.id = const Value.absent(),
    required int barangId,
    this.deletedAt = const Value.absent(),
  }) : barangId = Value(barangId);
  static Insertable<DeletedBarangData> custom({
    Expression<int>? id,
    Expression<int>? barangId,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barangId != null) 'barang_id': barangId,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DeletedBarangCompanion copyWith(
      {Value<int>? id, Value<int>? barangId, Value<DateTime>? deletedAt}) {
    return DeletedBarangCompanion(
      id: id ?? this.id,
      barangId: barangId ?? this.barangId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barangId.present) {
      map['barang_id'] = Variable<int>(barangId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeletedBarangCompanion(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BarangTable barang = $BarangTable(this);
  late final $TransaksiTable transaksi = $TransaksiTable(this);
  late final $DetailTransaksiTable detailTransaksi =
      $DetailTransaksiTable(this);
  late final $KategoriTable kategori = $KategoriTable(this);
  late final $DeletedBarangTable deletedBarang = $DeletedBarangTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [barang, transaksi, detailTransaksi, kategori, deletedBarang];
}

typedef $$BarangTableCreateCompanionBuilder = BarangCompanion Function({
  Value<int> id,
  required String nama,
  required String kategori,
  required int harga,
  Value<String?> gambarPath,
  Value<int> stok,
  Value<int> stokMinimal,
  Value<bool> kelolaStok,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BarangTableUpdateCompanionBuilder = BarangCompanion Function({
  Value<int> id,
  Value<String> nama,
  Value<String> kategori,
  Value<int> harga,
  Value<String?> gambarPath,
  Value<int> stok,
  Value<int> stokMinimal,
  Value<bool> kelolaStok,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BarangTableReferences
    extends BaseReferences<_$AppDatabase, $BarangTable, BarangData> {
  $$BarangTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DetailTransaksiTable, List<DetailTransaksiData>>
      _detailTransaksiRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.detailTransaksi,
              aliasName: $_aliasNameGenerator(
                  db.barang.id, db.detailTransaksi.idBarang));

  $$DetailTransaksiTableProcessedTableManager get detailTransaksiRefs {
    final manager =
        $$DetailTransaksiTableTableManager($_db, $_db.detailTransaksi)
            .filter((f) => f.idBarang.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_detailTransaksiRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BarangTableFilterComposer
    extends Composer<_$AppDatabase, $BarangTable> {
  $$BarangTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kategori => $composableBuilder(
      column: $table.kategori, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get harga => $composableBuilder(
      column: $table.harga, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gambarPath => $composableBuilder(
      column: $table.gambarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stok => $composableBuilder(
      column: $table.stok, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stokMinimal => $composableBuilder(
      column: $table.stokMinimal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get kelolaStok => $composableBuilder(
      column: $table.kelolaStok, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> detailTransaksiRefs(
      Expression<bool> Function($$DetailTransaksiTableFilterComposer f) f) {
    final $$DetailTransaksiTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detailTransaksi,
        getReferencedColumn: (t) => t.idBarang,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetailTransaksiTableFilterComposer(
              $db: $db,
              $table: $db.detailTransaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BarangTableOrderingComposer
    extends Composer<_$AppDatabase, $BarangTable> {
  $$BarangTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kategori => $composableBuilder(
      column: $table.kategori, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get harga => $composableBuilder(
      column: $table.harga, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gambarPath => $composableBuilder(
      column: $table.gambarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stok => $composableBuilder(
      column: $table.stok, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stokMinimal => $composableBuilder(
      column: $table.stokMinimal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get kelolaStok => $composableBuilder(
      column: $table.kelolaStok, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BarangTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarangTable> {
  $$BarangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get kategori =>
      $composableBuilder(column: $table.kategori, builder: (column) => column);

  GeneratedColumn<int> get harga =>
      $composableBuilder(column: $table.harga, builder: (column) => column);

  GeneratedColumn<String> get gambarPath => $composableBuilder(
      column: $table.gambarPath, builder: (column) => column);

  GeneratedColumn<int> get stok =>
      $composableBuilder(column: $table.stok, builder: (column) => column);

  GeneratedColumn<int> get stokMinimal => $composableBuilder(
      column: $table.stokMinimal, builder: (column) => column);

  GeneratedColumn<bool> get kelolaStok => $composableBuilder(
      column: $table.kelolaStok, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> detailTransaksiRefs<T extends Object>(
      Expression<T> Function($$DetailTransaksiTableAnnotationComposer a) f) {
    final $$DetailTransaksiTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detailTransaksi,
        getReferencedColumn: (t) => t.idBarang,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetailTransaksiTableAnnotationComposer(
              $db: $db,
              $table: $db.detailTransaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BarangTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BarangTable,
    BarangData,
    $$BarangTableFilterComposer,
    $$BarangTableOrderingComposer,
    $$BarangTableAnnotationComposer,
    $$BarangTableCreateCompanionBuilder,
    $$BarangTableUpdateCompanionBuilder,
    (BarangData, $$BarangTableReferences),
    BarangData,
    PrefetchHooks Function({bool detailTransaksiRefs})> {
  $$BarangTableTableManager(_$AppDatabase db, $BarangTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nama = const Value.absent(),
            Value<String> kategori = const Value.absent(),
            Value<int> harga = const Value.absent(),
            Value<String?> gambarPath = const Value.absent(),
            Value<int> stok = const Value.absent(),
            Value<int> stokMinimal = const Value.absent(),
            Value<bool> kelolaStok = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BarangCompanion(
            id: id,
            nama: nama,
            kategori: kategori,
            harga: harga,
            gambarPath: gambarPath,
            stok: stok,
            stokMinimal: stokMinimal,
            kelolaStok: kelolaStok,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nama,
            required String kategori,
            required int harga,
            Value<String?> gambarPath = const Value.absent(),
            Value<int> stok = const Value.absent(),
            Value<int> stokMinimal = const Value.absent(),
            Value<bool> kelolaStok = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BarangCompanion.insert(
            id: id,
            nama: nama,
            kategori: kategori,
            harga: harga,
            gambarPath: gambarPath,
            stok: stok,
            stokMinimal: stokMinimal,
            kelolaStok: kelolaStok,
            isSynced: isSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BarangTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({detailTransaksiRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (detailTransaksiRefs) db.detailTransaksi
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detailTransaksiRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$BarangTableReferences
                            ._detailTransaksiRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BarangTableReferences(db, table, p0)
                                .detailTransaksiRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.idBarang == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BarangTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BarangTable,
    BarangData,
    $$BarangTableFilterComposer,
    $$BarangTableOrderingComposer,
    $$BarangTableAnnotationComposer,
    $$BarangTableCreateCompanionBuilder,
    $$BarangTableUpdateCompanionBuilder,
    (BarangData, $$BarangTableReferences),
    BarangData,
    PrefetchHooks Function({bool detailTransaksiRefs})>;
typedef $$TransaksiTableCreateCompanionBuilder = TransaksiCompanion Function({
  Value<int> id,
  required int totalHarga,
  Value<DateTime> tanggalTransaksi,
  Value<bool> isSynced,
});
typedef $$TransaksiTableUpdateCompanionBuilder = TransaksiCompanion Function({
  Value<int> id,
  Value<int> totalHarga,
  Value<DateTime> tanggalTransaksi,
  Value<bool> isSynced,
});

final class $$TransaksiTableReferences
    extends BaseReferences<_$AppDatabase, $TransaksiTable, TransaksiData> {
  $$TransaksiTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DetailTransaksiTable, List<DetailTransaksiData>>
      _detailTransaksiRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.detailTransaksi,
              aliasName: $_aliasNameGenerator(
                  db.transaksi.id, db.detailTransaksi.idTransaksi));

  $$DetailTransaksiTableProcessedTableManager get detailTransaksiRefs {
    final manager =
        $$DetailTransaksiTableTableManager($_db, $_db.detailTransaksi)
            .filter((f) => f.idTransaksi.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_detailTransaksiRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransaksiTableFilterComposer
    extends Composer<_$AppDatabase, $TransaksiTable> {
  $$TransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalHarga => $composableBuilder(
      column: $table.totalHarga, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tanggalTransaksi => $composableBuilder(
      column: $table.tanggalTransaksi,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  Expression<bool> detailTransaksiRefs(
      Expression<bool> Function($$DetailTransaksiTableFilterComposer f) f) {
    final $$DetailTransaksiTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detailTransaksi,
        getReferencedColumn: (t) => t.idTransaksi,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetailTransaksiTableFilterComposer(
              $db: $db,
              $table: $db.detailTransaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransaksiTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaksiTable> {
  $$TransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalHarga => $composableBuilder(
      column: $table.totalHarga, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tanggalTransaksi => $composableBuilder(
      column: $table.tanggalTransaksi,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$TransaksiTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaksiTable> {
  $$TransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalHarga => $composableBuilder(
      column: $table.totalHarga, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggalTransaksi => $composableBuilder(
      column: $table.tanggalTransaksi, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> detailTransaksiRefs<T extends Object>(
      Expression<T> Function($$DetailTransaksiTableAnnotationComposer a) f) {
    final $$DetailTransaksiTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detailTransaksi,
        getReferencedColumn: (t) => t.idTransaksi,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetailTransaksiTableAnnotationComposer(
              $db: $db,
              $table: $db.detailTransaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransaksiTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransaksiTable,
    TransaksiData,
    $$TransaksiTableFilterComposer,
    $$TransaksiTableOrderingComposer,
    $$TransaksiTableAnnotationComposer,
    $$TransaksiTableCreateCompanionBuilder,
    $$TransaksiTableUpdateCompanionBuilder,
    (TransaksiData, $$TransaksiTableReferences),
    TransaksiData,
    PrefetchHooks Function({bool detailTransaksiRefs})> {
  $$TransaksiTableTableManager(_$AppDatabase db, $TransaksiTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaksiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> totalHarga = const Value.absent(),
            Value<DateTime> tanggalTransaksi = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              TransaksiCompanion(
            id: id,
            totalHarga: totalHarga,
            tanggalTransaksi: tanggalTransaksi,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int totalHarga,
            Value<DateTime> tanggalTransaksi = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              TransaksiCompanion.insert(
            id: id,
            totalHarga: totalHarga,
            tanggalTransaksi: tanggalTransaksi,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransaksiTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({detailTransaksiRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (detailTransaksiRefs) db.detailTransaksi
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detailTransaksiRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TransaksiTableReferences
                            ._detailTransaksiRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransaksiTableReferences(db, table, p0)
                                .detailTransaksiRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.idTransaksi == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransaksiTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransaksiTable,
    TransaksiData,
    $$TransaksiTableFilterComposer,
    $$TransaksiTableOrderingComposer,
    $$TransaksiTableAnnotationComposer,
    $$TransaksiTableCreateCompanionBuilder,
    $$TransaksiTableUpdateCompanionBuilder,
    (TransaksiData, $$TransaksiTableReferences),
    TransaksiData,
    PrefetchHooks Function({bool detailTransaksiRefs})>;
typedef $$DetailTransaksiTableCreateCompanionBuilder = DetailTransaksiCompanion
    Function({
  Value<int> id,
  required int idTransaksi,
  required int idBarang,
  required int kuantitas,
  required int hargaSatuan,
  required int subtotal,
});
typedef $$DetailTransaksiTableUpdateCompanionBuilder = DetailTransaksiCompanion
    Function({
  Value<int> id,
  Value<int> idTransaksi,
  Value<int> idBarang,
  Value<int> kuantitas,
  Value<int> hargaSatuan,
  Value<int> subtotal,
});

final class $$DetailTransaksiTableReferences extends BaseReferences<
    _$AppDatabase, $DetailTransaksiTable, DetailTransaksiData> {
  $$DetailTransaksiTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransaksiTable _idTransaksiTable(_$AppDatabase db) =>
      db.transaksi.createAlias($_aliasNameGenerator(
          db.detailTransaksi.idTransaksi, db.transaksi.id));

  $$TransaksiTableProcessedTableManager? get idTransaksi {
    if ($_item.idTransaksi == null) return null;
    final manager = $$TransaksiTableTableManager($_db, $_db.transaksi)
        .filter((f) => f.id($_item.idTransaksi!));
    final item = $_typedResult.readTableOrNull(_idTransaksiTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BarangTable _idBarangTable(_$AppDatabase db) => db.barang.createAlias(
      $_aliasNameGenerator(db.detailTransaksi.idBarang, db.barang.id));

  $$BarangTableProcessedTableManager? get idBarang {
    if ($_item.idBarang == null) return null;
    final manager = $$BarangTableTableManager($_db, $_db.barang)
        .filter((f) => f.id($_item.idBarang!));
    final item = $_typedResult.readTableOrNull(_idBarangTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DetailTransaksiTableFilterComposer
    extends Composer<_$AppDatabase, $DetailTransaksiTable> {
  $$DetailTransaksiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kuantitas => $composableBuilder(
      column: $table.kuantitas, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hargaSatuan => $composableBuilder(
      column: $table.hargaSatuan, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  $$TransaksiTableFilterComposer get idTransaksi {
    final $$TransaksiTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idTransaksi,
        referencedTable: $db.transaksi,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransaksiTableFilterComposer(
              $db: $db,
              $table: $db.transaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BarangTableFilterComposer get idBarang {
    final $$BarangTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idBarang,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableFilterComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetailTransaksiTableOrderingComposer
    extends Composer<_$AppDatabase, $DetailTransaksiTable> {
  $$DetailTransaksiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kuantitas => $composableBuilder(
      column: $table.kuantitas, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hargaSatuan => $composableBuilder(
      column: $table.hargaSatuan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  $$TransaksiTableOrderingComposer get idTransaksi {
    final $$TransaksiTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idTransaksi,
        referencedTable: $db.transaksi,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransaksiTableOrderingComposer(
              $db: $db,
              $table: $db.transaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BarangTableOrderingComposer get idBarang {
    final $$BarangTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idBarang,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableOrderingComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetailTransaksiTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetailTransaksiTable> {
  $$DetailTransaksiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kuantitas =>
      $composableBuilder(column: $table.kuantitas, builder: (column) => column);

  GeneratedColumn<int> get hargaSatuan => $composableBuilder(
      column: $table.hargaSatuan, builder: (column) => column);

  GeneratedColumn<int> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$TransaksiTableAnnotationComposer get idTransaksi {
    final $$TransaksiTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idTransaksi,
        referencedTable: $db.transaksi,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransaksiTableAnnotationComposer(
              $db: $db,
              $table: $db.transaksi,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BarangTableAnnotationComposer get idBarang {
    final $$BarangTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.idBarang,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableAnnotationComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetailTransaksiTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetailTransaksiTable,
    DetailTransaksiData,
    $$DetailTransaksiTableFilterComposer,
    $$DetailTransaksiTableOrderingComposer,
    $$DetailTransaksiTableAnnotationComposer,
    $$DetailTransaksiTableCreateCompanionBuilder,
    $$DetailTransaksiTableUpdateCompanionBuilder,
    (DetailTransaksiData, $$DetailTransaksiTableReferences),
    DetailTransaksiData,
    PrefetchHooks Function({bool idTransaksi, bool idBarang})> {
  $$DetailTransaksiTableTableManager(
      _$AppDatabase db, $DetailTransaksiTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetailTransaksiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetailTransaksiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetailTransaksiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> idTransaksi = const Value.absent(),
            Value<int> idBarang = const Value.absent(),
            Value<int> kuantitas = const Value.absent(),
            Value<int> hargaSatuan = const Value.absent(),
            Value<int> subtotal = const Value.absent(),
          }) =>
              DetailTransaksiCompanion(
            id: id,
            idTransaksi: idTransaksi,
            idBarang: idBarang,
            kuantitas: kuantitas,
            hargaSatuan: hargaSatuan,
            subtotal: subtotal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int idTransaksi,
            required int idBarang,
            required int kuantitas,
            required int hargaSatuan,
            required int subtotal,
          }) =>
              DetailTransaksiCompanion.insert(
            id: id,
            idTransaksi: idTransaksi,
            idBarang: idBarang,
            kuantitas: kuantitas,
            hargaSatuan: hargaSatuan,
            subtotal: subtotal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DetailTransaksiTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({idTransaksi = false, idBarang = false}) {
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
                if (idTransaksi) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.idTransaksi,
                    referencedTable:
                        $$DetailTransaksiTableReferences._idTransaksiTable(db),
                    referencedColumn: $$DetailTransaksiTableReferences
                        ._idTransaksiTable(db)
                        .id,
                  ) as T;
                }
                if (idBarang) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.idBarang,
                    referencedTable:
                        $$DetailTransaksiTableReferences._idBarangTable(db),
                    referencedColumn:
                        $$DetailTransaksiTableReferences._idBarangTable(db).id,
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

typedef $$DetailTransaksiTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetailTransaksiTable,
    DetailTransaksiData,
    $$DetailTransaksiTableFilterComposer,
    $$DetailTransaksiTableOrderingComposer,
    $$DetailTransaksiTableAnnotationComposer,
    $$DetailTransaksiTableCreateCompanionBuilder,
    $$DetailTransaksiTableUpdateCompanionBuilder,
    (DetailTransaksiData, $$DetailTransaksiTableReferences),
    DetailTransaksiData,
    PrefetchHooks Function({bool idTransaksi, bool idBarang})>;
typedef $$KategoriTableCreateCompanionBuilder = KategoriCompanion Function({
  Value<int> id,
  required String nama,
});
typedef $$KategoriTableUpdateCompanionBuilder = KategoriCompanion Function({
  Value<int> id,
  Value<String> nama,
});

class $$KategoriTableFilterComposer
    extends Composer<_$AppDatabase, $KategoriTable> {
  $$KategoriTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnFilters(column));
}

class $$KategoriTableOrderingComposer
    extends Composer<_$AppDatabase, $KategoriTable> {
  $$KategoriTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnOrderings(column));
}

class $$KategoriTableAnnotationComposer
    extends Composer<_$AppDatabase, $KategoriTable> {
  $$KategoriTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);
}

class $$KategoriTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KategoriTable,
    KategoriData,
    $$KategoriTableFilterComposer,
    $$KategoriTableOrderingComposer,
    $$KategoriTableAnnotationComposer,
    $$KategoriTableCreateCompanionBuilder,
    $$KategoriTableUpdateCompanionBuilder,
    (KategoriData, BaseReferences<_$AppDatabase, $KategoriTable, KategoriData>),
    KategoriData,
    PrefetchHooks Function()> {
  $$KategoriTableTableManager(_$AppDatabase db, $KategoriTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KategoriTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KategoriTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KategoriTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nama = const Value.absent(),
          }) =>
              KategoriCompanion(
            id: id,
            nama: nama,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nama,
          }) =>
              KategoriCompanion.insert(
            id: id,
            nama: nama,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KategoriTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KategoriTable,
    KategoriData,
    $$KategoriTableFilterComposer,
    $$KategoriTableOrderingComposer,
    $$KategoriTableAnnotationComposer,
    $$KategoriTableCreateCompanionBuilder,
    $$KategoriTableUpdateCompanionBuilder,
    (KategoriData, BaseReferences<_$AppDatabase, $KategoriTable, KategoriData>),
    KategoriData,
    PrefetchHooks Function()>;
typedef $$DeletedBarangTableCreateCompanionBuilder = DeletedBarangCompanion
    Function({
  Value<int> id,
  required int barangId,
  Value<DateTime> deletedAt,
});
typedef $$DeletedBarangTableUpdateCompanionBuilder = DeletedBarangCompanion
    Function({
  Value<int> id,
  Value<int> barangId,
  Value<DateTime> deletedAt,
});

class $$DeletedBarangTableFilterComposer
    extends Composer<_$AppDatabase, $DeletedBarangTable> {
  $$DeletedBarangTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get barangId => $composableBuilder(
      column: $table.barangId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$DeletedBarangTableOrderingComposer
    extends Composer<_$AppDatabase, $DeletedBarangTable> {
  $$DeletedBarangTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get barangId => $composableBuilder(
      column: $table.barangId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$DeletedBarangTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeletedBarangTable> {
  $$DeletedBarangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get barangId =>
      $composableBuilder(column: $table.barangId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DeletedBarangTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeletedBarangTable,
    DeletedBarangData,
    $$DeletedBarangTableFilterComposer,
    $$DeletedBarangTableOrderingComposer,
    $$DeletedBarangTableAnnotationComposer,
    $$DeletedBarangTableCreateCompanionBuilder,
    $$DeletedBarangTableUpdateCompanionBuilder,
    (
      DeletedBarangData,
      BaseReferences<_$AppDatabase, $DeletedBarangTable, DeletedBarangData>
    ),
    DeletedBarangData,
    PrefetchHooks Function()> {
  $$DeletedBarangTableTableManager(_$AppDatabase db, $DeletedBarangTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeletedBarangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeletedBarangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeletedBarangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> barangId = const Value.absent(),
            Value<DateTime> deletedAt = const Value.absent(),
          }) =>
              DeletedBarangCompanion(
            id: id,
            barangId: barangId,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int barangId,
            Value<DateTime> deletedAt = const Value.absent(),
          }) =>
              DeletedBarangCompanion.insert(
            id: id,
            barangId: barangId,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeletedBarangTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeletedBarangTable,
    DeletedBarangData,
    $$DeletedBarangTableFilterComposer,
    $$DeletedBarangTableOrderingComposer,
    $$DeletedBarangTableAnnotationComposer,
    $$DeletedBarangTableCreateCompanionBuilder,
    $$DeletedBarangTableUpdateCompanionBuilder,
    (
      DeletedBarangData,
      BaseReferences<_$AppDatabase, $DeletedBarangTable, DeletedBarangData>
    ),
    DeletedBarangData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BarangTableTableManager get barang =>
      $$BarangTableTableManager(_db, _db.barang);
  $$TransaksiTableTableManager get transaksi =>
      $$TransaksiTableTableManager(_db, _db.transaksi);
  $$DetailTransaksiTableTableManager get detailTransaksi =>
      $$DetailTransaksiTableTableManager(_db, _db.detailTransaksi);
  $$KategoriTableTableManager get kategori =>
      $$KategoriTableTableManager(_db, _db.kategori);
  $$DeletedBarangTableTableManager get deletedBarang =>
      $$DeletedBarangTableTableManager(_db, _db.deletedBarang);
}
