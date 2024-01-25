class HelperGetItems{

  bool checkPatternDownloader(String patternDownloaderUrl){
    switch (patternDownloaderUrl) {
      case "scontent-bog1-1.cdninstagram.com":
        return true;
      case "scontent":
        return true;
      case "cdninstagram":
        return true;
      case "instagram.fccs3-1.fna.fbcdn.net":
        return true;
      case "fna.fbcdn.net":
        return true;
      default:
        return false;
    }
  }
}