import 'package:gocv/apis/api.dart';
import 'package:gocv/providers/UserDataProvider.dart';
import 'package:gocv/utils/urls.dart';

class EducationRepository {
  // Method to get the access token from UserProvider
  String getAccessToken() {
    return UserProvider().tokens['access'];
  }

  getEducations(String resumeId) {
    final String accessToken = getAccessToken();
    final String url = '${URLS.kEducationUrl}$resumeId/list/';

    APIService().sendGetRequest(accessToken, url).then((data) async {});
  }
}
