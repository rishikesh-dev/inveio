import 'package:inveio/shared/presentation/widgets/gstin_text_field_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.gstController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController gstController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldWidget(
            controller: nameController,
            hintText: 'Enter your name',
            textFieldLabel: 'Name',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 10),

          TextFieldWidget(
            controller: emailController,
            hintText: 'Email',
            textFieldLabel: 'Email',
            enabled: false,
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 4),

          Text(
            'Contact support to change your email',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),

          const SizedBox(height: 10),

          GstinTextField(
            controller: gstController,
            hintText: 'Enter your GSTIN',
            textFieldLabel: 'GST Number',
            validator: GstinTextField.requiredValidator,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
