import './infinite_scroll.dart';
import './infinite_scroll_with_future.dart';
import './search_delegate_with_infinite_scroll.dart';
import 'package:flutter/material.dart';

class MainPageInfiniteScroll extends StatefulWidget {
  const MainPageInfiniteScroll({super.key});

  @override
  State<MainPageInfiniteScroll> createState() => _MainPageInfiniteScrollState();
}

class _MainPageInfiniteScrollState extends State<MainPageInfiniteScroll> {
  int currentPage = 0;
  Widget body() {
    switch (currentPage) {
      case 0:
        return const InfiniteScrollPage();
      case 1:
        return const InfiniteScrollWithFuturePage();
      case 2:
        return const Homepage();
      default:
        return const InfiniteScrollPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage == 0
            ? "Infinite Scroll"
            : currentPage == 1
                ? "Infinite Scroll w/ Future"
                : 'Search Delegate Infinite Scroll'),
        actions: [
          currentPage == 2
              ? IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: SearchDelegate1(context),
                    );
                  },
                )
              : const SizedBox.shrink()
        ],
      ),
      drawer: buildDrawer(context),
      body: body(),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlutterLogo(
                  size: 100,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Infinite Scroll Flutter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.keyboard_arrow_right_rounded),
            selected: currentPage == 0 ? true : false,
            title: const Text('Infinite Scroll'),
            onTap: () {
              setState(() {
                currentPage = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Infinite Scroll w/ Future'),
            leading: const Icon(Icons.keyboard_arrow_right_rounded),
            selected: currentPage == 1 ? true : false,
            onTap: () {
              setState(() {
                currentPage = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Search Delegate Infinite Scroll'),
            leading: const Icon(Icons.keyboard_arrow_right_rounded),
            selected: currentPage == 2 ? true : false,
            onTap: () {
              setState(() {
                currentPage = 2;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
