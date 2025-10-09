import 'package:elibrary_desktop/models/book.dart';
import 'package:elibrary_desktop/models/user.dart';
import 'package:elibrary_desktop/providers/book_provider.dart';
import 'package:elibrary_desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:elibrary_desktop/models/forum_thread.dart';
import 'package:elibrary_desktop/models/forum_comment.dart';
import 'package:elibrary_desktop/providers/forum_thread_provider.dart';
import 'package:elibrary_desktop/providers/forum_comment_provider.dart';
import 'package:elibrary_desktop/utils/datetime_helper.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumThreadProvider _threadProvider = ForumThreadProvider();
  final ForumCommentProvider _commentProvider = ForumCommentProvider();

  List<ForumThread> _threads = [];
  Map<int, List<ForumComment>> _commentsMap = {}; 
  bool _isLoading = true;
  String? _error;
  User? _currentUser;

  final TextEditingController _titleController = TextEditingController();

  int _currentPage = 1;
  int _pageSize = 5;
  int _totalCount = 0;

  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadThreads();
    _initializeData();
  }

  Future<void> _initializeData() async {
  try {
    final userProvider = UserProvider();
    _currentUser = await userProvider.getMe();
    await _loadThreads(); 
  } catch (e) {
    setState(() {
      _error = "Greška prilikom učitavanja korisnika: $e";
      _isLoading = false;
    });
  }
}

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _threadProvider.get(
        filter: {
          "Title": _titleController.text.trim(),
          "Page": _currentPage - 1,
          "PageSize": _pageSize,
        },
      );

      _threads = result.result;
      _totalCount = result.count ?? 0;

      for (var thread in _threads) {
        final commentResult = await _commentProvider.get(
          filter: {"ForumThreadId": thread.id},
        );
        _commentsMap[thread.id!] = commentResult.result;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Greška pri učitavanju foruma: $e";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterSection(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else
            Expanded(child: _buildForumList()),
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    _showAddThreadDialog();
  },
  child: const Icon(Icons.add),
  tooltip: 'Nova tema',
),

    );
  }
  void _showAddThreadDialog() {
  final TextEditingController _threadTitleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BookProvider _bookProvider = BookProvider();
  ForumThreadProvider _threadProvider = ForumThreadProvider();
  List<Book> _books = [];
  Book? _selectedBook;
  bool _isSubmitting = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> _loadBooks() async {
            try {
              final result = await _bookProvider.get();
              setState(() {
                _books = result.result;
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Greška pri dohvaćanju knjiga: $e")),
              );
            }
          }

          if (_books.isEmpty) {
            _loadBooks();
          }

          return AlertDialog(
            title: const Text("Nova tema"),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _threadTitleController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: "Naslov teme",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Naslov ne smije biti prazan.";
                        }
                        if (value.length > 50) {
                          return "Naslov ne smije imati više od 50 karaktera.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Book>(
                      isExpanded: true,
                      value: _selectedBook,
                      items: _books.map((book) {
                        return DropdownMenuItem<Book>(
                          value: book,
                          child: Text(book.title ?? "Nepoznata knjiga"),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: "Odaberi knjigu",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (book) {
                        setState(() {
                          _selectedBook = book;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Morate odabrati knjigu." : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Otkaži"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Objavi"),
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Niste prijavljeni.")),
                          );
                          return;
                        }

                        setState(() => _isSubmitting = true);

                        try {
                          await _threadProvider.insert({
                            "Title": _threadTitleController.text.trim(),
                            "UserId": _currentUser!.id,
                            "BookId": _selectedBook!.id,
                            "ThreadDate": DateTime.now().toIso8601String(),
                          });

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Tema uspješno dodana.")),
                          );
                          _loadThreads();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Greška: $e")),
                          );
                        } finally {
                          setState(() => _isSubmitting = false);
                        }
                      },
              ),
            ],
          );
        },
      );
    },
  );
}

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Naslov teme'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pretraži',
            onPressed: () {
              _currentPage = 1;
              _loadThreads();
            },
          ),
        ],
      ),
    );
  }

void _showAddCommentDialog(int threadId) {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Dodaj komentar"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _commentController,
            maxLength: 100,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Unesite komentar...",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Komentar ne može biti prazan.";
              }
              if (value.length > 100) {
                return "Komentar ne smije biti duži od 100 karaktera.";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Otkaži"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Pošalji"),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _commentProvider.insert({
                    "UserId": _currentUser?.id,
                    "ForumThreadId": threadId,
                    "Comment": _commentController.text.trim(),
                    "CommentDate": DateTime.now().toIso8601String(),
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Komentar uspješno dodan.")),
                  );

                  final commentResult = await _commentProvider.get(
                    filter: {"ForumThreadId": threadId},
                  );

                  setState(() {
                    _commentsMap[threadId] = commentResult.result;
                  });
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Greška: $e")),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}
  Widget _buildForumList() {
    return ListView.builder(
      itemCount: _threads.length,
      itemBuilder: (context, index) {
        final thread = _threads[index];
        final comments = _commentsMap[thread.id] ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.title ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(thread.user?.username ?? "-"),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(DateTimeHelper.formatDateTime(thread.threadDate)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.book, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(thread.book?.title ?? "-", overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Komentari:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_comment),
                      label: const Text("Dodaj komentar"),
                      onPressed: () {
                        _showAddCommentDialog(thread.id!);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                if (comments.isEmpty)
                  const Text("Nema komentara.")
                else
                  Column(
                    children: comments.map((comment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.comment, size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${comment.user?.username ?? '-'} - ${DateTimeHelper.formatDateTime(comment.commentDate)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.comment ?? '-'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _loadThreads();
                }
              : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text("Stranica $_currentPage od $_totalPages"),
        IconButton(
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _loadThreads();
                }
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}



