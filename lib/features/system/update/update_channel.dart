enum UpdateChannel {
  gitee,
  appstore;

  static UpdateChannel fromEnvironment() {
    const channel = String.fromEnvironment(
      'UPDATE_CHANNEL',
      defaultValue: 'gitee',
    );

    switch (channel.toLowerCase()) {
      case 'appstore':
        return UpdateChannel.appstore;
      case 'gitee':
      default:
        return UpdateChannel.gitee;
    }
  }
}

enum UpdatePlan {
  stable,
  beta;

  bool get includesBeta => this == UpdatePlan.beta;
}
