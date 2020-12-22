import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<Forecast> extract(String yandexUrl) async {
  // example: https://yandex.ru/pogoda/2
  Uri link = Uri.parse(yandexUrl);

  var request = await http.Client().get(link);
  var document = parse(request.body);

  Forecast fr = new Forecast();
  fr.placeName = document
      .getElementsByClassName("title title_level_1 header-title__title")
      .first
      .text;
  fr.weatherState =
      document.getElementsByClassName("link__condition").first.innerHtml;
  fr.currentTemp =
      document.getElementsByClassName("temp__value")[1].innerHtml.toString();
  fr.feelsLikeTemp =
      document.getElementsByClassName("temp__value")[2].innerHtml;
  fr.wind = document.getElementsByClassName("wind-speed")[0].innerHtml;
  fr.windDir = document.getElementsByClassName(" icon-abbr")[0].innerHtml;
  document.getElementsByClassName(" icon-abbr")[0].remove();
  fr.windMeasure = document.getElementsByClassName("fact__unit")[0].text;

  fr.humidity = document
      .getElementsByClassName("term term_orient_v fact__humidity")[0]
      .getElementsByClassName("term__value")[0]
      .text;

  fr.pressure = document
      .getElementsByClassName("term term_orient_v fact__pressure")[0]
      .getElementsByClassName("term__value")[0]
      .text;

  document.getElementsByClassName("fact__hour swiper-slide").forEach((element) {
    try {
      String time = element.getElementsByClassName("fact__hour-label")[0].text;
      String degree = element.getElementsByClassName("fact__hour-temp")[0].text;
      String icon;
      document
          .getElementsByClassName("fact__hour swiper-slide")[0]
          .nodes[0]
          .children
          .forEach((child) {
        if (child.attributes.containsKey("src")) {
          child.classes.forEach((childClass) {
            if (childClass.contains("icon_thumb_")) {
              icon = childClass.replaceAll("icon_thumb_", "");
            }
          });
        }
      });

      fr.forecastForNext24Hours.add(ForecastForHour(time, degree, icon));
    } catch (ex) {
      print(ex);
    }
  });

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
  print("https://yandex.ru/pogoda/?lat=$latitude&lon=$longitude");
  return await extract(
      "https://yandex.ru/pogoda/?lat=$latitude&lon=$longitude");
}

class Forecast {
  String placeName;
  String weatherState;
  String currentTemp;
  String feelsLikeTemp;

  String humidity;
  String pressure;

  String wind;
  String windDir;
  String windMeasure;

  List<ForecastForHour> forecastForNext24Hours = new List<ForecastForHour>();
}

class ForecastForHour {
  String time;
  String conditionIcon;
  String degree;

  ForecastForHour(this.time, this.degree, this.conditionIcon);
}

String findConditionIcon(String str) {
  print(str);
  return "";
}

class City {
  String cityName;
  String cityUrl;

  City(this.cityName, this.cityUrl);
}
