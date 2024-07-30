import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pokemon {
  int? count;
  String? next;
  dynamic previous;
  List<Results>? results;

  Pokemon({this.count, this.next, this.previous, this.results});

  Pokemon.fromJson(Map<String, dynamic> json) {
    count = json["count"];
    next = json["next"];
    previous = json["previous"];
    if (json["results"] != null) {
      results = [];
      json["results"].forEach((v) {
        results?.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["count"] = count;
    _data["next"] = next;
    _data["previous"] = previous;
    if (results != null) {
      _data["results"] = results?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Results {
  String? name;
  String? url;
  String? imageUrl;
  List<String>? types;
  List<String>? abilities;
  int? weight;
  int? height;
  Map<String, int>? stats;

  Results({
    this.name,
    this.url,
    this.types,
    this.abilities,
    this.weight,
    this.height,
    this.stats,
  }) {
    if (url!= null) {
      final id = url!.split('/').where((e) => e.isNotEmpty).last;
      imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    }
  }

  Results.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    url = json["url"];
    if (url!= null) {
      final id = url!.split('/').where((e) => e.isNotEmpty).last;
      imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    }
    types = json["types"]!= null? List<String>.from(json["types"]) : null;
    abilities = json["abilities"]!= null? List<String>.from(json["abilities"]) : null;
    weight = json["weight"];
    height = json["height"];
    if (json["stats"]!= null) {
      stats = {};
      json["stats"].forEach((stat) {
        stats![stat["stat"]["name"]] = stat["base_stat"];
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["url"] = url;
    if (types!= null) {
      _data["types"] = types?.map((e) => e).toList();
    }
    if (abilities!= null) {
      _data["abilities"] = abilities?.map((e) => e).toList();
    }
    _data["weight"] = weight;
    _data["height"] = height;
    if (stats!= null) {
      _data["stats"] = stats?.map((k, v) => MapEntry(k, v));
    }
    return _data;
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final int itemCount = 20;
  final TextEditingController _searchController = TextEditingController();
  List<Results>? filteredPokemonList;
  List<Results> allPokemonList = [];
  int offset = 0;
  bool isLoading = false;
  bool isLastPage = false;
  late ScrollController _scrollController;

  Future<List<Results>> getPostApi(int offset, int limit) async {
    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/?offset=$offset&limit=$limit'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      Pokemon pokemon = Pokemon.fromJson(data);
      return pokemon.results ?? [];
    } else {
      throw Exception('Failed to load Pokemon');
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchPokemon();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchPokemon() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    List<Results> newPokemonList = await getPostApi(offset, itemCount);

    setState(() {
      isLoading = false;
      if (newPokemonList.isEmpty) {
        isLastPage = true;
      } else {
        offset += itemCount;
        allPokemonList.addAll(newPokemonList);
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLastPage) {
        fetchPokemon();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bk.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "POKEMON",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    searchPokemon(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      filteredPokemonList = null;
                    });
                  },
                  child: Text('Clear Search'),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final pokemonList = filteredPokemonList ?? allPokemonList;
                      return GridView.builder(
                        controller: _scrollController,
                        itemCount: pokemonList.length + (isLoading ? 1 : 0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              _getCrossAxisCount(constraints.maxWidth),
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemBuilder: (context, index) {
                          if (index == pokemonList.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    pokemon: pokemonList[index],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 218, 231, 241),
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: AssetImage('assets/bk.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    pokemonList[index].imageUrl ?? '',
                                    height: 80,
                                    width: 80,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.error),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    pokemonList[index].name ?? 'No Name',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchPokemon(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPokemonList = null;
      });
      return;
    }

    final List<Results> filteredList = [];
    for (final pokemon in allPokemonList) {
      if (pokemon.name?.toLowerCase().contains(query.toLowerCase()) ?? false) {
        filteredList.add(pokemon);
      }
    }

    setState(() {
      filteredPokemonList = filteredList;
    });
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 2;
    } else if (width < 900) {
      return 3;
    } else {
      return 4;
    }
  }
}

class DetailScreen extends StatelessWidget {
  final Results pokemon;

  const DetailScreen({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name ?? 'Pokemon Detail'),
      ),
      body: Center(
        child: Text('Details for ${pokemon.name}'),
      ),
    );
  }
}
