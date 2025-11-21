import 'package:flutter/material.dart';

/// Breakpoints para diseño responsive
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Enum para tipos de dispositivo
enum DeviceType { mobile, tablet, desktop }

/// Builder responsive que adapta el layout según el tamaño de pantalla
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({super.key, required this.builder})
    : mobile = null,
      tablet = null,
      desktop = null;

  const ResponsiveBuilder.custom({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : builder = _defaultBuilder;

  static Widget _defaultBuilder(BuildContext context, DeviceType type) {
    throw UnimplementedError();
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  @override
  Widget build(BuildContext context) {
    if (mobile != null || tablet != null || desktop != null) {
      final deviceType = getDeviceType(context);
      switch (deviceType) {
        case DeviceType.desktop:
          return desktop ?? tablet ?? mobile!;
        case DeviceType.tablet:
          return tablet ?? mobile!;
        case DeviceType.mobile:
          return mobile!;
      }
    }

    return builder(context, getDeviceType(context));
  }
}

/// Widget para obtener valores responsive
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  T getValue(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// Extension para facilitar el uso de valores responsive
extension ResponsiveExtension on BuildContext {
  DeviceType get deviceType => ResponsiveBuilder.getDeviceType(this);
  bool get isMobile => ResponsiveBuilder.isMobile(this);
  bool get isTablet => ResponsiveBuilder.isTablet(this);
  bool get isDesktop => ResponsiveBuilder.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Widget para grid responsive
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  int _getColumns(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.mobile:
        return mobileColumns;
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = _getColumns(context);

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: 1,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Padding responsive
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  EdgeInsets _getPadding(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? const EdgeInsets.all(24);
      case DeviceType.tablet:
        return tablet ?? mobile ?? const EdgeInsets.all(16);
      case DeviceType.mobile:
        return mobile ?? const EdgeInsets.all(8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: _getPadding(context), child: child);
  }
}

/// Container con ancho máximo para desktop
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Configuración de texto responsive
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  double _getFontSize(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktopFontSize ?? tabletFontSize ?? mobileFontSize ?? 16;
      case DeviceType.tablet:
        return tabletFontSize ?? mobileFontSize ?? 14;
      case DeviceType.mobile:
        return mobileFontSize ?? 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = _getFontSize(context);

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
