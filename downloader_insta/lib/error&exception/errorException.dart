class errorException{
  static String exceptionFreeApiInsta = "{message: Please wait a few minutes before you try again., require_login: true, status: fail}";
  //{data: , status: error, message: media is not available}

  bool checkException(String exceptionError){
    switch (exceptionError) {
      case "{message: Please wait a few minutes before you try again., require_login: true, status: fail}":
        return true;
      case "{data: , status: error, message: media is not available}":
        return true;
      case "400 - {\"message\":\"Invalid media_id 66779100467636804090936879558432512686167743866\",\"status\":\"fail\"}":
        return true;
      case "{\"data\":\"\",\"status\":\"error\",\"message\":\"media is not available\"}":
        return true;
        //
      default:
        return false;
    }
  }
}