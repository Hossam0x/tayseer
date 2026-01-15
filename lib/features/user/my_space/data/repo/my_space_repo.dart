import 'package:dartz/dartz.dart';

import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/my_import.dart';

class MySpaceRepo {
  final ApiService apiService;
  MySpaceRepo(this.apiService);

  Future<Either<Failure, AdvisorChatModel>> getadvisorchat() async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.advisorUserChat,
      );
      return Right(AdvisorChatModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
