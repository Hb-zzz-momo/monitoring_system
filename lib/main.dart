import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ai_chat_provider.dart';
import 'screens/ai_assistant_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '监控系统',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(39, 99, 255, 1),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DevicePlaceholderScreen(),
    const MonitoringPlaceholderScreen(),
    const AlarmWorkOrderPlaceholderScreen(),
    const AIAssistantScreen(),
    const ProfilePlaceholderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(39, 99, 255, 1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: '3D 设备',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: '实时监测',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: '告警/工单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI 助手',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for other tabs
class DevicePlaceholderScreen extends StatelessWidget {
  const DevicePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D 设备'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '3D 设备视图',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class MonitoringPlaceholderScreen extends StatelessWidget {
  const MonitoringPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时监测'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '实时监测仪表盘',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmWorkOrderPlaceholderScreen extends StatelessWidget {
  const AlarmWorkOrderPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('告警/工单'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '告警中心'),
              Tab(text: '工单列表'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlarmTab(context),
            _buildWorkOrderTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '告警示例',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSampleAlarmCard(context),
      ],
    );
  }

  Widget _buildSampleAlarmCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 4,
              height: 50,
              color: const Color.fromRGBO(240, 68, 56, 1),
            ),
            title: const Text('部件过温告警'),
            subtitle: const Text('电机 A - 温度超过阈值'),
            trailing: const Text('10:30'),
          ),
          // AI Analysis widget would be inserted here
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Show AI analysis
                _showAIAnalysisDemo(context);
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text('AI 告警分析'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(39, 99, 255, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAIAnalysisDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Color.fromRGBO(39, 99, 255, 1)),
            SizedBox(width: 8),
            Text('AI 告警分析'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '这里会显示 AI 对告警的分析:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• 根因分析\n• 潜在风险\n• 建议措施\n• 预防建议'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('创建工单（带 AI 建议）')),
              );
            },
            child: const Text('创建工单'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '工单示例',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSampleWorkOrderCard(context),
      ],
    );
  }

  Widget _buildSampleWorkOrderCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('工单 #12345'),
            subtitle: Text('电机 A - 更换冷却风扇'),
            trailing: Chip(
              label: Text('处理中'),
              backgroundColor: Color.fromRGBO(245, 158, 11, 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showAIWorkOrderDemo(context);
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text('AI 工单建议'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(39, 99, 255, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAIWorkOrderDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Color.fromRGBO(39, 99, 255, 1)),
            SizedBox(width: 8),
            Text('AI 工单建议'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI 建议的工单操作:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• 立即行动\n• 所需备件\n• 预计耗时\n• 优先级评估'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('应用 AI 建议')),
              );
            },
            child: const Text('应用建议'),
          ),
        ],
      ),
    );
  }
}

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '个人设置',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
