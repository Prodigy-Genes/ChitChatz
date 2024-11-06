import 'package:chatapp/services/friend_request_status.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/model/notification.dart';
import 'package:chatapp/features/notification_helper.dart';
import 'package:chatapp/services/friend_request_service.dart';

class CollaborativeNotificationItem extends StatefulWidget {
  final NotificationModel notification;

  const CollaborativeNotificationItem({super.key, required this.notification});

  @override
  _CollaborativeNotificationItemState createState() => _CollaborativeNotificationItemState();
}

class _CollaborativeNotificationItemState extends State<CollaborativeNotificationItem> {
  final FriendRequestService _friendRequestService = FriendRequestService();
  FriendRequestStatus _friendRequestStatus = FriendRequestStatus.none;

  @override
  void initState() {
    super.initState();
    _checkFriendRequestStatus();
  }

  Future<void> _checkFriendRequestStatus() async {
    final targetUserId = widget.notification.senderId;
    final status = await _friendRequestService.checkFriendRequestStatus(targetUserId);
    setState(() {
      _friendRequestStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.notification.message,
                    style: TextStyle(
                      fontFamily: 'Kavivanar',
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: _friendRequestStatus == FriendRequestStatus.accepted || _friendRequestStatus == FriendRequestStatus.rejected ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
                if (_friendRequestStatus == FriendRequestStatus.accepted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Accepted',
                      style: TextStyle(
                        fontFamily: 'Kavivanar',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (_friendRequestStatus == FriendRequestStatus.rejected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Rejected',
                      style: TextStyle(
                        fontFamily: 'Kavivanar',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '${NotificationHelper.getNotificationTypeText(widget.notification.type)} • '
              '${NotificationHelper.formatTimestamp(widget.notification.timestamp)}',
              style: TextStyle(
                fontFamily: 'Kavivanar',
                color: Colors.grey[600],
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: NotificationHelper.getNotificationColor(widget.notification.type),
              child: Icon(
                NotificationHelper.getNotificationIcon(widget.notification.type),
                color: Colors.white,
              ),
            ),
            trailing: _buildTrailing(context),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Accept button
              if (_friendRequestStatus == FriendRequestStatus.pending)
                ElevatedButton(
                  onPressed: () {
                    NotificationHelper.handleNotificationAction(context, widget.notification, 'accept');
                    _friendRequestService.addFriend(widget.notification.senderId, widget.notification.receiverId);
                    setState(() {
                      _friendRequestStatus = FriendRequestStatus.accepted;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      fontFamily: 'Kavivanar',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              // Reject button
              if (_friendRequestStatus == FriendRequestStatus.pending)
                ElevatedButton(
                  onPressed: () {
                    NotificationHelper.handleNotificationAction(context, widget.notification, 'reject');
                    _friendRequestService.rejectFriendRequest(widget.notification.senderId, widget.notification.receiverId);
                    setState(() {
                      _friendRequestStatus = FriendRequestStatus.rejected;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      fontFamily: 'Kavivanar',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.notification.status == 'unread' && _friendRequestStatus != FriendRequestStatus.accepted && _friendRequestStatus != FriendRequestStatus.rejected)
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            NotificationHelper.handleNotificationAction(context, widget.notification, value);
            if (value == 'mark_read') {
              setState(() {
                _friendRequestStatus = FriendRequestStatus.accepted;
              });
            } else if (value == 'mark_unread') {
              setState(() {
                _friendRequestStatus = FriendRequestStatus.pending;
              });
            } else if (value == 'delete') {
              setState(() {
                _friendRequestStatus = FriendRequestStatus.none;
              });
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: widget.notification.status == 'unread' && _friendRequestStatus != FriendRequestStatus.accepted && _friendRequestStatus != FriendRequestStatus.rejected ? 'mark_read' : 'mark_unread',
              child: Text(
                widget.notification.status == 'unread' && _friendRequestStatus != FriendRequestStatus.accepted && _friendRequestStatus != FriendRequestStatus.rejected ? 'Mark as read' : 'Mark as unread',
                style: const TextStyle(fontFamily: 'Kavivanar'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(fontFamily: 'Kavivanar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}