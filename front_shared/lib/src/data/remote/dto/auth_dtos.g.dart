// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestDtoImpl _$$LoginRequestDtoImplFromJson(
  Map<String, dynamic> json,
) => _$LoginRequestDtoImpl(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$LoginRequestDtoImplToJson(
  _$LoginRequestDtoImpl instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

_$LoginResponseDtoImpl _$$LoginResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$LoginResponseDtoImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  coachId: json['coachId'] as String?,
);

Map<String, dynamic> _$$LoginResponseDtoImplToJson(
  _$LoginResponseDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'role': instance.role,
  'coachId': instance.coachId,
};
