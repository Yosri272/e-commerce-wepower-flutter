import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/common/master_controller.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/models/eCommerce/order/order_details_model.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';

class OrderDetailsCard extends ConsumerStatefulWidget {
  final OrderDetails orderDetails;
  const OrderDetailsCard({
    super.key,
    required this.orderDetails,
  });

  @override
  ConsumerState<OrderDetailsCard> createState() => _OrderDetailsCardState();
}

class _OrderDetailsCardState extends ConsumerState<OrderDetailsCard> {
  static final isFileExists = StateProvider<bool>((ref) => false);
  static final isloading = StateProvider<bool>((ref) => false);
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _init();
    _portListener();
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  Future<void> _init() async {
    final file = await _checkFileExists();
    ref.read(isFileExists.notifier).state = file != null;
  }

  _portListener() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      int status = data[1];
      int process = data[2];
      if (status == DownloadTaskStatus.complete.index) {
        ref.read(isFileExists.notifier).state = true;
      } else if (status == DownloadTaskStatus.failed.index) {
        GlobalFunction.showCustomSnackbar(
            message: 'Something went wrong!', isSuccess: false);
      }
      if (process == 100) {
        ref.read(isloading.notifier).state = false;
      }
    });
  }

  Future<String?> _checkFileExists() async {
    final saveDir = await _getDownloadDirectory();
    final fileName = 'invoice-${widget.orderDetails.data.order.orderCode}.pdf';
    final filePath = '$saveDir/$fileName';
    final file = File(filePath);

    return await file.exists() ? filePath : null;
  }

  Future<String?> _getDownloadDirectory() async {
    Directory? appDocDir;

    if (Platform.isAndroid) {
      appDocDir = Directory('/storage/emulated/0/Download');
      if (!await appDocDir.exists()) {
        appDocDir = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      appDocDir = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    return appDocDir?.path;
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
  }

  Future<void> _downloadFile() async {
    await _requestPermission();
    final url = '${widget.orderDetails.data.order.invoiceUrl}';
    final saveDir = await _getDownloadDirectory();
    final fileName = 'invoice-${widget.orderDetails.data.order.orderCode}.pdf';
    final filePath = await _checkFileExists();

    if (filePath == null) {
      ref.read(isloading.notifier).state = true;
      FlutterDownloader.enqueue(
        url: url,
        savedDir: saveDir!,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      OpenFile.open(filePath);
    }
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GlobalFunction.getContainerColor(),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildRowWidget(
            context: context,
            key: S.of(context).orderStatus,
            value: widget.orderDetails.data.order.orderStatus,
            isOrderStatus: true,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).orderId,
            value: widget.orderDetails.data.order.orderCode,
          ),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).orderDate,
            value: DateFormat('d MMMM y', 'en_US').format(
                DateTime.parse(widget.orderDetails.data.order.createdAt)),
          ),
          Gap(14.h),
          _buildPaymentMethodRow(),
          Gap(14.h),
          _buildRowWidget(
            context: context,
            key: S.of(context).totalAmount,
            value: GlobalFunction.price(
              currency: ref
                  .read(masterControllerProvider.notifier)
                  .materModel
                  .data
                  .currency
                  .symbol,
              position: ref
                  .read(masterControllerProvider.notifier)
                  .materModel
                  .data
                  .currency
                  .position,
              price: widget.orderDetails.data.order.payableAmount.toString(),
            ),
            isAmount: false,
          ),
          Gap(14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(''),
              ref.watch(isloading)
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () => _downloadFile(),
                      child: Row(
                        children: [
                          Icon(
                            ref.watch(isFileExists)
                                ? Icons.open_in_new
                                : Icons.cloud_download,
                            color: EcommerceAppColor.gray,
                            size: 18.sp,
                          ),
                          Gap(5.w),
                          Text(
                            ref.watch(isFileExists)
                                ? 'Open Invoice '
                                : S.of(context).downloadInvoice,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                fontSize: 12.sp,
                                color: colors(context).primaryColor),
                          )
                        ],
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRowWidget({
    required BuildContext context,
    required String key,
    required dynamic value,
    bool isAmount = false,
    bool isOrderStatus = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: AppTextStyle(context).bodyTextSmall,
        ),
        if (isOrderStatus) ...[
          GlobalFunction.getStatusWidget(context: context, status: value)
        ] else ...[
          Consumer(builder: (context, ref, _) {
            return Text(
              isAmount
                  ? '${ref.read(masterControllerProvider.notifier).materModel.data.currency.symbol}$value'
                  : value.toString(),
              style: AppTextStyle(context).bodyText,
            );
          }),
        ]
      ],
    );
  }

  Widget _buildPaymentMethodRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(ContextLess.context).paymentMethod,
          style: AppTextStyle(ContextLess.context).bodyTextSmall,
        ),
        if (widget.orderDetails.data.order.paymentMethod == 'Cash Payment') ...[
          Text(
            widget.orderDetails.data.order.paymentMethod,
            style: AppTextStyle(ContextLess.context).bodyText,
          ),
        ] else
          Row(
            children: [
              Text(
                widget.orderDetails.data.order.paymentMethod,
                style: AppTextStyle(ContextLess.context).bodyText,
              ),
              Gap(4.w),
              _buildPaymentStatusWidget(),
            ],
          ),
      ],
    );
  }

  Widget _buildPaymentStatusWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: widget.orderDetails.data.order.paymentStatus == 'Pending'
            ? EcommerceAppColor.carrotOrange
            : EcommerceAppColor.green,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Center(
        child: Text(
          widget.orderDetails.data.order.paymentStatus.toUpperCase()[0] +
              widget.orderDetails.data.order.paymentStatus.substring(1),
          style: AppTextStyle(ContextLess.context)
              .bodyText
              .copyWith(fontSize: 12.sp, color: EcommerceAppColor.white),
        ),
      ),
    );
  }

  @pragma("vm:entry-point")
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }
}
