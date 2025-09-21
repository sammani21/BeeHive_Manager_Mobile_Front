// utils/insights_utils.dart
import 'package:pass_log/models/product_model.dart';
import 'package:intl/intl.dart';

class InsightsUtils {
  static Map<String, dynamic> generateMarketingTip(List<Product> products) {
    if (products.isEmpty) {
      return {
        'tip': "Add your first product to get marketing insights!",
        'totalProduction': 0,
        'peakMonth': null,
      };
    }

    double totalProduction = products.fold(0, (sum, product) => sum + product.quantity);
    Map<int, double> monthlyProduction = {};
    
    for (var product in products) {
      int month = product.harvestDate.month;
      monthlyProduction[month] = (monthlyProduction[month] ?? 0) + product.quantity;
    }
    
    int peakMonth = 0;
    double maxProduction = 0;
    monthlyProduction.forEach((month, production) {
      if (production > maxProduction) {
        maxProduction = production;
        peakMonth = month;
      }
    });
    
    String monthName = DateFormat('MMMM').format(DateTime(2023, peakMonth, 1));
    
    return {
      'tip': "Your production peaks in $monthName - consider increasing stock before this period. "
          "Total production: ${totalProduction.toStringAsFixed(2)} ${products.isNotEmpty ? products.first.unit : 'units'}",
      'totalProduction': totalProduction,
      'peakMonth': peakMonth,
    };
  }

  static Map<String, double> getProductionByType(List<Product> products) {
    Map<String, double> productionByType = {};
    for (var product in products) {
      productionByType[product.productType] = 
          (productionByType[product.productType] ?? 0) + product.quantity;
    }
    return productionByType;
  }

  static Map<String, dynamic> calculateStats(List<Product> products) {
    if (products.isEmpty) {
      return {
        'totalProducts': 0,
        'productTypes': 0,
        'totalProduction': 0,
        'mostProducedType': "None",
      };
    }

    double totalProduction = products.fold(0, (sum, product) => sum + product.quantity);
    int productTypes = products.map((e) => e.productType).toSet().length;
    
    Map<String, double> productionByType = getProductionByType(products);
    
    String mostProducedType = "None";
    double maxProduction = 0;
    productionByType.forEach((type, production) {
      if (production > maxProduction) {
        maxProduction = production;
        mostProducedType = type;
      }
    });
    
    return {
      'totalProducts': products.length,
      'productTypes': productTypes,
      'totalProduction': totalProduction,
      'mostProducedType': mostProducedType,
    };
  }
}