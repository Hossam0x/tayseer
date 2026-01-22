import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Message Shimmer Loading Widget
///
/// Displays a shimmer effect while messages are loading from the server
class MessageShimmer extends StatelessWidget {
  final int itemCount;

  const MessageShimmer({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Alternate between sent and received message styles
        final isSent = index % 3 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: isSent
              ? _buildSentMessageShimmer(context)
              : _buildReceivedMessageShimmer(context),
        );
      },
    );
  }

  Widget _buildSentMessageShimmer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedMessageShimmer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Avatar shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
        ),
        const SizedBox(width: 8),
        // Message bubble shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
