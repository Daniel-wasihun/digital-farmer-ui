import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/weather_controller.dart';
import 'package:intl/intl.dart';

// Utility to capitalize the first letter of a string
String capitalizeFirstLetter(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

// Format location name with capitalization
String getFormattedLocationName(String? location) =>
    location != null ? capitalizeFirstLetter(location) : 'Unknown';

// Generate dates for the last 7 days
List<String> getLast7DaysDates() => List.generate(
      7,
      (i) => DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: i))),
    );

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.put(WeatherController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;
    final isSmallPhone = size.width < 360;

    // Responsive scaling factor for UI elements
    final double scaleFactor = isLargeTablet ? 1.2 : isTablet ? 1.1 : isSmallPhone ? 0.9 : 1.0;
    // Responsive padding
    final double padding = isLargeTablet ? 24.0 : isTablet ? 20.0 : isSmallPhone ? 12.0 : 16.0;

    // Base font sizes
    const double baseHeaderFontSize = 26.0;
    const double baseTitleFontSize = 16.0;
    const double baseSubtitleFontSize = 12.0;
    const double baseDetailFontSize = 10.0;

    // Scaled font sizes
    final double headerFontSize = baseHeaderFontSize * scaleFactor;
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;

    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background painter for cloud effects
          CustomPaint(
            painter: WeatherBackgroundPainter(isDarkMode: isDarkMode),
            size: Size.infinite,
          ),
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [Colors.grey[800]!.withOpacity(0.8), Colors.grey[850]!.withOpacity(0.8)]
                    : [Colors.white.withOpacity(0.9), Colors.grey[50]!.withOpacity(0.9)],
              ),
            ),
            child: SafeArea(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.green[300]! : Colors.green[500]!),
                      strokeWidth: 4 * scaleFactor,
                    ),
                  );
                }

                final weatherData = controller.weatherData.value;
                final hasValidData = weatherData != null && controller.isValidWeatherData(weatherData);

                // Error state
                if (!hasValidData && controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60 * scaleFactor,
                          color: theme.colorScheme.error,
                        ),
                        SizedBox(height: padding),
                        Text(
                          controller.errorMessage.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: subtitleFontSize,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: padding),
                        ElevatedButton(
                          onPressed: () => controller.fetchWeatherData(
                            latitude: 11.7833,
                            longitude: 39.6,
                            city: 'weldiya',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.green[300] : Colors.green[500],
                            padding: EdgeInsets.symmetric(horizontal: 24 * scaleFactor, vertical: 12 * scaleFactor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scaleFactor)),
                            elevation: 4,
                          ),
                          child: Text(
                            'Retry'.tr,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // No data state
                if (!hasValidData) {
                  return Center(
                    child: Text(
                      'No Weather Data Available'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: subtitleFontSize,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  );
                }

                final forecast = weatherData['forecast'] as List;
                final cardLabels = [
                  'Today'.tr,
                  'Tomorrow'.tr,
                  forecast.length > 2 ? forecast[2]['date'].toString() : 'Day After'.tr,
                ];

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Current Weather Header
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 28 * scaleFactor,
                                      color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                    ),
                                    SizedBox(width: 8 * scaleFactor),
                                    Text(
                                      getFormattedLocationName(weatherData['location']?['name']?.toString()),
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontSize: headerFontSize,
                                        fontWeight: FontWeight.w800,
                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                        shadows: [
                                          Shadow(
                                            blurRadius: 6.0,
                                            color: isDarkMode ? Colors.black54 : Colors.black26,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6 * scaleFactor),
                                Row(
                                  children: [
                                    Text(
                                      weatherData['location']?['local_time']?.toString() ??
                                          DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                    if (controller.isOffline.value) ...[
                                      SizedBox(width: 8 * scaleFactor),
                                      Text(
                                        '(Offline)'.tr,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: detailFontSize,
                                          color: theme.colorScheme.error,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.refresh,
                                size: 28 * scaleFactor,
                                color: isDarkMode ? Colors.green[300] : Colors.green[500],
                              ),
                              onPressed: () => controller.fetchWeatherData(
                                latitude: 11.7833,
                                longitude: 39.6,
                                city: 'weldiya',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Current Weather Card
                      SizedBox(
                        height: (size.height * 0.15).clamp(100, 140),
                        child: Card(
                          elevation: 3,
                          color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          child: Padding(
                            padding: EdgeInsets.all(padding * 0.8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500),
                                      transitionBuilder: (Widget child, Animation<double> animation) =>
                                          ScaleTransition(scale: animation, child: child),
                                      child: Icon(
                                        _getWeatherIcon(weatherData['current']?['condition']?.toString() ?? 'sunny'),
                                        key: ValueKey(weatherData['current']?['condition'] ?? 'sunny'),
                                        color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                        size: 48 * scaleFactor,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scaleFactor),
                                    Text(
                                      (weatherData['current']?['condition']?.toString() ?? 'sunny').toLowerCase().tr,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: subtitleFontSize * 0.9,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${weatherData['current']?['temperature']?['c']?.toString() ?? 'N/A'}°C',
                                      style: theme.textTheme.displaySmall?.copyWith(
                                        fontSize: headerFontSize * 1.2,
                                        fontWeight: FontWeight.w900,
                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                      ),
                                    ),
                                    Text(
                                      'Feels Like: ${weatherData['current']?['feels_like']?['c']?.toString() ?? 'N/A'}°C'.tr,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize * 0.9,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'Humidity: ${weatherData['current']?['humidity']?.toString() ?? 'N/A'}%'.tr,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize * 0.9,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),  
                      // Question Input Card
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          elevation: 3,
                          color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.question_answer,
                                      size: 20 * scaleFactor,
                                      color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                    ),
                                    SizedBox(width: 8 * scaleFactor),
                                    Text(
                                      'Ask a Question'.tr,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w800,
                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8 * scaleFactor),
                                TextField(
                                  controller: controller.questionController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., How is the weather today?'.tr,
                                    hintStyle: TextStyle(
                                      fontSize: detailFontSize,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100]!.withOpacity(0.9),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.send,
                                        size: 20 * scaleFactor,
                                        color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                      ),
                                      onPressed: () => controller.askWeatherQuestion(),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16 * scaleFactor,
                                      horizontal: 12 * scaleFactor,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: detailFontSize,
                                    fontFamily: Get.locale?.languageCode == 'am' ? 'NotoSansEthiopic' : null,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                  ),
                                  onSubmitted: (value) => controller.askWeatherQuestion(),
                                ),
                                SizedBox(height: 8 * scaleFactor),
                                if (controller.isAskLoading.value)
                                  Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3 * scaleFactor,
                                      valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.green[300]! : Colors.green[500]!),
                                    ),
                                  ),
                                if (controller.askAnswer.value != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8 * scaleFactor),
                                    child: Text(
                                      controller.askAnswer.value!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        fontFamily: Get.locale?.languageCode == 'am' ? 'NotoSansEthiopic' : null,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 3-Day Forecast Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20 * scaleFactor,
                                  color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                ),
                                SizedBox(width: 8 * scaleFactor),
                                Text(
                                  '3-Day Forecast'.tr,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12 * scaleFactor),
                            SizedBox(
                              height: 100 * scaleFactor,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const ClampingScrollPhysics(),
                                itemCount: forecast.length > 3 ? 3 : forecast.length,
                                itemBuilder: (context, index) {
                                  final dayData = forecast[index]['day'];
                                  final astroData = forecast[index]['astro'];
                                  final hourlyData = forecast[index]['hourly'];
                                  // Wider card width, responsive to screen size
                                  final double cardWidth = (size.width * 0.45).clamp(220, 250);
                                  return Padding(
                                    padding: EdgeInsets.only(right: 0 * scaleFactor),
                                    child: AnimatedOpacity(
                                      opacity: 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => ForecastDetailSheet(
                                              label: cardLabels[index],
                                              dayData: dayData,
                                              astroData: astroData,
                                              hourlyData: hourlyData,
                                              theme: theme,
                                              isDarkMode: isDarkMode,
                                              scaleFactor: scaleFactor,
                                              padding: padding,
                                              headerFontSize: headerFontSize,
                                              subtitleFontSize: subtitleFontSize,
                                              detailFontSize: detailFontSize,
                                              titleFontSize: titleFontSize,
                                            ),
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: cardWidth,
                                          child: Card(
                                            elevation: 4,
                                            color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              // padding: EdgeInsets.all(10 * scaleFactor),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Centered day header
                                                  Text(
                                                    cardLabels[index],
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      fontSize: detailFontSize * 1.3,
                                                      fontWeight: FontWeight.w900,
                                                      color: isDarkMode ? Colors.white : Colors.grey[900],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4 * scaleFactor),
                                                  // Icons   weather
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(width: 4 * scaleFactor),
                                                      AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 500),
                                                        transitionBuilder: (Widget child, Animation<double> animation) =>
                                                            ScaleTransition(scale: animation, child: child),
                                                        child: Icon(
                                                          _getWeatherIcon(dayData?['condition']?.toString() ?? 'sunny'),
                                                          key: ValueKey(dayData?['condition'] ?? 'sunny'),
                                                          color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                                          size: 35 * scaleFactor,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8 * scaleFactor),
                                                      // Temperature range
                                                      Text(
                                                        '${dayData?['max_temp']?['c']?.toString() ?? 'N/A'}°C / ${dayData?['min_temp']?['c']?.toString() ?? 'N/A'}°C',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize * 1.1,
                                                          fontWeight: FontWeight.w700,
                                                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                  // Weather condition
                                                  Flexible(
                                                    child: Text(
                                                      (dayData?['condition']?.toString() ?? 'sunny').toLowerCase().tr,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        fontSize: detailFontSize * 0.95,
                                                        fontWeight: FontWeight.w600,
                                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Historical Weather Card
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          elevation: 3,
                          color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 20 * scaleFactor,
                                      color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                    ),
                                    SizedBox(width: 8 * scaleFactor),
                                    Text(
                                      'Historical Weather (Last 7 Days)'.tr,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: titleFontSize*0.8,
                                        fontWeight: FontWeight.w800,
                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12 * scaleFactor),
                                if (weatherData['historical'] is List && (weatherData['historical'] as List).isNotEmpty)
                                  ...List.generate(
                                    (weatherData['historical'] as List).length,
                                    (index) {
                                      final historical = (weatherData['historical'] as List)[index];
                                      final precip = double.tryParse(historical['total_precip']?.toString() ?? '0') ?? 0;
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 6 * scaleFactor),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _getHistoricalIcon(precip),
                                              size: 18 * scaleFactor,
                                              color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                            ),
                                            SizedBox(width: 8 * scaleFactor),
                                            Expanded(
                                              child: Text(
                                                historical['date']?.toString() ?? 'N/A',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontSize: detailFontSize,
                                                  color: isDarkMode ? Colors.white : Colors.grey[900],
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${historical['avg_temp']?.toString() ?? 'N/A'}°C',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: detailFontSize,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                                  ),
                                                ),
                                                Text(
                                                  'Precip: ${historical['total_precip']?.toString() ?? 'N/A'} mm'.tr,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: detailFontSize * 0.9,
                                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Text(
                                    'Historical data not available'.tr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: subtitleFontSize,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: padding * 2),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Language Toggle FAB
          Positioned(
            bottom: 12 * scaleFactor,
            right: 12 * scaleFactor,
            child: FloatingActionButton(
              onPressed: () => controller.toggleLanguage(),
              backgroundColor: isDarkMode ? Colors.green[300] : Colors.green[500],
              tooltip: 'Toggle Language'.tr,
              mini: true,
              child: Icon(
                Icons.language,
                color: Colors.white,
                size: 20 * scaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get weather icon based on condition
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'clear':
        return Icons.nights_stay;
      case 'partly cloudy':
        return Icons.cloud_queue;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
        return Icons.water_drop;
      default:
        return Icons.wb_sunny;
    }
  }

  // Get historical weather icon based on precipitation
  IconData _getHistoricalIcon(double precip) {
    if (precip > 0.5) {
      return Icons.water_drop;
    } else if (precip > 0) {
      return Icons.cloud_queue;
    } else {
      return Icons.wb_sunny;
    }
  }
}

class ForecastDetailSheet extends StatelessWidget {
  final String label;
  final dynamic dayData;
  final dynamic astroData;
  final dynamic hourlyData;
  final ThemeData theme;
  final bool isDarkMode;
  final double scaleFactor;
  final double padding;
  final double headerFontSize;
  final double subtitleFontSize;
  final double detailFontSize;
  final double titleFontSize;

  const ForecastDetailSheet({
    super.key,
    required this.label,
    required this.dayData,
    required this.astroData,
    required this.hourlyData,
    required this.theme,
    required this.isDarkMode,
    required this.scaleFactor,
    required this.padding,
    required this.headerFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
    required this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        elevation: 4,
        color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
              child: Container(
                width: 40 * scaleFactor,
                height: 4 * scaleFactor,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode ? Colors.white : Colors.grey[900],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              _getWeatherIcon(dayData?['condition']?.toString() ?? 'sunny'),
                              key: ValueKey(dayData?['condition'] ?? 'sunny'),
                              color: isDarkMode ? Colors.green[300] : Colors.green[500],
                              size: 44 * scaleFactor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      Text(
                        (dayData?['condition']?.toString() ?? 'sunny').toLowerCase().tr,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      Divider(
                        color: isDarkMode ? Colors.grey[600]!.withOpacity(0.2) : Colors.grey[200]!.withOpacity(0.2),
                        height: 16 * scaleFactor,
                      ),
                      _buildDetailRow(
                        'Max/Min Temp'.tr,
                        '${dayData?['max_temp']?['c']?.toString() ?? 'N/A'}°C / ${dayData?['min_temp']?['c']?.toString() ?? 'N/A'}°C',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.thermostat,
                      ),
                      _buildDetailRow(
                        'Avg Temp'.tr,
                        '${dayData?['avg_temp']?['c']?.toString() ?? 'N/A'}°C',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.thermostat_auto,
                      ),
                      _buildDetailRow(
                        'Precipitation'.tr,
                        dayData?['precipitation']?['chance']?.toString() ?? 'N/A',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.umbrella,
                      ),
                      _buildDetailRow(
                        'Wind'.tr,
                        '${dayData?['max_wind']?['kph']?.toString() ?? 'N/A'} kph',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.air,
                      ),
                      _buildDetailRow(
                        'Humidity'.tr,
                        '${dayData?['humidity']?.toString() ?? 'N/A'}%',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.water_drop_outlined,
                      ),
                      _buildDetailRow(
                        'UV Index'.tr,
                        dayData?['uv']?.toString() ?? 'N/A',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.wb_sunny_outlined,
                      ),
                      _buildDetailRow(
                        'Visibility'.tr,
                        '${dayData?['visibility']?['km']?.toString() ?? 'N/A'} km',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.visibility,
                      ),
                      SizedBox(height: 12 * scaleFactor),
                      Text(
                        'Hourly Forecast'.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      _buildDetailRow(
                        'Morning'.tr,
                        '${hourlyData?['morning']?['temp_range']?[0]?.toString() ?? 'N/A'}°C - ${hourlyData?['morning']?['temp_range']?[1]?.toString() ?? 'N/A'}°C, ${(hourlyData?['morning']?['condition']?.toString() ?? 'N/A').toLowerCase().tr}',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.wb_sunny,
                      ),
                      _buildDetailRow(
                        'Midday'.tr,
                        '${hourlyData?['midday']?['temp_range']?[0]?.toString() ?? 'N/A'}°C - ${hourlyData?['midday']?['temp_range']?[1]?.toString() ?? 'N/A'}°C, ${(hourlyData?['midday']?['condition']?.toString() ?? 'N/A').toLowerCase().tr}',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.wb_sunny,
                      ),
                      _buildDetailRow(
                        'Evening'.tr,
                        '${hourlyData?['evening']?['temp_range']?[0]?.toString() ?? 'N/A'}°C - ${hourlyData?['evening']?['temp_range']?[1]?.toString() ?? 'N/A'}°C, ${(hourlyData?['evening']?['condition']?.toString() ?? 'N/A').toLowerCase().tr}',
                        theme,
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.nights_stay,
                      ),
                      if (astroData != null) ...[
                        SizedBox(height: 12 * scaleFactor),
                        Text(
                          'Astronomy'.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        _buildDetailRow(
                          'Sunrise'.tr,
                          astroData['sunrise']?.toString() ?? 'N/A',
                          theme,
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.wb_sunny,
                        ),
                        _buildDetailRow(
                          'Sunset'.tr,
                          astroData['sunset']?.toString() ?? 'N/A',
                          theme,
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nights_stay,
                        ),
                        _buildDetailRow(
                          'Moon Phase'.tr,
                          astroData['moon_phase']?.toString() ?? 'N/A',
                          theme,
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nightlight_round,
                        ),
                        _buildDetailRow(
                          'Moonrise'.tr,
                          astroData['moonrise']?.toString() ?? 'N/A',
                          theme,
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nightlight,
                        ),
                        _buildDetailRow(
                          'Moonset'.tr,
                          astroData['moonset']?.toString() ?? 'N/A',
                          theme,
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nightlight_outlined,
                        ),
                      ],
                      SizedBox(height: 16 * scaleFactor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get weather icon for forecast detail
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'clear':
        return Icons.nights_stay;
      case 'partly cloudy':
        return Icons.cloud_queue;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
        return Icons.water_drop;
      default:
        return Icons.wb_sunny;
    }
  }

  // Build detail row for forecast details
  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme,
    double fontSize,
    bool isDarkMode, {
    IconData? icon,
    bool isTitle = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 6 * fontSize / 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8 * fontSize / 10),
                  child: Icon(
                    icon,
                    size: 18 * fontSize / 10,
                    color: isDarkMode ? Colors.green[300] : Colors.green[500],
                  ),
                ),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: isTitle ? FontWeight.w800 : FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
          if (!isTitle)
            Flexible(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class WeatherBackgroundPainter extends CustomPainter {
  final bool isDarkMode;

  WeatherBackgroundPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: isDarkMode
            ? [Colors.grey[800]!.withOpacity(0.4), Colors.grey[850]!.withOpacity(0.4)]
            : [Colors.white.withOpacity(0.4), Colors.grey[50]!.withOpacity(0.4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw cloud shapes
    for (var i = 0; i < 3; i++) {
      final cloudPaint = Paint()
        ..color = isDarkMode ? Colors.grey[500]!.withOpacity(0.3) : Colors.grey[300]!.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      final cloudPath = Path()
        ..moveTo(50 + i * 200, 100 + i * 50)
        ..quadraticBezierTo(80 + i * 200, 80 + i * 50, 110 + i * 200, 100 + i * 50)
        ..quadraticBezierTo(140 + i * 200, 120 + i * 50, 170 + i * 200, 100 + i * 50)
        ..quadraticBezierTo(200 + i * 200, 80 + i * 50, 230 + i * 200, 100 + i * 50)
        ..quadraticBezierTo(230 + i * 200, 140 + i * 50, 190 + i * 200, 140 + i * 50)
        ..quadraticBezierTo(160 + i * 200, 160 + i * 50, 130 + i * 200, 140 + i * 50)
        ..quadraticBezierTo(90 + i * 200, 160 + i * 50, 50 + i * 200, 140 + i * 50)
        ..close();

      canvas.drawPath(cloudPath, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}