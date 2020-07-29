import 'dart:collection';

import 'ASTNode.dart';

class Script {
  static var log_verbose = false;

  var variables = HashMap<String, int>();

  int evaluate(ASTNode node, String indent) {
    var result;
    if (log_verbose) {
      print(indent + 'Calculating: ${node.type}');
    }

    switch (node.type) {
      case ASTNodeType.ProgramEntry:
        node.children.forEach((child) {
          result = evaluate(child, indent);
        });
        break;
      case ASTNodeType.Additive:
        var child1 = node.children[0];
        var value1 = evaluate(child1, indent + '\t');
        var child2 = node.children[1];
        var value2 = evaluate(child2, indent + '\t');
        if (node.text == '+') {
          result = value1 + value2;
        } else {
          result = value1 - value2;
        }
        break;
      case ASTNodeType.Multiplicative:
        var child1 = node.children[0];
        var value1 = evaluate(child1, indent + '\t');
        var child2 = node.children[1];
        var value2 = evaluate(child2, indent + '\t');
        if (node.text == '*') {
          result = value1 * value2;
        } else {
          result = (value1 / value2).round();
        }
        break;
      case ASTNodeType.IntLiteral:
        result = int.parse(node.text);
        break;
      case ASTNodeType.Identifier:
        var varName = node.text;
        if (variables.containsKey(varName)) {
          var value = variables[varName];
          if (value != null) {
            result = value;
          } else {
            throw Exception( 'variable ' + varName + ' has not been set any value');
          }
        } else {
          throw Exception('unknown variable: ' + varName);
        }
        break;
      case ASTNodeType.AssignmentStmt:
        var varName = node.text;
        if (!variables.containsKey(varName)) {
          throw Exception('unknown variable: ' + varName);
        } //接着执行下面的代码
        var varValue;
        if (node.children.isNotEmpty) {
          var child = node.children[0];
          result = evaluate(child, indent + '\t');
          varValue = result;
        }
        variables[varName] = varValue;
        break;
      case ASTNodeType.IntDeclaration:
        var varName = node.text;
        var varValue;
        if (node.children.isNotEmpty) {
          var child = node.children[0];
          result = evaluate(child, indent + '\t');
          varValue = result;
        }
        variables[varName] = varValue;
        break;

      default:
    }

    if (log_verbose) {
      print(indent + 'Result: ' + result);
    } else if (indent == '') {
      // 顶层的语句
      if (node.type == ASTNodeType.IntDeclaration ||
          node.type == ASTNodeType.AssignmentStmt) {
        print('${node.text}: ${result}');
      } else if (node.type != ASTNodeType.ProgramEntry) {
        print(result);
      }
    }
    return result;
  }
}
