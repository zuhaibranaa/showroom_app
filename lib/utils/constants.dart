class AppConstants {
  // App Info
  static const String appName = 'Showroom';
  
  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String vehiclesRoute = '/vehicles';
  static const String vehicleDetailRoute = '/vehicles/:id';
  static const String addVehicleRoute = '/vehicles/add';
  static const String salesRoute = '/sales';
  static const String saleDetailRoute = '/sales/:id';
  static const String addSaleRoute = '/sales/add';
  static const String dealersRoute = '/dealers';
  static const String dealerDetailRoute = '/dealers/:id';
  static const String addDealerRoute = '/dealers/add';
  static const String profileRoute = '/profile';

  // Messages
  static const String loadingMessage = 'Loading...';
  static const String errorMessage = 'An error occurred';
  static const String successMessage = 'Operation successful';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
}
