import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'services/api_service.dart'; // Import the API service
import 'models/movie_model.dart'; // Import the model file
import 'movie_detail_page.dart'; // Import the movie detail page
import 'package:binge/pages/baseScaffold.dart';

class MoviesHomePageContent extends StatefulWidget {
  @override
  _MoviesHomePageContentState createState() => _MoviesHomePageContentState();
}

class _MoviesHomePageContentState extends State<MoviesHomePageContent> {
  final ApiService apiService = ApiService();
  List<Movie>? movies;
  List<Movie>? topRatedMovies;
  List<Movie>? monthTopRatedMovies; // New variable for month top-rated movies
  List<Movie>? yearTopRatedMovies;
  // New variable for top-rated movies
  List<Movie>? searchResults = [];
  String searchQuery = '';
  OverlayEntry? searchOverlay;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies();
    fetchTopRatedMovies();
    fetchMonthTopRatedMovies(); // Fetch top-rated movies of the month
    fetchYearTopRatedMovies();
    // Fetch top-rated movies
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        clearSearchOverlay();
      }
    });
  }

  Future<void> fetchTrendingMovies() async {
    try {
      final List<Movie> trendingMovies = await apiService.fetchTrendingMovies();
      setState(() {
        movies = trendingMovies;
      });
    } catch (error) {
      print('Error fetching trending movies: $error');
    }
  }

  Future<void> fetchTopRatedMovies() async {
    // New method to fetch top-rated movies
    try {
      final List<Movie> ratedMovies = await apiService.fetchTopRatedMovies();
      setState(() {
        topRatedMovies = ratedMovies;
      });
    } catch (error) {
      print('Error fetching top-rated movies: $error');
    }
  }

  Future<void> fetchMonthTopRatedMovies() async {
    try {
      final List<Movie> ratedMovies =
          await apiService.fetchMonthTopRatedMovies();
      setState(() {
        monthTopRatedMovies = ratedMovies;
      });
    } catch (error) {
      print('Error fetching month top-rated movies: $error');
    }
  }

  Future<void> fetchYearTopRatedMovies() async {
    try {
      final List<Movie> ratedMovies =
          await apiService.fetchYearTopRatedMovies();
      setState(() {
        yearTopRatedMovies = ratedMovies;
      });
    } catch (error) {
      print('Error fetching year top-rated movies: $error');
    }
  }

  Future<void> searchMovies() async {
    if (searchQuery.isNotEmpty) {
      try {
        final List<Movie> searchedMovies =
            await apiService.searchMovies(searchQuery);
        setState(() {
          searchResults = searchedMovies;
          showSearchOverlay();
        });
      } catch (error) {
        print('Error searching movies: $error');
      }
    } else {
      clearSearchOverlay();
    }
  }

  void showSearchOverlay() {
    clearSearchOverlay();
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    double statusBarHeight = MediaQuery.of(context).padding.top;

    searchOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 70 + statusBarHeight,
        left: position.dx + 16,
        right: position.dx + 16,
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0.0),
            topRight: Radius.circular(0.0),
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListView.builder(
              itemCount: searchResults?.length ?? 0,
              itemBuilder: (context, index) {
                final movie = searchResults![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title ?? 'Unknown Title',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rating: ${movie.voteAverage?.toStringAsFixed(1) ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    leading: Container(
                      width: 50,
                      height: 75,
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            child: Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                    onTap: () {
                      clearSearchOverlay();
                      _searchFocusNode.unfocus();
                      _searchController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailPage(movie: movie),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(searchOverlay!);
  }

  void clearSearchOverlay() {
    if (searchOverlay != null) {
      searchOverlay!.remove();
      searchOverlay = null;
    }
  }

  Future<bool> _onWillPop() async {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    clearSearchOverlay();
    _searchFocusNode.removeListener(() {});
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    const String placeholderImageUrl =
        'https://www.huber-usa.com/daisy_website_files/_processed_/8/0/csm_no-image_d5c4ab1322.jpg';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          clearSearchOverlay();
          _searchFocusNode.unfocus();
        },
        child: BaseScaffold(
          resizeToAvoidBottomInset: true, // Change to true to avoid overflow
          body: SingleChildScrollView(
            // Wrap in SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the left
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for movies...',
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchMovies();
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        searchMovies();
                      });
                    },
                  ),
                ),
                SizedBox(height: 16), // Space below the search bar
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, bottom: 8.0), // Align to left, add spacing
                  child: Text(
                    "Trending Now",
                    style: TextStyle(
                      fontSize: 20, // Set font size
                      fontWeight:
                          FontWeight.bold, // Bold font for section title
                    ),
                  ),
                ),
                movies == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 0), // Reduce gap
                        child: CarouselSlider.builder(
                          itemCount: movies!.length,
                          itemBuilder: (context, index, realIndex) {
                            final movie = movies![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailPage(movie: movie),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.8, // Increased width
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                        fit: BoxFit.cover,
                                        height: 250, // Height set to 250
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey,
                                            child: Icon(Icons.broken_image),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        movie.title ?? 'Unknown Title',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 250.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayInterval: Duration(seconds: 3),
                          ),
                        ),
                      ),
                SizedBox(height: 16), // Space below the carousel
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, bottom: 8.0), // Align to left, add spacing
                  child: Text(
                    "Top Rated Movies of all time",
                    style: TextStyle(
                      fontSize: 20, // Set font size
                      fontWeight:
                          FontWeight.bold, // Bold font for section title
                    ),
                  ),
                ),

                topRatedMovies == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        height:
                            250, // Set a fixed height for the horizontal list
                        child: ListView.builder(
                          scrollDirection: Axis
                              .horizontal, // Set scroll direction to horizontal
                          itemCount: topRatedMovies?.length ?? 0,
                          itemBuilder: (context, index) {
                            final movie = topRatedMovies![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailPage(movie: movie),
                                  ),
                                );
                              },
                              child: Container(
                                width:
                                    150, // Set a fixed width for each movie item
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                        fit: BoxFit.cover,
                                        height:
                                            200, // Set a fixed height for the movie poster
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Return the placeholder image when there's an error
                                          return Image.network(
                                            placeholderImageUrl,
                                            fit: BoxFit.cover,
                                            height:
                                                200, // Maintain the same height
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            8.0), // Space between the poster and title
                                    Text(
                                      movie.title ?? 'Unknown Title',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2, // Limit title to 2 lines
                                      overflow: TextOverflow
                                          .ellipsis, // Add ellipsis if title is too long
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(height: 16), // Space below the carousel
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, bottom: 8.0), // Align to left, add spacing
                  child: Text(
                    "Top Rated Movies of the Month",
                    style: TextStyle(
                      fontSize: 20, // Set font size
                      fontWeight:
                          FontWeight.bold, // Bold font for section title
                    ),
                  ),
                ),
                monthTopRatedMovies == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: monthTopRatedMovies?.length ?? 0,
                          itemBuilder: (context, index) {
                            final movie = monthTopRatedMovies![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailPage(movie: movie),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                        fit: BoxFit.cover,
                                        height: 200,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Return the placeholder image when there's an error
                                          return Image.network(
                                            placeholderImageUrl,
                                            fit: BoxFit.cover,
                                            height: 200,
                                          );
                                        },
                                        // Optionally handle loading state
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      movie.title ?? 'Unknown Title',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                SizedBox(height: 16), // Space below the carousel
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, bottom: 8.0), // Align to left, add spacing
                  child: Text(
                    "Top Rated Movies of the Year",
                    style: TextStyle(
                      fontSize: 20, // Set font size
                      fontWeight:
                          FontWeight.bold, // Bold font for section title
                    ),
                  ),
                ),
                yearTopRatedMovies == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: yearTopRatedMovies?.length ?? 0,
                          itemBuilder: (context, index) {
                            final movie = yearTopRatedMovies![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailPage(movie: movie),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                        fit: BoxFit.cover,
                                        height: 200,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Return the placeholder image when there's an error
                                          return Image.network(
                                            placeholderImageUrl,
                                            fit: BoxFit.cover,
                                            height:
                                                200, // Maintain the same height
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      movie.title ?? 'Unknown Title',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
