import 'package:flutter/material.dart';

class CustomFlowPage extends StatefulWidget {
  @override
  _CustomFlowPageState createState() => _CustomFlowPageState();
}

class _CustomFlowPageState extends State<CustomFlowPage> {
  late BackButtonDispatcher _backButtonDispatcher;
  late FlowRouterDelegate _routerDelegate;

  @override
  void initState() {
    super.initState();
    _routerDelegate = FlowRouterDelegate(FlowState());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher.takePriority();

    return Router(
      routerDelegate: _routerDelegate,
      backButtonDispatcher: _backButtonDispatcher,
    );
  }
}

class CustomFlowPage1 extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final void Function(String name) onSubmitted;

  CustomFlowPage1({required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(controller: _nameController),
          ElevatedButton(
            onPressed: () => onSubmitted(_nameController.text),
            child: Text('Next'),
          )
        ],
      ),
    );
  }
}

class CustomFlowPage2 extends StatelessWidget {
  final String name;
  CustomFlowPage2({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [Text('Hello, $name!')],
      ),
    );
  }
}

class FlowState {
  String? name;
}

class FlowRouterDelegate extends RouterDelegate<void>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<void> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  FlowState get flowState => _flowState;
  FlowState _flowState;
  set flowState(FlowState value) {
    if (value == _flowState) {
      return;
    }
    _flowState = value;
    notifyListeners();
  }

  FlowRouterDelegate(this._flowState);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(child: CustomFlowPage1(
          onSubmitted: (name) {
            flowState.name = name;
            notifyListeners();
          },
        )),
        if (flowState.name != null)
          MaterialPage(child: CustomFlowPage2(name: flowState.name!)),
      ],
      onPopPage: (route, result) {
        notifyListeners();
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(void path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }
}
