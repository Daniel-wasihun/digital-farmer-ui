// import 'package:agri/controllers/market_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class FiltersSection extends StatelessWidget {
//   const FiltersSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MarketController>();

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0), // Reduced padding
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Filter Prices',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Smaller text
//             ),
//             const SizedBox(height: 8), // Reduced spacing
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Crop Name', style: TextStyle(fontSize: 10)), // Smaller text
//                       const SizedBox(height: 4), // Reduced spacing
//                       Obx(() => DropdownButtonFormField<String>(
//                             value: controller.cropFilter.value.isEmpty ? null : controller.cropFilter.value,
//                             decoration: const InputDecoration(
//                               labelText: 'Select Crop',
//                             ),
//                             items: (controller.cropData.keys)
//                                 .map<DropdownMenuItem<String>>((crop) => DropdownMenuItem<String>(
//                                       value: crop,
//                                       child: Text(crop, style: const TextStyle(fontSize: 10)), // Smaller text
//                                     ))
//                                 .toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 controller.setCropFilter(value);
//                               }
//                             },
//                           )),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8), // Reduced spacing
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Crop Type', style: TextStyle(fontSize: 10)), // Smaller text
//                       const SizedBox(height: 4), // Reduced spacing
//                       Obx(() => DropdownButtonFormField<String>(
//                             value: controller.cropTypeFilter.value.isEmpty ? null : controller.cropTypeFilter.value,
//                             decoration: const InputDecoration(
//                               labelText: 'Select Type',
//                             ),
//                             items: (controller.cropFilter.value.isNotEmpty
//                                     ? (controller.cropData[controller.cropFilter.value] ?? []) as Iterable<String>
//                                     : <String>[])
//                                 .map<DropdownMenuItem<String>>((type) => DropdownMenuItem<String>(
//                                       value: type,
//                                       child: Text(type, style: const TextStyle(fontSize: 10)), // Smaller text
//                                     ))
//                                 .toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 controller.setCropTypeFilter(value);
//                               }
//                             },
//                           )),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8), // Reduced spacing
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Market', style: TextStyle(fontSize: 10)), // Smaller text
//                       const SizedBox(height: 4), // Reduced spacing
//                       Obx(() => DropdownButtonFormField<String>(
//                             value: controller.marketFilter.value.isEmpty ? null : controller.marketFilter.value,
//                             decoration: const InputDecoration(
//                               labelText: 'Select Market',
//                             ),
//                             items: (controller.marketNames as Iterable<String>)
//                                 .map<DropdownMenuItem<String>>((market) => DropdownMenuItem<String>(
//                                       value: market,
//                                       child: Text(market, style: const TextStyle(fontSize: 10)), // Smaller text
//                                     ))
//                                 .toList(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 controller.setMarketFilter(value);
//                               }
//                             },
//                           )),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8), // Reduced spacing
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Date', style: TextStyle(fontSize: 10)), // Smaller text
//                       const SizedBox(height: 4), // Reduced spacing
//                       Obx(() => TextField(
//                             readOnly: true,
//                             decoration: InputDecoration(
//                               labelText: controller.selectedDate.value != null
//                                   ? controller.selectedDate.value.toString().split(' ')[0]
//                                   : 'Select Date',
//                             ),
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (picked != null) {
//                                 controller.setDate(picked);
//                               }
//                             },
//                           )),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8), // Reduced spacing
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.search),
//                 label: const Text('Find'),
//                 onPressed: () => controller.fetchPrices(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }