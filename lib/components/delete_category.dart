import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class DeleteCategory extends StatefulWidget {
  DeleteCategory({
    super.key,
  });

  @override
  State<DeleteCategory> createState() => _DeleteCategoryState();
}

class _DeleteCategoryState extends State<DeleteCategory> {
  final List<String> _selectedTags = [];
  late Future<List<Tag>> _tagsFuture;

  @override
  void initState() {
    super.initState();
    _tagsFuture = getAllTags();
    _tagsFuture.then((tags) {});
  }

  Future<void> _refreshTags() async {
    _tagsFuture = getAllTags();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double listWidth = MediaQuery.of(context).size.width * 0.8;
    return FutureBuilder<List<Tag>>(
      future: _tagsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('タグがありません'));
        }

        final List<String> tags = snapshot.data!
            .where(
                (tag) => !['location', 'things', 'others'].contains(tag.name))
            .map((tag) => tag.name)
            .toList();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final bool isSelected = _selectedTags.contains(tag);

                  return Center(
                    child: SizedBox(
                      width: listWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: CheckboxListTile(
                          title: Text(tag),
                          value: isSelected,
                          activeColor: const Color(0xFFDE543F),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: CustomButton(
                label: "削除",
                onPressed: () async {
                  await deleteTags(_selectedTags);
                  setState(() {
                    _selectedTags.clear();
                  });
                  await _refreshTags();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
