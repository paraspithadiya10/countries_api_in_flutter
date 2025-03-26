import 'package:countries_api_demo/models/country_model.dart';

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
