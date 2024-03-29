// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

abstract class _$TestCarValidator implements Validator<Car> {
  static String licensePlateSizeMessage(
      int min, int max, Object validatedValue) {
    return 'The license plate $validatedValue must be between $min and $max characters long';
  }

  static String seatCountMinMessage(dynamic value, Object validatedValue) {
    return 'Car must at least have $value seats available';
  }

  static String seatCountMaxMessage(dynamic value, Object validatedValue) {
    return 'Car cannot have more than $value seats';
  }

  static String topSpeedMaxMessage(dynamic value, Object validatedValue) {
    return 'The top speed $validatedValue is higher than $value';
  }

  @override
  List<FieldValidator> getFieldValidators() {
    return [
      FieldValidator<String>(
          name: 'manufacturer', validators: [NotNullValidator()]),
      FieldValidator<String>(name: 'licensePlate', validators: [
        SizeValidator(min: 2, max: 14)..message = licensePlateSizeMessage,
        NotNullValidator()
      ]),
      FieldValidator<int>(name: 'seatCount', validators: [
        MinValidator(value: 1)..message = seatCountMinMessage,
        MaxValidator(value: 2)..message = seatCountMaxMessage
      ]),
      FieldValidator<int>(
          name: 'topSpeed',
          validators: [MaxValidator(value: 350)..message = topSpeedMaxMessage])
    ];
  }

  String validateManufacturer(Object value) =>
      errorCheck('manufacturer', value);
  String validateLicensePlate(Object value) =>
      errorCheck('licensePlate', value);
  String validateSeatCount(Object value) => errorCheck('seatCount', value);
  String validateTopSpeed(Object value) => errorCheck('topSpeed', value);
  @override
  PropertyMap<Car> props(Car instance) {
    return PropertyMap<Car>({
      'manufacturer': instance.manufacturer,
      'licensePlate': instance.licensePlate,
      'seatCount': instance.seatCount,
      'topSpeed': instance.topSpeed
    });
  }
}
