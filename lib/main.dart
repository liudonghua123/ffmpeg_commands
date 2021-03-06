import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/constans.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import 'effects.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: defaultPrimaryColor,
        brightness: Brightness.dark,
        accentColor: Colors.black45,
      ),
      home: HomePage(title: title),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _widthFormController = TextEditingController();
  final TextEditingController _heightFormController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  var enables = {
    'enableTrim': false,
    'enableScale': false,
    'enableWatermark': false,
  };
  var colors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.grey,
    Colors.white,
  ];
  var colorNames = [
    'black',
    'red',
    'green',
    'blue',
    'purple',
    'grey',
    'white',
  ];

  Widget _buildStaticSection(String title, List<Widget> children) {
    return Card(
      color: Colors.white.withOpacity(0.3),
      elevation: cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(contentMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(title),
              leading: Icon(
                Icons.info,
                color: Colors.green,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSection(
      String title, List<Widget> children, String enableField) {
    return Card(
      color: Colors.white.withOpacity(0.3),
      elevation: cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(contentMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(title),
              value: enables[enableField],
              onChanged: (bool value) {
                setState(() {
                  enables[enableField] = value;
                  if (value) {
                    _scrollController.animateTo(
                      // https://stackoverflow.com/questions/43485529/programmatically-scrolling-to-the-end-of-a-listview
                      // _scrollController.position.maxScrollExtent not work
                      _scrollController.offset +
                          _scrollController.position.extentInside,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                });
              },
              secondary: const Icon(
                Icons.settings,
                color: Colors.blue,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: enables[enableField]
                  ? Column(
                      children: children,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _widthFormController.dispose();
    _heightFormController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: [
        Positioned.fill(child: AnimatedBackground()),
        Positioned.fill(child: Particles(30)),
        SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: horizontalMargin, vertical: verticalMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  initialValue: <String, Object>{
                    'input': 'sample.mp4',
                    'output': 'output.mp4',
                  },
                  autovalidate: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      /// input/output settings
                      _buildStaticSection(
                        '输入输出设置',
                        [
                          FormBuilderTextField(
                            attribute: "input",
                            decoration: InputDecoration(
                              labelText: "输入文件",
                            ),
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: '输入文件不能为空'),
                            ],
                          ),

                          ///output
                          FormBuilderTextField(
                            attribute: "output",
                            decoration: InputDecoration(
                              labelText: "输出文件",
                            ),
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: '输出文件不能为空'),
                            ],
                          ),
                        ],
                      ),

                      /// basic compress settings
                      _buildStaticSection(
                        '压缩基本参数',
                        [
                          FormBuilderSlider(
                            attribute: "crf",
                            min: 0,
                            max: 60,
                            initialValue: 28,
                            divisions: 60,
                            decoration: InputDecoration(
                              labelText: "crf",
                            ),
                            numberFormat: NumberFormat("##", 'en_US'),
                          ),
                          FormBuilderDropdown(
                            attribute: "preset",
                            decoration: InputDecoration(
                              labelText: "preset",
                            ),
                            initialValue: 'medium',
                            hint: Text('Select preset'),
                            validators: [FormBuilderValidators.required()],
                            items: [
                              'ultrafast',
                              'superfast',
                              'veryfast',
                              'faster',
                              'fast',
                              'medium',
                              'slow',
                              'slower',
                              'veryslow',
                              'placebo',
                            ]
                                .map((preset) => DropdownMenuItem(
                                    value: preset, child: Text("$preset")))
                                .toList(),
                          ),
                        ],
                      ),

                      /// trim settings
                      _buildSwitchSection(
                        '视频片段裁剪设置',
                        [
                          FormBuilderTextField(
                            attribute: "startTime",
                            initialValue: "00:00:00",
                            decoration: InputDecoration(
                              labelText: "开始时间",
                            ),
                          ),
                          FormBuilderTextField(
                            attribute: "endTime",
                            initialValue: "00:00:00",
                            decoration: InputDecoration(
                              labelText: "结束时间",
                            ),
                          ),
                        ],
                        'enableTrim',
                      ),

                      /// trim settings
                      _buildSwitchSection(
                        '分辨率设置',
                        [
                          FormBuilderTextField(
                            attribute: "width",
                            controller: _widthFormController,
                            decoration: InputDecoration(
                              labelText: "width",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.build),
                                onPressed: () {
                                  setState(() {
                                    _widthFormController.text = '-1';
                                  });
                                },
                              ),
                            ),
                          ),
                          FormBuilderTextField(
                            attribute: "height",
                            controller: _heightFormController,
                            decoration: InputDecoration(
                              labelText: "height",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.build),
                                onPressed: () {
                                  setState(() {
                                    _heightFormController.text = '-1';
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                        'enableScale',
                      ),

                      /// trim settings
                      _buildSwitchSection(
                        '水印设置',
                        [
                          FormBuilderTextField(
                            attribute: "text",
                            decoration: InputDecoration(
                              labelText: "水印文本",
                            ),
                          ),
                          FormBuilderDropdown(
                            attribute: "position",
                            decoration: InputDecoration(
                              labelText: "位置",
                            ),
                            initialValue: Alignment.bottomCenter,
                            hint: Text('Select position'),
                            validators: [FormBuilderValidators.required()],
                            items: [
                              Alignment.topLeft,
                              Alignment.topCenter,
                              Alignment.topRight,
                              Alignment.centerLeft,
                              Alignment.center,
                              Alignment.centerRight,
                              Alignment.bottomLeft,
                              Alignment.bottomCenter,
                              Alignment.bottomRight,
                            ]
                                .map((Alignment position) => DropdownMenuItem(
                                    value: position, child: Text("$position")))
                                .toList(),
                          ),
                          FormBuilderTouchSpin(
                            attribute: "fontsize",
                            initialValue: 12,
                            step: 1,
                            min: 8,
                            max: 72,
                            decoration: InputDecoration(
                              labelText: "字体大小",
                            ),
                          ),
                          FormBuilderDropdown(
                            attribute: "fontcolor",
                            decoration: InputDecoration(
                              labelText: "字体颜色",
                            ),
                            initialValue: 'black',
                            hint: Text('Select color'),
                            validators: [FormBuilderValidators.required()],
                            items: colors.asMap().entries.map((entry) {
                              int index = entry.key;
                              Color color = entry.value;
                              return DropdownMenuItem(
                                value: colorNames[index],
                                child: Container(
                                  height: 30,
                                  color: color,
                                  child: Center(
                                    child: FittedBox(
                                      child: Text("${colorNames[index]}"),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        'enableWatermark',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // contruct the final commands
          if (_fbKey.currentState.saveAndValidate()) {
            print(_fbKey.currentState.value);
            String commands =
                "ffmpeg -i ${_fbKey.currentState.value['input']} ${getBasicCompress()} ${getTrim()} ${getScale()} ${getWatermark()} -o ${_fbKey.currentState.value['output']}";
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text(commands)));
            ClipboardData data = new ClipboardData(text: commands);
            Clipboard.setData(data);
          } else {
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text('输入校验有误，请重试！')));
          }
        },
        child: Icon(Icons.assignment_turned_in),
      ),
    );
  }

  String getBasicCompress() {
    return '-crf ${_fbKey.currentState.value['crf']} -preset ${_fbKey.currentState.value['preset']}';
  }

  String getTrim() {
    if (!enables['enableTrim']) {
      return '';
    }
    return '-ss ${_fbKey.currentState.value['startTime']} -t ${_fbKey.currentState.value['endTime']}';
  }

  String getScale() {
    if (!enables['enableScale']) {
      return '';
    }
    return '-vf "scale=${_fbKey.currentState.value['width']}:${_fbKey.currentState.value['height']}"';
  }

  String getWatermark() {
    if (!enables['enableWatermark']) {
      return '';
    }
    Alignment position = _fbKey.currentState.value['position'] as Alignment;
    double x = position.x;
    double y = position.y;
    String xStr, yStr;
    if (x == -1.0) {
      xStr = '10';
    } else if (x == 0.0) {
      xStr = '(w-text_w)/2';
    } else if (x == 1.0) {
      xStr = 'w-text_w-10';
    }
    if (y == -1.0) {
      yStr = '10';
    } else if (y == 0.0) {
      yStr = '(h-text_h)/2';
    } else if (y == 1.0) {
      yStr = 'h-text_h-10';
    }
    return '-vf "drawtext=text=\'${_fbKey.currentState.value['text']}\':x=${xStr}:y=${yStr}:fontsize=${_fbKey.currentState.value['fontsize']}:fontcolor=${_fbKey.currentState.value['fontcolor']}"';
  }
}
