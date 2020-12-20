import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<Forecast> extract(String yandexUrl) async {
  // example: https://yandex.ru/pogoda/2
  Uri link = Uri.parse(yandexUrl);

  var request = await http.Client().get(link);
  var document = parse(request.body);

  Forecast fr = new Forecast();
  fr.weatherState =
      document.getElementsByClassName("link__condition").first.innerHtml;
  fr.currentTemp =
      document.getElementsByClassName("temp__value")[1].innerHtml.toString();
  fr.feelsLikeTemp =
      document.getElementsByClassName("temp__value")[2].innerHtml;
  fr.wind = document.getElementsByClassName("wind-speed")[0].innerHtml;
  fr.windDir = document.getElementsByClassName(" icon-abbr")[0].innerHtml;

  fr.humidity = document
      .getElementsByClassName("term term_orient_v fact__humidity")[0]
      .getElementsByClassName("term__value")[0]
      .text;

  fr.pressure = document
          .getElementsByClassName("term term_orient_v fact__pressure")[0]
          .getElementsByClassName("term__value")[0]
          .text +
      "мм рт. ст.";

  return fr;
}

Future<List<City>> searchCityByName(String city) async {
  List<City> res = new List<City>();
  Uri link = Uri.parse("https://yandex.ru/pogoda/search?request=" + city);

  var request = await http.Client().get(link);
  var document = parse(request.body);

  document
      .getElementsByClassName("link place-list__item-name")
      .forEach((element) {
    res.add(new City(
        element.innerHtml, "https://yandex.ru" + element.attributes["href"]));
  });

  return res;
}

Future<Forecast> searchForecastByCoords(
    double longitude, double latitude) async {
  // https://yandex.ru/pogoda/?lat=59.93486023&lon=30.3153553
  return await extract(
      "https://yandex.ru/pogoda/?lat={$latitude}3&lon={$longitude}");
}

class Forecast {
  String weatherState;
  String currentTemp;
  String feelsLikeTemp;

  String humidity;
  String pressure;

  String wind;
  String windDir;
}

class City {
  String cityName;
  String cityUrl;

  City(this.cityName, this.cityUrl);
}
