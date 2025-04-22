import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/weather_controller.dart';

// Utility function to capitalize the first letter of a string
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.put(WeatherController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;
    final isSmallPhone = size.width < 360;

    // Dynamic scaleFactor for better responsiveness
    final double scaleFactor = isLargeTablet
        ? 1.3
        : isTablet
            ? 1.1
            : isSmallPhone
                ? 0.85
                : 1.0;

    // Responsive padding
    final double padding = isLargeTablet
        ? 20.0
        : isTablet
            ? 16.0
            : isSmallPhone
                ? 12.0
                : 14.0;

    // Base font sizes
    const double baseTitleFontSize = 18.0; // Increased for better readability
    const double baseSubtitleFontSize = 14.0;
    const double baseDetailFontSize = 12.0;

    // Calculate responsive font sizes
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;

    // Use theme
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                )
              : controller.weatherData.value == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'No Data Available'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: subtitleFontSize,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: padding),
                          ElevatedButton(
                            onPressed: () {
                              Future.microtask(() => controller.fetchWeatherData(
                                    latitude: 11.7833,
                                    longitude: 39.6,
                                    city: 'weldiya',
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Retry'.tr,
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await controller.fetchWeatherData(
                          latitude: 11.7833,
                          longitude: 39.6,
                          city: 'weldiya',
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header with Location and Language Toggle
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capitalizeFirstLetter(controller.weatherData.value!['location']['name'].toString()),
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 4.0,
                                              color: isDarkMode ? Colors.black54 : Colors.black12,
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        controller.weatherData.value!['location']['local_time'],
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: subtitleFontSize,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: padding),
                              // Current Weather Section (Neumorphic Card)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                      offset: Offset(4, 4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                      offset: Offset(-4, -4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(padding),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          AnimatedSwitcher(
                                            duration: Duration(milliseconds: 300),
                                            child: Icon(
                                              _getWeatherIcon(controller.weatherData.value!['current']['condition']),
                                              key: ValueKey(controller.weatherData.value!['current']['condition']),
                                              color: theme.colorScheme.secondary,
                                              size: 50 * scaleFactor,
                                            ),
                                          ),
                                          SizedBox(height: 8 * scaleFactor),
                                          Text(
                                            controller.weatherData.value!['current']['condition'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: subtitleFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${controller.weatherData.value!['current']['temperature']['c']}°C',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              fontSize: titleFontSize * 1.5,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          Text(
                                            'Feels Like: ${controller.weatherData.value!['current']['feels_like']['c']}°C'.tr,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: subtitleFontSize,
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                          Text(
                                            'Humidity: ${controller.weatherData.value!['current']['humidity']}%'.tr,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: subtitleFontSize,
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: padding),
                              // Quick Ask Section (Neumorphic Card)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                      offset: Offset(4, 4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                      offset: Offset(-4, -4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(padding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ask a Question'.tr,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 8 * scaleFactor),
                                      TextField(
                                        controller: controller.questionController,
                                        decoration: InputDecoration(
                                          hintText: 'e.g., How is the weather today?'.tr,
                                          hintStyle: TextStyle(
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.send, color: theme.colorScheme.primary),
                                            onPressed: () {
                                              controller.askWeatherQuestion();
                                            },
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          controller.askWeatherQuestion();
                                        },
                                      ),
                                      SizedBox(height: 8 * scaleFactor),
                                      if (controller.isAskLoading.value)
                                        Center(child: CircularProgressIndicator()),
                                      if (controller.askAnswer.value != null)
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            controller.askAnswer.value!,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: padding),
                              // Forecast Section
                              Text(
                                '3-Day Forecast'.tr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 8 * scaleFactor),
                              SizedBox(
                                height: 140 * scaleFactor,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.weatherData.value!['forecast'].length,
                                  itemBuilder: (context, index) {
                                    final forecast = controller.weatherData.value!['forecast'][index];
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      margin: EdgeInsets.symmetric(horizontal: 4 * scaleFactor),
                                      width: 110 * scaleFactor,
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                            offset: Offset(4, 4),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                            offset: Offset(-4, -4),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            forecast['date'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 4 * scaleFactor),
                                          AnimatedSwitcher(
                                            duration: Duration(milliseconds: 300),
                                            child: Icon(
                                              _getWeatherIcon(forecast['day']['condition']),
                                              key: ValueKey(forecast['day']['condition']),
                                              color: theme.colorScheme.secondary,
                                              size: 24 * scaleFactor,
                                            ),
                                          ),
                                          SizedBox(height: 4 * scaleFactor),
                                          Text(
                                            forecast['day']['condition'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${forecast['day']['max_temp']['c']}°C / ${forecast['day']['min_temp']['c']}°C',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Wind: ${forecast['day']['max_wind']['kph']} kph'.tr,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: padding),
                              // Historical Weather Section
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                      offset: Offset(4, 4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                      offset: Offset(-4, -4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    'Historical Weather (Last 7 Days)'.tr,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: controller.weatherData.value!['historical'].length,
                                      itemBuilder: (context, index) {
                                        final historical = controller.weatherData.value!['historical'][index];
                                        return Card(
                                          elevation: 0,
                                          color: Colors.transparent,
                                          margin: EdgeInsets.symmetric(vertical: 4 * scaleFactor),
                                          child: ListTile(
                                            title: Text(
                                              historical['date'],
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: detailFontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Avg Temp: ${historical['avg_temp']}°C\nPrecipitation: ${historical['total_precip']} mm'.tr,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: detailFontSize,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: padding),
                              // Tabs for Detailed Info (Only Current Weather and Irrigation Needs)
                              DefaultTabController(
                                length: 2,
                                child: Column(
                                  children: [
                                    TabBar(
                                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                      ),
                                      labelColor: theme.colorScheme.primary,
                                      unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                                      indicatorColor: theme.colorScheme.primary,
                                      tabs: [
                                        Tab(text: 'Current Weather'.tr),
                                        Tab(text: 'Irrigation Needs'.tr),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.5,
                                      child: TabBarView(
                                        children: [
                                          // Current Weather Details
                                          SingleChildScrollView(
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              margin: EdgeInsets.symmetric(vertical: 8),
                                              padding: EdgeInsets.all(padding),
                                              decoration: BoxDecoration(
                                                color: isDarkMode ? Colors.grey[850] : Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                                    offset: Offset(4, 4),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                                    offset: Offset(-4, -4),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildDetailRow(
                                                    'Temperature'.tr,
                                                    '${controller.weatherData.value!['current']['temperature']['c']}°C / ${controller.weatherData.value!['current']['temperature']['f']}°F',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Feels Like'.tr,
                                                    '${controller.weatherData.value!['current']['feels_like']['c']}°C / ${controller.weatherData.value!['current']['feels_like']['f']}°F',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Humidity'.tr,
                                                    '${controller.weatherData.value!['current']['humidity']}%',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Wind'.tr,
                                                    '${controller.weatherData.value!['current']['wind']['kph']} kph ${controller.weatherData.value!['current']['wind']['direction']}',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Pressure'.tr,
                                                    '${controller.weatherData.value!['current']['pressure']['mb']} mb',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Precipitation'.tr,
                                                    '${controller.weatherData.value!['current']['precipitation']['mm']} mm',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Visibility'.tr,
                                                    '${controller.weatherData.value!['current']['visibility']['km']} km',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'UV Index'.tr,
                                                    '${controller.weatherData.value!['current']['uv']}',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Cloud Cover'.tr,
                                                    '${controller.weatherData.value!['current']['cloud']}%',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                  _buildDetailRow(
                                                    'Dew Point'.tr,
                                                    '${controller.weatherData.value!['current']['dew_point']['c']}°C',
                                                    theme,
                                                    detailFontSize,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Irrigation and Pest Info
                                          SingleChildScrollView(
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              margin: EdgeInsets.symmetric(vertical: 8),
                                              padding: EdgeInsets.all(padding),
                                              decoration: BoxDecoration(
                                                color: isDarkMode ? Colors.grey[850] : Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                                    offset: Offset(4, 4),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                  BoxShadow(
                                                    color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                                    offset: Offset(-4, -4),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildDetailRow(
                                                    'Irrigation Needs'.tr,
                                                    '',
                                                    theme,
                                                    detailFontSize,
                                                    isTitle: true,
                                                  ),
                                                  ...controller.weatherData.value!['irrigation'].entries.map<Widget>((entry) {
                                                    return _buildDetailRow(
                                                      capitalizeFirstLetter(entry.key).tr, // Translate crop name
                                                      '${entry.value} mm/week',
                                                      theme,
                                                      detailFontSize,
                                                    );
                                                  }).toList(),
                                                  SizedBox(height: 8 * scaleFactor),
                                                  _buildDetailRow(
                                                    'Pest and Disease Risk'.tr,
                                                    controller.weatherData.value!['pestDiseaseRisk'],
                                                    theme,
                                                    detailFontSize,
                                                    isTitle: true,
                                                  ),
                                                  _buildDetailRow(
                                                    'Temperature Stress'.tr,
                                                    controller.weatherData.value!['tempStress'],
                                                    theme,
                                                    detailFontSize,
                                                    isTitle: true,
                                                  ),
                                                  _buildDetailRow(
                                                    'Planting Windows'.tr,
                                                    '',
                                                    theme,
                                                    detailFontSize,
                                                    isTitle: true,
                                                  ),
                                                  ...controller.weatherData.value!['plantingWindows'].entries.map<Widget>((entry) {
                                                    return _buildDetailRow(
                                                      capitalizeFirstLetter(entry.key).tr, // Translate crop name
                                                      entry.value,
                                                      theme,
                                                      detailFontSize,
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.toggleLanguage,
        backgroundColor: theme.colorScheme.primary,
        tooltip: 'Toggle Language'.tr,
        child: Icon(
          Icons.language,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'clear':
        return Icons.nights_stay;
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      default:
        return Icons.wb_sunny;
    }
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme,
    double fontSize, {
    bool isTitle = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: isTitle ? FontWeight.w600 : FontWeight.normal,
              color: isTitle ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          if (!isTitle)
            Flexible(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}