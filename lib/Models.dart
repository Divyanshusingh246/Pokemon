
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
        results = json["results"] == null ? null : (json["results"] as List).map((e) => Results.fromJson(e)).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["count"] = count;
        _data["next"] = next;
        _data["previous"] = previous;
        if(results != null) {
            _data["results"] = results?.map((e) => e.toJson()).toList();
        }
        return _data;
    }
}

class Results {
  String? name;
  String? url;
  String? imageUrl;

  Results({this.name, this.url}) {
    if (url != null) {
      final id = url!.split('/').where((e) => e.isNotEmpty).last;
      imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    }
  }

  Results.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    url = json["url"];
    if (url != null) {
      final id = url!.split('/').where((e) => e.isNotEmpty).last;
      imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["url"] = url;
    return _data;
  }
}
