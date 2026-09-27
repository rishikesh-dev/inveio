import 'package:flutter/material.dart';

/// Returns a [SliverToBoxAdapter] wrapping a [SizedBox] with the given [height].
SliverToBoxAdapter kHeight([double height = 10]) =>
    SliverToBoxAdapter(child: SizedBox(height: height));

/// Returns a [SliverToBoxAdapter] wrapping a [SizedBox] with the given [width].
SliverToBoxAdapter kWidth([double width = 10]) =>
    SliverToBoxAdapter(child: SizedBox(width: width));
