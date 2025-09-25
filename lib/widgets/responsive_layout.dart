import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? webLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.webLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si on est sur web et qu'on a un layout web spécifique
        if (kIsWeb && webLayout != null) {
          return webLayout!;
        }

        // Sinon, on utilise les breakpoints standard
        if (constraints.maxWidth > 1200) {
          return webLayout ?? tabletLayout ?? mobileLayout;
        } else if (constraints.maxWidth > 800) {
          return tabletLayout ?? mobileLayout;
        } else {
          return mobileLayout;
        }
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio = 0.7,
    this.padding,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;

        // Adapter le nombre de colonnes selon la largeur d'écran
        if (constraints.maxWidth > 1400) {
          crossAxisCount = 6; // Très large écran
        } else if (constraints.maxWidth > 1200) {
          crossAxisCount = 5; // Large écran
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4; // Écran moyen
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3; // Tablette
        } else {
          crossAxisCount = 2; // Mobile
        }

        return GridView.builder(
          padding: padding ?? const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: child,
      ),
    );
  }
}
