enum FriendRequestStatus {
  none,
  pending,
  accepted,
  rejected,
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

// Move fromString method to the enum
extension FriendRequestStatusParser on String {
  FriendRequestStatus toFriendRequestStatus() {
    switch (this) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.none;
    }
  }
}
