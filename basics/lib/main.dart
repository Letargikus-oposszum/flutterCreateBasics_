import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: "Alap widgetek",
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 33, 112, 239),
                Color.fromARGB(255, 45, 67, 98),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tóth Albert',
                  style: TextStyle(color: Colors.white60, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Tartalom(jegyzék)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Kinyitottam életregényemet, lapoztam',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                Text(
                  'benne, és a "tartalmas életút" fejezet',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                Text(
                  'címnél hosszan elidőztem, kissé haboztam',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                Text(
                  'ez most sok vagy kevés, vakartam a fejemet',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
