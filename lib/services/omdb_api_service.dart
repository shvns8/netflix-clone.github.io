import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/movie.dart';
import '../models/search_result.dart';

class OmdbApiService {
  final String baseUrl = ApiConstants.baseUrl;
  final String apiKey = ApiConstants.apiKey;
  final String posterBaseUrl = ApiConstants.posterBaseUrl;

  // Get movie details by IMDb ID
  Future<Movie> getMovieById(String imdbId) async {
    final url = '$baseUrl?apikey=$apiKey&i=$imdbId';
    
    if (kDebugMode) {
      print('Fetching movie details: $url');
    }
    
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details: ${response.statusCode} - ${response.body}');
    }
  }

  // Search movies by title
  Future<SearchResponse> searchMovies(String searchTerm, {int page = 1}) async {
    final url = '$baseUrl?apikey=$apiKey&s=$searchTerm&page=$page';
    
    if (kDebugMode) {
      print('Searching movies: $url');
    }
    
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return SearchResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to search movies: ${response.statusCode} - ${response.body}');
    }
  }

  // Get movie details by title
  Future<Movie> getMovieByTitle(String title, {String? year}) async {
    String url = '$baseUrl?apikey=$apiKey&t=$title';
    
    if (year != null) {
      url += '&y=$year';
    }

    if (kDebugMode) {
      print('Fetching movie by title: $url');
    }
    
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details: ${response.statusCode} - ${response.body}');
    }
  }

  // Get high-resolution poster by IMDb ID
  Future<String> getMoviePoster(String imdbId, {String size = 'SX300'}) async {
    final url = '$posterBaseUrl?apikey=$apiKey&i=$imdbId';
    
    if (kDebugMode) {
      print('Fetching poster: $url');
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (kDebugMode) {
        print('Poster response status: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        return url;
      } else {
        if (kDebugMode) {
          print('Poster API failed, falling back to movie details');
        }
        // If poster API fails, fallback to the poster URL from the movie details
        final movie = await getMovieById(imdbId);
        return movie.poster;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching poster: $e');
      }
      // If there's an error, fallback to the poster URL from the movie details
      final movie = await getMovieById(imdbId);
      return movie.poster;
    }
  }
} 