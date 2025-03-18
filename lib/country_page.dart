import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:countries_api_demo/country_model.dart';
import 'package:countries_api_demo/db_helper.dart';
import 'package:countries_api_demo/flag_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  List<CountryModel> allCountries = [];
  List<CountryModel> displayedCountries = [];

  String searchQuery = '';

  DBHelper? dbRef;

  bool isAscending = true;

  @override
  void initState() {
    dbRef = DBHelper.getInstance;
    getCountriesData();
    super.initState();
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

    setState(() {
      allCountries = displayAllCountries;
    });
    applyFilter();
  }

  void applyFilter() {
    List<CountryModel> filteredList = allCountries
        .where((country) =>
            (country.name!.common)!.toLowerCase().contains(searchQuery))
        .toList();

    filteredList.sort((a, b) => isAscending
        ? (a.cca2!).compareTo(b.cca2!)
        : (b.cca2!).compareTo(a.cca2!));

    setState(() {
      displayedCountries = filteredList;
    });
  }

  void deleteCountry(CountryModel country) async {
    await dbRef!.deleteCountry(country.cca2!);
    setState(() {
      allCountries.removeWhere((c) => c.cca2 == country.cca2);
    });
    applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Countries'),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isAscending = !isAscending;
                    applyFilter();
                  });
                },
                icon: Icon(Icons.sort))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (String text) {
                  searchQuery = text;
                  setState(() {
                    applyFilter();
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: displayedCountries.length,
                  itemBuilder: (context, index) {
                    var country = displayedCountries[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Card(
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FlagPage(country: country)));
                            },
                            child: Hero(
                              tag: country.cca2!,
                              child: SizedBox(
                                height: 40,
                                width: 50,
                                child: CachedNetworkImage(
                                  imageUrl: '${country.flags!.png}',
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          title: Text('${country.name!.common}'),
                          subtitle: Text(
                              'code: ${country.cca2}  currency: ${country.currencies!.values.first.symbol}'),
                          onLongPress: () {
                            deleteCountry(country);
                          },
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}
