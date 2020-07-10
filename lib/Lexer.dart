
import 'package:PlayScriptDartVersion/Token.dart';
import 'package:PlayScriptDartVersion/TokenReader.dart';

enum DfaState {
  _Initial,

  _If, _Id_if1, _Id_if2, _Else, _Id_else1, _Id_else2, _Id_else3, _Id_else4, _Int, _Id_int1, _Id_int2, _Id_int3, _Id, _GT, _GE,

  _Assignment,

  _Plus, _Minus, _Star, _Slash,

  _SemiColon,
  _LeftParen,
  _RightParen,

  _IntLiteral
}

class Lexer {

  /// Tokennize the [code] string and return a [TokenReader] created by that [code] .
  TokenReader tokenize(String code) {
    List<Token> _tokens = new List();
    StringBuffer tokenText = new StringBuffer();

  }

  /// Return whether or not [codeUnit] is a alpha.
  bool _isAlpha(int codeUnit) {
    return codeUnit >= 'a'.codeUnitAt(0) && codeUnit <= 'z'.codeUnitAt(0) || codeUnit >= 'A'.codeUnitAt(0) && codeUnit <= 'Z'.codeUnitAt(0);
  }

  /// Return whether or not [codeUnit] is a digit.
  bool _isDigit(int codeUnit) {
    return codeUnit >= '0'.codeUnitAt(0) && codeUnit <= '9'.codeUnitAt(0);
  }

  /// Return whether or not [codeUnit] is a digit.
  bool _isBlank(int codeUnit) {
    return codeUnit == ' '.codeUnitAt(0) || codeUnit == '\t'.codeUnitAt(0) || codeUnit == '\n'.codeUnitAt(0);
  }

}