import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:http/http.dart' as http;

class InfiniteScrollWithFuturePage extends StatefulWidget {
  const InfiniteScrollWithFuturePage({super.key});

  @override
  State<InfiniteScrollWithFuturePage> createState() =>
      _InfiniteScrollWithFuturePageState();
}

class _InfiniteScrollWithFuturePageState
    extends State<InfiniteScrollWithFuturePage> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _data = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNews(_page);
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _refreshNews() async {
    setState(() {
      _page = 1;
      _data.clear();
      fetchNews(_page);
    });
  }

  Future<List<dynamic>> fetchNews(int page) async {
    final String apiUrl =
        'https://webapi.bps.go.id/v1/api/list/model/news/domain/0000/key/3c54cfd18f561c31311d53db76432c89/?page=$page';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['data'] != "") {
        List<dynamic> data = jsonDecode(response.body)['data'][1];
        return data;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load news');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _isLoading = true;
      _page++;
    });

    fetchNews(_page).then((newItems) {
      setState(() {
        _isLoading = false;
        _data.addAll(newItems);
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: fetchNews(_page),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _data.isEmpty) {
            return Skeletonizer(
                effect: ShimmerEffect(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  duration: const Duration(seconds: 1),
                ),
                child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        child: ListTile(
                          leading: Bone.square(
                            size: 48,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          title: const Bone.text(
                            borderRadius: BorderRadius.all(
                              Radius.circular(2),
                            ),
                          ),
                          subtitle: const Bone.text(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 2),
                    itemCount: 10));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (snapshot.hasData &&
                snapshot.data!.isNotEmpty &&
                _data.isEmpty) {
              _data.addAll(snapshot.data!);
            }

            return RefreshIndicator(
              onRefresh: _refreshNews,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                  height: 2,
                ),
                padding: const EdgeInsets.all(10),
                controller: _scrollController,
                itemCount: _data.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _data.length) {
                    final news = _data[index];

                    return Card(
                      elevation: 5,
                      child: ListTile(
                        leading: ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: news['picture']!,
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
                          news['title']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(news['newscat_name']!),
                        onTap: () {},
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}
