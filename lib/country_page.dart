import 'package:cached_network_image/cached_network_image.dart';
import 'package:countries_api_demo/flag_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countries_api_demo/providers/country_provider.dart';

class CountryPage extends ConsumerWidget {
  const CountryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryState = ref.watch(countryProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Countries'),
          actions: [
            IconButton(
                onPressed: () {
                  ref.read(countryProvider.notifier).toggleSort();
                },
                icon: const Icon(Icons.sort))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (String text) {
                  ref.read(countryProvider.notifier).setSearchQuery(text);
                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: 'Search',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))),
              ),
            ),
            if (countryState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                    itemCount: countryState.displayedCountries.length,
                    itemBuilder: (context, index) {
                      var country = countryState.displayedCountries[index];
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
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            title: Text('${country.name!.common}'),
                            subtitle: Text(
                                'code: ${country.cca2}  currency: ${country.currencies!.values.first.symbol}'),
                            onLongPress: () {
                              ref
                                  .read(countryProvider.notifier)
                                  .deleteCountry(country);
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
