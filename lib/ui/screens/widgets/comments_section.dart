import 'package:Talab/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import '../../../utils/custom_text.dart';
import '../../../utils/extensions/extensions.dart';

class CommentData {
  final String userName;
  final String date;
  final String comment;
  final String? answer;
  final String? avatarUrl;

  CommentData({
    required this.userName,
    required this.date,
    required this.comment,
    this.answer,
    this.avatarUrl,
  });
}

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _controller = TextEditingController();
  final List<CommentData> _comments = [
    CommentData(
      userName: 'Alice',
      date: 'Jun 05,2025',
      comment: '26',
      answer:
          'Sure, you can see more details at https://example.com',
    ),
    CommentData(
      userName: 'Bob',
      date: 'Jun 04,2025',
      comment: '22',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addComment(String text) {
    setState(() {
      _comments.insert(
        0,
        CommentData(
          userName: 'You',
          date: _formattedDate(DateTime.now()),
          comment: text,
        ),
      );
    });
  }

  String _formattedDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day.toString().padLeft(2, '0')},${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8c296d);
    final double listMaxHeight = MediaQuery.of(context).size.height * 0.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Lot Questions (${_comments.length})',
          fontWeight: FontWeight.bold,
          fontSize: context.font.large,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask about the lot',
                  filled: true,
                  fillColor: context.color.borderColor.darken(20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.color.borderColor.darken(60)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.color.borderColor.darken(60)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;
                _addComment(_controller.text.trim());
                _controller.clear();
              },
              child: const Text('Ask'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _comments.isEmpty
            ? CustomText('No questions yet.')
            : ConstrainedBox(
                constraints: BoxConstraints(maxHeight: listMaxHeight),
                child: ListView.builder(
                  itemCount: _comments.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.color.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: primaryColor,
                                backgroundImage: c.avatarUrl != null
                                    ? NetworkImage(c.avatarUrl!)
                                    : null,
                                child: c.avatarUrl == null
                                    ? Text(
                                        c.userName.isNotEmpty
                                            ? c.userName[0].toUpperCase()
                                            : '',
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      c.userName,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 2),
                                    CustomText(
                                      c.date,
                                      fontSize: context.font.small,
                                      color: context.color.textLightColor,
                                    ),
                                    const SizedBox(height: 6),
                                    CustomText(
                                      c.comment,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (c.answer != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.reply, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: SelectableText.rich(
                                    TextSpan(
                                      text: c.answer,
                                      style: TextStyle(
                                        color: context.color.textDefaultColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Translate'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
        const SizedBox(height: 16),
        Container(
          height: 60,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: context.color.borderColor.darken(20),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: CustomText('Banner Ad'),
        ),
      ],
    );
  }
}