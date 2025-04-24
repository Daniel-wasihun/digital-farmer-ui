import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/weather_controller.dart';
import 'package:intl/intl.dart';

// Utility method to capitalize the first letter of a string
String capitalizeFirstLetter(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

// Method to format location name with proper capitalization
String getFormattedLocationName(String? location) =>
    location != null ? capitalizeFirstLetter(location) : 'Unknown';

// Method to get the last 7 days' dates
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

    final double scaleFactor = isLargeTablet ? 1.2 : isTablet ? 1.1 : isSmallPhone ? 0.9 : 1.0;
    final double padding = isLargeTablet ? 20.0 : isTablet ? 16.0 : isSmallPhone ? 10.0 : 14.0;

    const double baseHeaderFontSize = 24.0;
    const double baseTitleFontSize = 14.0;
    const double baseSubtitleFontSize = 10.0;
    const double baseDetailFontSize = 8.0;

    final double headerFontSize = baseHeaderFontSize * scaleFactor;
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;
    final double historicalDetailFontSize = baseDetailFontSize * scaleFactor * 0.9;

    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.green[50]!.withOpacity(0.8), Colors.green[200]!.withOpacity(0.9)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      strokeWidth: 4 * scaleFactor,
                    ),
                  );
                }

                final weatherData = controller.weatherData.value;
                final hasValidData = weatherData != null && controller.isValidWeatherData(weatherData);

                if (!hasValidData && controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50 * scaleFactor,
                          color: theme.colorScheme.error,
                        ),
                        SizedBox(height: padding),
                        Text(
                          controller.errorMessage.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: subtitleFontSize,
                            color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.7) : theme.colorScheme.onSurface,
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
                            backgroundColor: theme.colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor, vertical: 10 * scaleFactor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scaleFactor)),
                            elevation: 5,
                          ),
                          child: Text(
                            'Retry'.tr,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!hasValidData) {
                  return Center(
                    child: Text(
                      'No Weather Data Available'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: subtitleFontSize,
                        color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.7) : theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
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
                                      size: 24 * scaleFactor,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(width: 8 * scaleFactor),
                                    Text(
                                      getFormattedLocationName(weatherData['location']?['name']?.toString()),
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontSize: headerFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 4.0,
                                            color: Colors.black26,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4 * scaleFactor),
                                Row(
                                  children: [
                                    Text(
                                      weatherData['location']?['local_time']?.toString() ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
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
                                size: 24 * scaleFactor,
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: EdgeInsets.all(padding * 1.2),
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
                                            color: theme.colorScheme.secondary,
                                            size: 60 * scaleFactor,
                                          ),
                                        ),
                                        SizedBox(height: 8 * scaleFactor),
                                        Text(
                                          (weatherData['current']?['condition']?.toString() ?? 'sunny').toLowerCase().tr,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontSize: subtitleFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
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
                                            fontSize: headerFontSize * 1.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'Feels Like: ${weatherData['current']?['feels_like']?['c']?.toString() ?? 'N/A'}°C'.tr,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: detailFontSize,
                                            color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                          ),
                                        ),
                                        Text(
                                          'Humidity: ${weatherData['current']?['humidity']?.toString() ?? 'N/A'}%'.tr,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: detailFontSize,
                                            color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: EdgeInsets.all(padding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.question_answer,
                                          size: 18 * scaleFactor,
                                          color: theme.colorScheme.primary,
                                        ),
                                        SizedBox(width: 8 * scaleFactor),
                                        Text(
                                          'Ask a Question'.tr,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
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
                                          color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.send,
                                            size: 18 * scaleFactor,
                                            color: theme.colorScheme.primary,
                                          ),
                                          onPressed: () => controller.askWeatherQuestion(),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8 * scaleFactor,
                                          horizontal: 10 * scaleFactor,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: detailFontSize,
                                        color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                      ),
                                      onSubmitted: (value) => controller.askWeatherQuestion(),
                                    ),
                                    SizedBox(height: 8 * scaleFactor),
                                    ElevatedButton(
                                      onPressed: () => controller.askCropQuestion('teff'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor, vertical: 10 * scaleFactor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scaleFactor)),
                                      ),
                                      child: Text(
                                        'Get Teff Tips'.tr,
                                        style: TextStyle(
                                          fontSize: subtitleFontSize,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8 * scaleFactor),
                                    if (controller.isAskLoading.value)
                                      Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3 * scaleFactor,
                                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                        ),
                                      ),
                                    if (controller.askAnswer.value != null)
                                      Padding(
                                        padding: EdgeInsets.only(top: 8 * scaleFactor),
                                        child: Text(
                                          controller.askAnswer.value!,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: detailFontSize,
                                            color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18 * scaleFactor,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 8 * scaleFactor),
                                Text(
                                  '3-Day Forecast'.tr,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            (weatherData['forecast'] is List && (weatherData['forecast'] as List).isNotEmpty)
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: size.width),
                                    child: IntrinsicWidth(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          for (var index = 0;
                                              index <
                                                  ((weatherData['forecast'] as List).length > 3
                                                      ? 3
                                                      : (weatherData['forecast'] as List).length);
                                              index++)
                                            Expanded(
                                              child: Card(
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8 * scaleFactor),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        (weatherData['forecast'] as List)[index]['date']?.toString() ?? 'N/A',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      SizedBox(height: 4 * scaleFactor),
                                                      AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 500),
                                                        transitionBuilder: (Widget child, Animation<double> animation) =>
                                                            ScaleTransition(scale: animation, child: child),
                                                        child: Icon(
                                                          _getWeatherIcon(
                                                              (weatherData['forecast'] as List)[index]['day']?['condition']?.toString() ??
                                                                  'sunny'),
                                                          key: ValueKey((weatherData['forecast'] as List)[index]['day']?['condition'] ?? 'sunny'),
                                                          color: theme.colorScheme.secondary,
                                                          size: 20 * scaleFactor,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4 * scaleFactor),
                                                      Text(
                                                        ((weatherData['forecast'] as List)[index]['day']?['condition']?.toString() ?? 'sunny')
                                                            .toLowerCase()
                                                            .tr,
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize,
                                                          fontWeight: FontWeight.w500,
                                                          color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      Text(
                                                        '${(weatherData['forecast'] as List)[index]['day']?['max_temp']?['c']?.toString() ?? 'N/A'}°C / ${(weatherData['forecast'] as List)[index]['day']?['min_temp']?['c']?.toString() ?? 'N/A'}°C',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Precip: ${(weatherData['forecast'] as List)[index]['day']?['precipitation']?['chance']?.toString() ?? 'N/A'}'.tr,
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                                        ),
                                                      ),
                                                      Text(
                                                        'Wind: ${(weatherData['forecast'] as List)[index]['day']?['max_wind']?['kph']?.toString() ?? 'N/A'} kph'.tr,
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                                        ),
                                                      ),
                                                      Text(
                                                        'UV: ${(weatherData['forecast'] as List)[index]['day']?['uv']?.toString() ?? 'N/A'}'.tr,
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                                    child: Text(
                                      'Forecast data not available'.tr,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: subtitleFontSize,
                                        color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                            SizedBox(height: padding),
                            Divider(
                              color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                            ),
                            SizedBox(height: padding),
                            DefaultTabController(
                              length: 3, // Added Astro tab
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TabBar(
                                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                      unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                      labelColor: theme.colorScheme.primary,
                                      unselectedLabelColor:
                                          isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface.withOpacity(0.5),
                                      indicator: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: theme.colorScheme.primary,
                                            width: 3.0,
                                          ),
                                        ),
                                      ),
                                      indicatorSize: TabBarIndicatorSize.label,
                                      tabs: [
                                        Tab(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                            child: Text(
                                              'Current Weather'.tr,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                            child: Text(
                                              'Irrigation Needs'.tr,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                            child: Text(
                                              'Astronomy'.tr,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8 * scaleFactor),
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: SizedBox(
                                      height: size.height * 0.35,
                                      child: TabBarView(
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: [
                                          SingleChildScrollView(
                                            padding: EdgeInsets.all(padding),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _buildDetailRow(
                                                  'Temperature'.tr,
                                                  '${weatherData['current']?['temperature']?['c']?.toString() ?? 'N/A'}°C / ${weatherData['current']?['temperature']?['f']?.toString() ?? 'N/A'}°F',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.thermostat,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Feels Like'.tr,
                                                  '${weatherData['current']?['feels_like']?['c']?.toString() ?? 'N/A'}°C / ${weatherData['current']?['feels_like']?['f']?.toString() ?? 'N/A'}°F',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.thermostat_auto,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Humidity'.tr,
                                                  '${weatherData['current']?['humidity']?.toString() ?? 'N/A'}%',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.water_drop_outlined,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Wind'.tr,
                                                  '${weatherData['current']?['wind']?['kph']?.toString() ?? 'N/A'} kph ${weatherData['current']?['wind']?['direction']?.toString() ?? 'N/A'}',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.air,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Pressure'.tr,
                                                  '${weatherData['current']?['pressure']?['mb']?.toString() ?? 'N/A'} mb',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.compress,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Precipitation'.tr,
                                                  '${weatherData['current']?['precipitation']?['mm']?.toString() ?? 'N/A'} mm',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.umbrella,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Visibility'.tr,
                                                  '${weatherData['current']?['visibility']?['km']?.toString() ?? 'N/A'} km',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.visibility,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'UV Index'.tr,
                                                  weatherData['current']?['uv']?.toString() ?? 'N/A',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.wb_sunny_outlined,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Cloud Cover'.tr,
                                                  '${weatherData['current']?['cloud']?.toString() ?? 'N/A'}%',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.cloud_outlined,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Dew Point'.tr,
                                                  '${weatherData['current']?['dew_point']?['c']?.toString() ?? 'N/A'}°C',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  icon: Icons.dew_point,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SingleChildScrollView(
                                            padding: EdgeInsets.all(padding),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _buildDetailRow(
                                                  'Irrigation Needs'.tr,
                                                  '',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  isTitle: true,
                                                  icon: Icons.water,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                ...(weatherData['irrigation'] is Map
                                                        ? (weatherData['irrigation'] as Map).entries
                                                        : <MapEntry>[]).map<Widget>(
                                                  (entry) => Column(
                                                    children: [
                                                      _buildDetailRow(
                                                        capitalizeFirstLetter(entry.key.toString()),
                                                        '${entry.value?.toString() ?? 'N/A'} mm/week',
                                                        theme,
                                                        detailFontSize,
                                                        isDarkMode,
                                                        icon: Icons.grass,
                                                      ),
                                                      Divider(
                                                        color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                        height: 16 * scaleFactor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                _buildDetailRow(
                                                  'Pest and Disease Risk'.tr,
                                                  weatherData['pestDiseaseRisk']?.toString() ?? 'N/A',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  isTitle: true,
                                                  icon: Icons.bug_report,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Temperature Stress'.tr,
                                                  weatherData['tempStress']?.toString() ?? 'N/A',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  isTitle: true,
                                                  icon: Icons.warning,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                _buildDetailRow(
                                                  'Planting Windows'.tr,
                                                  '',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  isTitle: true,
                                                  icon: Icons.calendar_today,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                ...(weatherData['plantingWindows'] is Map
                                                        ? (weatherData['plantingWindows'] as Map).entries
                                                        : <MapEntry>[]).map<Widget>(
                                                  (entry) => Column(
                                                    children: [
                                                      _buildDetailRow(
                                                        capitalizeFirstLetter(entry.key.toString()),
                                                        entry.value?.toString() ?? 'N/A',
                                                        theme,
                                                        detailFontSize,
                                                        isDarkMode,
                                                        icon: Icons.local_florist,
                                                      ),
                                                      Divider(
                                                        color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                        height: 16 * scaleFactor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SingleChildScrollView(
                                            padding: EdgeInsets.all(padding),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _buildDetailRow(
                                                  'Astronomy'.tr,
                                                  '',
                                                  theme,
                                                  detailFontSize,
                                                  isDarkMode,
                                                  isTitle: true,
                                                  icon: Icons.star,
                                                ),
                                                Divider(
                                                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                  height: 16 * scaleFactor,
                                                ),
                                                if (weatherData['forecast'] is List && (weatherData['forecast'] as List).isNotEmpty)
                                                  ...[
                                                    _buildDetailRow(
                                                      'Sunrise'.tr,
                                                      (weatherData['forecast'] as List)[0]['astro']?['sunrise']?.toString() ?? 'N/A',
                                                      theme,
                                                      detailFontSize,
                                                      isDarkMode,
                                                      icon: Icons.wb_sunny,
                                                    ),
                                                    Divider(
                                                      color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                      height: 16 * scaleFactor,
                                                    ),
                                                    _buildDetailRow(
                                                      'Sunset'.tr,
                                                      (weatherData['forecast'] as List)[0]['astro']?['sunset']?.toString() ?? 'N/A',
                                                      theme,
                                                      detailFontSize,
                                                      isDarkMode,
                                                      icon: Icons.nights_stay,
                                                    ),
                                                    Divider(
                                                      color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                      height: 16 * scaleFactor,
                                                    ),
                                                    _buildDetailRow(
                                                      'Moon Phase'.tr,
                                                      (weatherData['forecast'] as List)[0]['astro']?['moon_phase']?.toString() ?? 'N/A',
                                                      theme,
                                                      detailFontSize,
                                                      isDarkMode,
                                                      icon: Icons.nightlight_round,
                                                    ),
                                                    Divider(
                                                      color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                      height: 16 * scaleFactor,
                                                    ),
                                                    _buildDetailRow(
                                                      'Moonrise'.tr,
                                                      (weatherData['forecast'] as List)[0]['astro']?['moonrise']?.toString() ?? 'N/A',
                                                      theme,
                                                      detailFontSize,
                                                      isDarkMode,
                                                      icon: Icons.nightlight,
                                                    ),
                                                    Divider(
                                                      color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                                                      height: 16 * scaleFactor,
                                                    ),
                                                    _buildDetailRow(
                                                      'Moonset'.tr,
                                                      (weatherData['forecast'] as List)[0]['astro']?['moonset']?.toString() ?? 'N/A',
                                                      theme,
                                                      detailFontSize,
                                                      isDarkMode,
                                                      icon: Icons.nightlight_outlined,
                                                    ),
                                                  ]
                                                else
                                                  Text(
                                                    'Astronomy data not available'.tr,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontSize: subtitleFontSize,
                                                      color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: padding),
                            Divider(
                              color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.1) : theme.colorScheme.onSurface.withOpacity(0.1),
                            ),
                            SizedBox(height: padding),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ExpansionTile(
                                iconColor: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface.withOpacity(0.5),
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 16 * scaleFactor,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(width: 6 * scaleFactor),
                                    Text(
                                      'Historical Weather (Last 7 Days)'.tr,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: titleFontSize * 0.9,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(padding * 0.8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (weatherData['historical'] is List && (weatherData['historical'] as List).isNotEmpty)
                                          StatefulBuilder(
                                            builder: (BuildContext context, StateSetter setState) {
                                              final isExpandedList = List.generate(
                                                (weatherData['historical'] as List).length,
                                                (_) => false,
                                              );

                                              return Column(
                                                children: [
                                                  for (var index = 0; index < (weatherData['historical'] as List).length; index++)
                                                    Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(iconTheme: IconThemeData(size: 16 * scaleFactor)),
                                                      child: ExpansionTile(
                                                        iconColor: isDarkMode
                                                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                                                            : theme.colorScheme.onSurface.withOpacity(0.5),
                                                        controlAffinity: ListTileControlAffinity.trailing,
                                                        backgroundColor: isExpandedList[index]
                                                            ? Colors.green[100]!.withOpacity(0.9)
                                                            : Colors.transparent,
                                                        onExpansionChanged: (bool expanded) {
                                                          setState(() => isExpandedList[index] = expanded);
                                                        },
                                                        title: WeatherAccordionHeader(
                                                          date: (weatherData['historical'] as List)[index]['date']?.toString() ?? 'N/A',
                                                          temperature:
                                                              '${(weatherData['historical'] as List)[index]['avg_temp']?.toString() ?? 'N/A'}°C',
                                                          precipitation:
                                                              '${(weatherData['historical'] as List)[index]['total_precip']?.toString() ?? 'N/A'} mm',
                                                          theme: theme,
                                                          isDarkMode: isDarkMode,
                                                          historicalDetailFontSize: historicalDetailFontSize,
                                                          scaleFactor: scaleFactor,
                                                        ),
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: 16 * scaleFactor,
                                                                vertical: 8 * scaleFactor),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                _buildDetailRow(
                                                                  'Avg Temp'.tr,
                                                                  '${(weatherData['historical'] as List)[index]['avg_temp']?.toString() ?? 'N/A'}°C',
                                                                  theme,
                                                                  historicalDetailFontSize,
                                                                  isDarkMode,
                                                                  icon: Icons.thermostat,
                                                                ),
                                                                Divider(
                                                                  color: isDarkMode
                                                                      ? theme.colorScheme.onSurface.withOpacity(0.1)
                                                                      : theme.colorScheme.onSurface.withOpacity(0.1),
                                                                  height: 12 * scaleFactor,
                                                                ),
                                                                _buildDetailRow(
                                                                  'Precipitation'.tr,
                                                                  '${(weatherData['historical'] as List)[index]['total_precip']?.toString() ?? 'N/A'} mm',
                                                                  theme,
                                                                  historicalDetailFontSize,
                                                                  isDarkMode,
                                                                  icon: Icons.umbrella,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          )
                                        else
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                                            child: Text(
                                              'Historical data not available'.tr,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: subtitleFontSize,
                                                color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: padding),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Positioned(
              bottom: 8 * scaleFactor,
              right: 8 * scaleFactor,
              child: FloatingActionButton(
                onPressed: () => controller.toggleLanguage(),
                backgroundColor: Colors.green[600],
                tooltip: 'Toggle Language'.tr,
                mini: true,
                child: Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 16 * scaleFactor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidWeatherData(Map<String, dynamic> data) {
    return data.containsKey('location') &&
        data['location'] is Map &&
        data['location'].containsKey('name') &&
        data.containsKey('current') &&
        data['current'] is Map &&
        data['current'].containsKey('condition') &&
        data['current'].containsKey('temperature') &&
        data.containsKey('forecast') &&
        data['forecast'] is List &&
        data.containsKey('historical') &&
        data['historical'] is List &&
        data.containsKey('cropData') &&
        data.containsKey('irrigation') &&
        data.containsKey('pestDiseaseRisk') &&
        data.containsKey('tempStress') &&
        data.containsKey('plantingWindows');
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'clear':
        return Icons.nights_stay;
      case 'partly cloudy':
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

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme,
    double fontSize,
    bool isDarkMode, {
    bool isTitle = false,
    IconData? icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 6 * fontSize / 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8 * fontSize / 8),
                  child: Icon(
                    icon,
                    size: 16 * fontSize / 8,
                    color: isTitle ? theme.colorScheme.primary : (isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9)),
                  ),
                ),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: isTitle ? FontWeight.w600 : FontWeight.normal,
                  color: isTitle ? theme.colorScheme.primary : isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
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
                  color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
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

class WeatherAccordionHeader extends StatelessWidget {
  final String date;
  final String temperature;
  final String precipitation;
  final ThemeData theme;
  final bool isDarkMode;
  final double historicalDetailFontSize;
  final double scaleFactor;

  const WeatherAccordionHeader({
    super.key,
    required this.date,
    required this.temperature,
    required this.precipitation,
    required this.theme,
    required this.isDarkMode,
    required this.historicalDetailFontSize,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: historicalDetailFontSize,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8 * scaleFactor),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              temperature,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: historicalDetailFontSize,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Precip: $precipitation'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: historicalDetailFontSize * 0.9,
                color: isDarkMode ? theme.colorScheme.onSurface.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    for (var i = 0; i < 50; i++) {
      final x = (i * size.width / 50) + (size.width * 0.02 * (i % 3));
      final yStart = (i % 5) * size.height / 5;
      final yEnd = yStart + 15;
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}