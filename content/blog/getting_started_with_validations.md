+++
author = "Robbert Halff"
categories = ["Dart", "Validations", "Flutter"]
date = "2019-08-08"
description = "Validations for Dart"
featured = "pic01.jpg"
featuredalt = "Pic 1"
featuredpath = "date"
linktitle = ""
title = "@Validations"
type = "post"
codeTabs = true
asciinema = true
+++
[Validations](https://github.com/dartlib/validations/tree/master/validations) is a validation library for Dart and Flutter using annotations,
which allows you to concisely define validations for your models.

It's inspired by the [JSR380 Bean Validation specification](https://beanvalidation.org/2.0/spec/
) for Java.
some parts of the specification have not been implemented yet though or make less sense for validations written in Dart.



There are several ways in which the validations can be used.
The library is tailored to work well with [flutter form validation](https://flutter.dev/docs/cookbook/forms/validation
), but the annotations are equally valuable for model validation.

This article will go through setting up validations for your project and will handle the available api methods.


## Step 1. Install Validations

Installing validations is straight forward. Three dependencies will have
to be installed, one runtime dependency and two dev dependencies which are used
to generate the validations based on the annotations.

> **NOTE:**
>
> This article assumes a newly created project directory named `validations_test`.
>
> each code sample contains the file name which should be put within this project directory.

**pubspec.yaml**
```yaml
name: validations_test 
version: 0.0.1

environment:
  sdk: '>=2.4.0 <3.0.0'
dependencies:
  validations: ^0.8.3 
dev_dependencies:
  build_runner:
  validations_generator: ^0.8.3 
```

After you've added the dependencies use `pub get` to install them.

## Step 2. Creating your model.

Chances are when you are in need of validations you already have an idea which 
models should be in need of validation.

For the sake of example we are going to make one up.

**lib/car.dart**
{{% code-tabs %}}
{{% code-tab Annotations %}}
```dart
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:validations/validations.dart';

part 'car.g.dart';

class Car {
  @NotNull()
  String manufacturer;

  @Size(
    min: 2,
    max: 14,
    message:
        r'The license plate $validatedValue must be between $min and $max characters long',
  )
  @NotNull()
  String licensePlate;

  @Min(
    value: 1,
    message: r'Car must at least have $value seats available',
  )
  @Max(
    value: 2,
    message: r'Car cannot have more than $value seats',
  )
  int seatCount;

  @Max(
    value: 350,
    message: r'The top speed $validatedValue is higher than $value',
  )
  int topSpeed;
}

@GenValidator()
class TestCarValidator extends Validator<Car> with _$TestCarValidator {}
```
{{% /code-tab %}}
{{% code-tab Fields %}}
```dart
import 'package:validations/validations.dart';

part 'car.g.dart';

class Car {
  String manufacturer;
  String licensePlate;
  int seatCount;
  int topSpeed;
}

@GenValidator(
  fields: {
    'manufacturer': [NotNull()],
    'licensePlate': [
      NotNull(),
      Size(
        min:2,
        max: 14,
        message: r'The license plate $validatedValue must be between $min and $max characters long',
      ),
    ],
    'seatCount': [
      Min(
        value: 1,
         message: r'Car must at least have $value seats available',
      ),
      Max(
        value: 2,
         message: r'Car cannot have more than $value seats',
      ),
    ],
    'topSpeed': [
      Max(value: 350),
      message: r'The top speed $validatedValue is higher than $value',
    ],
  },
)
class TestCarValidator extends Validator<Car> with _$TestCarValidator {}
```
{{% /code-tab %}}
{{% /code-tabs %}}

There are two different ways of specifying the validations, use the *Fields* tab above to see how to define them without annotations.

This has been done mainly in case you do not want to clutter your model with extra annotations.

The `part 'car.g.dart'` refers to the generated part file which will be generated in the next step.

The `TestCardValidator` class is mandatory, must be annotated with a `@Genvalidator()` annotation and further specified as shown above.

> **NOTE:**
>
> Validations comes with rather a few out of the box annotations to validate
> your models.
>
> You can consult the [API documentation](https://pub.dev/documentation/validations/latest/annotations/annotations-library.html
> ) to determine which ones are available.


## Step 3. Running the generator 

After you have defined the validations you must run the generator.

This can be done using:
```bash
pub run build_runner build
```

This will generate the `car.g.dart` part file in the same directory as the validator was defined.

> **NOTE:**
>
> It's not required to define the validator within the same file as the model.
>
> e.g. validators for many different models could be defined within one separate file.

## Step 4. Using the CarValidator 

In order to use the validator let's create a `main.dart` file which creates a new Car model and uses the validator to validate the instance.

**lib/main.dart**
```dart
import './car.dart';

final validator = TestCarValidator();

final car = Car()
  ..licensePlate = 'D'
  ..manufacturer = null
  ..seatCount = 3
  ..topSpeed = 500;

main() {
  final violations = validator.validate(car);

  print('There are ${violations.length} violations.');
  for (var violation in violations) {
    print(violation.message);
  }
}
```
In the above case all values are incorrect and if this code is run there will 4 violations.

```bash
$ dart lib/main.dart
There are 4 violations.
Car.manufacturer: Value cannot be null
Car.licensePlate: The license plate D must be between 2 and 14 characters long
Car.seatCount: Car cannot have more than 2 seats
Car.topSpeed: The top speed 500 is higher than 350
```

### Graph Validation

Say we want to add a driver to our *Car* model and this *Driver* model has it's own set of validations.

**lib/driver.dart**
```dart
import 'package:validations/validations.dart';
part 'driver.g.dart';

class Driver {
  Driver({this.name});
  @NotNull()
  String name;
}

@GenValidator()
class TestDriverValidator extends Validator<Driver> with _$TestDriverValidator {}
```

The **@Valid** annotation can be used to hint the car model we also want to validate the driver.

**lib/car.dart**
```dart
import 'driver.dart';

class Car {
  ...
  
  @Valid(message: 'There should be a valid driver!')
  Driver driver;
  
  ...
}
```

From the Bean Spec:

> "In addition to supporting instance validation, validation of graphs of objects is also supported. The result of a graph validation is returned as a unified set of constraint violations. @Valid is used to express validation traversal of an association."

Whenever an @Valid annotation is encountered the annotated model for that field will be validated with the associated validator.
This behavior works recursively if needed.

If we now regenerate our validators and re-run the main file a new violation will popup stating we also haven't specified a valid driver.

```bash
$ dart lib/main.dart
There are 4 violations.
Car.Driver: Value cannot be null
Car.manufacturer: Value cannot be null
Car.licensePlate: The license plate D must be between 2 and 14 characters long
Car.seatCount: Car cannot have more than 2 seats
Car.topSpeed: The top speed 500 is higher than 350
```
### Summary

This article just serves as a brief introduction to what validations can do.

If you want to learn more on how to integrate validations into your specific setup.
Please look at the other articles:

* Using @Validations for Flutter form validation (TODO).
* Jaguar ORM and Validations (TODO).

