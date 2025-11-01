import 'dart:convert';

import 'package:http/http.dart' as http;

// API call from Countries and wikipedia API
//No API key needed. for both restcountries.com and en.wikipedia.org

class CityInfoService {
  final String wikiBaseUrl = 'en.wikipedia.org';
  final String restCountriesBaseUrl = 'restcountries.com';
  String nameholder = '';

  // Fetch city or country description from Wikipedia
  Future<String> fetchCityDescription(String name) async {
    nameholder = name.toLowerCase();
    final uri = Uri.https(wikiBaseUrl, '/api/rest_v1/page/summary/$name');
    final response = await http.get(uri);

    //200 means HTTP OK SUCCESS
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      //tries to get the value associated with the key "extract": in the json file from wikipedia
      // "??"--> If the value on the left is null, use the value on the right instead.
      return data['extract'] ?? 'No description available.';
    } else {
      return 'Could not fetch info.';
    }
  }

  // Fetch by ISO code (e.g. Egypt "EG") from countires api
  Future<Map<String, dynamic>?> fetchCountryInfo(String iso) async {
    final uri = Uri.https(restCountriesBaseUrl, '/v3.1/alpha/$iso');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Country not found ($iso)');
    }
    //print('Fetched country: $iso');
    // Decode the response (top-level is a List)
    final dataList = jsonDecode(res.body) as List<dynamic>;

    final data = dataList[0] as Map<String, dynamic>;
    final commonNameCheck = (data['name']?['common'] ?? 'Unknown')
        .toString()
        .toLowerCase();

    print('Fetched countries name common: $commonNameCheck');
    print('Fetched countries data : $dataList');
    print('string late : $nameholder');

    /* if (nameholder == commonNameCheck) {
      return _mapCountryData(data);
    } else {
      return null;
    }*/

    // Get the first country map
    //final data = dataList[0] as Map<String, dynamic>;

    // Access the common name directly (optional, for logging or simple use)
    /*final commonName = data['name']?['common'] ?? 'Unknown';
    print('Fetched countries name common: $commonName');
    print('Fetched countries data : $dataList');*/

    // Map and return full structured data
    return _mapCountryData(data);
  }

  // Fetch by *exact* country name
  Future<Map<String, dynamic>?> fetchCountryInfoByName(String country) async {
    final clean = country.trim();

    // first: try exact match
    final exactUri = Uri.https(restCountriesBaseUrl, '/v3.1/name/$clean', {
      'fullText': 'true',
    });

    var res = await http.get(exactUri);

    // fallback if exact match not found
    if (res.statusCode == 404) {
      final fuzzyUri = Uri.https(restCountriesBaseUrl, '/v3.1/name/$clean');
      res = await http.get(fuzzyUri);
    }
    //   if country is not found throw exception
    if (res.statusCode != 200) {
      throw Exception('Country info not found for $country');
    }

    final List<dynamic> list = jsonDecode(res.body);

    // filter to exact match manually just in case
    // makes all user input lower case, then picks the common and official name from "countries" jsoon api and compares to lower
    //orElse: part is the fallback for firstWhere
    final lower = clean.toLowerCase();
    final match = list.firstWhere((c) {
      final n = (c['name']['common'] as String).toLowerCase();
      final o = (c['name']['official'] as String).toLowerCase();
      return n == lower || o == lower;
    }, orElse: () => list[0]);

    return _mapCountryData(match);
  }

  Map<String, dynamic>? _mapCountryData(dynamic data) {
    final currencies = data['currencies'] as Map?;
    final currencyData = currencies != null && currencies.isNotEmpty
        ? currencies.values.first
        : {'name': 'N/A', 'symbol': ''};

    return {
      'name': data['name']?['common'] ?? 'N/A',
      'currency': currencyData['name'] ?? 'N/A',
      'currencySymbol': currencyData['symbol'] ?? '',
      'flag': data['flags']?['png'] ?? '',
      'continent': (data['continents'] as List?)?.first ?? 'N/A',
      'capital': (data['capital'] as List?)?.first ?? 'N/A',
      'population': data['population'] ?? 'N/A',
      'language': (data['languages'] as Map?)?.values.join(', ') ?? 'N/A',
      'area': data['area'] ?? 'N/A',
      'timezone': (data['timezones'] as List?)?.first ?? 'N/A',
      'googleMap': data['maps']?['googleMaps'] ?? '',
    };
  }
}
