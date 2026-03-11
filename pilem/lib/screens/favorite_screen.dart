import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:pilem/screens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> favoriteMovies = [];

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoriteMovies =
          favList.map((movie) => Movie.fromJson(jsonDecode(movie))).toList();
    });
  }

  Future<void> removeFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = prefs.getStringList('favorites') ?? [];
    favList.removeWhere((item) {
      final decoded = Movie.fromJson(jsonDecode(item));
      return decoded.id == movie.id;
    });
    await prefs.setStringList('favorites', favList);
    loadFavorites();
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Movies')),
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'Belum ada film favorit',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final Movie movie = favoriteMovies[index];
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => removeFavorite(movie),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(movie: movie),
                    ),
                  ).then((_) => loadFavorites()),
                );
              },
            ),
    );
  }
}