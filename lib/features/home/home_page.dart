import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.black,
          title: Text(
            'CineLog',
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.tealAccent),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Trending Movies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: AspectRatio(
                        aspectRatio: 2/3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: Colors.grey[850],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Icon(Icons.movie, size: 40, color: Colors.tealAccent),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Movie ${index + 1}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '2025',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Recently Added',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.grey[850],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: Icon(Icons.movie, size: 40, color: Colors.tealAccent),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Movie ${index + 1}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '2025',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
