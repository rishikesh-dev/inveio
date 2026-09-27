import 'package:flutter/material.dart';

extension SliverExtension on Widget {
  Padding withPadding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  SliverToBoxAdapter toSliver() {
    return SliverToBoxAdapter(child: this);
  }

  Center center() {
    return Center(child: this);
  }

  Align align(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }

  SizedBox sized({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }

  Expanded expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  Flexible flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }
}
