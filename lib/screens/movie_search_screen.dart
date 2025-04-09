import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/omdb_api_service.dart';
import '../widgets/netflix_logo.dart';
import 'movie_details_screen.dart';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final _searchController = TextEditingController();
  final _omdbApiService = OmdbApiService();
  List<SearchResult> _searchResults = [];
  Map<String, String> _posterCache = {}; // Cache for high-res posters
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Add a sample search when the app starts
    _searchMovies('Avengers');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('Starting search for: $query');
      }
      
      final response = await _omdbApiService.searchMovies(query);
      
      if (kDebugMode) {
        print('Search completed. Found ${response.search.length} results');
      }
      
      setState(() {
        _searchResults = response.search;
        _isLoading = false;
        
        if (!response.response) {
          _errorMessage = response.error ?? 'No results found';
          if (kDebugMode) {
            print('Search error: $_errorMessage');
          }
        }
      });

      // Preload high-res posters for better UX
      for (var movie in _searchResults) {
        if (movie.poster != 'N/A') {
          try {
            final posterUrl = await _omdbApiService.getMoviePoster(movie.imdbID);
            if (mounted) {
              setState(() {
                _posterCache[movie.imdbID] = posterUrl;
              });
            }
          } catch (e) {
            // Silently fail and use default poster
            if (kDebugMode) {
              print('Error fetching poster for ${movie.title}: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during search: $e');
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const NetflixLogo(),
        centerTitle: false,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search for movies',
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _searchMovies(_searchController.text),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              onSubmitted: _searchMovies,
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.red))
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_searchResults.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No results found. Try a different search term.',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final movie = _searchResults[index];
                  // Use high-res poster if available, otherwise use the default poster
                  final posterUrl = _posterCache[movie.imdbID] ?? movie.poster;
                  return ListTile(
                    leading: posterUrl != 'N/A'
                        ? Image.network(
                            posterUrl,
                            width: 50,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.movie, size: 50, color: Colors.red),
                          )
                        : const Icon(Icons.movie, size: 50, color: Colors.red),
                    title: Text(
                      movie.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${movie.year} • ${movie.type}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            imdbId: movie.imdbID,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 