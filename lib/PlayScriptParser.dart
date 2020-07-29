import 'dart:collection';

import 'package:PlayScriptDartVersion/ASTNode.dart';
import 'package:PlayScriptDartVersion/PlayScriptLexer.dart';
import 'package:PlayScriptDartVersion/Token.dart';
import 'package:PlayScriptDartVersion/TokenReader.dart';

/// A simple parser provide expression and variable's initialization , as well as init statement and assignment statement.
///
/// programm -> intDeclare | expressionStatement | assignmentStatement
/// intDeclare -> 'int' Id ( = additive) ';'
/// expressionStatement -> addtive ';'
/// addtive -> multiplicative ( (+ | -) multiplicative)*
/// multiplicative -> primary ( (* | /) primary)*
/// primary -> IntLiteral | Id | (additive)
class Parser {
  ASTNode parse(String script) {
    return _prog(Lexer().tokenize(script));
  }

  _SimpleASTNode _prog(TokenReader reader) {
    final node = _SimpleASTNode(ASTNodeType.ProgramEntry, 'pwc');

    while (reader.peek() != null) {
      var child = _intDeclare(reader);
      child ??= _expressionStatement(reader);
      child ??= _assignmentStatement(reader);

      if (child != null) {
        node.addChild(child);
      } else {
        throw WrongGrammarException('unknown statement');
      }
    }

    return node;
  }

  _SimpleASTNode _expressionStatement(TokenReader reader) {
    var pos = reader.getPosition();
    var node = _additive(reader);
    if (node != null) {
      final token = reader.peek();
      if (token != null && token.type == TokenType.SemiColon) {
        reader.read();
      } else {
        node = null;
        reader.setPosition(pos);
      }
    }
    return node;
  }

  _SimpleASTNode _assignmentStatement(TokenReader reader) {
    var node;
    var token = reader.peek();
    if (token != null && token.type == TokenType.Identifier) {
      token = reader.read();
      node = _SimpleASTNode(ASTNodeType.AssignmentStmt, token.value);
      token = reader.peek();
      if (token != null && token.type == TokenType.Assignment) {
        reader.read();
        var child = _additive(reader);
        if (child == null) {
          //Error , There is no legal expression to the right of the equal sign
          throw WrongGrammarException(
              'invalide assignment statement, expecting an expression');
        } else {
          node.addChild(child);
          token = reader.peek();
          if (token != null && token.type == TokenType.SemiColon) {
            reader.read();
          } else {
            //Error ，Missing semicolon
            throw Exception('invalid statement, expecting semicolon');
          }
        }
      } else {
        reader.unread();
        node = null;
      }
    }
    return node;
  }

  _SimpleASTNode _intDeclare(TokenReader reader) {

    var node;
    var token = reader.peek();
    if (token != null && token.type == TokenType.Int) {
      token = reader.read();
      if (reader.peek().type == TokenType.Identifier) {
        token = reader.read();
        node =  _SimpleASTNode(ASTNodeType.IntDeclaration, token.value);
        token = reader.peek();
        if (token != null && token.type == TokenType.Assignment) {
          reader.read();  //取出等号
          var child = _additive(reader);
          if (child == null) {
            throw WrongGrammarException('invalide variable initialization, expecting an expression');
          }
          else{
            node.addChild(child);
          }
        }
      } else {
        throw WrongGrammarException('variable name expected');
      }

      if (node != null) {
        token = reader.peek();
        if (token != null && token.type == TokenType.SemiColon) {
          reader.read();
        } else {
          throw WrongGrammarException('invalid statement, expecting semicolon');
        }
      }
    }
    return node;
  }

  _SimpleASTNode _additive(TokenReader reader) {

    var child1 = _multiplicative(reader);  //应用add规则
    var node = child1;
    if (child1 != null) {
      while (true) {                              //循环应用add'规则
        var token = reader.peek();
        if (token != null && (token.type == TokenType.Plus || token.type == TokenType.Minus)) {
          token = reader.read();              //读出加号
          var child2 = _multiplicative(reader);  //计算下级节点
          if (child2 !=null) {
            node = _SimpleASTNode(ASTNodeType.Additive, token.value);
            node.addChild(child1);              //注意，新节点在顶层，保证正确的结合性
            node.addChild(child2);
            child1 = node;
          }else{
            throw WrongGrammarException('invalid additive expression, expecting the right part.');
          }
        } else {
          break;
        }
      }
    }
    return node;
    
  }

  _SimpleASTNode _multiplicative(TokenReader reader) {
    var child1 = _primary(reader);
    var node = child1;

    while (true) {
      var token = reader.peek();
      if (token != null && (token.type == TokenType.Star || token.type == TokenType.Slash)) {
        token = reader.read();
        var child2 = _primary(reader);
        if (child2 != null) {
          node = _SimpleASTNode(ASTNodeType.Multiplicative, token.value);
          node.addChild(child1);
          node.addChild(child2);
          child1 = node;
        }else{
          throw WrongGrammarException('invalid multiplicative expression, expecting the right part.');
        }
      } else {
        break;
      }
    }

    return node;
  }

  _SimpleASTNode _primary(TokenReader reader) {
    var node;
    var token = reader.peek();
    if (token != null) {
      if (token.type == TokenType.IntLiteral) {
        token = reader.read();
        node = _SimpleASTNode(ASTNodeType.IntLiteral, token.value);
      } else if (token.type == TokenType.Identifier) {
        token = reader.read();
        node = _SimpleASTNode(ASTNodeType.Identifier, token.value);
      } else if (token.type == TokenType.LeftParen) {
        reader.read();
        node = _additive(reader);
        if (node != null) {
          token = reader.peek();
          if (token != null && token.type == TokenType.RightParen) {
            reader.read();
          } else {
            throw WrongGrammarException('expecting right parenthesis');
          }
        } else {
          throw WrongGrammarException('expecting an additive expression inside parenthesis');
        }
      }
    }
    return node;  //这个方法也做了AST的简化，就是不用构造一个primary节点，直接返回子节点。因为它只有一个子节点。
  }
}

class WrongGrammarException implements Exception {
  final String _text;

  WrongGrammarException(this._text);

  @override
  String toString() {
    return _text;
  }
}

class _SimpleASTNode implements ASTNode {
  ASTNode _parent;
  final List<ASTNode> _children = <ASTNode>[];
  List<ASTNode> _readonlyChildren;
  final ASTNodeType _type;
  final String _text;

  _SimpleASTNode(this._type, this._text) {
    _readonlyChildren = UnmodifiableListView(_children);
  }

  void addChild(_SimpleASTNode child) {
    if (child != null) {
      _children.add(child);
      child._parent = this;
    }
  }

  @override
  UnmodifiableListView<ASTNode> get children => _readonlyChildren;

  @override
  ASTNode get parent => _parent;

  @override
  String get text => _text;

  @override
  ASTNodeType get type => _type;
}

void printAST(ASTNode node, String indent) {
  final str = dumpAST(node, indent);
  print(str);
}

String dumpAST(ASTNode node, String indent) {
  var str = '$indent${node.type} ${node.text}\n';
  node.children.forEach((element) => {
    str += dumpAST(element, '$indent\t')
  });
  return str;
}
