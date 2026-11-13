import 'package:flutter/material.dart';

class ClearHistoryTextFieldWidget extends StatelessWidget {
  const ClearHistoryTextFieldWidget({super.key, this.controller});
  final TextEditingController? controller;
  
  @override
Widget build(BuildContext context) {    
   return TextField(autofocus: true, controller: controller);}}
