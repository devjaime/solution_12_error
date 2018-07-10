// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

/// For this app, the only [Category] endpoint we retrieve from an API is Currency.
///
///Si tuviéramos más, podríamos mantener una lista de [Categorías] aquí.
const apiCategory = {
  'name': 'Currency',
  'route': 'currency',
};


/// La API REST recupera conversiones de unidad para [Categorías] que cambian.
///
/// Por ejemplo, el tipo de cambio, los precios de las acciones, la altura del
/// las mareas cambian a menudo.
/// Hemos configurado una API que recupera una lista de monedas y su actual
/// tipo de cambio (datos simulados)
///   GET /currency: obtener una lista de monedas
///   GET /currency/convert: obtener conversión de una cantidad de moneda a otra
class Api {
  /// We use the `dart:io` HttpClient. More details: https://flutter.io/networking/
  // We specify the type here for readability. Since we're defining a final
  // field, the type is determined at initialization.
  final HttpClient _httpClient = HttpClient();

  /// El end point API al que queremos llegar.
  ///
  /// Esta API no tiene una clave, pero a menudo, las API requieren autenticación
  final String _url = 'flutter.udacity.com';


  /// Obtiene todas las unidades y tasas de conversión para una categoría determinada.
  ///
  /// El parámetro `category` es el nombre de la [Category] de la cual
  /// recuperar unidades. Pasamos esto al parámetro de consulta en la llamada API.
  ///
  /// Devuelve una lista. Devuelve null en error.
  Future<List> getUnits(String category) async {
    final uri = Uri.https(_url, '/$category');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['units'] == null) {
      print('Error retrieving units.');
      return null;
    }
    return jsonResponse['units'];
  }

  /// Given two units, converts from one to another.
  ///
  /// Returns a double, which is the converted amount. Returns null on error.
  Future<double> convert(
      String category, String amount, String fromUnit, String toUnit) async {
    final uri = Uri.https(_url, '/$category/convert',
        {'amount': amount, 'from': fromUnit, 'to': toUnit});
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['status'] == null) {
      print('Error retrieving conversion.');
      return null;
    } else if (jsonResponse['status'] == 'error') {
      print(jsonResponse['message']);
      return null;
    }
    return jsonResponse['conversion'].toDouble();
  }

  /// Fetches and decodes a JSON object represented as a Dart [Map].
  ///
  /// Returns null if the API server is down, or the response is not JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
