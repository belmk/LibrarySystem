import 'package:elibrary_mobile/models/book.dart';
import 'package:elibrary_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:elibrary_mobile/models/forum_thread.dart';
import 'package:elibrary_mobile/models/forum_comment.dart';
import 'package:elibrary_mobile/providers/forum_thread_provider.dart';
import 'package:elibrary_mobile/providers/forum_comment_provider.dart';
import 'package:elibrary_mobile/providers/book_provider.dart';
import 'package:elibrary_mobile/providers/user_provider.dart';

class MobileForumScreen extends StatefulWidget {
  const MobileForumScreen({super.key});

  @override
  State<MobileForumScreen> createState() => _MobileForumScreenState();
}

class _MobileForumScreenState extends State<MobileForumScreen> {
  final ForumThreadProvider _threadProvider = ForumThreadProvider();
  final ForumCommentProvider _commentProvider = ForumCommentProvider();

  List<ForumThread> _threads = [];
  Map<int, List<ForumComment>> _comments = {};

  bool _loading = true;
  String? _error;
  User? _me;

  final TextEditingController _titleFilter = TextEditingController();
  final TextEditingController _bookFilter = TextEditingController();
  final TextEditingController _userFilter = TextEditingController();

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;
  int get _totalPages => _totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    try {
      _me = await UserProvider().getMe();
      await _loadThreads();
    } catch (e) {
      setState(() {
        _error = "Greška: $e";
        _loading = false;
      });
    }
  }

  Future<void> _loadThreads() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _threadProvider.get(filter: {
        "ForumTitle": _titleFilter.text.trim(),
        "BookTitle": _bookFilter.text.trim(),
        "Username": _userFilter.text.trim(),
        "Page": _currentPage - 1,
        "PageSize": _pageSize,
      });

      _threads = result.result;
      _totalCount = result.count ?? 0;

      for (var t in _threads) {
        final commentResult =
            await _commentProvider.get(filter: {"ForumThreadId": t.id});
        _comments[t.id!] = commentResult.result;
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Greška: $e";
      });
    }
  }

  void _resetFilters() {
    _titleFilter.clear();
    _bookFilter.clear();
    _userFilter.clear();
    setState(() => _currentPage = 1);
    _loadThreads();
  }

  void _showAddCommentDialog(int threadId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dodaj komentar"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Vaš komentar...",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Otkaži"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Objavi"),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              try {
                await _commentProvider.insert({
                  "ForumThreadId": threadId,
                  "UserId": _me!.id,
                  "Comment": controller.text.trim(),
                  "CommentDate": DateTime.now().toIso8601String(),
                });

                Navigator.pop(context);
                await _loadThreads();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Greška: $e")),
                );
              }
            },
          )
        ],
      ),
    );
  }

  void _showAddThreadDialog() {
    final title = TextEditingController();
    Book? selectedBook;
    List<Book> books = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          if (books.isEmpty) {
            BookProvider().get().then((res) {
              setState(() => books = res.result);
            });
          }

          return AlertDialog(
            title: const Text("Nova tema"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: "Naslov",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Book>(
                  value: selectedBook,
                  items: books
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.title ?? "-"),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Knjiga",
                  ),
                  onChanged: (b) => setState(() => selectedBook = b),
                )
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Otkaži"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text("Objavi"),
                onPressed: () async {
                  if (title.text.isEmpty || selectedBook == null) return;

                  await _threadProvider.insert({
                    "Title": title.text.trim(),
                    "UserId": _me!.id,
                    "BookId": selectedBook!.id,
                    "ThreadDate": DateTime.now().toIso8601String(),
                  });

                  Navigator.pop(context);
                  await _loadThreads();
                },
              ),
            ],
          );
        });
      },
    );
  }

 Widget _buildFilterSection() {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      children: [
        TextField(
          controller: _titleFilter,
          decoration: const InputDecoration(
            labelText: 'Naslov teme',
            prefixIcon: Icon(Icons.forum_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _bookFilter,
          decoration: const InputDecoration(
            labelText: 'Knjiga',
            prefixIcon: Icon(Icons.menu_book_outlined),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _userFilter,
          decoration: const InputDecoration(
            labelText: 'Korisnik',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                setState(() => _currentPage = 1);
                _loadThreads();
              },
              icon: const Icon(Icons.search, color: Colors.blueAccent),
              tooltip: 'Pretraži',
            ),
            IconButton(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              tooltip: 'Resetuj filtere',
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadThreads();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text("Stranica $_currentPage od $_totalPages"),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadThreads();
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadCard(ForumThread t) {
    final comments = _comments[t.id] ?? [];

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          t.title ?? "-",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Knjiga: ${t.book?.title ?? '-'}\nAutor: ${t.user?.username ?? '-'}",
        ),
        children: [
          ...comments.map(
            (c) => ListTile(
              leading: const Icon(Icons.comment),
              title: Text(c.comment ?? ""),
              subtitle: Text("${c.user?.username} — ${c.commentDate}"),
            ),
          ),

          TextButton.icon(
            icon: const Icon(Icons.add_comment),
            label: const Text("Dodaj komentar"),
            onPressed: () => _showAddCommentDialog(t.id!),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showAddThreadDialog,
      ),
      body: RefreshIndicator(
        onRefresh: _loadThreads,
        child: ListView(
          children: [
            _buildFilterSection(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                    child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                )),
              )
            else
              ..._threads.map(_buildThreadCard),

            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}
