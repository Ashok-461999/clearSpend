import '../models/sip_installment.dart';

abstract class SipInstallmentRepository {
  Future<int> save(SipInstallment installment);
  Future<void> delete(int id);
  Future<List<SipInstallment>> getForInvestment(int investmentId);
  Stream<List<SipInstallment>> watchForInvestment(int investmentId);
}
