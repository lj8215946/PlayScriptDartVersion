import 'dart:collection';

import 'package:PlayScriptDartVersion/ASTNode.dart';

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

  }


}


class _SimpleASTNode implements ASTNode {
  ASTNode _parent;
  final List<ASTNode> _children = <ASTNode>[];
  UnmodifiableListView<ASTNode> _readonlyChildren;
  final ASTNodeType _type;
  final String _text;

  _SimpleASTNode(this._type, this._text) {
    _readonlyChildren = UnmodifiableListView(_children);
  }

  void addChild(_SimpleASTNode child) {
    if (child != null) {
      children.add(child);
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

void dumpAST(ASTNode node, String indent) {
  print('$indent${node.type} ${node.text}');
  node.children.forEach((element) => dumpAST(element, '$indent\t'));
}
