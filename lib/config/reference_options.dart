/// Field choices for vehicle reference data.
class ReferenceOptions {
  static const makes = ['Honda', 'Other', 'Road Prince', 'Suzuki', 'United', 'Yamaha'];
  static const modelsByMake = <String, List<String>>{
    'Honda': ['CB125F', 'CB150F', 'CD70', 'CD70 Dream', 'CG125', 'CG125S', 'CG125S GOLD', 'CG150', 'ICON-e', 'Other', 'Pridor'],
    'Suzuki': ['GD110S', 'GR150', 'GS150', 'Other', 'Suzuki 110'],
    'United': ['Other', 'US100', 'US125', 'US70'],
    'Yamaha': ['Other', 'YBR125', 'YBR125G'],
    'Road Prince': ['Other', 'RP100', 'RP125', 'RP70'],
    'Other': ['Other'],
  };
  static const colors = ['Black', 'Blue', 'Green', 'Other', 'Red', 'Silver', 'White'];
  static const cities = ['Gujranwala', 'Islamabad', 'Lahore', 'Other', 'Punjab', 'Sialkot'];
  static final years = List.generate(28, (i) => 2027 - i);
  static const bikeExpenseCategories = ['Challan', 'Commission', 'Other', 'Paint', 'Spare parts', 'Token tax', 'Transfer fee', 'Transport'];
  static const showroomExpenseCategories = ['Electricity', 'Internet', 'Other', 'Salaries', 'Shop rent', 'Tea and misc.'];
  static const newChecklist = ['Invoice', 'Original file'];
  static const usedChecklist = ['Original file', 'Seller CNIC copy', 'Card'];
  static const documentStatuses = <String, String>{'APPLIED':'Applied','PENDING':'Pending','RECEIVED':'Received','DUPLICATE':'Duplicate'};
  static const registrationStatuses = <String,String>{'NOT_APPLIED':'Not applied','APPLIED':'Applied for','SUBMITTED_EXCISE':'Submitted in Excise','COMPLETED':'Completed'};
  static const challanStatuses = <String,String>{'NOT_CHECKED':'Not checked','NO_CHALLAN':'No challan','PENDING':'Pending','CLEARED':'Cleared'};
  static const biometricStatuses = <String,String>{'NOT_REQUIRED':'Not required','PENDING':'Pending','DONE':'Done'};
  static const paymentModes = <String,String>{'CASH':'Cash','BANK':'Bank','ONLINE':'Online','CHEQUE':'Cheque'};
  static const banks = ['UBL', 'MCB', 'BOP', 'BAHL'];
  static String label(Map<String,String> options, String? value) => options[value] ?? value ?? '—';
}
