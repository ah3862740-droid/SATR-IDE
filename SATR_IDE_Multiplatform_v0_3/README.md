# SATR IDE 0.3 — Multi-platform starter

هذا مشروع Flutter متعدد المنصات كبداية فعلية لبيئة تطوير SATR، وليس موقعًا. يتضمن واجهة IDE، محررًا، نافذة نتيجة، واجهة طرفية تفاعلية، صفحة تعليم، ومساحة مشاريع أولية.

## المنصات المستهدفة
Android, iOS, Windows, macOS, Linux. أنشئ ملفات المنصات بواسطة Flutter SDK على جهاز التطوير (`flutter create .`) ثم ابنِ المنصة المطلوبة.

## المتطلبات
- Flutter stable حديث (Dart 3.4+)
- Android Studio / Xcode حسب المنصة
- Windows: Visual Studio مع Desktop C++ workload
- Linux: حزم GTK development المطلوبة من Flutter

## التشغيل
```bash
flutter create --platforms=android,ios,windows,macos,linux .
flutter pub get
flutter run
```

## بناء
```bash
flutter build apk
flutter build appbundle
flutter build ios
flutter build windows
flutter build macos
flutter build linux
```
بناء iOS يحتاج macOS وXcode. بناء Windows يحتاج Windows. لا يمكن بناء كل الأنظمة من هاتف Android واحد.

## الحالة والحدود بوضوح
- هذا scaffold قابل للتطوير وليس إصدارًا نهائيًا أو ملفات تثبيت جاهزة.
- محرر النصوص يعمل، لكن تلوين syntax والإكمال التلقائي وملف explorer الحقيقي وحفظ/فتح الملفات عبر منتقي النظام ما زالت مراحل لاحقة.
- لوحة الطرفية الحالية تستخدم xterm لعرض الطرفية والتفاعل معها؛ ليست بعد shell نظام حقيقي. تشغيل shell أصلي سيضاف عبر adapters: Process على desktop، ومحدود/اختياري على Android، ولا يوجد shell عام على iOS بسبب قيود النظام.
- مفسر HAKEM المضمّن prototype صغير يدعم اطبع وخلي وكرر البسيط فقط. يجب دمج المحرك المرجعي واختبارات اللغة قبل ادعاء التوافق الكامل.
- لا تنفذ أوامر طرفية عشوائية بصلاحيات مرتفعة. التصميم النهائي يجب أن يستخدم مساحة عمل محددة وصلاحيات واضحة.
