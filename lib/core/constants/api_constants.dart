// Constantes de API — SoftwArt Mobile
class ApiConstants {
 
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://softwart-backend.onrender.com/api',
  );


  // Auth
  static const String login = '/auth/login';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Appointments
  static const String appointments = '/appointments';
  static String changeAppointmentStatus(int id) =>
      '/appointment-status/cita/$id/estado';

  // Sale Details (services/orders)
  static const String saleDetails = '/sale-details';
  static const String serviceStatus = '/service-status';
  static String changeSaleDetailStatus(int id) =>
      '/service-status/detalle/$id/estado';

  // Sales
  static const String sales = '/sales';
  static String paymentPlan(int id) => '/sales/$id/payment-plan';

  // Clients
  static const String clients = '/clients';

  // Payments
  static const String payments = '/payments';
  static String changePaymentStatus(int id) => '/payment-status/pago/$id/estado';
}
