import 'package:flutter/material.dart';
import '../models/company_settings_model.dart';
import '../models/localized_string.dart';
import '../models/brand_model.dart';

final List<CompanySettingsModel> fakeCompanies = [
  // ─── 1. مطعم لبناني ───
  CompanySettingsModel(
    id: 'cmp_001',
    category: const StoreCategoryModel(
      id: 'appliances',
      name: LocalizedString(ar: 'أجهزة منزلية', en: 'Home Appliances'),
      icon: 'appliances',
    ),
    name: const LocalizedString(ar: 'مطعم بيار', en: 'Beyrut Restaurant'),
    description: const LocalizedString(
      ar: 'مطعم لبناني أصيل يقدم أشهى المأكولات التقليدية والمشاوي اللبنانية الفاخرة منذ عام 1985.',
      en: 'An authentic Lebanese restaurant serving the finest traditional cuisine and premium Lebanese grills since 1985.',
    ),
    deliveryFee: 3.0,
    slogan: const LocalizedString(ar: 'شعار المطعم', en: 'Restaurant Logo'),
    heroCards: const [
      StoreStatistic(
        value: LocalizedString(ar: '+10', en: '+10'),
        label: LocalizedString(ar: 'سنين خبرة', en: 'Years Experience'),
      ),
      StoreStatistic(
        value: LocalizedString(ar: '+1000', en: '+1000'),
        label: LocalizedString(ar: 'صنف متنوع', en: 'Various Items'),
      ),
      StoreStatistic(
        value: LocalizedString(ar: '+100', en: '+100'),
        label: LocalizedString(ar: 'فرع حول العالم', en: 'Global Branches'),
      ),
    ],
    theme: const StoreTheme(primaryColor: '#000000', secondaryColor: '#FFFFFF'),
    brands: const [],
    addresses: [
      CompanyAddressModel(
        address: const LocalizedString(
          ar: 'شارع الحمرا، بيروت، لبنان',
          en: 'Hamra Street, Beirut, Lebanon',
        ),
        latitude: 33.8938,
        longitude: 35.5018,
        isTHIS: true,
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80',
        linkMap: 'https://maps.google.com/?q=33.8938,35.5018',
      ),
      CompanyAddressModel(
        address: const LocalizedString(
          ar: 'لبنان، محافظة المتن، شارع جل الديب',
          en: 'Lebanon, Metn Governorate, Jal El Dib Street',
        ),
        latitude: 33.9182,
        longitude: 35.5880,
        isTHIS: false,
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80',
        linkMap: 'https://maps.google.com/?q=33.9182,35.5880',
      ),
    ],
    socials: const [
      SocialModel(
        title: LocalizedString(ar: 'فيسبوك', en: 'Facebook'),
        link: 'https://facebook.com/beyrutrestaurant',
        icon: 'facebook',
        color: Colors.blue,
        socialType: SocialType.facebook,
      ),
      SocialModel(
        title: LocalizedString(ar: 'انستغرام', en: 'Instagram'),
        link: 'https://instagram.com/beyrutrestaurant',
        icon: 'instagram',
        color: Colors.purple,
        socialType: SocialType.instagram,
      ),
      SocialModel(
        title: LocalizedString(ar: 'تويتر', en: 'Twitter'),
        link: 'https://twitter.com/beyrutrestaurant',
        icon: 'twitter',
        color: Colors.lightBlue,
        socialType: SocialType.twitter,
      ),
      SocialModel(
        title: LocalizedString(ar: 'واتساب', en: 'WhatsApp'),
        link: '+96170000001',
        icon: 'whatsapp',
        color: Colors.green,
        socialType: SocialType.whatsapp,
      ),
      SocialModel(
        title: LocalizedString(ar: 'الهاتف', en: 'Phone'),
        link: '+96170000001',
        icon: 'phone',
        color: Colors.blueGrey,
        socialType: SocialType.contactPhoneFirst,
      ),
      SocialModel(
        title: LocalizedString(ar: 'البريد الإلكتروني', en: 'Email'),
        link: 'info@beyrutrestaurant.com',
        icon: 'email',
        color: Colors.redAccent,
        socialType: SocialType.contactEmail,
      ),
    ],
    currency: 'USD',
    orders: 1000,
    visitor: 1000,
    followers: 1000,

    footerDescription: const LocalizedString(
      ar: 'وجهتك الأولى لتذوق أصالة المطبخ اللبناني في قلب بيروت، حيث التقليل يلتقي بالجودة العالية.',
      en: 'Your premier destination to taste authentic Lebanese cuisine in the heart of Beirut, where tradition meets premium quality.',
    ),
    aboutUs: const LocalizedString(
      ar: 'تأسس مطعم بيار عام 1985 في قلب شارع الحمرا ببيروت. نحن نفتخر بتقديم أشهى المأكولات اللبنانية التقليدية بأجود المكونات الطازجة. فريقنا من الطهاة المحترفين يحرص على الحفاظ على الأصالة في كل طبق نقدمه.',
      en: 'Beyrut Restaurant was established in 1985 in the heart of Hamra Street, Beirut. We take pride in serving the finest traditional Lebanese cuisine with the freshest premium ingredients. Our team of professional chefs ensures authenticity in every dish we serve.',
    ),
    termsAndConditions: const LocalizedString(
      ar: '1. قبول الشروط\nبمجرد طلبك من مطعم بيار، فإنك توافق على هذه الشروط.\n2. سياسة التوصيل\nنحن نلتزم بتوصيل طلباتك في الوقت المحدد. في حال التأخير، يرجى التواصل معنا.\n3. سياسة الإلغاء\nيمكن إلغاء الطلب خلال 10 دقائق من تأكيده.',
      en: '1. Acceptance of Terms\nBy placing an order with Beyrut Restaurant, you agree to these terms.\n2. Delivery Policy\nWe are committed to delivering your orders on time. In case of delay, please contact us.\n3. Cancellation Policy\nOrders can be cancelled within 10 minutes of confirmation.',
    ),
    privacyPolicy: const LocalizedString(
      ar: 'نحن نحترم خصوصيتك. المعلومات التي تقدمها تُستخدم فقط لمعالجة طلباتك وتحسين خدماتنا. لا نشارك بياناتك مع أطراف ثالثة دون إذنك.',
      en: 'We respect your privacy. The information you provide is used solely to process your orders and improve our services. We do not share your data with third parties without your consent.',
    ),
    paymentMethods: const [PaymentMethodType.cod, PaymentMethodType.creditCard],
  ),

  // ─── 2. متجر ألعاب ───
  CompanySettingsModel(
    id: 'cmp_002',
    category: const StoreCategoryModel(
      id: 'electronics',
      name: LocalizedString(ar: 'إلكترونيات', en: 'Electronics'),
      icon: 'electronics',
    ),
    name: const LocalizedString(ar: 'جيم بروز', en: 'Game Bros LB'),
    description: const LocalizedString(
      ar: 'أكبر متجر ألعاب في لبنان. نقدم أحدث أجهزة الألعاب، الألعاب الرقمية، والإكسسوارات مع توصيل سريع لجميع المناطق.',
      en: 'Lebanon\'s biggest gaming store. We offer the latest gaming consoles, digital games, and accessories with fast delivery to all areas.',
    ),
    deliveryFee: 2.0,
    slogan: const LocalizedString(ar: 'أفضل المنتجات', en: 'Best products'),
    theme: const StoreTheme(primaryColor: '#000000', secondaryColor: '#FFFFFF'),
    brands: const [],
    addresses: [
      CompanyAddressModel(
        address: const LocalizedString(
          ar: 'شارع جل الديب، المتن، لبنان',
          en: 'Jal El Dib Street, Metn, Lebanon',
        ),
        latitude: 33.9182,
        longitude: 35.5880,
        isTHIS: true,
        imageUrl: '',
        linkMap: 'https://maps.google.com/?q=33.9182,35.5880',
      ),
    ],
    socials: const [
      SocialModel(
        title: LocalizedString(ar: 'فيسبوك', en: 'Facebook'),
        link: 'https://facebook.com/gamebroslb',
        icon: 'facebook',
        color: Colors.blue,
        socialType: SocialType.facebook,
      ),
      SocialModel(
        title: LocalizedString(ar: 'انستغرام', en: 'Instagram'),
        link: 'https://instagram.com/gamebroslb',
        icon: 'instagram',
        color: Colors.purple,
        socialType: SocialType.instagram,
      ),
      SocialModel(
        title: LocalizedString(ar: 'تويتر', en: 'Twitter'),
        link: 'https://twitter.com/gamebroslb',
        icon: 'twitter',
        color: Colors.lightBlue,
        socialType: SocialType.twitter,
      ),
      SocialModel(
        title: LocalizedString(ar: 'واتساب', en: 'WhatsApp'),
        link: '+96170000002',
        icon: 'whatsapp',
        color: Colors.green,
        socialType: SocialType.whatsapp,
      ),
      SocialModel(
        title: LocalizedString(ar: 'الهاتف', en: 'Phone'),
        link: '+96170000002',
        icon: 'phone',
        color: Colors.blueGrey,
        socialType: SocialType.contactPhoneFirst,
      ),
      SocialModel(
        title: LocalizedString(ar: 'البريد الإلكتروني', en: 'Email'),
        link: 'support@gamebroslb.com',
        icon: 'email',
        color: Colors.redAccent,
        socialType: SocialType.contactEmail,
      ),
    ],
    currency: 'USD',
    heroCards: const [
      StoreStatistic(
        value: LocalizedString(ar: '+١٠', en: '10+'),
        label: LocalizedString(ar: 'سنة في السوق', en: 'Years in Market'),
      ),
      StoreStatistic(
        value: LocalizedString(ar: '+٥,٠٠٠', en: '5,000+'),
        label: LocalizedString(ar: 'لعبة متوفرة', en: 'Games Available'),
      ),
      StoreStatistic(
        value: LocalizedString(ar: '+٢٠,٠٠٠', en: '20,000+'),
        label: LocalizedString(ar: 'لاعب سعيد', en: 'Happy Gamers'),
      ),
    ],
    footerDescription: const LocalizedString(
      ar: 'وجهتك الأولى لعشاق الألعاب في لبنان. نقدم أحدث الأجهزة والألعاب بأسعار تنافسية وخدمة عملاء متميزة.',
      en: 'Your premier destination for gamers in Lebanon. We offer the latest consoles and games at competitive prices with outstanding customer service.',
    ),
    aboutUs: const LocalizedString(
      ar: 'جيم بروز هو متجر ألعاب لبناني رائد تأسس عام 2014. نحن متخصصون في بيع أجهزة الألعاب، الألعاب الرقمية، والإكسسوارات. نقدم خدمة التوصيل لجميع مناطق لبنان مع إمكانية الاستلام من المتجر.',
      en: 'Game Bros LB is a leading Lebanese gaming store founded in 2014. We specialize in selling gaming consoles, digital games, and accessories. We offer delivery service to all areas of Lebanon with in-store pickup options.',
    ),
    termsAndConditions: const LocalizedString(
      ar: '1. الشروط العامة\nجميع المنتجات أصلية وتحت الضمان.\n2. سياسة الإرجاع\nيمكن إرجاع المنتجات خلال 7 أيام في حال وجود عيب مصنعي.\n3. التوصيل\nالتوصيل مجاني للطلبات فوق 50 دولار.',
      en: '1. General Terms\nAll products are original and under warranty.\n2. Return Policy\nProducts can be returned within 7 days in case of manufacturing defects.\n3. Delivery\nFree delivery for orders above \$50.',
    ),
    privacyPolicy: const LocalizedString(
      ar: 'نحن نحمي بياناتك الشخصية. المعلومات تُستخدم فقط لمعالجة طلباتك ولا تُباع أو تُشارك مع أي طرف ثالث.',
      en: 'We protect your personal data. Information is used solely for processing your orders and is not sold or shared with any third party.',
    ),
  ),

  // ─── 3. متجر عادي (إلكترونيات ومنزليات) ───
  CompanySettingsModel(
    id: 'cmp_003',
    category: const StoreCategoryModel(
      id: 'electronics',
      name: LocalizedString(ar: 'متجر الكترونيات', en: 'Electronics Store'),
      icon: 'electronics',
    ),
    name: const LocalizedString(ar: 'خوري هوم', en: 'Khoury Home'),
    description: const LocalizedString(
      ar: 'أكبر متجر للأجهزة المنزلية والإلكترونيات في لبنان. نقدم تشكيلة واسعة من الأجهزة الكهربائية، الإلكترونيات، والأدوات المنزلية بأفضل الأسعار.',
      en: 'Lebanon\'s largest store for home appliances and electronics. We offer a wide range of electrical appliances, electronics, and home tools at the best prices.',
    ),
    deliveryFee: 5.0,
    slogan: const LocalizedString(ar: 'أفضل المنتجات', en: 'Best products'),
    theme: const StoreTheme(primaryColor: '#000000', secondaryColor: '#FFFFFF'),
    brands: const [],
    addresses: [
      CompanyAddressModel(
        address: const LocalizedString(
          ar: 'طريق المطار، بيروت، لبنان',
          en: 'Airport Road, Beirut, Lebanon',
        ),
        latitude: 33.8547,
        longitude: 35.4890,
        isTHIS: true,
        imageUrl: '',
        linkMap: 'https://maps.google.com/?q=33.8547,35.4890',
      ),
    ],
    socials: const [
      SocialModel(
        title: LocalizedString(ar: 'فيسبوك', en: 'Facebook'),
        link: 'https://facebook.com/khouryhome',
        icon: 'facebook',
        color: Colors.blue,
        socialType: SocialType.facebook,
      ),
      SocialModel(
        title: LocalizedString(ar: 'انستغرام', en: 'Instagram'),
        link: 'https://instagram.com/khouryhome',
        icon: 'instagram',
        color: Colors.purple,
        socialType: SocialType.instagram,
      ),
      SocialModel(
        title: LocalizedString(ar: 'تويتر', en: 'Twitter'),
        link: 'https://twitter.com/khouryhome',
        icon: 'twitter',
        color: Colors.lightBlue,
        socialType: SocialType.twitter,
      ),
      SocialModel(
        title: LocalizedString(ar: 'واتساب', en: 'WhatsApp'),
        link: '+96170000003',
        icon: 'whatsapp',
        color: Colors.green,
        socialType: SocialType.whatsapp,
      ),
      SocialModel(
        title: LocalizedString(ar: 'الهاتف', en: 'Phone'),
        link: '+96170000003',
        icon: 'phone',
        color: Colors.blueGrey,
        socialType: SocialType.contactPhoneFirst,
      ),
      SocialModel(
        title: LocalizedString(ar: 'البريد الإلكتروني', en: 'Email'),
        link: 'info@khouryhome.com',
        icon: 'email',
        color: Colors.redAccent,
        socialType: SocialType.contactEmail,
      ),
    ],
    currency: 'USD',
    heroCards: const [
      StoreStatistic(
        value: LocalizedString(ar: '+٤٠', en: '40+'),
        label: LocalizedString(ar: 'سنة من الثقة', en: 'Years of Trust'),
      ),
      StoreStatistic(
        value: LocalizedString(ar: '+١٠٠', en: '100+'),
        label: LocalizedString(ar: 'ماركة عالمية', en: 'International Brands'),
      ),
      StoreStatistic(
        value: LocalizedString(ar: '+٥٠٠,٠٠٠', en: '500,000+'),
        label: LocalizedString(ar: 'عميل راضٍ', en: 'Satisfied Customers'),
      ),
    ],
    footerDescription: const LocalizedString(
      ar: 'وجهتك الأولى للأجهزة المنزلية والإلكترونيات في لبنان. نقدم منتجات عالية الجودة من أفضل الماركات العالمية مع ضمان شامل وخدمة ما بعد البيع.',
      en: 'Your premier destination for home appliances and electronics in Lebanon. We offer high-quality products from the best international brands with comprehensive warranty and after-sales service.',
    ),
    aboutUs: const LocalizedString(
      ar: 'خوري هوم هي شركة لبنانية رائدة في مجال بيع الأجهزة المنزلية والإلكترونيات. تأسست الشركة عام 1983 ونمت لتصبح واحدة من أكبر سلاسل المتاجر في لبنان. نحن نقدم منتجات عالية الجودة من أفضل الماركات العالمية مع خدمة عملاء متميزة.',
      en: 'Khoury Home is a leading Lebanese company in the field of home appliances and electronics. The company was founded in 1983 and grew to become one of the largest retail chains in Lebanon. We offer high-quality products from the best international brands with outstanding customer service.',
    ),
    termsAndConditions: const LocalizedString(
      ar: '1. الشروط والأحكام\nباستخدامك لموقع خوري هوم، فإنك توافق على هذه الشروط.\n2. الضمان\nجميع المنتجات تحت ضمان الشركة المصنعة بالإضافة إلى ضمان خوري هوم.\n3. سياسة الإرجاع\nيمكن إرجاع المنتجات خلال 14 يوماً مع الفاتورة الأصلية.',
      en: '1. Terms and Conditions\nBy using Khoury Home website, you agree to these terms.\n2. Warranty\nAll products are under manufacturer warranty in addition to Khoury Home warranty.\n3. Return Policy\nProducts can be returned within 14 days with the original invoice.',
    ),
    privacyPolicy: const LocalizedString(
      ar: 'نحن نلتزم بحماية خصوصيتك. البيانات التي تجمعها خوري هوم تُستخدم فقط لتحسين تجربة التسوق الخاصة بك ولن تُشارك مع أي طرف ثالث دون موافقتك الصريحة.',
      en: 'We are committed to protecting your privacy. Data collected by Khoury Home is used solely to improve your shopping experience and will not be shared with any third party without your explicit consent.',
    ),
  ),
];
