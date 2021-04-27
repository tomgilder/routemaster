import 'package:deep_linking/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArticlePage extends StatefulWidget {
  final String id;

  const ArticlePage({required this.id});

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Article? _article;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  void _loadArticle() async {
    final api = Provider.of<Api>(context, listen: false);

    final response = await api.getArticle(articleId: widget.id);
    if (response is ApiSuccess<Article>) {
      // Success, show the article. Auth failure is handled globally.
      setState(() => _article = response.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_article == null) {
      // Loading spinner
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Article ${widget.id}',
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(height: 20),
          Text('Hello this is article ${widget.id}'),
        ],
      ),
    );
  }
}
