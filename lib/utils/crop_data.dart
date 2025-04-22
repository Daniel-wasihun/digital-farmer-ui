
const Map<String, Map<String, dynamic>> cropData = {
  // Cereals
  "teff": {
    "temp_range": [15, 25],
    "weekly_water_mm": [20, 40],
    "humidity_range": [50, 70],
    "altitude_range_m": [1700, 2800],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },
  "maize": {
    "temp_range": [18, 30],
    "weekly_water_mm": [40, 80],
    "humidity_range": [50, 80],
    "altitude_range_m": [1000, 2400],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Cereal"
  },
  "wheat": {
    "temp_range": [12, 24],
    "weekly_water_mm": [30, 50],
    "humidity_range": [40, 70],
    "altitude_range_m": [1900, 2700],
    "soil_type": ["Vertisols", "Nitosols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Cereal"
  },
  "barley": {
    "temp_range": [10, 22],
    "weekly_water_mm": [25, 45],
    "humidity_range": [40, 70],
    "altitude_range_m": [2000, 3000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },
  "sorghum": {
    "temp_range": [25, 35],
    "weekly_water_mm": [25, 50],
    "humidity_range": [40, 60],
    "altitude_range_m": [400, 1800],
    "soil_type": ["Vertisols", "Arenosols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Cereal"
  },
  "millet": {
    "temp_range": [25, 35],
    "weekly_water_mm": [15, 30],
    "humidity_range": [30, 60],
    "altitude_range_m": [500, 1800],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },
  "oats": {
    "temp_range": [12, 22],
    "weekly_water_mm": [30, 50],
    "humidity_range": [50, 70],
    "altitude_range_m": [2000, 3000],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },
  "finger_millet": {
    "temp_range": [18, 28],
    "weekly_water_mm": [20, 40],
    "humidity_range": [40, 65],
    "altitude_range_m": [1000, 2400],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },
  "triticale": {
    "temp_range": [12, 22],
    "weekly_water_mm": [30, 50],
    "humidity_range": [40, 70],
    "altitude_range_m": [1900, 2700],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },
  "rice": {
    "temp_range": [20, 35],
    "weekly_water_mm": [80, 120],
    "humidity_range": [70, 90],
    "altitude_range_m": [400, 1600],
    "soil_type": ["Vertisols", "Fluvisols"],
    "growing_season": ["Meher"],
    "category": "Cereal"
  },

  // Pulses
  "chickpea": {
    "temp_range": [15, 30],
    "weekly_water_mm": [15, 30],
    "humidity_range": [40, 60],
    "altitude_range_m": [1400, 2600],
    "soil_type": ["Vertisols", "Nitosols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Pulse"
  },
  "haricot_bean": {
    "temp_range": [18, 28],
    "weekly_water_mm": [20, 40],
    "humidity_range": [50, 70],
    "altitude_range_m": [1400, 2600],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Pulse"
  },
  "lentil": {
    "temp_range": [12, 24],
    "weekly_water_mm": [15, 30],
    "humidity_range": [40, 65],
    "altitude_range_m": [1800, 2800],
    "soil_type": ["Vertisols", "Nitosols"],
    "growing_season": ["Meher"],
    "category": "Pulse"
  },
  "faba_bean": {
    "temp_range": [12, 24],
    "weekly_water_mm": [20, 40],
    "humidity_range": [50, 75],
    "altitude_range_m": [1800, 3000],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher"],
    "category": "Pulse"
  },
  "pea": {
    "temp_range": [12, 24],
    "weekly_water_mm": [20, 40],
    "humidity_range": [50, 70],
    "altitude_range_m": [1800, 2800],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Pulse"
  },
  "grass_pea": {
    "temp_range": [15, 28],
    "weekly_water_mm": [15, 30],
    "humidity_range": [40, 65],
    "altitude_range_m": [1400, 2600],
    "soil_type": ["Vertisols", "Nitosols"],
    "growing_season": ["Meher"],
    "category": "Pulse"
  },
  "soybean": {
    "temp_range": [20, 30],
    "weekly_water_mm": [30, 60],
    "humidity_range": [50, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Pulse"
  },

  // Oilseeds
  "niger_seed": {
    "temp_range": [15, 25],
    "weekly_water_mm": [20, 40],
    "humidity_range": [50, 70],
    "altitude_range_m": [1600, 2500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Oilseed"
  },
  "flaxseed": {
    "temp_range": [15, 25],
    "weekly_water_mm": [20, 40],
    "humidity_range": [50, 70],
    "altitude_range_m": [1800, 2500],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher"],
    "category": "Oilseed"
  },
  "sesame": {
    "temp_range": [25, 35],
    "weekly_water_mm": [15, 30],
    "humidity_range": [40, 60],
    "altitude_range_m": [0, 1500],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Oilseed"
  },
  "groundnut": {
    "temp_range": [20, 32],
    "weekly_water_mm": [30, 50],
    "humidity_range": [50, 70],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Arenosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Oilseed"
  },
  "sunflower": {
    "temp_range": [20, 30],
    "weekly_water_mm": [30, 50],
    "humidity_range": [40, 70],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Cambisols", "Nitosols"],
    "growing_season": ["Meher"],
    "category": "Oilseed"
  },

  // Root/Tuber Crops
  "potato": {
    "temp_range": [15, 20],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Root/Tuber"
  },
  "sweet_potato": {
    "temp_range": [20, 30],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Root/Tuber"
  },
  "taro": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [70, 90],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Fluvisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Root/Tuber"
  },
  "cassava": {
    "temp_range": [25, 35],
    "weekly_water_mm": [30, 50],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Root/Tuber"
  },
  "yam": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [70, 90],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Root/Tuber"
  },
  "enset": {
    "temp_range": [16, 24],
    "weekly_water_mm": [40, 70],
    "humidity_range": [70, 90],
    "altitude_range_m": [1600, 3100],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Root/Tuber"
  },

  // Vegetables
  "onion": {
    "temp_range": [15, 25],
    "weekly_water_mm": [40, 60],
    "humidity_range": [50, 70],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Cambisols", "Nitosols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "tomato": {
    "temp_range": [18, 28],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "cabbage": {
    "temp_range": [15, 20],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "carrot": {
    "temp_range": [15, 22],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "beetroot": {
    "temp_range": [15, 22],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "kale": {
    "temp_range": [15, 22],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Vertisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "lettuce": {
    "temp_range": [15, 20],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "spinach": {
    "temp_range": [15, 20],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 3000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "green_pepper": {
    "temp_range": [18, 28],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "eggplant": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },
  "okra": {
    "temp_range": [25, 35],
    "weekly_water_mm": [40, 70],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Vegetable"
  },
  "squash": {
    "temp_range": [20, 30],
    "weekly_water_mm": [40, 70],
    "humidity_range": [60, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Vegetable"
  },

  // Fruits
  "avocado": {
    "temp_range": [18, 26],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [1000, 2200],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "banana": {
    "temp_range": [20, 30],
    "weekly_water_mm": [60, 100],
    "humidity_range": [70, 90],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "mango": {
    "temp_range": [20, 35],
    "weekly_water_mm": [40, 70],
    "humidity_range": [50, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "papaya": {
    "temp_range": [20, 32],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "orange": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1800],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "lemon": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1800],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "lime": {
    "temp_range": [20, 32],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1800],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "grapefruit": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1800],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "pineapple": {
    "temp_range": [20, 30],
    "weekly_water_mm": [40, 70],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Cambisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },
  "guava": {
    "temp_range": [20, 30],
    "weekly_water_mm": [40, 70],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Fruit"
  },

  // Spices
  "chilli_pepper": {
    "temp_range": [20, 30],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Spice"
  },
  "ginger": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [70, 90],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Spice"
  },
  "turmeric": {
    "temp_range": [20, 30],
    "weekly_water_mm": [50, 80],
    "humidity_range": [70, 90],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Spice"
  },
  "garlic": {
    "temp_range": [15, 25],
    "weekly_water_mm": [40, 60],
    "humidity_range": [50, 70],
    "altitude_range_m": [1500, 2500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Spice"
  },
  "fenugreek": {
    "temp_range": [15, 25],
    "weekly_water_mm": [20, 40],
    "humidity_range": [40, 65],
    "altitude_range_m": [1500, 2500],
    "soil_type": ["Vertisols", "Nitosols"],
    "growing_season": ["Meher"],
    "category": "Spice"
  },
  "coriander": {
    "temp_range": [15, 25],
    "weekly_water_mm": [20, 40],
    "humidity_range": [40, 65],
    "altitude_range_m": [1500, 2500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Spice"
  },

  // Beverages
  "coffee": {
    "temp_range": [15, 24],
    "weekly_water_mm": [30, 50],
    "humidity_range": [60, 80],
    "altitude_range_m": [1200, 2200],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Beverage"
  },
  "tea": {
    "temp_range": [14, 26],
    "weekly_water_mm": [40, 70],
    "humidity_range": [70, 90],
    "altitude_range_m": [1500, 2500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Beverage"
  },

  // Sugar Crops
  "sugarcane": {
    "temp_range": [20, 35],
    "weekly_water_mm": [60, 100],
    "humidity_range": [60, 80],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Vertisols", "Cambisols"],
    "growing_season": ["Meher"],
    "category": "Sugar Crop"
  },

  // Cash Crops
  "tobacco": {
    "temp_range": [20, 30],
    "weekly_water_mm": [40, 70],
    "humidity_range": [50, 80],
    "altitude_range_m": [1000, 2000],
    "soil_type": ["Cambisols", "Nitosols"],
    "growing_season": ["Meher"],
    "category": "Cash Crop"
  },
  "cotton": {
    "temp_range": [20, 35],
    "weekly_water_mm": [50, 80],
    "humidity_range": [50, 70],
    "altitude_range_m": [500, 1500],
    "soil_type": ["Vertisols", "Arenosols"],
    "growing_season": ["Meher"],
    "category": "Cash Crop"
  },
  "cut_flowers": {
    "temp_range": [15, 25],
    "weekly_water_mm": [40, 60],
    "humidity_range": [60, 80],
    "altitude_range_m": [1500, 2500],
    "soil_type": ["Nitosols", "Cambisols"],
    "growing_season": ["Meher", "Belg"],
    "category": "Cash Crop"
  }
};