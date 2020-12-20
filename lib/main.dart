import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'YandexPogoda.dart' as Pogoda;

void main() {
  runApp(MaterialApp(
    home: Screen(),
  ));
}

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final textController = TextEditingController();
  bool allowSearch = false;
  List<Pogoda.City> cities;

  @override
  void initState() {
    super.initState();
    textController.addListener(checkSearchText);
  }

  void checkSearchText() async {
    if (textController.text.isNotEmpty) {
      cities = await Pogoda.searchCity(textController.text);
    } else {
      cities = null;
    }

    setState(() {});

    // print("aue");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Прогноз погоды"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: textController,
                onSubmitted: (value) async {
                  cities = await Pogoda.searchCity(textController.text);
                  setState(() {});
                },
                decoration: InputDecoration(
                    hintText: "Найти город или район",
                    prefixIcon: Icon(CupertinoIcons.search)),
              ),
              Expanded(child: showCities(cities))
            ],
          ),
        ),
      ),
    );
  }

  Widget showCities(List<Pogoda.City> cities) {
    if (textController.text != "")
      return ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, int index) {
            return Card(
              child: InkWell(
                onTap: () {
                  print(cities[index].cityUrl);
                },
                child: ListTile(
                  shape: Border.all(),
                  title: Text(cities[index].cityName),
                ),
              ),
            );
          });
    else
      return Text("");
  }
}

void showForecast(Pogoda.Forecast forecast) {
  print("Погода: " + forecast.weatherState);
  print("Текущая температура: " + forecast.currentTemp);
  print("ощущается как: " + forecast.feelsLikeTemp);
  print("Ветер: " + forecast.wind + " м/с, " + forecast.windDir);
  print("Влажность: " + forecast.humidity);
  print("Давление: " + forecast.pressure);
}
