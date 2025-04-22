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
    const double baseTitleFontSize = 16.0;
    const double baseSubtitleFontSize = 12.0;
    const double baseDetailFontSize = 10.0;

    // Calculate responsive font sizes
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;

    // Use theme
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Obx(
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
                          onPressed: () => controller.fetchWeatherData(
                            latitude: 11.7833,
                            longitude: 39.6,
                            city: 'weldiya',
                          ),
                          child: Text('Retry'.tr),
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
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.language,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: controller.toggleLanguage,
                                  tooltip: 'Toggle Language'.tr,
                                ),
                              ],
                            ),
                            SizedBox(height: padding),
                            // Current Weather Section
                            Card(
                              elevation: theme.cardTheme.elevation,
                              color: theme.cardTheme.color,
                              shape: theme.cardTheme.shape,
                              shadowColor: theme.cardTheme.shadowColor,
                              child: Padding(
                                padding: EdgeInsets.all(padding),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(
                                          _getWeatherIcon(controller.weatherData.value!['current']['condition']),
                                          color: theme.colorScheme.secondary,
                                          size: 50 * scaleFactor,
                                        ),
                                        SizedBox(height: 8 * scaleFactor),
                                        Text(
                                          controller.weatherData.value!['current']['condition'],
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: subtitleFontSize,
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
                                          ),
                                        ),
                                        Text(
                                          'Feels Like: ${controller.weatherData.value!['current']['feels_like']['c']}°C'.tr,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: subtitleFontSize,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                        Text(
                                          'Humidity: ${controller.weatherData.value!['current']['humidity']}%'.tr,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: subtitleFontSize,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: padding),
                            // Quick Ask Section
                            Card(
                              elevation: theme.cardTheme.elevation,
                              color: theme.cardTheme.color,
                              shape: theme.cardTheme.shape,
                              shadowColor: theme.cardTheme.shadowColor,
                              child: Padding(
                                padding: EdgeInsets.all(padding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ask a Question'.tr,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: titleFontSize,
                                      ),
                                    ),
                                    SizedBox(height: 8 * scaleFactor),
                                    TextField(
                                      controller: controller.questionController,
                                      decoration: InputDecoration(
                                        hintText: 'e.g., How is the weather for maize today?'.tr,
                                        border: OutlineInputBorder(),
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
                                  return Card(
                                    elevation: theme.cardTheme.elevation,
                                    color: theme.cardTheme.color,
                                    shape: theme.cardTheme.shape,
                                    shadowColor: theme.cardTheme.shadowColor,
                                    child: Container(
                                      width: 110 * scaleFactor,
                                      padding: EdgeInsets.all(8 * scaleFactor),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            forecast['date'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 4 * scaleFactor),
                                          Icon(
                                            _getWeatherIcon(forecast['day']['condition']),
                                            color: theme.colorScheme.secondary,
                                            size: 24 * scaleFactor,
                                          ),
                                          SizedBox(height: 4 * scaleFactor),
                                          Text(
                                            forecast['day']['condition'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                            ),
                                          ),
                                          Text(
                                            '${forecast['day']['max_temp']['c']}°C / ${forecast['day']['min_temp']['c']}°C',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                            ),
                                          ),
                                          Text(
                                            'Wind: ${forecast['day']['max_wind']['kph']} kph'.tr,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: padding),
                            // Historical Weather Section
                            ExpansionTile(
                              title: Text(
                                'Historical Weather (Last 7 Days)'.tr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: titleFontSize,
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
                                      elevation: theme.cardTheme.elevation,
                                      color: theme.cardTheme.color,
                                      shape: theme.cardTheme.shape,
                                      shadowColor: theme.cardTheme.shadowColor,
                                      margin: EdgeInsets.symmetric(vertical: 4 * scaleFactor),
                                      child: ListTile(
                                        title: Text(
                                          historical['date'],
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: detailFontSize,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Avg Temp: ${historical['avg_temp']}°C\nPrecipitation: ${historical['total_precip']} mm'.tr,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: detailFontSize,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: padding),
                            // Tabs for Detailed Info
                            DefaultTabController(
                              length: 4,
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
                                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                                    indicatorColor: theme.colorScheme.primary,
                                    tabs: [
                                      Tab(text: 'Current Weather'.tr),
                                      Tab(text: 'Crop Data'.tr),
                                      Tab(text: 'Irrigation Needs'.tr),
                                      Tab(text: 'Crop Info'.tr),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 0.5,
                                    child: TabBarView(
                                      children: [
                                        // Current Weather Details
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding: EdgeInsets.all(padding),
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
                                        // Crop Data
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding: EdgeInsets.all(padding),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: controller.weatherData.value!['cropData'].entries.map<Widget>((entry) {
                                                return _buildCropData(
                                                  capitalizeFirstLetter(entry.key).tr, // Translate crop name
                                                  entry.value,
                                                  theme,
                                                  detailFontSize,
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        // Irrigation and Pest Info
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding: EdgeInsets.all(padding),
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
                                        // Crop Info with Backend Integration
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding: EdgeInsets.all(padding),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Select a Crop for Detailed Info'.tr,
                                                  style: theme.textTheme.titleLarge?.copyWith(
                                                    fontSize: titleFontSize,
                                                  ),
                                                ),
                                                SizedBox(height: 8 * scaleFactor),
                                                DropdownButton<String>(
                                                  value: controller.selectedCrop.value,
                                                  isExpanded: true,
                                                  items: controller.weatherData.value!['cropData'].keys.map<DropdownMenuItem<String>>((crop) {
                                                    return DropdownMenuItem<String>(
                                                      value: crop,
                                                      child: Text(capitalizeFirstLetter(crop).tr), // Translate crop name
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      controller.selectedCrop.value = value;
                                                      controller.fetchCropInfo(value); // Fetch crop info in the current language
                                                    }
                                                  },
                                                ),
                                                SizedBox(height: 8 * scaleFactor),
                                                if (controller.isCropInfoLoading.value)
                                                  Center(child: CircularProgressIndicator()),
                                                if (controller.cropInfo.value != null)
                                                  Card(
                                                    elevation: theme.cardTheme.elevation,
                                                    color: theme.cardTheme.color,
                                                    shape: theme.cardTheme.shape,
                                                    shadowColor: theme.cardTheme.shadowColor,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(padding),
                                                      child: Text(
                                                        controller.cropInfo.value!,
                                                        style: theme.textTheme.bodyMedium?.copyWith(
                                                          fontSize: detailFontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCropData(
    String cropName,
    Map<String, dynamic> data,
    ThemeData theme,
    double fontSize,
  ) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      shadowColor: theme.cardTheme.shadowColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cropName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 4),
            _buildDetailRow(
              'Optimal Temp Range'.tr,
              '${data['temp_range'][0]}°C - ${data['temp_range'][1]}°C',
              theme,
              fontSize,
            ),
            _buildDetailRow(
              'Weekly Water'.tr,
              '${data['weekly_water_mm'][0]} mm - ${data['weekly_water_mm'][1]} mm',
              theme,
              fontSize,
            ),
            _buildDetailRow(
              'Optimal Humidity'.tr,
              '${data['humidity_range'][0]}% - ${data['humidity_range'][1]}%',
              theme,
              fontSize,
            ),
            _buildDetailRow(
              'Altitude Range'.tr,
              '${data['altitude_range_m'][0]} m - ${data['altitude_range_m'][1]} m',
              theme,
              fontSize,
            ),
            _buildDetailRow(
              'Soil Type'.tr,
              data['soil_type'].join(', '),
              theme,
              fontSize,
            ),
            _buildDetailRow(
              'Growing Season'.tr,
              data['growing_season'].join(', '),
              theme,
              fontSize,
            ),
            _buildDetailRow(
              'Category'.tr,
              data['category'],
              theme,
              fontSize,
            ),
          ],
        ),
      ),
    );
  }
}