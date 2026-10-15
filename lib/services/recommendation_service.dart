import 'package:flutter/material.dart';

import '../models/dummy_models.dart';
import '../theme/app_theme.dart';

/// Service pintar untuk mengkurasi rekomendasi produk skincare
/// secara dinamis berdasarkan hasil analisis wajah AI pengguna.
class RecommendationService {
  RecommendationService._();

  /// Hasil rekomendasi yang dipisahkan antara Pagi dan Malam
  static RoutineRecommendation getPersonalizedRoutine(AnalysisResult result) {
    // 1. Ekstrak metrik
    double getMetric(String name) {
      try {
        final m = result.metrics.firstWhere(
          (m) => m.label.toLowerCase() == name.toLowerCase(),
        );
        return m.value * 100; // konversi ke 0-100
      } catch (_) {
        return 0.0;
      }
    }

    final acne = getMetric('Acne');
    final oiliness = getMetric('Oiliness');
    final dryness = getMetric('Dryness');
    final spots = getMetric('Spots');
    final skinType = result.skinType.toLowerCase();

    // 2. Tentukan fokus utama masalah
    String primaryFocus;
    String focusDescription;

    if (acne >= 35) {
      primaryFocus = 'Jerawat & Pori Tersumbat';
      focusDescription =
          'Fokus: Meredakan inflamasi jerawat (${acne.toInt()}%), membersihkan pori, dan memperkuat skin barrier tanpa iritasi.';
    } else if (skinType.contains('dry') || dryness >= 40) {
      primaryFocus = 'Hidrasi Kulit Kering';
      focusDescription =
          'Fokus: Memulihkan kelembapan mendalam (${dryness.toInt()}%), mencegah kulit bersisik, dan menutrisi lapisan pelindung kulit.';
    } else if (skinType.contains('oily') || oiliness >= 60) {
      primaryFocus = 'Kontrol Sebum & Kilap';
      focusDescription =
          'Fokus: Mengurangi produksi minyak berlebih (${oiliness.toInt()}%), merapatkan pori, dan pelembap oil-free.';
    } else if (spots >= 40) {
      primaryFocus = 'Menyamarkan Bintik & Bekas Jerawat';
      focusDescription =
          'Fokus: Mencerahkan noda hiperpigmentasi (${spots.toInt()}%) dan perlindungan sinar UV maksimal.';
    } else {
      primaryFocus = 'Perawatan Keseimbangan Kulit';
      focusDescription =
          'Fokus: Menjaga skin barrier sehat dan hidrasi seimbang untuk tipe kulit ${result.skinType}.';
    }

    // 3. Kurasi produk spesifik
    List<Product> morningProducts;
    List<Product> nightProducts;

    if (acne >= 35) {
      // ── RUTINITAS KHUSUS JERAWAT ──────────────────────────────────────────
      morningProducts = [
        Product(
          name: 'Blemish Control Cleanser',
          brand: 'CeraVe',
          category: 'Cleanser',
          ingredient: 'Salicylic Acid 2%, Niacinamide, Hectorite Clay',
          description:
              'Pembersih gel busa yang diformulasikan khusus untuk mengatasi jerawat dan komedo tanpa merusak pelindung kulit alami.',
          reason:
              'Dipilih khusus untuk jerawat aktif (${acne.toInt()}%) guna membersihkan minyak penyumbat pori di pagi hari.',
          icon: Icons.bubble_chart_rounded,
          tint: AppColors.blue,
          price: 'Rp 195.000',
          size: '236 ml',
          howToUse:
              'Basahi wajah, usap pembersih dengan gerakan memutar lembut selama 45 detik, lalu bilas hingga bersih dengan air suam kuku.',
          shopUrl: 'https://s.shopee.co.id/gQTEFWScZ',
          imageAsset: 'assets/products/cerave_cleanser.png',
        ),
        Product(
          name: '5X Ceramide Barrier Repair Moisture Gel',
          brand: 'Skintific',
          category: 'Moisturizer',
          ingredient: '5X Ceramide, Hyaluronic Acid, Centella Asiatica',
          description:
              'Gel pelembap ringan oil-free yang menenangkan kemerahan jerawat dan mengunci hidrasi tanpa menyumbat pori-pori.',
          reason:
              'Tekstur gel bebas minyak sangat aman untuk kulit berjerawat dan mempercepat pemulihan skin barrier.',
          icon: Icons.water_drop_rounded,
          tint: AppColors.purple,
          price: 'Rp 139.000',
          size: '30 g',
          howToUse:
              'Oleskan merata ke seluruh wajah setelah cuci muka, tepuk-tepuk hingga meresap sempurna.',
          shopUrl: 'https://s.shopee.co.id/9KiRYTEbjL',
          imageAsset: 'assets/products/skintific_moisturizer.png',
        ),
        Product(
          name: 'UV Moisture Gel SPF 50+ PA++++',
          brand: 'Skin Aqua',
          category: 'Sunscreen',
          ingredient: 'Hyaluronic Acid, Collagen, Vitamin C',
          description:
              'Sunscreen berbasis air yang ringan, non-comedogenic, dan tidak meninggalkan rasa lengket atau white cast.',
          reason:
              'Melindungi kulit berjerawat dari sinar UV agar inflamasi tidak memburuk dan tidak timbul noda hitam PIH.',
          icon: Icons.wb_sunny_rounded,
          tint: AppColors.warning,
          price: 'Rp 65.000',
          size: '40 g',
          howToUse:
              'Gunakan sebanyak 2 ruas jari sebagai langkah terakhir di pagi hari 15 menit sebelum beraktivitas di luar.',
          shopUrl: 'https://s.shopee.co.id/9pei9EzZ7c',
          imageAsset: 'assets/products/skin_aqua_sunscreen.png',
        ),
      ];

      nightProducts = [
        Product(
          name: 'Salicylic Acid 2% Masque Cleanser',
          brand: 'The Ordinary',
          category: 'Cleanser',
          ingredient: 'Salicylic Acid 2%, Charcoal, Amazonian Clay',
          description:
              'Pembersih eksfoliasi mendalam untuk membersihkan pori tersumbat, kotoran harian, dan menghaluskan permukaan kulit.',
          reason:
              'Eksfoliasi malam yang efektif melarutkan sebum di dalam pori agar jerawat cepat kering.',
          icon: Icons.cleaning_services_rounded,
          tint: AppColors.blue,
          price: 'Rp 195.000',
          size: '100 ml',
          howToUse:
              'Gunakan di malam hari pada wajah bersih. Ratakan tipis, diamkan maksimal 10 menit lalu bilas bersih.',
          shopUrl: 'https://s.shopee.co.id/BUCdWKVjg',
          imageAsset: 'assets/products/ordinary_cleanser.png',
        ),
        Product(
          name: 'Niacinamide 10% + Zinc 1%',
          brand: 'The Ordinary',
          category: 'Serum',
          ingredient: 'Niacinamide 10%, Zinc PCA 1%',
          description:
              'Serum aktif untuk menenangkan jerawat meradang, memudarkan bekas kemerahan, dan mengontrol produksi minyak berlebih.',
          reason:
              'Zinc PCA aktif menekan bakteri jerawat sementara Niacinamide memudarkan bekas jerawat.',
          icon: Icons.science_rounded,
          tint: AppColors.purple,
          price: 'Rp 145.000',
          size: '30 ml',
          howToUse:
              'Teteskan 2-3 tetes ke telapak tangan, tepuk perlahan ke area wajah berjerawat sebelum krim pelembap.',
          shopUrl: 'https://s.shopee.co.id/6L4pytwVi8',
          imageAsset: 'assets/products/ordinary_serum.png',
        ),
        Product(
          name: 'Centella Blemish Calming Cream',
          brand: 'COSRX',
          category: 'Night Treatment',
          ingredient: 'Centella Asiatica Water, Tea Tree Oil, Zinc Oxide',
          description:
              'Krim totol malam hari yang diformulasikan khusus untuk meredakan kemerahan dan mempercepat kempesnya jerawat aktif.',
          reason:
              'Bekerja semalaman meredakan jerawat yang sedang meradang tanpa membuat kulit di sekitarnya kering.',
          icon: Icons.nightlight_rounded,
          tint: AppColors.success,
          price: 'Rp 175.000',
          size: '30 ml',
          howToUse:
              'Totolkan secukupnya pada bintik-bintik jerawat aktif setelah pelembap malam sebelum tidur.',
          shopUrl: 'https://s.shopee.co.id/60Rza8sXxi',
          imageAsset: 'assets/products/skintific_moisturizer.png',
        ),
      ];
    } else if (skinType.contains('dry') || dryness >= 40) {
      // ── RUTINITAS KHUSUS KULIT KERING / DEHIDRASI ─────────────────────────
      morningProducts = [
        Product(
          name: 'Hydrating Facial Cleanser',
          brand: 'CeraVe',
          category: 'Cleanser',
          ingredient: 'Ceramides 1, 3, 6-II, Hyaluronic Acid',
          description:
              'Pembersih non-foaming berbentuk lotion yang membersihkan secara lembut tanpa menghilangkan kelembapan alami kulit kering.',
          reason:
              'Cocok untuk kulit kering (${dryness.toInt()}%) karena menjaga hidrasi sejak langkah pertama mencuci muka.',
          icon: Icons.water_drop_outlined,
          tint: AppColors.blue,
          price: 'Rp 180.000',
          size: '236 ml',
          howToUse:
              'Usapkan pada wajah basah, pijat perlahan tanpa digosok kencang, bilas dengan air bersuhu ruangan.',
          shopUrl: 'https://s.shopee.co.id/gQTEFWScZ',
          imageAsset: 'assets/products/cerave_cleanser.png',
        ),
        Product(
          name: 'Advanced Snail 96 Mucin Power Essence',
          brand: 'COSRX',
          category: 'Essence',
          ingredient: 'Snail Secretion Filtrate 96%, Sodium Hyaluronate',
          description:
              'Esens kaya nutrisi yang melembapkan secara intensif, memperbaiki tekstur kering, dan mengembalikan kekenyalan kulit.',
          reason:
              'Memberikan kelembapan ekstra ke lapisan dalam kulit kering yang dehidrasi.',
          icon: Icons.auto_awesome,
          tint: AppColors.purple,
          price: 'Rp 190.000',
          size: '100 ml',
          howToUse:
              'Tuangkan 1-2 pump ke telapak tangan, aplikasikan ke seluruh wajah dengan gerakan menepuk lembut.',
          shopUrl: 'https://s.shopee.co.id/60Rza8sXxi',
          imageAsset: 'assets/products/cosrx_moisturizer.png',
        ),
        Product(
          name: 'UV Moisture Milk SPF 50+ PA++++',
          brand: 'Skin Aqua',
          category: 'Sunscreen',
          ingredient: 'Hyaluronic Acid, Collagen, Vitamin B5',
          description:
              'Sunscreen bertekstur susu yang sangat melembapkan, menutrisi kulit kering, dan melindungi dari sinar UV seharian.',
          reason:
              'Menjaga kelembapan kulit kering di bawah sinar matahari tanpa rasa kering atau tertarik.',
          icon: Icons.wb_sunny_rounded,
          tint: AppColors.warning,
          price: 'Rp 70.000',
          size: '40 g',
          howToUse:
              'Kocok sebelum digunakan. Oleskan merata pada wajah dan leher 15 menit sebelum keluar ruangan.',
          shopUrl: 'https://s.shopee.co.id/9pei9EzZ7c',
          imageAsset: 'assets/products/skin_aqua_sunscreen.png',
        ),
      ];

      nightProducts = [
        Product(
          name: 'Gokujyun Ultimate Moisturizing Face Wash',
          brand: 'Hada Labo',
          category: 'Cleanser',
          ingredient: '3 Types of Hyaluronic Acid, No Fragrance, No Alcohol',
          description:
              'Sabun pembersih dengan pH seimbang yang membersihkan kotoran sekaligus mengunci kelembapan alami kulit kering.',
          reason:
              'Membersihkan wajah malam hari tanpa rasa kesat atau kering tertarik.',
          icon: Icons.bubble_chart_rounded,
          tint: AppColors.blue,
          price: 'Rp 55.000',
          size: '100 g',
          howToUse:
              'Keluarkan 2 cm pada telapak tangan, busakan dengan air lalu pijat lembut ke wajah. Bilas hingga bersih.',
          shopUrl: 'https://s.shopee.co.id/BUCdWKVjg',
          imageAsset: 'assets/products/cerave_cleanser.png',
        ),
        Product(
          name: 'Hyaluronic Acid 2% + B5 Hydration Serum',
          brand: 'The Ordinary',
          category: 'Serum',
          ingredient: 'Hyaluronic Acid Multi-Molecular, Vitamin B5',
          description:
              'Serum hidrasi bertingkat yang menyerap ke berbagai kedalaman kulit untuk mengisi kembali cadangan air kulit.',
          reason:
              'Mengatasi kekeringan kulit (${dryness.toInt()}%) saat tidur agar kulit bangun dalam keadaan kenyal.',
          icon: Icons.science_rounded,
          tint: AppColors.purple,
          price: 'Rp 150.000',
          size: '30 ml',
          howToUse:
              'Oleskan beberapa tetes ke wajah sebelum krim pelembap malam hari.',
          shopUrl: 'https://s.shopee.co.id/6L4pytwVi8',
          imageAsset: 'assets/products/ordinary_serum.png',
        ),
        Product(
          name: 'Ceramide Ato Concentrate Cream',
          brand: 'Illiyoon',
          category: 'Night Cream',
          ingredient: 'Ceramide Skin Complex™, Panax Ginseng Root Extract',
          description:
              'Krim pelembap intensif dengan kapsul ceramide mikro yang memperkuat pelindung kulit kering dan menahan hidrasi hingga 72 jam.',
          reason:
              'Krim kaya lipid esensial untuk memulihkan skin barrier kulit kering secara mendalam.',
          icon: Icons.nightlight_rounded,
          tint: AppColors.success,
          price: 'Rp 195.000',
          size: '150 ml',
          howToUse:
              'Aplikasikan secukupnya sebagai langkah penutup rutinitas malam. Pijat lembut hingga kapsul ceramide meresap.',
          shopUrl: 'https://s.shopee.co.id/9KiRYTEbjL',
          imageAsset: 'assets/products/skintific_moisturizer.png',
        ),
      ];
    } else if (skinType.contains('oily') || oiliness >= 60) {
      // ── RUTINITAS KHUSUS KULIT BERMINYAK ──────────────────────────────────
      morningProducts = [
        Product(
          name: 'Oily Skin Cleanser',
          brand: 'Cetaphil',
          category: 'Cleanser',
          ingredient: 'Niacinamide, Panthenol, Glycerin',
          description:
              'Pembersih wajah berbusa lembut yang terbukti secara klinis mampu mengurangi minyak berlebih tanpa membuat kulit kering.',
          reason:
              'Mengontrol produksi sebum pagi hari pada kulit berminyak (${oiliness.toInt()}%).',
          icon: Icons.bubble_chart_rounded,
          tint: AppColors.blue,
          price: 'Rp 145.000',
          size: '125 ml',
          howToUse:
              'Pijat lembut ke kulit yang basah selama 30 detik lalu bilas hingga bersih.',
          shopUrl: 'https://s.shopee.co.id/gQTEFWScZ',
          imageAsset: 'assets/products/cerave_cleanser.png',
        ),
        Product(
          name: 'Oil-Free Ultra-Moisturizing Lotion',
          brand: 'COSRX',
          category: 'Moisturizer',
          ingredient: 'Birch Sap 70%, Tea Tree Oil',
          description:
              'Lotion pelembap bebas minyak yang sangat cepat menyerap, memberikan hidrasi segar tanpa meninggalkan rasa lengket atau kilap.',
          reason:
              'Menghidrasi kulit berminyak tanpa memicu produksi minyak tambahan di siang hari.',
          icon: Icons.water_drop_rounded,
          tint: AppColors.purple,
          price: 'Rp 210.000',
          size: '100 ml',
          howToUse:
              'Oleskan merata ke seluruh wajah setelah membersihkan muka di pagi hari.',
          shopUrl: 'https://s.shopee.co.id/60Rza8sXxi',
          imageAsset: 'assets/products/cosrx_moisturizer.png',
        ),
        Product(
          name: 'UV Aqua Rich Watery Essence SPF 50+',
          brand: 'Biore',
          category: 'Sunscreen',
          ingredient: 'Hyaluronic Acid, Royal Jelly Extract',
          description:
              'Tabir surya bertekstur watery essence yang sangat ringan, tidak berminyak, dan memberikan hasil akhir matte lembut.',
          reason:
              'Menjaga kulit berminyak bebas kilap seharian sambil memberikan perlindungan UV optimal.',
          icon: Icons.wb_sunny_rounded,
          tint: AppColors.warning,
          price: 'Rp 115.000',
          size: '50 g',
          howToUse:
              'Oleskan merata ke wajah dan leher 15 menit sebelum keluar ruangan.',
          shopUrl: 'https://s.shopee.co.id/9pei9EzZ7c',
          imageAsset: 'assets/products/skin_aqua_sunscreen.png',
        ),
      ];

      nightProducts = [
        Product(
          name: 'Salicylic Acid 2% Masque Cleanser',
          brand: 'The Ordinary',
          category: 'Cleanser',
          ingredient: 'Salicylic Acid 2%, Charcoal Powder',
          description:
              'Pembersih masker eksfoliasi yang menyerap minyak berlebih dan membersihkan pori secara tuntas setelah beraktivitas.',
          reason:
              'Membersihkan residu minyak dan polusi yang menumpuk di pori seharian.',
          icon: Icons.cleaning_services_rounded,
          tint: AppColors.blue,
          price: 'Rp 195.000',
          size: '100 ml',
          howToUse:
              'Gunakan malam hari pada wajah bersih dan kering, bilas setelah 10 menit.',
          shopUrl: 'https://s.shopee.co.id/BUCdWKVjg',
          imageAsset: 'assets/products/ordinary_cleanser.png',
        ),
        Product(
          name: 'Niacinamide 10% + Zinc 1% Oil Control Serum',
          brand: 'The Ordinary',
          category: 'Serum',
          ingredient: 'Niacinamide 10%, Zinc PCA 1%',
          description:
              'Serum pengontrol sebum terpopuler untuk meregulasi produksi minyak dan merapatkan tampilan pori-pori besar.',
          reason:
              'Kombinasi terbaik untuk mengurangi produksi minyak wajah (${oiliness.toInt()}%) saat tidur.',
          icon: Icons.science_rounded,
          tint: AppColors.purple,
          price: 'Rp 145.000',
          size: '30 ml',
          howToUse:
              'Teteskan 2 tetes ke area T-zone dan pipi, ratakan sebelum pelembap.',
          shopUrl: 'https://s.shopee.co.id/6L4pytwVi8',
          imageAsset: 'assets/products/ordinary_serum.png',
        ),
        Product(
          name: '5X Ceramide Barrier Moisture Gel',
          brand: 'Skintific',
          category: 'Moisturizer',
          ingredient: '5X Ceramide, Hyaluronic Acid, Centella',
          description:
              'Gel pelembap oil-free yang memperkuat barrier kulit tanpa memicu minyak berlebih saat bangun tidur.',
          reason:
              'Pelembap malam bebas minyak yang menyerap dalam hitungan detik.',
          icon: Icons.nightlight_rounded,
          tint: AppColors.success,
          price: 'Rp 139.000',
          size: '30 g',
          howToUse:
              'Oleskan tipis merata ke seluruh wajah sebagai langkah terakhir sebelum tidur.',
          shopUrl: 'https://s.shopee.co.id/9KiRYTEbjL',
          imageAsset: 'assets/products/skintific_moisturizer.png',
        ),
      ];
    } else {
      // ── RUTINITAS KULIT NORMAL / KOMBINASI ────────────────────────────────
      morningProducts = [
        Product(
          name: 'Gentle Foaming Cleanser',
          brand: 'CeraVe',
          category: 'Cleanser',
          ingredient: 'Ceramides, Niacinamide, Hyaluronic Acid',
          description:
              'Pembersih wajah berbusa lembut yang efektif membersihkan kotoran dan sebum berlebih tanpa merusak skin barrier alami kulit.',
          reason:
              'Membersihkan sebum area T-zone tanpa membuat area pipi kering.',
          icon: Icons.bubble_chart_rounded,
          tint: AppColors.blue,
          price: 'Rp 165.000',
          size: '236 ml',
          howToUse:
              'Busakan lembut lalu usap ke seluruh wajah secara melingkar selama 30-60 detik. Bilas hingga bersih.',
          shopUrl: 'https://s.shopee.co.id/gQTEFWScZ',
          imageAsset: 'assets/products/cerave_cleanser.png',
        ),
        Product(
          name: 'Oil-Free Ultra-Moisturizing Lotion',
          brand: 'COSRX',
          category: 'Moisturizer',
          ingredient: 'Birch Sap 70%',
          description:
              'Pelembap bertekstur gel-lotion sangat ringan yang cepat meresap dan menjaga keseimbangan kadar air tanpa rasa lengket.',
          reason:
              'Menghidrasi kulit kombinasi secara seimbang tanpa menyumbat pori-pori.',
          icon: Icons.water_drop_rounded,
          tint: AppColors.purple,
          price: 'Rp 210.000',
          size: '100 ml',
          howToUse:
              'Aplikasikan pelembap secukupnya ke seluruh area wajah dan leher secara merata hingga meresap.',
          shopUrl: 'https://s.shopee.co.id/60Rza8sXxi',
          imageAsset: 'assets/products/cosrx_moisturizer.png',
        ),
        Product(
          name: 'Daily UV Shield SPF 50+ PA++++',
          brand: 'Skin Aqua',
          category: 'Sunscreen',
          ingredient: 'Zinc Oxide, Hyaluronic Acid, Collagen',
          description:
              'Tabir surya harian berspektrum luas dengan hasil akhir matte lembut, non-comedogenic, dan tidak meninggalkan white cast.',
          reason:
              'Melindungi kulit dari paparan sinar UV untuk mencegah hiperpigmentasi dan menjaga elastisitas.',
          icon: Icons.wb_sunny_rounded,
          tint: AppColors.warning,
          price: 'Rp 65.000',
          size: '40 g',
          howToUse:
              'Gunakan sebanyak 2 ruas jari sebagai langkah terakhir di pagi hari 15 menit sebelum terpapar sinar matahari.',
          shopUrl: 'https://s.shopee.co.id/9pei9EzZ7c',
          imageAsset: 'assets/products/skin_aqua_sunscreen.png',
        ),
      ];

      nightProducts = [
        Product(
          name: 'Salicylic Acid 2% Masque Cleanser',
          brand: 'The Ordinary',
          category: 'Cleanser',
          ingredient: 'Salicylic Acid, Charcoal, Amazonian Clays',
          description:
              'Pembersih dan eksfoliator lembut dengan kandungan asam salisilat untuk membersihkan pori-pori tersumbat dan menghaluskan tekstur kulit.',
          reason:
              'Mengangkat sel kulit mati harian dan menjaga pori-pori tetap bersih.',
          icon: Icons.cleaning_services_rounded,
          tint: AppColors.blue,
          price: 'Rp 195.000',
          size: '100 ml',
          howToUse:
              'Oleskan tipis dan hindari area mata, diamkan tidak lebih dari 10 menit lalu bilas bersih dengan air hangat.',
          shopUrl: 'https://s.shopee.co.id/BUCdWKVjg',
          imageAsset: 'assets/products/ordinary_cleanser.png',
        ),
        Product(
          name: 'Niacinamide 10% + Zinc 1% Serum',
          brand: 'The Ordinary',
          category: 'Serum',
          ingredient: 'Niacinamide 10%, Zinc PCA 1%',
          description:
              'Serum berbasis air berkonsentrasi tinggi untuk mengontrol produksi sebum berlebih, merapatkan tampilan pori, dan menyamarkan noda.',
          reason:
              'Menyeimbangkan kadar air dan minyak serta menjaga tekstur kulit tetap halus.',
          icon: Icons.science_rounded,
          tint: AppColors.purple,
          price: 'Rp 145.000',
          size: '30 ml',
          howToUse:
              'Teteskan 2-3 tetes ke telapak tangan lalu tepuk-tepuk secara perlahan ke seluruh wajah sebelum pelembap malam.',
          shopUrl: 'https://s.shopee.co.id/6L4pytwVi8',
          imageAsset: 'assets/products/ordinary_serum.png',
        ),
        Product(
          name: '5X Ceramide Barrier Repair Moisture Gel',
          brand: 'Skintific',
          category: 'Moisturizer',
          ingredient: '5X Ceramide, Hyaluronic Acid, Centella Asiatica',
          description:
              'Gel pelembap malam dengan formula 5 jenis ceramide untuk memperbaiki dan mengunci kelembapan skin barrier saat tidur.',
          reason:
              'Mempercepat regenerasi sel kulit sepanjang malam.',
          icon: Icons.nightlight_rounded,
          tint: AppColors.success,
          price: 'Rp 139.000',
          size: '30 g',
          howToUse:
              'Oleskan merata pada wajah dan leher sebagai langkah terakhir rutinitas malam.',
          shopUrl: 'https://s.shopee.co.id/9KiRYTEbjL',
          imageAsset: 'assets/products/skintific_moisturizer.png',
        ),
      ];
    }

    return RoutineRecommendation(
      skinType: result.skinType,
      score: result.score,
      primaryFocus: primaryFocus,
      focusDescription: focusDescription,
      morningProducts: morningProducts,
      nightProducts: nightProducts,
    );
  }
}

class RoutineRecommendation {
  const RoutineRecommendation({
    required this.skinType,
    required this.score,
    required this.primaryFocus,
    required this.focusDescription,
    required this.morningProducts,
    required this.nightProducts,
  });

  final String skinType;
  final int score;
  final String primaryFocus;
  final String focusDescription;
  final List<Product> morningProducts;
  final List<Product> nightProducts;
}
