import 'dart:io';

import 'package:PlayScriptDartVersion/PlayScript.dart';
import 'package:PlayScriptDartVersion/PlayScriptParser.dart';

void main(List<String> args) {
  if (args.isNotEmpty && args[0] == '-v') {
    Script.log_verbose = true;
    print('verbose mode');
  }
  print('Simple script language!');

  final parser = Parser();
  final script = Script();

  var scriptText = '';
  stdout.write('\n>'); //提示符

  while (true) {
    try {
      final line = stdin.readLineSync();
      if (line == 'exit();') {
        print('good bye!');
        break;
      }
      scriptText += line + '\n';
      if (line.endsWith(';')) {
        final tree = parser.parse(scriptText);
        if (Script.log_verbose) {
          printAST(tree, '');
        }

        script.evaluate(tree, '');
      }

      stdout.write('\n>'); //提示符
      scriptText = '';
    } catch (e) {
      print(e);
      stdout.write('\n>'); //提示符
      scriptText = '';
    }
  }
}
