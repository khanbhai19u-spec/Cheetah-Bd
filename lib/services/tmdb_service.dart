import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class TmdbService {
  final String apiKey = '17509a46d9802f1f5b73bf7b9d8bad7c';

  Future<List<Movie>> fetchTrendingMovies() async {
    final url = Uri.parse('https://api.themoviedb.org/3/trending/movie/day?api_key=$apiKey');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
