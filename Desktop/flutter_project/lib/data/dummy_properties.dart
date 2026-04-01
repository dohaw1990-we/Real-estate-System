import '../models/property.dart';

class DummyPropertyData {
  static List<Property> getSampleProperties() {
    return [
      // القاهرة - وسط المدينة
      Property(
        id: '1',
        title: 'شقة فاخرة بوسط القاهرة',
        price: 2500000,
        location: 'وسط القاهرة - التحرير',
        type: PropertyType.apartment,
        description: 'شقة حديثة وفاخرة بإطلالة على النيل',
        contactPhone: '+201001234567',
        images: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop',
        ],
      ),
      // المعادي
      Property(
        id: '2',
        title: 'فيلا فاخرة بالمعادي',
        price: 8500000,
        location: 'المعادي - القاهرة',
        type: PropertyType.villa,
        description: 'فيلا كبيرة مع حديقة وحمام سباحة، موقع مميز',
        contactPhone: '+201001234568',
        images: [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop',
        ],
      ),
      // الجيزة
      Property(
        id: '3',
        title: 'شقة عائلية بالجيزة',
        price: 1800000,
        location: 'الجيزة - الهرم',
        type: PropertyType.apartment,
        description: 'شقة واسعة مناسبة للعائلات الكبيرة',
        contactPhone: '+201001234569',
        images: [
          'https://images.unsplash.com/photo-1540932653986-d12d27d8acad?w=600&h=400&fit=crop',
        ],
      ),
      // الإسكندرية
      Property(
        id: '4',
        title: 'منزل بشاطئ الإسكندرية',
        price: 5500000,
        location: 'الإسكندرية - الشاطبي',
        type: PropertyType.house,
        description: 'منزل رائع بإطلالة على البحر المتوسط',
        contactPhone: '+201001234570',
        images: [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop',
        ],
      ),
      // حلوان
      Property(
        id: '5',
        title: 'مكتب عصري بحلوان',
        price: 1200000,
        location: 'حلوان - القاهرة',
        type: PropertyType.office,
        description: 'مكتب حديث مع كل المرافق اللازمة',
        contactPhone: '+201001234571',
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop',
        ],
      ),
      // الشروق
      Property(
        id: '6',
        title: 'فيلا حديثة بمدينة الشروق',
        price: 6500000,
        location: 'الشروق - القاهرة الجديدة',
        type: PropertyType.villa,
        description: 'فيلا عصرية مع تصميم معماري مميز',
        contactPhone: '+201001234572',
        images: [
          'https://images.unsplash.com/photo-1601584942278-04be67dcb884?w=600&h=400&fit=crop',
        ],
      ),
      // محرم بك
      Property(
        id: '7',
        title: 'شقة سكنية بمحرم بك',
        price: 1500000,
        location: 'محرم بك - الإسكندرية',
        type: PropertyType.apartment,
        description: 'شقة مريحة في موقع حيوي بالإسكندرية',
        contactPhone: '+201001234573',
        images: [
          'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=600&h=400&fit=crop',
        ],
      ),
      // مدينة نصر
      Property(
        id: '8',
        title: 'منزل واسع بمدينة نصر',
        price: 7200000,
        location: 'مدينة نصر - القاهرة',
        type: PropertyType.house,
        description: 'منزل فسيح بحديقة واسعة وموقع مميز',
        contactPhone: '+201001234574',
        images: [
          'https://images.unsplash.com/photo-1570129477492-45a003537e1f?w=600&h=400&fit=crop',
        ],
      ),
      // التجمع الخامس
      Property(
        id: '9',
        title: 'مكتب بالتجمع الخامس',
        price: 3200000,
        location: 'التجمع الخامس - القاهرة الجديدة',
        type: PropertyType.office,
        description: 'مكتب حديث في منطقة تجارية راقية',
        contactPhone: '+201001234575',
        images: [
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop',
        ],
      ),
      // الدقي
      Property(
        id: '10',
        title: 'شقة فاخرة بالدقي',
        price: 2800000,
        location: 'الدقي - الجيزة',
        type: PropertyType.apartment,
        description: 'شقة عصرية مع كل الخدمات الحديثة',
        contactPhone: '+201001234576',
        images: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop',
        ],
      ),
      // الزمالك
      Property(
        id: '11',
        title: 'فيلا بالزمالك على النيل',
        price: 9500000,
        location: 'الزمالك - القاهرة',
        type: PropertyType.villa,
        description: 'فيلا فاخرة جداً بإطلالة مباشرة على النيل',
        contactPhone: '+201001234577',
        images: [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop',
        ],
      ),
      // الكيت كات
      Property(
        id: '12',
        title: 'شقة دوبلكس بالكيت كات',
        price: 3500000,
        location: 'الكيت كات - الجيزة',
        type: PropertyType.apartment,
        description: 'شقة دوبلكس فاخرة في موقع متميز',
        contactPhone: '+201001234578',
        images: [
          'https://images.unsplash.com/photo-1540932653986-d12d27d8acad?w=600&h=400&fit=crop',
        ],
      ),
      // مصر الجديدة
      Property(
        id: '13',
        title: 'منزل تراثي بمصر الجديدة',
        price: 6800000,
        location: 'مصر الجديدة - القاهرة',
        type: PropertyType.house,
        description: 'منزل بطراز معماري كلاسيكي جميل',
        contactPhone: '+201001234579',
        images: [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop',
        ],
      ),
      // الإمام أحمد بن طولون
      Property(
        id: '14',
        title: 'مكتب بحي الإمام أحمد بن طولون',
        price: 1600000,
        location: 'حي الإمام أحمد بن طولون - القاهرة',
        type: PropertyType.office,
        description: 'مكتب مناسب للشركات الصغيرة والمتوسطة',
        contactPhone: '+201001234580',
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop',
        ],
      ),
      // الرحاب
      Property(
        id: '15',
        title: 'فيلا بمدينة الرحاب',
        price: 5800000,
        location: 'الرحاب - القاهرة الجديدة',
        type: PropertyType.villa,
        description: 'فيلا حديثة في مجتمع عمراني متطور',
        contactPhone: '+201001234581',
        images: [
          'https://images.unsplash.com/photo-1601584942278-04be67dcb884?w=600&h=400&fit=crop',
        ],
      ),
      // بنها
      Property(
        id: '16',
        title: 'شقة سكنية ببنها',
        price: 900000,
        location: 'بنها - القليوبية',
        type: PropertyType.apartment,
        description: 'شقة اقتصادية في موقع مناسب',
        contactPhone: '+201001234582',
        images: [
          'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=600&h=400&fit=crop',
        ],
      ),
      // العاشر من رمضان
      Property(
        id: '17',
        title: 'منزل بمدينة العاشر من رمضان',
        price: 4200000,
        location: 'العاشر من رمضان - الشرقية',
        type: PropertyType.house,
        description: 'منزل عصري في منطقة صناعية واعدة',
        contactPhone: '+201001234583',
        images: [
          'https://images.unsplash.com/photo-1570129477492-45a003537e1f?w=600&h=400&fit=crop',
        ],
      ),
      // العبور
      Property(
        id: '18',
        title: 'مكتب بمدينة العبور',
        price: 2100000,
        location: 'العبور - القليوبية',
        type: PropertyType.office,
        description: 'مكتب حديث بتكييف مركزي',
        contactPhone: '+201001234584',
        images: [
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop',
        ],
      ),
      // السادس من أكتوبر
      Property(
        id: '19',
        title: 'شقة بمدينة السادس من أكتوبر',
        price: 1400000,
        location: 'السادس من أكتوبر - الجيزة',
        type: PropertyType.apartment,
        description: 'شقة عملية في منطقة آمنة وهادئة',
        contactPhone: '+201001234585',
        images: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop',
        ],
      ),
      // المقطم
      Property(
        id: '20',
        title: 'فيلا بالمقطم',
        price: 7800000,
        location: 'المقطم - القاهرة',
        type: PropertyType.villa,
        description: 'فيلا فاخرة بإطلالات جميلة',
        contactPhone: '+201001234586',
        images: [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&h=400&fit=crop',
        ],
      ),
      // أكتوبر
      Property(
        id: '21',
        title: 'شقة سكنية بمدينة أكتوبر',
        price: 1200000,
        location: 'أكتوبر - الجيزة',
        type: PropertyType.apartment,
        description: 'شقة مريحة بأسعار معقولة',
        contactPhone: '+201001234587',
        images: [
          'https://images.unsplash.com/photo-1540932653986-d12d27d8acad?w=600&h=400&fit=crop',
        ],
      ),
      // الإسماعيلية
      Property(
        id: '22',
        title: 'منزل بالإسماعيلية',
        price: 3800000,
        location: 'الإسماعيلية',
        type: PropertyType.house,
        description: 'منزل مريح بموقع استراتيجي',
        contactPhone: '+201001234588',
        images: [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop',
        ],
      ),
      // السويس
      Property(
        id: '23',
        title: 'شقة بالسويس',
        price: 850000,
        location: 'السويس',
        type: PropertyType.apartment,
        description: 'شقة اقتصادية في منطقة سكنية',
        contactPhone: '+201001234589',
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop',
        ],
      ),
      // بورسعيد
      Property(
        id: '24',
        title: 'فيلا ببورسعيد',
        price: 4800000,
        location: 'بورسعيد',
        type: PropertyType.villa,
        description: 'فيلا جميلة في منطقة ساحلية',
        contactPhone: '+201001234590',
        images: [
          'https://images.unsplash.com/photo-1601584942278-04be67dcb884?w=600&h=400&fit=crop',
        ],
      ),
      // الغردقة
      Property(
        id: '25',
        title: 'شقة بالغردقة بإطلالة بحرية',
        price: 2200000,
        location: 'الغردقة - البحر الأحمر',
        type: PropertyType.apartment,
        description: 'شقة سياحية بإطلالة على البحر الأحمر',
        contactPhone: '+201001234591',
        images: [
          'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=600&h=400&fit=crop',
        ],
      ),
      // شرم الشيخ
      Property(
        id: '26',
        title: 'فيلا فاخرة بشرم الشيخ',
        price: 9200000,
        location: 'شرم الشيخ - جنوب سيناء',
        type: PropertyType.villa,
        description: 'فيلا سياحية فاخرة جداً',
        contactPhone: '+201001234592',
        images: [
          'https://images.unsplash.com/photo-1570129477492-45a003537e1f?w=600&h=400&fit=crop',
        ],
      ),
      // الأقصر
      Property(
        id: '27',
        title: 'منزل بالأقصر',
        price: 2600000,
        location: 'الأقصر',
        type: PropertyType.house,
        description: 'منزل تراثي جميل بالمدينة التاريخية',
        contactPhone: '+201001234593',
        images: [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop',
        ],
      ),
      // أسوان
      Property(
        id: '28',
        title: 'شقة بأسوان بإطلالة على النيل',
        price: 1900000,
        location: 'أسوان',
        type: PropertyType.apartment,
        description: 'شقة جميلة بإطلالة على نيل أسوان',
        contactPhone: '+201001234594',
        images: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop',
        ],
      ),
      // الفيوم
      Property(
        id: '29',
        title: 'مكتب بالفيوم',
        price: 950000,
        location: 'الفيوم',
        type: PropertyType.office,
        description: 'مكتب صغير في منطقة تجارية',
        contactPhone: '+201001234595',
        images: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop',
        ],
      ),
      // بني سويف
      Property(
        id: '30',
        title: 'شقة ببني سويف',
        price: 780000,
        location: 'بني سويف',
        type: PropertyType.apartment,
        description: 'شقة سكنية محترمة بأسعار منخفضة',
        contactPhone: '+201001234596',
        images: [
          'https://images.unsplash.com/photo-1540932653986-d12d27d8acad?w=600&h=400&fit=crop',
        ],
      ),
    ];
  }
}
