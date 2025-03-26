import 'dart:convert';

import 'package:countries_api_demo/country_model.dart';
import 'package:countries_api_demo/db_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CountryState {
  final List<CountryModel> allCountries;
  final List<CountryModel> displayedCountries;
  final String searchQuery;
  final bool isAscending;

  CountryState({
    this.allCountries = const [],
    this.displayedCountries = const [],
    this.searchQuery = '',
    this.isAscending = true,
  });

  CountryState copyWith({
    List<CountryModel>? allCountries,
    List<CountryModel>? displayedCountries,
    String? searchQuery,
    bool? isAscending,
  }) {
    return CountryState(
      allCountries: allCountries ?? this.allCountries,
      displayedCountries: displayedCountries ?? this.displayedCountries,
      searchQuery: searchQuery ?? this.searchQuery,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

class CountryNotifier extends StateNotifier<CountryState> {
  final DBHelper? dbRef;

  CountryNotifier(this.dbRef) : super(CountryState()) {
    getCountriesData();
  }

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

  Future<void> getCountriesData() async {
    final List<Map<String, dynamic>> countries = await dbRef!.getAllCountries();

    List<CountryModel> displayAllCountries =
        countries.map((country) => CountryModel.fromDatabase(country)).toList();

    if (displayAllCountries.isEmpty) {
      List<CountryModel> displayAllCountries = await fetchCountriesFromAPI();

      List<Map<String, dynamic>> dbMaps =
          displayAllCountries.map((country) => country.toDatabase()).toList();

      await dbRef!.insertCountries(dbMaps);
    }

    state = state.copyWith(allCountries: displayAllCountries);
    applyFilter();
  }

  void applyFilter() {
    List<CountryModel> filteredList = state.allCountries
        .where((country) =>
            (country.name!.common)!.toLowerCase().contains(state.searchQuery))
        .toList();

    filteredList.sort((a, b) => state.isAscending
        ? (a.cca2!).compareTo(b.cca2!)
        : (b.cca2!).compareTo(a.cca2!));

    state = state.copyWith(displayedCountries: filteredList);
  }

  void searchQuery(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
    applyFilter();
  }

  void toggleSort() {
    state = state.copyWith(isAscending: !state.isAscending);
    applyFilter();
  }

  void deleteCountry(CountryModel country) async {
    await dbRef!.deleteCountry(country.cca2!);
    final newAllCountries = [...state.allCountries]
      ..removeWhere((c) => c.cca2 == country.cca2);

    state = state.copyWith(allCountries: newAllCountries);
    applyFilter();
  }
}

final countryProvider =
    StateNotifierProvider<CountryNotifier, CountryState>((ref) {
  final dbRef = DBHelper.getInstance;
  return CountryNotifier(dbRef);
});
