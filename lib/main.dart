import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

// MODEL POST
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

// MAIN APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo[900],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: Colors.blueGrey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Post? createdPost;
  bool isLoading = false;

  final String baseUrl =
      'https://jsonplaceholder.typicode.com/posts';

  // SNACKBAR
  void showMessage(
      String message, {
        bool success = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // CREATE
  Future<void> createPost(
      String title,
      String body,
      ) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        // JSONPlaceholder mengembalikan ID 101 untuk CREATE.
        // Gunakan ID 1 agar UPDATE dan DELETE memakai
        // data contoh yang tersedia di JSONPlaceholder.
        setState(() {
          createdPost = Post(
            id: 1,
            userId: 1,
            title: title,
            body: body,
            createdAt: DateTime.now(),
          );
        });

        showMessage(
          'Post berhasil ditambahkan!',
          success: true,
        );
      } else {
        showMessage(
          'Gagal menambahkan post. Kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // UPDATE
  Future<void> updatePost(
      int id,
      String title,
      String body,
      ) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          createdPost = Post(
            id: id,
            userId: 1,
            title: title,
            body: body,
            createdAt: createdPost?.createdAt ?? DateTime.now(),
          );
        });

        showMessage(
          'Post berhasil diupdate!',
          success: true,
        );
      } else {
        showMessage(
          'Gagal mengupdate post. Kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // DELETE
  Future<void> deletePost(int id) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        setState(() {
          createdPost = null;
        });

        showMessage(
          'Post berhasil dihapus!',
          success: true,
        );
      } else {
        showMessage(
          'Gagal menghapus post. Kode: ${response.statusCode}',
        );
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // DIALOG TAMBAH
  Future<void> showAddPostDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        final titleController = TextEditingController();
        final bodyController = TextEditingController();

        return AlertDialog(
          title: const Text('Tambah Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  showMessage(
                    'Nama dan Pekerjaan harus diisi',
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  {
                    'title': title,
                    'body': body,
                  },
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;

    await createPost(
      result['title']!,
      result['body']!,
    );
  }

  // DIALOG UPDATE
  Future<void> showUpdatePostDialog(
      Post currentPost,
      ) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        final titleController = TextEditingController(
          text: currentPost.title,
        );

        final bodyController = TextEditingController(
          text: currentPost.body,
        );

        return AlertDialog(
          title: const Text('Update Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  showMessage(
                    'Nama dan Pekerjaan harus diisi',
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  {
                    'title': title,
                    'body': body,
                  },
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;

    await updatePost(
      currentPost.id,
      result['title']!,
      result['body']!,
    );
  }

  // DIALOG KONFIRMASI HAPUS
  Future<void> showDeleteConfirmationDialog(
      int id,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus post ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (!mounted || result != true) return;

    await deletePost(id);
  }

  // TAMPILAN UTAMA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo CRUD client-server'),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          if (createdPost == null)
            Center(
              child: Text(
                'Demo CRUD client-server di Flutter',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo[900],
                ),
              ),
            )
          else
            ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.indigo.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  createdPost!.title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                enabled: !isLoading,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'update',
                                    child: Text('Update'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) {
                                  final post = createdPost;

                                  if (post == null || isLoading) {
                                    return;
                                  }

                                  if (value == 'update') {
                                    showUpdatePostDialog(post);
                                  } else if (value == 'delete') {
                                    showDeleteConfirmationDialog(
                                      post.id,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            createdPost!.body,
                            style: GoogleFonts.openSans(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.blueGrey[900],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text('ID: ${createdPost!.id}'),

                          const SizedBox(height: 8),

                          Text(
                            'User ID: ${createdPost!.userId}',
                          ),

                          const SizedBox(height: 16),

                          Text(
                            DateFormat(
                              "dd MMMM yyyy, HH:mm 'WIB'",
                              'id_ID',
                            ).format(createdPost!.createdAt),
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.blueGrey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : showAddPostDialog,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }
}
