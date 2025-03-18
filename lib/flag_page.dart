import 'package:countries_api_demo/country_model.dart';
import 'package:flutter/material.dart';

class FlagPage extends StatelessWidget {
  const FlagPage({super.key, required this.country});

  final CountryModel country;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text('${country.name!.common}'),
      ),
      body: Hero(
        tag: country.cca2!,
        child: Center(
          child: Image.network(
            '${country.flags!.png}',
            fit: BoxFit.fill,
            height: height * 0.25,
            width: width * 0.9,
          ),
        ),
      ),
    );
  }
}
