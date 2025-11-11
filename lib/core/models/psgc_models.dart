class Region {
  final String code;
  final String name;

  Region({
    required this.code,
    required this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}

class Province {
  final String code;
  final String name;
  final String? regionCode;

  Province({
    required this.code,
    required this.name,
    this.regionCode,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      regionCode: json['regionCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'regionCode': regionCode,
    };
  }
}

class City {
  final String code;
  final String name;
  final String provinceCode;
  final String? districtCode;
  final bool isCity;

  City({
    required this.code,
    required this.name,
    required this.provinceCode,
    this.districtCode,
    this.isCity = false,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      provinceCode: json['provinceCode'] ?? '',
      districtCode: json['districtCode'],
      isCity: json['isCity'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'provinceCode': provinceCode,
      'districtCode': districtCode,
      'isCity': isCity,
    };
  }
}

class Barangay {
  final String code;
  final String name;
  final String cityCode;

  Barangay({
    required this.code,
    required this.name,
    required this.cityCode,
  });

  factory Barangay.fromJson(Map<String, dynamic> json) {
    return Barangay(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      cityCode: json['cityCode'] ?? json['cityOrMunicipalityCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'cityCode': cityCode,
    };
  }
}
