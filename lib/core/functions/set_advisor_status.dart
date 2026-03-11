import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/core/shared/network/local_network.dart';

AdvisorStatus? setAdvisorStatus(String? key) {
  switch (key) {
    case 'PENDING':
      advisorStatus = AdvisorStatus.pending;
    case 'APPROVED':
      advisorStatus = AdvisorStatus.approved;
    case 'DISAPPROVED':
      advisorStatus = AdvisorStatus.disapproved;
    default:
      advisorStatus = null;
  }
  CachNetwork.setData(key: kAdvisorStatus, value: advisorStatus?.name ?? '');
  return advisorStatus;
}
