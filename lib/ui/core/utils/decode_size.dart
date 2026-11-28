import 'package:flutter/widgets.dart';

int decodeWidth(BuildContext context, double logicalWidth) =>
    (logicalWidth * MediaQuery.devicePixelRatioOf(context)).round();
