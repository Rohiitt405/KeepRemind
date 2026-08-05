class GithubConstants {
  const GithubConstants._();

  static const owner = "Rohiitt405";
  static const repository = "KeepRemind";

  static String get latestReleaseApi =>
      "https://api.github.com/repos/$owner/$repository/releases/latest";
}
