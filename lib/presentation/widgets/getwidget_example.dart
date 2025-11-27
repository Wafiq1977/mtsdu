import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class GetWidgetExample extends StatelessWidget {
  const GetWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GFButton(
          onPressed: () {},
          text: 'GF Button',
          shape: GFButtonShape.pills,
          type: GFButtonType.outline,
        ),
        const SizedBox(height: 10),
        GFCard(
          title: const GFListTile(
            titleText: 'GF Card Title',
            subTitleText: 'GF Card Subtitle',
          ),
          content: const Text('This is a GF Card content.'),
          buttonBar: GFButtonBar(
            children: [
              GFButton(
                onPressed: () {},
                text: 'Cancel',
                type: GFButtonType.outline,
              ),
              GFButton(
                onPressed: () {},
                text: 'OK',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
