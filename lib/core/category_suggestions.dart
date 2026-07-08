import 'category.dart';

class CategorySuggestor {
  static final Map<RegExp, Category> _rules = {
    RegExp(r'zomato|swiggy|domino|pizzahut|mcdonald|kfc|burgerking|dunzo|zepto|blinkit|grocer|milk|bread|restaurant|cafe|hotel|tiffin|dhaba|eatery|food|pizza|burger|sushi|biryani|chinese|bakery|catering', caseSensitive: false): Category.food,
    RegExp(r'uber|ola|rapido|meru|megacab|shuttl|zoomcar|drivezy|indrive|auto|taxi|cab|petrol|fuel|gas|toll|parking|metro|bus|train|railway|flight|airline|indigo|spicejet|goair', caseSensitive: false): Category.transport,
    RegExp(r'amazon|flipkart|myntra|ajio|meesho|nykaa|snapdeal|shopclues|lenskart|pepperfry|urbanladder|shopping|mall|store|retail|bazar|mart|supermarket|walmart|target', caseSensitive: false): Category.shopping,
    RegExp(r'netflix|spotify|prime|youtube|hotstar|sonyliv|jiotv|zee5|voot|altbalaji|discovery|bookmy|bookmyshow|ticket|movie|cinema|theatre|game|gaming|playstation|xbox|steam|music', caseSensitive: false): Category.entertainment,
    RegExp(r'apollo|fortis|medplus|netmeds|pharmacy|medicin|doctor|hospital|clinic|dental|eye|lab|diagnostic|health|fitness|gym|yoga|wellness|ayush|ayurveda', caseSensitive: false): Category.health,
    RegExp(r'udemy|coursera|byju|vedantu|unacademy|skillshare|class|course|tutor|coaching|school|college|university|exam|book|library|study|education|learning', caseSensitive: false): Category.education,
    RegExp(r'rent|electric|water|broadband|jio|airtel|vi|recharge|bill|tax|society|maintenance|wifi|cable|phone', caseSensitive: false): Category.utilities,
    RegExp(r'flat|apartment|house|pg|rental|broker|property|builder|construction|paint|plumber|electrician|repair|renovation|furniture|home', caseSensitive: false): Category.housing,
    RegExp(r'sports|decat|nike|adidas|puma|reebok|underarmour|jersey|kit|equipment|cricket|football|badminton|tennis|swim|cycling', caseSensitive: false): Category.sports,
    RegExp(r'freelance|gig|upwork|fiverr|freelancer|project|contract|consult', caseSensitive: false): Category.freelance,
    RegExp(r'salary|wage|payroll|stipend|bonus', caseSensitive: false): Category.salary,
  };

  static Category suggest(String? payeeName) {
    if (payeeName == null || payeeName.isEmpty) return Category.other;
    for (final entry in _rules.entries) {
      if (entry.key.hasMatch(payeeName)) return entry.value;
    }
    return Category.other;
  }
}
