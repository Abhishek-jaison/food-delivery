// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotional_banner_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromotionalBannerModelAdapter
    extends TypeAdapter<PromotionalBannerModel> {
  @override
  final int typeId = 2;

  @override
  PromotionalBannerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromotionalBannerModel(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      description: fields[3] as String,
      imageUrl: fields[4] as String,
      discountText: fields[5] as String?,
      buttonText: fields[6] as String?,
      phoneNumber: fields[7] as String?,
      website: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PromotionalBannerModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.discountText)
      ..writeByte(6)
      ..write(obj.buttonText)
      ..writeByte(7)
      ..write(obj.phoneNumber)
      ..writeByte(8)
      ..write(obj.website);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromotionalBannerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
