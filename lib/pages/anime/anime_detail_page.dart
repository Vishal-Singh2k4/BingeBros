import 'package:flutter/material.dart';
import 'models/anime_model.dart';
import 'services/api_service.dart';

class AnimeDetailPage extends StatelessWidget {
  final Anime anime;

  AnimeDetailPage({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w500${anime.posterPath}',
                  fit: BoxFit.cover,
                  height: 400,
                  width: double.infinity,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              anime.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Release date',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  anime.releaseDate,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: anime.genres.map((genre) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(genre.name),
                    backgroundColor: Colors.grey[800],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Text(
              'Synopsis',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8.0),
            ExpandableText(
              text: anime.overview,
            ),
            SizedBox(height: 16.0),
            Text(
              'Related Anime',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8.0),
            RelatedAnime(animeId: anime.id),
          ],
        ),
      ),
      backgroundColor: Colors.black87,
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  ExpandableText({required this.text, this.maxLines = 3});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: expanded ? null : widget.maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? 'Read less' : 'Read more',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class RelatedAnime extends StatelessWidget {
  final int animeId;
  RelatedAnime({required this.animeId});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return FutureBuilder(
      future: apiService.getRelatedAnime(animeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching related anime.'));
        } else {
          List<Anime> relatedAnime = snapshot.data as List<Anime>;
          return Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedAnime.length,
              itemBuilder: (context, index) {
                Anime anime = relatedAnime[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w200${anime.posterPath}',
                          height: 130,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        width: 90,
                        child: Text(
                          anime.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
