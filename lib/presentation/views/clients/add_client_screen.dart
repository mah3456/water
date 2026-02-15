import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water/wigets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/client_model.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/profilecontroller.dart';



class AddClientScreen extends StatefulWidget {
  AddClientScreen({super.key, this.client});

  final ClientModel? client;

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final ClientsController clienthelper = Get.put(ClientsController());
  final ProfileController user = Get.put(ProfileController());

  final _formKey = GlobalKey<FormState>();


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _meterController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(!widget.client.isNull){
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _addressController.text = widget.client!.address;
      _meterController.text = widget.client!.meterNumber;
      _notesController.text = widget.client!.notes ?? '';
    }
  }

  @override
  void dispose() {
    // تنظيف المتحكمات عند التدمير
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _meterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            !widget.client.isNull ? 'تحديث بيانات عميل' : 'إضافة عميل جديد'
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _TextFormField(
                    controller: _nameController,
                    inputType: TextInputType.text,
                    lines: 1,
                    label: 'اسم العميل',
                    icon: Icon(Icons.person),
                    validiting: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم العميل';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  _TextFormField(
                    controller: _phoneController,
                    lines: 1,
                    label: 'رقم الهاتف',
                    icon: Icon(Icons.phone),
                    inputType: TextInputType.phone,
                    validiting: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  _TextFormField(
                    controller: _addressController,
                    inputType: TextInputType.text,
                    label: 'العنوان',
                    icon: Icon(Icons.location_on),
                    lines: 1,
                    validiting: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال العنوان';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  _TextFormField(
                    controller: _meterController,
                    inputType: TextInputType.number,
                    lines: 1,
                    label: 'رقم العداد',
                    icon: Icon(Icons.confirmation_number),
                    validiting: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم العداد';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  _TextFormField(
                    controller: _notesController,
                    lines: 2,
                    inputType: TextInputType.text,
                    label: 'ملاحظات (اختياري)',
                    icon: Icon(Icons.note),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: clienthelper.isLoading.value ? null : () => _submitForm(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.systemBlue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            // تعطيل الزر أثناء التحميل
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: clienthelper.isLoading.value
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                !widget.client.isNull ? 'جاري التحديث...' : 'جاري الإضافة...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                              : Text(
                            'حفظ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // مؤشر التحميل الذي يغطي الشاشة
          if (clienthelper.isLoading.value)
           LoadingWidget()
        ],
      ),
    );
  }

  Widget _TextFormField({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    FormFieldValidator<String>? validiting,
    required TextInputType inputType,
    required int lines,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon,
        border: const OutlineInputBorder(),
      ),
      maxLines: lines,
      keyboardType: inputType,
      validator: validiting,
      enabled: !clienthelper.isLoading.value, // تعطيل الحقول أثناء التحميل
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }


    if (widget.client == null) {
      // إضافة عميل جديد
      final client = ClientModel(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        meterNumber: _meterController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        createdBy: user.supabase.auth.currentUser!.id,
      );

      final success = await clienthelper.addClient(client: client);

      if (success) {
        // تحديث البيانات
        clienthelper.loadClients();
        clienthelper.getAllClients();

        // تنظيف الحقول
        _nameController.clear();
        _phoneController.clear();
        _addressController.clear();
        _meterController.clear();
        _notesController.clear();

        Helpers.customSnackBar(
          title: 'نجاح',
          message: 'تم إضافة العميل بنجاح',
          background: CupertinoColors.systemGreen,
        );

      } else {
        Helpers.customSnackBar(
          title: 'خطأ',
          message: 'فشل إضافة العميل',
          background: CupertinoColors.systemRed,
        );
      }
    } else {
      // تحديث بيانات العميل
      final client = ClientModel(
        id: widget.client!.id,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        currentBill: widget.client!.currentBill,
        totalDebt: widget.client!.totalDebt,
        meterNumber: _meterController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: widget.client!.createdAt,
        createdBy: user.supabase.auth.currentUser!.id,
      );

      // TODO: استبدل هذا بدالة التحديث الحقيقية
      final success = await clienthelper.updateClient(client: client);

      if (success) {
        clienthelper.loadClients();
        clienthelper.getAllClients();

        Helpers.customSnackBar(
          title: 'نجاح',
          message: 'تم تحديث بيانات العميل',
          background: CupertinoColors.systemGreen,
        );

        // العودة للشاشة السابقة بعد نجاح العملية
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pop();
        });
      } else {
        Helpers.customSnackBar(
          title: 'خطأ',
          message: 'فشل تحديث بيانات العميل',
          background: CupertinoColors.systemRed,
        );
      }
    }
  }

}