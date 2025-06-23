import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/animate_image.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_button.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_text_field.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/gen/assets.gen.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';
import 'package:ready_ecommerce/views/common/authentication/layouts/confirm_otp_layout.dart';

class RecoverPasswordLayout extends StatefulWidget {
  const RecoverPasswordLayout({super.key});

  @override
  State<RecoverPasswordLayout> createState() => _RecoverPasswordLayoutState();
}

class _RecoverPasswordLayoutState extends State<RecoverPasswordLayout> {
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedImage(
                          imageSize: 100.w,
                          imageWidget: SvgPicture.asset(
                            Assets.svg.recoverpPassword,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Gap(30.h),
                        Text(
                          S.of(context).recoverPassword,
                          style: AppTextStyle(context)
                              .title
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Gap(16.h),
                        Text(
                          S.of(context).recoverPassDes,
                          textAlign: TextAlign.center,
                          style: AppTextStyle(context).bodyText.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Gap(40.h),
                        CustomTextFormField(
                          name: S.of(context).phoneNumber,
                          hintText: S.of(context).enterPhoneNum,
                          textInputType: TextInputType.phone,
                          controller: phoneController,
                          textInputAction: TextInputAction.done,
                          validator: (value) => GlobalFunction.phoneValidator(
                            value: value!,
                            hintText: S.of(context).phoneNumber,
                            context: context,
                          ),
                        ),
                        Gap(30.h),
                        CustomButton(
                          buttonText: S.of(context).sendOtp,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.nav.pushNamed(
                                Routes.confirmOTP,
                                arguments: ConfirmOTPScreenArguments(
                                  phoneNumber: phoneController.text,
                                  isPasswordRecover: true,
                                ),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 26.h,
              left: 16.w,
              child: IconButton(
                onPressed: () {
                  context.nav.pop();
                },
                icon: Icon(
                  Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
