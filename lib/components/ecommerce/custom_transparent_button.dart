// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';

class CustomTransparentButton extends StatelessWidget {
  final String buttonText;
  final void Function() onTap;
  final Color? buttonTextColor;
  final Color? borderColor;
  final Color? buttonColor;
  const CustomTransparentButton({
    Key? key,
    required this.buttonText,
    required this.onTap,
    this.buttonTextColor,
    this.borderColor,
    this.buttonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50.r),
      onTap: onTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.r),
          color: buttonColor,
          border: Border.all(
            color: borderColor ?? EcommerceAppColor.black,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: AppTextStyle(context).buttonText.copyWith(
                  color: buttonTextColor,
                ),
          ),
        ),
      ),
    );
  }
}
