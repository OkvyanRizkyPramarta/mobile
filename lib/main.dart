import 'package:fintech/DetailCashFlow.dart';
import 'package:fintech/TambahPemasukan.dart';
import 'package:flutter/material.dart';

import 'DatabaseHelper.dart';
import 'TambahPengeluaran.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/', // Rute awal adalah '/' (halaman login)
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => Beranda(), // Rute untuk halaman beranda
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: const Center(
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircleAvatar(
            radius: 80, // Sesuaikan dengan ukuran yang Anda inginkan
            backgroundImage: NetworkImage(
                'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.Bc9Ijabqw8mxYDsSLVp0hgHaE_%26pid%3DApi&f=1&ipt=694a02b8a8bf93f1ccc100f7b0415ff320cc22fcedd732b8407f32584be9bd52&ipo=images'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: () {
              // Implementasi logika autentikasi di sini
              String username = _usernameController.text;
              String password = _passwordController.text;
              // Contoh sederhana, Anda harus menggantinya dengan logika autentikasi yang aman
              if (username == 'admin' && password == 'admin') {
                Navigator.of(context)
                    .pushReplacementNamed('/home'); // Ganti rute ke '/home'
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Login Gagal'),
                      content: const Text('Username atau password salah.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('Login'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity,
                  50), // Sesuaikan dengan lebar dan tinggi yang diinginkan
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class Beranda extends StatelessWidget {
  Beranda({Key? key}) : super(key: key);

  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Beranda'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FutureBuilder<List<double>>(
              future: Future.wait(
                  [dbHelper.getTotalIncome(), dbHelper.getTotalOutcome()]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Loading...');
                } else {
                  double totalIncome = snapshot.data![0];
                  double totalOutcome = snapshot.data![1];
                  return Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Table(
                        border:
                            TableBorder.all(), // Add borders to the table cells
                        children: [
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  color: Colors
                                      .blue, // Set the background color to blue
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rangkuman Pemasukan',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors
                                          .white, // Set text color to white
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  color: Colors
                                      .blue, // Set the background color to blue
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rangkuman Pengeluaran',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors
                                          .white, // Set text color to white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rp. ${totalIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rp. ${totalOutcome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      // Rest of your UI...
                    ],
                  );
                }
              },
            ),

            const SizedBox(
                height:
                    20), // Jarak antara pengeluaran dan pemasukan dengan gambar grafik
            Image.network(
              'https://www.pngkey.com/png/full/238-2383266_line-graph-png-transparent-line-graph-png.png',
              fit: BoxFit.fill, // Mengatur gambar agar penuh secara lebar
              height: 250, // Mengatur tinggi gambar menjadi 150
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman "Tambah Pemasukan" saat ikon ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TambahPemasukan(),
                        ),
                      );
                    },
                    child: const Text('Tambah Pemasukan'),
                  ),
                ), // Jarak antara tombol
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Jarak antara tombol
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman "Tambah Pengeluaran" saat ikon ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TambahPengeluaran(),
                        ),
                      );
                    },
                    child: const Text('Tambah Pengeluaran'),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman "Tambah Pengeluaran" saat ikon ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailCashFlow(),
                        ),
                      );
                    },
                    child: const Text('Detail Cash Flow'),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Aksi ketika tombol Pengaturan ditekan
                    },
                    child: const Text('Pengaturan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
