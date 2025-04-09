import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/omdb_api_service.dart';
import '../widgets/netflix_logo.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String imdbId;
  
  const MovieDetailsScreen({
    super.key,
    required this.imdbId,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _omdbApiService = OmdbApiService();
  Movie? _movie;
  String? _posterUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final movie = await _omdbApiService.getMovieById(widget.imdbId);
      
      // Try to get high-res poster
      String posterUrl = movie.poster;
      try {
        posterUrl = await _omdbApiService.getMoviePoster(widget.imdbId);
      } catch (e) {
        // If poster API fails, use the standard poster URL
        posterUrl = movie.poster;
        if (kDebugMode) {
          print('Error fetching poster: $e');
        }
      }
      
      setState(() {
        _movie = movie;
        _posterUrl = posterUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load movie details: $e';
      });
      if (kDebugMode) {
        print('Error loading movie details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const NetflixLogo(),
        backgroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_movie == null) {
      return const Center(
        child: Text(
          'No movie details available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _posterUrl != null && _posterUrl != 'N/A'
                ? Image.network(
                    _posterUrl!,
                    height: 300,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.movie, size: 100, color: Colors.red),
                  )
                : const Icon(Icons.movie, size: 100, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            _movie!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_movie!.year} • ${_movie!.rated} • ${_movie!.runtime}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${_movie!.imdbRating}/10',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Genre: ${_movie!.genre}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Plot',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_movie!.plot, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Text(
            'Director',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_movie!.director, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Text(
            'Cast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_movie!.actors, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
} 