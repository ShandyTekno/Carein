import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SkinMetric {
  const SkinMetric({
    required this.label,
    required this.level,
    required this.value,
    required this.icon,
  });

  final String label;
  final String level; // Low / Moderate / High
  final double value; // 0.0 - 1.0
  final IconData icon;

  Color get color {
    switch (level) {
      case 'Low':
        return AppColors.success;
      case 'Moderate':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }
}

class AnalysisResult {
  const AnalysisResult({
    required this.date,
    required this.score,
    required this.skinType,
    required this.metrics,
    required this.insight,
  });

  final String date;
  final int score;
  final String skinType;
  final List<SkinMetric> metrics;
  final String insight;

  String get rating => score >= 80 ? 'Great' : (score >= 70 ? 'Good' : 'Fair');
}

class Product {
  const Product({
    required this.name,
    required this.brand,
    required this.category,
    required this.ingredient,
    required this.description,
    required this.reason,
    required this.icon,
    required this.tint,
    required this.price,
    required this.size,
    required this.howToUse,
    required this.shopUrl,
    this.imageAsset,
  });

  final String name;
  final String brand;
  final String category;
  final String ingredient;
  final String description;
  final String reason;
  final IconData icon;
  final Color tint;
  final String price;
  final String size;
  final String howToUse;
  final String shopUrl;
  final String? imageAsset;
}

class DummyData {
  DummyData._();

  static const userName = 'Shandy';
  static const userEmail = 'shandy@carein.app';

  static const latest = AnalysisResult(
    date: '30 Sep 2026',
    score: 78,
    skinType: 'Combination',
    metrics: [
      SkinMetric(label: 'Acne', level: 'Moderate', value: 0.65, icon: Icons.bubble_chart_rounded),
      SkinMetric(label: 'Oiliness', level: 'High', value: 0.80, icon: Icons.water_drop_outlined),
      SkinMetric(label: 'Dryness', level: 'Low', value: 0.20, icon: Icons.air_rounded),
      SkinMetric(label: 'Spots', level: 'Moderate', value: 0.50, icon: Icons.blur_on_rounded),
      SkinMetric(label: 'Texture', level: 'Moderate', value: 0.48, icon: Icons.grain_rounded),
    ],
    insight:
        'Your skin appears combination with higher oiliness around the T-zone and moderate acne. '
        'A gentle cleanser and a lightweight, oil-free moisturizer will help maintain moisture balance and clarify pores.',
  );

  static const history = <AnalysisResult>[
    latest,
    AnalysisResult(
      date: '20 Sep 2026',
      score: 74,
      skinType: 'Combination',
      metrics: [
        SkinMetric(label: 'Acne', level: 'Moderate', value: 0.62, icon: Icons.bubble_chart_rounded),
        SkinMetric(label: 'Oiliness', level: 'High', value: 0.82, icon: Icons.water_drop_outlined),
        SkinMetric(label: 'Dryness', level: 'Low', value: 0.20, icon: Icons.air_rounded),
        SkinMetric(label: 'Spots', level: 'Moderate', value: 0.55, icon: Icons.blur_on_rounded),
        SkinMetric(label: 'Texture', level: 'Moderate', value: 0.54, icon: Icons.grain_rounded),
      ],
      insight:
          'Your skin shows combination traits with noticeable oiliness around the T-zone and moderate acne.',
    ),
    AnalysisResult(
      date: '10 Sep 2026',
      score: 70,
      skinType: 'Oily',
      metrics: [
        SkinMetric(label: 'Acne', level: 'High', value: 0.72, icon: Icons.bubble_chart_rounded),
        SkinMetric(label: 'Oiliness', level: 'High', value: 0.88, icon: Icons.water_drop_outlined),
        SkinMetric(label: 'Dryness', level: 'Low', value: 0.15, icon: Icons.air_rounded),
        SkinMetric(label: 'Spots', level: 'Moderate', value: 0.60, icon: Icons.blur_on_rounded),
        SkinMetric(label: 'Texture', level: 'Moderate', value: 0.58, icon: Icons.grain_rounded),
      ],
      insight:
          'Your skin appears oily with active breakouts. Oil control and gentle exfoliation are a good place to start.',
    ),
  ];

  static const morning = <Product>[
    Product(
      name: 'Gentle Foaming Cleanser',
      brand: 'CeraVe',
      category: 'Cleanser',
      ingredient: 'Ceramides, Niacinamide, Hyaluronic Acid',
      description: 'Pembersih wajah berbusa lembut yang efektif membersihkan kotoran dan sebum berlebih tanpa merusak skin barrier alami kulit.',
      reason: 'Sangat cocok untuk membersihkan sebum T-zone tanpa membuat area kulit lainnya kering.',
      icon: Icons.bubble_chart_rounded,
      tint: AppColors.blue,
      price: 'Rp 165.000',
      size: '236 ml',
      howToUse: 'Basahi wajah dengan air hangat. Tuangkan pembersih secukupnya ke telapak tangan, busakan lembut lalu usap ke seluruh wajah secara melingkar selama 30-60 detik. Bilas hingga bersih.',
      shopUrl: 'https://s.shopee.co.id/gQTEFWScZ',
      imageAsset: 'assets/products/cerave_cleanser.png',
    ),
    Product(
      name: 'Oil-Free Ultra-Moisturizing Lotion',
      brand: 'COSRX',
      category: 'Moisturizer',
      ingredient: 'Betula Platyphylla Japonica Juice (Birch Sap) 70%',
      description: 'Pelembap bertekstur gel-lotion sangat ringan yang cepat meresap dan menjaga keseimbangan kadar air tanpa rasa lengket atau greasy.',
      reason: 'Menghidrasi kulit kombinasi secara seimbang tanpa menyumbat pori-pori.',
      icon: Icons.water_drop_rounded,
      tint: AppColors.purple,
      price: 'Rp 210.000',
      size: '100 ml',
      howToUse: 'Setelah mencuci muka dan menggunakan toner, aplikasikan pelembap secukupnya ke seluruh area wajah dan leher secara merata hingga meresap.',
      shopUrl: 'https://s.shopee.co.id/60Rza8sXxi',
      imageAsset: 'assets/products/cosrx_moisturizer.png',
    ),
    Product(
      name: 'Daily UV Shield SPF 50+ PA++++',
      brand: 'Skin Aqua',
      category: 'Sunscreen',
      ingredient: 'Zinc Oxide, Hyaluronic Acid, Collagen',
      description: 'Tabir surya harian berspektrum luas dengan hasil akhir matte lembut, non-comedogenic, dan tidak meninggalkan white cast.',
      reason: 'Melindungi kulit dari paparan sinar UV untuk mencegah hiperpigmentasi dan bekas jerawat baru.',
      icon: Icons.wb_sunny_rounded,
      tint: AppColors.warning,
      price: 'Rp 65.000',
      size: '40 g',
      howToUse: 'Gunakan sebanyak 2 ruas jari sebagai langkah terakhir perawatan kulit di pagi hari. Oleskan merata pada wajah dan leher 15 menit sebelum terpapar sinar matahari.',
      shopUrl: 'https://s.shopee.co.id/9pei9EzZ7c',
      imageAsset: 'assets/products/skin_aqua_sunscreen.png',
    ),
  ];

  static const night = <Product>[
    Product(
      name: 'Salicylic Acid 2% Masque Cleanser',
      brand: 'The Ordinary',
      category: 'Cleanser',
      ingredient: 'Salicylic Acid (BHA), Charcoal, Amazonian Clays',
      description: 'Pembersih dan eksfoliator lembut dengan kandungan asam salisilat untuk membersihkan pori-pori tersumbat dan menghaluskan tekstur kulit.',
      reason: 'Membantu meredakan jerawat aktif dan mengangkat sel kulit mati yang memicu komedo.',
      icon: Icons.cleaning_services_rounded,
      tint: AppColors.blue,
      price: 'Rp 195.000',
      size: '100 ml',
      howToUse: 'Gunakan pada wajah yang kering dan bersih di malam hari. Oleskan tipis dan hindari area mata, diamkan tidak lebih dari 10 menit lalu bilas bersih dengan air hangat.',
      shopUrl: 'https://s.shopee.co.id/BUCdWKVjg',
      imageAsset: 'assets/products/ordinary_cleanser.png',
    ),
    Product(
      name: 'Niacinamide 10% + Zinc 1% Serum',
      brand: 'The Ordinary',
      category: 'Serum',
      ingredient: 'Niacinamide 10%, Zinc PCA 1%',
      description: 'Serum berbasis air berkonsentrasi tinggi untuk mengontrol produksi sebum berlebih, merapatkan tampilan pori, dan menyamarkan noda bekas jerawat.',
      reason: 'Direkomendasikan untuk menyeimbangkan kadar minyak dan meratakan warna kulit yang tidak merata.',
      icon: Icons.science_rounded,
      tint: AppColors.purple,
      price: 'Rp 145.000',
      size: '30 ml',
      howToUse: 'Teteskan 2-3 tetes ke telapak tangan lalu tepuk-tepuk secara perlahan ke seluruh wajah setelah pembersihan wajah sebelum pelembap malam.',
      shopUrl: 'https://s.shopee.co.id/6L4pytwVi8',
      imageAsset: 'assets/products/ordinary_serum.png',
    ),
    Product(
      name: '5X Ceramide Barrier Repair Moisture Gel',
      brand: 'Skintific',
      category: 'Moisturizer',
      ingredient: '5X Ceramide, Hyaluronic Acid, Centella Asiatica, Marine Collagen',
      description: 'Gel pelembap malam dengan formula 5 jenis ceramide untuk memperbaiki dan mengunci kelembapan skin barrier saat tidur.',
      reason: 'Menenangkan iritasi kemerahan dan mempercepat pemulihan tekstur kulit sepanjang malam.',
      icon: Icons.nightlight_rounded,
      tint: AppColors.success,
      price: 'Rp 139.000',
      size: '30 g',
      howToUse: 'Oleskan merata pada wajah dan leher sebagai langkah terakhir rutinitas malam. Pijat lembut dengan gerakan ke atas hingga meresap sempurna.',
      shopUrl: 'https://s.shopee.co.id/9KiRYTEbjL',
      imageAsset: 'assets/products/skintific_moisturizer.png',
    ),
  ];

  static List<Product> get homeRecommendations => [
        morning[0],
        night[1],
        morning[2],
        morning[1],
      ];
}
