enum FriendRequestStatus {
  none,
  pending,
  accepted,
  rejected
}

extension FriendRequestStatusExtension on FriendRequestStatus {
  String toText() {
    switch (this) {
      case FriendRequestStatus.none:
        return 'Add Friend';
      case FriendRequestStatus.pending:
        return 'Request Sent';
      case FriendRequestStatus.accepted:
        return 'Friends';
      case FriendRequestStatus.rejected:
        return 'Add Friend';
    }
  }
}
