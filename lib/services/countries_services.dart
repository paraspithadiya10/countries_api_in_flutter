import 'dart:convert';

import 'package:countries_api_demo/country_model.dart';
import 'package:http/http.dart' as http;

class CountriesServices {
  Future<List<CountryModel>> fetchCountriesFromAPI() async {
    final response = await http.get(Uri.parse(
        'https://restcountries.com/v3.1/all?fields=name,flags,cca2,currencies'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CountryModel.fromJson(json)).toList();
    } else {
      return throw Exception('Failed to load data');
    }
  }
}
