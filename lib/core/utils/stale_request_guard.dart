/// Issues monotonically increasing request tokens to prevent stale async work
/// from updating state after a newer request has started.
class StaleRequestGuard {
  int _latestRequestId = 0;

  /// Starts a request and returns its token.
  int beginRequest() => ++_latestRequestId;

  /// Whether [requestId] belongs to the most recently started request.
  bool isCurrent(int requestId) => requestId == _latestRequestId;
}
