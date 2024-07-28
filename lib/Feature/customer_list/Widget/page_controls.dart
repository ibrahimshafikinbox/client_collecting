import 'package:flutter/material.dart';

class PageControls extends StatelessWidget {
  final int currentPageIndex;
  final int totalPageCount;
  final Function(int) onPageChanged;

  const PageControls({
    Key? key,
    required this.currentPageIndex,
    required this.totalPageCount,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            if (currentPageIndex > 0) {
              onPageChanged(currentPageIndex - 1);
            }
          },
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              totalPageCount,
              (index) => GestureDetector(
                onTap: () {
                  onPageChanged(index);
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        currentPageIndex == index ? Colors.blue : Colors.grey,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            if (currentPageIndex < totalPageCount - 1) {
              onPageChanged(currentPageIndex + 1);
            }
          },
        ),
      ],
    );
  }
}
