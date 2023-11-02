import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homofix_expert/Custom_Widget/custom_medium_button.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyRezorPey extends StatefulWidget {
  final String expertId;
  const MyRezorPey({
    Key? key,
    required this.expertId,
  }) : super(key: key);

  @override
  _MyRezorPeyState createState() => _MyRezorPeyState();
}

class _MyRezorPeyState extends State<MyRezorPey> {
  bool isLoading = true;
  List<dynamic> _technicianDataList = [];
  late Timer timer;
  Future<void> _fetchTechnicianDataList() async {
    final url =
        'https://support.homofixcompany.com/api/RechargeHistory/GET/?technician_id=${widget.expertId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      _technicianDataList = parsed['data'];
    } else {
      // Handle error
    }
    setState(() {
      isLoading = false;
    });
  }

  late Razorpay _razorpay;
  TextEditingController _controller = TextEditingController();
  String? _paymentId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   _fetchTechnicianDataList();
    // });
    _fetchTechnicianDataList();
    // _controller.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
    _controller.dispose();
  }

  void openCheckout() async {
    final amountText = _controller.text.trim();
    if (amountText.isEmpty) {
      // Display an error message and return.
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      // Display an error message and return.
      return;
    }

    var options = {
      'key': 'rzp_live_fmTFhASzIlY2uL',
      'amount': (amount * 100).toInt(),
      'name': 'Homofix Company',
      'description': 'Expert Recharge',
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final url = 'https://support.homofixcompany.com/api/RechargeHistory/Post/';
    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    final data = {
      'technician_id': widget.expertId,
      'payment_id': response.paymentId,
      'amount': _controller.text,
      "status": 'success',
    };
    print('--------------Hello--------');
    print(_paymentId);
    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        // Payment data successfully posted to the API
        debugPrint('Payment data successfully posted to the API');
      } else {
        debugPrint(
            'Error posting payment data to the API: ${response.statusCode}');
      }
    } catch (e) {
      // Exception while posting payment data to the API
      debugPrint('Exception while posting payment data to the API: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Error: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Payment Gateway".toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(
                FontAwesomeIcons.qrcode,
                size: 35,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset('assets/qrScanner.jpg'),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      body: (isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Enter Amount',
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(color: Color(4288914861), fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(10.0),
                        elevation: 0,
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: _controller,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              hintStyle: TextStyle(
                                color: Color(4288914861),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14.0),
                              prefixIcon: Icon(
                                FontAwesomeIcons.indianRupee,
                                color: Color(4288914861),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  //  Text(
                  //   'Enter amount:',
                  //   style: customSmallTextStyle,
                  // ),
                  // TextField(
                  //   controller: _controller,
                  //   keyboardType:
                  //       TextInputType.numberWithOptions(decimal: true),
                  //   decoration: InputDecoration(
                  //     hintText: '\u20B9',
                  //   ),
                  // ),
                  SizedBox(height: 16.0),
                  CustomContainerMediamButton(
                      buttonText: 'Recharge Now',
                      onTap: () {
                        openCheckout();
                      }),
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    elevation: 0,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F0FD),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Recharge History ".toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff002790),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        //   height: MediaQuery.of(context).size.height - 200,
                        child: ListView.builder(
                          reverse: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _technicianDataList.length,
                          itemBuilder: (context, index) {
                            final technicianData = _technicianDataList[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Card(
                                elevation: 0,
                                child: ListTile(
                                  title: Text(
                                    '${technicianData['payment_id'] ?? ''}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${technicianData['date'] ?? ''}',
                                    style: customSmallTextStyle,
                                  ),
                                  trailing: Wrap(
                                    direction: Axis.vertical,
                                    children: [
                                      Text(
                                        '\u20B9 ${technicianData['amount'] ?? ''}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${technicianData['status'] ?? ''}',
                                        style: customSmallTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
    );
  }
}
