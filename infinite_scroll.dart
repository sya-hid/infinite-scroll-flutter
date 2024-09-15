import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

class InfiniteScrollPage extends StatefulWidget {
  const InfiniteScrollPage({super.key});

  @override
  State<InfiniteScrollPage> createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _data = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final String url =
        'https://webapi.bps.go.id/v1/api/list/model/publication/domain/0000/key/3c54cfd18f561c31311d53db76432c89/page/$_page';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'][1];

      setState(() {
        _data.addAll(data);
        _page++;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchData();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
      _data.clear();
    });
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Infinite Scroll'),
      ),
      body: _isLoading || _data.isEmpty
          ? Skeletonizer(
              effect: ShimmerEffect(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                duration: const Duration(seconds: 1),
              ),
              child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 2,
                      ),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        leading: Bone.square(
                          size: 48,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        title: const Bone.text(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                        subtitle: const Bone.text(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                    );
                  },
                  itemCount: 10))
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(10),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 2,
                ),
                controller: _scrollController,
                itemCount: _data.length + 1,
                itemBuilder: (context, index) {
                  if (index == _data.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final publicationItem = _data[index];

                  return Card(
                    elevation: 5,
                    child: ListTile(
                      onTap: () {},
                      leading: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: publicationItem['cover']!,
                          width: 48,
                          progressIndicatorBuilder: (context, url, progress) {
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Icons.image,
                              size: 48,
                            );
                          },
                        ),
                      ),
                      title: Text(
                        publicationItem['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('ISSN : ${publicationItem['issn']!}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
