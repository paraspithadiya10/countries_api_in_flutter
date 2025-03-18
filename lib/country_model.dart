// ignore_for_file: prefer_collection_literals, unnecessary_this

class CountryModel {
  Flags? flags;
  Name? name;
  String? cca2;
  Map<String, Currency>? currencies;

  CountryModel({this.flags, this.name, this.cca2, this.currencies});

  CountryModel.fromJson(Map<String, dynamic> json) {
    flags = json['flags'] != null ? Flags.fromJson(json['flags']) : null;
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    cca2 = json['cca2'];
    currencies = json['currencies'] != null
        ? (json['currencies'] as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, Currency.fromJson(value));
          })
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (flags != null) {
      data['flags'] = flags!.toJson();
    }
    if (name != null) {
      data['name'] = name!.toJson();
    }
    data['cca2'] = cca2;
    if (currencies != null) {
      data['currencies'] =
          currencies!.map((key, value) => MapEntry(key, value.toJson()));
    }
    return data;
  }

  Map<String, dynamic> toDatabase() {
    return {
      'code': cca2 ?? '',
      'name': name?.common ?? '',
      'flagUrl': flags?.png ?? '',
      'currency': currencies?.values.first.symbol ?? '',
    };
  }

  factory CountryModel.fromDatabase(Map<String, dynamic> data) {
    return CountryModel(
      cca2: data['code'],
      name: Name(common: data['name']),
      flags: Flags(png: data['flagUrl']),
      currencies: {
        'SHP': Currency(symbol: data['currency'], name: "Saint Helena Pound"),
      },
    );
  }
}

class Flags {
  String? png;
  String? svg;
  String? alt;

  Flags({this.png, this.svg, this.alt});

  Flags.fromJson(Map<String, dynamic> json) {
    png = json['png'];
    svg = json['svg'];
    alt = json['alt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['png'] = png;
    data['svg'] = svg;
    data['alt'] = alt;
    return data;
  }
}

class Name {
  String? common;
  String? official;
  NativeName? nativeName;

  Name({this.common, this.official, this.nativeName});

  Name.fromJson(Map<String, dynamic> json) {
    common = json['common'];
    official = json['official'];
    nativeName = json['nativeName'] != null
        ? NativeName.fromJson(json['nativeName'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['common'] = common;
    data['official'] = official;
    if (nativeName != null) {
      data['nativeName'] = nativeName!.toJson();
    }
    return data;
  }
}

class NativeName {
  Eng? eng;

  NativeName({this.eng});

  NativeName.fromJson(Map<String, dynamic> json) {
    eng = json['eng'] != null ? Eng.fromJson(json['eng']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (eng != null) {
      data['eng'] = eng!.toJson();
    }
    return data;
  }
}

class Eng {
  String? official;
  String? common;

  Eng({this.official, this.common});

  Eng.fromJson(Map<String, dynamic> json) {
    official = json['official'];
    common = json['common'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['official'] = official;
    data['common'] = common;
    return data;
  }
}

class Currency {
  String name;
  String symbol;

  Currency({
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        name: json["name"],
        symbol: json["symbol"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "symbol": symbol,
      };
}
