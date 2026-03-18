import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import 'models.dart';

// Обновленная функция: теперь показует день и ночь
IconData getWeatherIcon(String iconCode) {
  bool isDay = iconCode.endsWith('d');
  
  if (iconCode.startsWith('01')) return isDay ? Icons.wb_sunny : Icons.nightlight_round;
  if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) return Icons.cloud;
  if (iconCode.startsWith('09') || iconCode.startsWith('10')) return Icons.water_drop;
  if (iconCode.startsWith('11')) return Icons.flash_on;
  if (iconCode.startsWith('13')) return Icons.ac_unit;
  
  return Icons.cloud;
}

// --- 1. СЕТКА ДЕТАЛЕЙ (Влажность, ветер и т.д.) ---
class WeatherGridDetails extends StatelessWidget {
  final WeatherInfo weather;

  const WeatherGridDetails({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        // ИЗМЕНЕНИЕ 1: Было 2.5, стало 1.8Pxs
        childAspectRatio: 1.8, 
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildDetailTile(Icons.water_drop, '${weather.humidity}%', 'Humidity'),
          _buildDetailTile(Icons.air, '${weather.windSpeed} m/s', 'Wind'),
          _buildDetailTile(Icons.thermostat, '${weather.temperature.toStringAsFixed(1)}°', 'Real Feel'),
          _buildDetailTile(Icons.visibility, '10 km', 'Visibility'),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded( 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HourlyForecastView extends StatelessWidget {
  final List<ForecastItem> forecast;

  const HourlyForecastView({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: forecast.length > 8 ? 8 : forecast.length,
            itemBuilder: (context, index) {
              final item = forecast[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('j').format(item.time), style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 5),
                    // Передаем iconCode вместо mainCondition
                    Icon(getWeatherIcon(item.iconCode), color: Colors.white, size: 24),
                    const SizedBox(height: 5),
                    Text(
                      '${item.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- 3. БОКОВОЕ МЕНЮ С СОХРАНЕННЫМИ ГОРОДАМИ ---
class FavoritesDrawer extends StatelessWidget {
  final List<FavoriteItem> favorites;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(String) onSelect;

  const FavoritesDrawer({
    super.key,
    required this.favorites,
    required this.onEdit,
    required this.onDelete,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          color: Colors.black.withOpacity(0.25),
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
                ),
                child: Center(
                  child: Text('Saved Locations', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (ctx, i) {
                    final item = favorites[i];
                    return ListTile(
                      title: Text(item.nickname, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${item.lastTemp}°C', style: const TextStyle(color: Colors.tealAccent)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => onEdit(i)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(i)),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(item.apiName);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
