// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      songName: fields[1] as String,
      filePath: fields[3] as String?,
      songArtist: fields[2] as String?,
      songImage: fields[0] as Uint8List?,
      songAlbum: fields[4] as String?,
      durationInSeconds: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.songImage)
      ..writeByte(1)
      ..write(obj.songName)
      ..writeByte(2)
      ..write(obj.songArtist)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.songAlbum)
      ..writeByte(5)
      ..write(obj.durationInSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
