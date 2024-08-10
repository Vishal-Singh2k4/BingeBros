import 'package:flutter/material.dart';

class AvatarSelectionModal extends StatefulWidget {
  final String selectedAvatar;
  final Function(String) onAvatarSelected;

  AvatarSelectionModal({
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  @override
  _AvatarSelectionModalState createState() => _AvatarSelectionModalState();
}

class _AvatarSelectionModalState extends State<AvatarSelectionModal> {
  late String currentAvatar;

  @override
  void initState() {
    super.initState();
    currentAvatar = widget.selectedAvatar;
  }

  final List<String> avatars = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatar5.png',
    'assets/avatar6.png',
    'assets/avatar7.png',
    'assets/avatar8.png',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose Avatar'),
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 avatars per row
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              String avatar = avatars[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentAvatar = avatar;
                  });
                  widget.onAvatarSelected(avatar);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: currentAvatar == avatar
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      avatar,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
