class SearchResult {
  final String title;
  final String year;
  final String imdbID;
  final String type;
  final String poster;

  SearchResult({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.type,
    required this.poster,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      imdbID: json['imdbID'] ?? '',
      type: json['Type'] ?? '',
      poster: json['Poster'] ?? '',
    );
  }
}

class SearchResponse {
  final List<SearchResult> search;
  final String totalResults;
  final bool response;
  final String? error;

  SearchResponse({
    required this.search,
    required this.totalResults,
    required this.response,
    this.error,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    List<SearchResult> searchResults = [];
    if (json['Response'] == 'True' && json['Search'] != null) {
      searchResults = (json['Search'] as List)
          .map((item) => SearchResult.fromJson(item))
          .toList();
    }

    return SearchResponse(
      search: searchResults,
      totalResults: json['totalResults'] ?? '0',
      response: json['Response'] == 'True',
      error: json['Error'],
    );
  }
} 