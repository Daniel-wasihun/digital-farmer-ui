import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/weather_controller.dart';

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
    final screenWidth = size.width;

    // Responsive scaling factor (matched to ChatTab and CropTipsTab)
    final double scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final double adjustedScaleFactor = scaleFactor * 1.1;

    // Dynamic responsive padding (matched to ChatTab and CropTipsTab)
    final double padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    // Base font sizes (matched to ChatTab and CropTipsTab)
    const double baseHeaderFontSize = 32.0;
    const double baseTitleFontSize = 20.0;
    const double baseSubtitleFontSize = 16.0;
    const double baseDetailFontSize = 14.0;

    // Scaled font sizes with clamps (matched to ChatTab and CropTipsTab)
    final double headerFontSize = (baseHeaderFontSize * adjustedScaleFactor).clamp(22.0, 38.0);
    final double titleFontSize = (baseTitleFontSize * adjustedScaleFactor).clamp(16.0, 28.0);
    final double subtitleFontSize = (baseSubtitleFontSize * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final double detailFontSize = (baseDetailFontSize * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    // Font fallbacks for Amharic (matched to ChatTab and CropTipsTab)
    const List<String> fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;

            return Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.green[300]! : Colors.green[500]!),
                    strokeWidth: 3 * adjustedScaleFactor,
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
                        size: 48 * adjustedScaleFactor,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: padding * 0.8),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontFamilyFallback: fontFamilyFallbacks,
                          fontSize: subtitleFontSize,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: padding * 0.8),
                      ElevatedButton(
                        onPressed: () => controller.fetchWeatherData(
                          latitude: 11.7833,
                          longitude: 39.6,
                          city: 'weldiya',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.green[300] : Colors.green[500],
                          padding: EdgeInsets.symmetric(horizontal: 24 * adjustedScaleFactor, vertical: 12 * adjustedScaleFactor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * adjustedScaleFactor)),
                          elevation: 6,
                        ),
                        child: Text(
                          'Retry'.tr,
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
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
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontFamilyFallback: fontFamilyFallbacks,
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

              // Build content
              Widget content = Column(
                children: [
                  // Current Weather Header
                  Padding(
                    padding: EdgeInsets.all(padding * 0.8),
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
                                  size: 26 * adjustedScaleFactor,
                                  color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                ),
                                SizedBox(width: 6 * adjustedScaleFactor),
                                Text(
                                  getFormattedLocationName(weatherData['location']?['name']?.toString()),
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
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
                            SizedBox(height: 4 * adjustedScaleFactor),
                            Row(
                              children: [
                                Text(
                                  weatherData['location']?['local_time']?.toString() ??
                                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: detailFontSize,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                                if (controller.isOffline.value) ...[
                                  SizedBox(width: 6 * adjustedScaleFactor),
                                  Text(
                                    '(Offline)'.tr,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.poppins().fontFamily,
                                      fontFamilyFallback: fontFamilyFallbacks,
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
                            size: 26 * adjustedScaleFactor,
                            color: isDarkMode ? Colors.green[300] : Colors.green[500],
                          ),
                          onPressed: () => controller.fetchWeatherData(
                            latitude: 11.7833,
                            longitude: 39.6,
                            city: 'weldiya',
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Current Weather Card
                  SizedBox(
                    height: (size.height * 0.12).clamp(80, 130),
                    child: Card(
                      elevation: 6,
                      color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * adjustedScaleFactor)),
                      margin: EdgeInsets.symmetric(vertical: 4 * adjustedScaleFactor, horizontal: 12 * adjustedScaleFactor),
                      child: Padding(
                        padding: EdgeInsets.all(padding * 0.6),
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
                                    size: 40 * adjustedScaleFactor,
                                  ),
                                ),
                                SizedBox(height: 4 * adjustedScaleFactor),
                                Text(
                                  (weatherData['current']?['condition']?.toString() ?? 'sunny').toLowerCase().tr,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: subtitleFontSize,
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
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: headerFontSize * 1.1,
                                    fontWeight: FontWeight.w900,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                  ),
                                ),
                                Text(
                                  'Feels Like: ${weatherData['current']?['feels_like']?['c']?.toString() ?? 'N/A'}°C'.tr,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: detailFontSize,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Humidity: ${weatherData['current']?['humidity']?.toString() ?? 'N/A'}%'.tr,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: detailFontSize,
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
                      elevation: 6,
                      color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * adjustedScaleFactor)),
                      margin: EdgeInsets.symmetric(vertical: 4 * adjustedScaleFactor, horizontal: 12 * adjustedScaleFactor),
                      child: Padding(
                        padding: EdgeInsets.all(padding * 0.8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.question_answer,
                                  size: 18 * adjustedScaleFactor,
                                  color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                ),
                                SizedBox(width: 6 * adjustedScaleFactor),
                                Text(
                                  'Ask a Question'.tr,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6 * adjustedScaleFactor),
                            SizedBox(
                              height: 40 * adjustedScaleFactor,
                              child: TextField(
                                controller: controller.questionController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., How is the weather today?'.tr,
                                  hintStyle: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: detailFontSize,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      size: 18 * adjustedScaleFactor,
                                      color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                    ),
                                    onPressed: () => controller.askWeatherQuestion(),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10 * adjustedScaleFactor,
                                    horizontal: 12 * adjustedScaleFactor,
                                  ),
                                ),
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontFamilyFallback: fontFamilyFallbacks,
                                  fontSize: detailFontSize,
                                  color: isDarkMode ? Colors.white : Colors.grey[900],
                                ),
                                onSubmitted: (value) => controller.askWeatherQuestion(),
                              ),
                            ),
                            SizedBox(height: 6 * adjustedScaleFactor),
                            if (controller.isAskLoading.value)
                              Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3 * adjustedScaleFactor,
                                  valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.green[300]! : Colors.green[500]!),
                                ),
                              ),
                            if (controller.askAnswer.value != null)
                              Padding(
                                padding: EdgeInsets.only(top: 6 * adjustedScaleFactor),
                                child: Text(
                                  controller.askAnswer.value!,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: detailFontSize,
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
                    padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10 * adjustedScaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18 * adjustedScaleFactor,
                              color: isDarkMode ? Colors.green[300] : Colors.green[500],
                            ),
                            SizedBox(width: 6 * adjustedScaleFactor),
                            Text(
                              '3-Day Forecast'.tr,
                              style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontFamilyFallback: fontFamilyFallbacks,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * adjustedScaleFactor),
                        SizedBox(
                          height: 100 * adjustedScaleFactor,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            itemCount: forecast.length > 3 ? 3 : forecast.length,
                            itemBuilder: (context, index) {
                              final dayData = forecast[index]['day'];
                              final astroData = forecast[index]['astro'];
                              final hourlyData = forecast[index]['hourly'];
                              final double cardWidth = (size.width * 0.7).clamp(220, 360);
                              final double cardHeight = 100 * adjustedScaleFactor;
                              final double iconSize = 20 * adjustedScaleFactor;
                              return Padding(
                                padding: EdgeInsets.only(right: 10 * adjustedScaleFactor),
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
                                          scaleFactor: adjustedScaleFactor,
                                          padding: padding,
                                          headerFontSize: headerFontSize,
                                          subtitleFontSize: subtitleFontSize,
                                          detailFontSize: detailFontSize,
                                          titleFontSize: titleFontSize,
                                          fontFamilyFallbacks: fontFamilyFallbacks,
                                        ),
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: cardWidth,
                                      height: cardHeight,
                                      child: Card(
                                        elevation: 6,
                                        color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * adjustedScaleFactor)),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: (cardHeight - iconSize) / 2,
                                              right: 8 * adjustedScaleFactor,
                                              child: Icon(
                                                Icons.chevron_right,
                                                size: iconSize,
                                                color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8 * adjustedScaleFactor),
                                                    child: Text(
                                                      cardLabels[index],
                                                      style: TextStyle(
                                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                                        fontFamilyFallback: fontFamilyFallbacks,
                                                        fontSize: detailFontSize * 1.3,
                                                        fontWeight: FontWeight.w900,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4 * adjustedScaleFactor),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(width: 6 * adjustedScaleFactor),
                                                    AnimatedSwitcher(
                                                      duration: const Duration(milliseconds: 500),
                                                      transitionBuilder: (Widget child, Animation<double> animation) =>
                                                          ScaleTransition(scale: animation, child: child),
                                                      child: Icon(
                                                        _getWeatherIcon(dayData?['condition']?.toString() ?? 'sunny'),
                                                        key: ValueKey(dayData?['condition'] ?? 'sunny'),
                                                        color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                                        size: 32 * adjustedScaleFactor,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6 * adjustedScaleFactor),
                                                    Text(
                                                      '${dayData?['max_temp']?['c']?.toString() ?? 'N/A'}°C / ${dayData?['min_temp']?['c']?.toString() ?? 'N/A'}°C',
                                                      style: TextStyle(
                                                        fontFamily: GoogleFonts.poppins().fontFamily,
                                                        fontFamilyFallback: fontFamilyFallbacks,
                                                        fontSize: detailFontSize * 1.2,
                                                        fontWeight: FontWeight.w700,
                                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    (dayData?['condition']?.toString() ?? 'sunny').toLowerCase().tr,
                                                    style: TextStyle(
                                                      fontFamily: GoogleFonts.poppins().fontFamily,
                                                      fontFamilyFallback: fontFamilyFallbacks,
                                                      fontSize: detailFontSize,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                      elevation: 6,
                      color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * adjustedScaleFactor)),
                      margin: EdgeInsets.symmetric(vertical: 4 * adjustedScaleFactor, horizontal: 12 * adjustedScaleFactor),
                      child: Padding(
                        padding: EdgeInsets.all(padding * 0.8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 18 * adjustedScaleFactor,
                                  color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                ),
                                SizedBox(width: 6 * adjustedScaleFactor),
                                Text(
                                  'Historical Weather (Last 7 Days)'.tr,
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.poppins().fontFamily,
                                    fontFamilyFallback: fontFamilyFallbacks,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8 * adjustedScaleFactor),
                            if (weatherData['historical'] is List && (weatherData['historical'] as List).isNotEmpty)
                              ...List.generate(
                                (weatherData['historical'] as List).length,
                                (index) {
                                  final historical = (weatherData['historical'] as List)[index];
                                  final precip = double.tryParse(historical['total_precip']?.toString() ?? '0') ?? 0;
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4 * adjustedScaleFactor),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getHistoricalIcon(precip),
                                          size: 16 * adjustedScaleFactor,
                                          color: isDarkMode ? Colors.green[300] : Colors.green[500],
                                        ),
                                        SizedBox(width: 6 * adjustedScaleFactor),
                                        Expanded(
                                          child: Text(
                                            historical['date']?.toString() ?? 'N/A',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.poppins().fontFamily,
                                              fontFamilyFallback: fontFamilyFallbacks,
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
                                              style: TextStyle(
                                                fontFamily: GoogleFonts.poppins().fontFamily,
                                                fontFamilyFallback: fontFamilyFallbacks,
                                                fontSize: detailFontSize,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode ? Colors.white : Colors.grey[900],
                                              ),
                                            ),
                                            Text(
                                              'Precip: ${historical['total_precip']?.toString() ?? 'N/A'} mm'.tr,
                                              style: TextStyle(
                                                fontFamily: GoogleFonts.poppins().fontFamily,
                                                fontFamilyFallback: fontFamilyFallbacks,
                                                fontSize: detailFontSize,
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
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontFamilyFallback: fontFamilyFallbacks,
                                  fontSize: subtitleFontSize,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(
                          child: content,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
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
  final List<String> fontFamilyFallbacks;

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
    required this.fontFamilyFallbacks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        elevation: 6,
        color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scaleFactor)),
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
                  borderRadius: BorderRadius.circular(2 * scaleFactor),
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
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: fontFamilyFallbacks,
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
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontFamilyFallback: fontFamilyFallbacks,
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
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.thermostat,
                      ),
                      _buildDetailRow(
                        'Avg Temp'.tr,
                        '${dayData?['avg_temp']?['c']?.toString() ?? 'N/A'}°C',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.thermostat_auto,
                      ),
                      _buildDetailRow(
                        'Precipitation'.tr,
                        dayData?['precipitation']?['chance']?.toString() ?? 'N/A',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.umbrella,
                      ),
                      _buildDetailRow(
                        'Wind'.tr,
                        '${dayData?['max_wind']?['kph']?.toString() ?? 'N/A'} kph',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.air,
                      ),
                      _buildDetailRow(
                        'Humidity'.tr,
                        '${dayData?['humidity']?.toString() ?? 'N/A'}%',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.water_drop_outlined,
                      ),
                      _buildDetailRow(
                        'UV Index'.tr,
                        dayData?['uv']?.toString() ?? 'N/A',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.wb_sunny_outlined,
                      ),
                      _buildDetailRow(
                        'Visibility'.tr,
                        '${dayData?['visibility']?['km']?.toString() ?? 'N/A'} km',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.visibility,
                      ),
                      SizedBox(height: 12 * scaleFactor),
                      Text(
                        'Hourly Forecast'.tr,
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontFamilyFallback: fontFamilyFallbacks,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      _buildDetailRow(
                        'Morning'.tr,
                        '${hourlyData?['morning']?['temp_range']?[0]?.toString() ?? 'N/A'}°C - ${hourlyData?['morning']?['temp_range']?[1]?.toString() ?? 'N/A'}°C, ${(hourlyData?['morning']?['condition']?.toString() ?? 'N/A').toLowerCase().tr}',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.wb_sunny,
                      ),
                      _buildDetailRow(
                        'Midday'.tr,
                        '${hourlyData?['midday']?['temp_range']?[0]?.toString() ?? 'N/A'}°C - ${hourlyData?['midday']?['temp_range']?[1]?.toString() ?? 'N/A'}°C, ${(hourlyData?['midday']?['condition']?.toString() ?? 'N/A').toLowerCase().tr}',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.wb_sunny,
                      ),
                      _buildDetailRow(
                        'Evening'.tr,
                        '${hourlyData?['evening']?['temp_range']?[0]?.toString() ?? 'N/A'}°C - ${hourlyData?['evening']?['temp_range']?[1]?.toString() ?? 'N/A'}°C, ${(hourlyData?['evening']?['condition']?.toString() ?? 'N/A').toLowerCase().tr}',
                        detailFontSize,
                        isDarkMode,
                        icon: Icons.nights_stay,
                      ),
                      if (astroData != null) ...[
                        SizedBox(height: 12 * scaleFactor),
                        Text(
                          'Astronomy'.tr,
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        _buildDetailRow(
                          'Sunrise'.tr,
                          astroData['sunrise']?.toString() ?? 'N/A',
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.wb_sunny,
                        ),
                        _buildDetailRow(
                          'Sunset'.tr,
                          astroData['sunset']?.toString() ?? 'N/A',
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nights_stay,
                        ),
                        _buildDetailRow(
                          'Moon Phase'.tr,
                          astroData['moon_phase']?.toString() ?? 'N/A',
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nightlight_round,
                        ),
                        _buildDetailRow(
                          'Moonrise'.tr,
                          astroData['moonrise']?.toString() ?? 'N/A',
                          detailFontSize,
                          isDarkMode,
                          icon: Icons.nightlight,
                        ),
                        _buildDetailRow(
                          'Moonset'.tr,
                          astroData['moonset']?.toString() ?? 'N/A',
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
    double fontSize,
    bool isDarkMode, {
    IconData? icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 6 * scaleFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8 * scaleFactor),
                  child: Icon(
                    icon,
                    size: 18 * scaleFactor,
                    color: isDarkMode ? Colors.green[300] : Colors.green[500],
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontFamilyFallback: fontFamilyFallbacks,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontFamilyFallback: fontFamilyFallbacks,
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