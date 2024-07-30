import 'package:flutter/material.dart';

import 'first_screen.dart'; // Import the Results class

class DetailScreen extends StatelessWidget {
  final Results pokemon;

  DetailScreen({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bk.jpg'), // Assuming bk.jpg is in the assets folder
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make background transparent
        appBar: AppBar(
          title: Text(pokemon.name ?? 'Pokemon Details'),
          backgroundColor: Colors.transparent, // Make app bar transparent
          elevation: 0, // Remove app bar shadow
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pokemon Image
              pokemon.imageUrl != null
                  ? Image.network(
                      pokemon.imageUrl!,
                      height: 200,
                      width: 200,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error),
                    )
                  : CircularProgressIndicator(), // Show loading indicator if image URL is not available
              SizedBox(height: 20),
              // Pokemon Name
              Text(
                pokemon.name ?? 'No Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Pokemon Details
              Text(
                'Weight: ${pokemon.weight ?? 'N/A'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Height: ${pokemon.height ?? 'N/A'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              // Stats
              Text(
                'Stats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (pokemon.stats != null) ...pokemon.stats!.keys.map((statName) {
                return Text(
                  '$statName: ${pokemon.stats![statName] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
