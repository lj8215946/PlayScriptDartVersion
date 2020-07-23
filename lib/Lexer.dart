import 'package:PlayScriptDartVersion/Token.dart';
import 'package:PlayScriptDartVersion/TokenReader.dart';
import 'package:collection/collection.dart';

enum _DfaState {
//  If,
//  Id_if1,
//  Id_if2,
//  Else,
//  Id_else1,
//  Id_else2,
//  Id_else3,
//  Id_else4,
  Int,
  Initial,
  Id_int1,
  Id_int2,
  Id_int3,
  Id,
  GT,
  GE,
  Assignment,
  Plus,
  Minus,
  Star,
  Slash,
  SemiColon,
  LeftParen,
  RightParen,
  IntLiteral
}

class _TokenWorkingData {
  _DfaState state;
  TokenType tokenType;
  StringBuffer tokenText;

  Token createToken() {
    var token = Token(tokenType, tokenText.toString());
    tokenText = StringBuffer();
    return token;
  }
}

class Lexer {
  static var FIRST_LETTER_TO_DFA_STATE_MAP = <bool Function(int), _DfaState>{
    (int ch) => _isCharEqualsStringFirstLetter(ch, 'i'): _DfaState.Id_int1,
    (int ch) => _isAlpha(ch): _DfaState.Id,
    //进入Id状态
    (int ch) => _isDigit(ch): _DfaState.IntLiteral,
    //第一个字符是数字
    (int ch) => _isCharEqualsStringFirstLetter(ch, '>'): _DfaState.GT,
    //第一个字符是>
    (int ch) => _isCharEqualsStringFirstLetter(ch, '+'): _DfaState.Plus,
    (int ch) => _isCharEqualsStringFirstLetter(ch, '-'): _DfaState.Minus,
    (int ch) => _isCharEqualsStringFirstLetter(ch, '*'): _DfaState.Star,
    (int ch) => _isCharEqualsStringFirstLetter(ch, '/'): _DfaState.Slash,
    (int ch) => _isCharEqualsStringFirstLetter(ch, ';'): _DfaState.SemiColon,
    (int ch) => _isCharEqualsStringFirstLetter(ch, '('): _DfaState.LeftParen,
    (int ch) => _isCharEqualsStringFirstLetter(ch, ')'): _DfaState.RightParen,
    (int ch) => _isCharEqualsStringFirstLetter(ch, '='): _DfaState.Assignment,
  };

  static const DFA_STATE_TO_TOKEN_TYPE_MAP = <_DfaState, TokenType>{
    _DfaState.Id_int1: TokenType.Identifier,
    _DfaState.Id: TokenType.Identifier,
    _DfaState.IntLiteral: TokenType.IntLiteral,
    _DfaState.GT: TokenType.GT,
    _DfaState.Plus: TokenType.Plus,
    _DfaState.Minus: TokenType.Minus,
    _DfaState.Star: TokenType.Star,
    _DfaState.Slash: TokenType.Slash,
    _DfaState.SemiColon: TokenType.SemiColon,
    _DfaState.LeftParen: TokenType.LeftParen,
    _DfaState.RightParen: TokenType.RightParen,
    _DfaState.Assignment: TokenType.Assignment,
  };

  /// Tokennize the [code] string and return a [TokenReader] created by that [code] .
  TokenReader tokenize(String code) {
    var tokens = <Token>[];

    var curState = _DfaState.Initial;

    final workingData = _TokenWorkingData();
    workingData.tokenText = StringBuffer();

    for (var index = 0; index < code.length; index++) {
      final ch = code.codeUnitAt(index);
      switch (curState) {
        case _DfaState.Initial:
          curState = _initToken(ch, workingData, tokens).state;
          break;
        case _DfaState.Id:
          if (_isAlpha(ch) || _isDigit(ch)) {
            workingData.tokenText.writeCharCode(ch); //保持标识符状态
          } else {
            curState =
                _initToken(ch, workingData, tokens).state; //退出标识符状态，并保存Token
          }
          break;
        case _DfaState.GT:
          if (_isCharEqualsStringFirstLetter(ch, '=')) {
            workingData.tokenType = TokenType.GE; //转换成GE
            curState = _DfaState.GE;
            workingData.tokenText.writeCharCode(ch);
          } else {
            curState =
                _initToken(ch, workingData, tokens).state; //退出GT状态，并保存Token
          }
          break;
        case _DfaState.GE:
        case _DfaState.Assignment:
        case _DfaState.Plus:
        case _DfaState.Minus:
        case _DfaState.Star:
        case _DfaState.Slash:
        case _DfaState.SemiColon:
        case _DfaState.LeftParen:
        case _DfaState.RightParen:
          curState =
              _initToken(ch, workingData, tokens).state; //退出当前状态，并保存Token
          break;
        case _DfaState.IntLiteral:
          if (_isDigit(ch)) {
            workingData.tokenText.writeCharCode(ch); //继续保持在数字字面量状态
          } else {
            curState =
                _initToken(ch, workingData, tokens).state; //退出当前状态，并保存Token
          }
          break;
        case _DfaState.Id_int1:
          if (_isCharEqualsStringFirstLetter(ch, 'n')) {
            curState = _DfaState.Id_int2;
            workingData.tokenText.writeCharCode(ch);
          } else if (_isDigit(ch) || _isAlpha(ch)) {
            curState = _DfaState.Id; //切换回Id状态
            workingData.tokenText.writeCharCode(ch);
          } else {
            curState = _initToken(ch, workingData, tokens).state;
          }
          break;
        case _DfaState.Id_int2:
          if (_isCharEqualsStringFirstLetter(ch, 't')) {
            curState = _DfaState.Id_int3;
            workingData.tokenText.writeCharCode(ch);
          } else if (_isDigit(ch) || _isAlpha(ch)) {
            curState = _DfaState.Id; //切换回id状态
            workingData.tokenText.writeCharCode(ch);
          } else {
            curState = _initToken(ch, workingData, tokens).state;
          }
          break;
        case _DfaState.Id_int3:
          if (_isBlank(ch)) {
            workingData.tokenType = TokenType.Int;
            curState = _initToken(ch, workingData, tokens).state;
          } else {
            curState = _DfaState.Id; //切换回Id状态
            workingData.tokenText.writeCharCode(ch);
          }
          break;
        default:
      }
    }

    _finishLastTokenIfNeeds(workingData, tokens);

    return SimpleTokenReader(tokens);
  }

  void _finishLastTokenIfNeeds(
      _TokenWorkingData tokenWorkingData, List<Token> tokens) {
    if (tokenWorkingData.tokenText.length > 0) {
      tokens.add(tokenWorkingData.createToken());
    }
  }

  /// Init Current Token State By [ch] .
  _TokenWorkingData _initToken(
      int ch, _TokenWorkingData tokenWorkingData, List<Token> tokens) {
    _finishLastTokenIfNeeds(tokenWorkingData, tokens);

    var newState = _DfaState.Initial;
    for (var entry in FIRST_LETTER_TO_DFA_STATE_MAP.entries) {
      if (entry.key(ch)) {
        newState = entry.value;
        break;
      }
    }

    tokenWorkingData.state = newState;
    if (newState != _DfaState.Initial) {
      tokenWorkingData.tokenType = DFA_STATE_TO_TOKEN_TYPE_MAP[newState];
      tokenWorkingData.tokenText.writeCharCode(ch);
    }

    return tokenWorkingData;
  }

  /// Return whether or not [codeUnit] is a alpha.
  static bool _isAlpha(int codeUnit) {
    return codeUnit >= 'a'.codeUnitAt(0) && codeUnit <= 'z'.codeUnitAt(0) ||
        codeUnit >= 'A'.codeUnitAt(0) && codeUnit <= 'Z'.codeUnitAt(0);
  }

  /// Return whether or not [codeUnit] is a digit.
  static bool _isDigit(int codeUnit) {
    return codeUnit >= '0'.codeUnitAt(0) && codeUnit <= '9'.codeUnitAt(0);
  }

  /// Return whether or not [codeUnit] is a digit.
  static bool _isBlank(int codeUnit) {
    return codeUnit == ' '.codeUnitAt(0) ||
        codeUnit == '\t'.codeUnitAt(0) ||
        codeUnit == '\n'.codeUnitAt(0);
  }

  static bool _isCharEqualsStringFirstLetter(int ch, String str) {
    return ch == str.codeUnitAt(0);
  }
}

///Encapsulate the Token list to provide streaming access capabilities
class SimpleTokenReader implements TokenReader {
  final List<Token> _tokens;
  int _pos;

  SimpleTokenReader(this._tokens) {
    _pos = 0;
  }

  @override
  Token read() {
    if (_pos < _tokens.length) {
      return _tokens[_pos++];
    }
    return null;
  }

  @override
  Token peek() {
    if (_pos < _tokens.length) {
      return _tokens[_pos++];
    }
    return null;
  }

  @override
  void unread() {
    if (_pos > 0) {
      _pos--;
    }
  }

  @override
  int getPosition() {
    return _pos;
  }

  @override
  void setPosition(int position) {
    if (position >= 0 && position < _tokens.length) {
      _pos = position;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleTokenReader &&
          runtimeType == other.runtimeType &&
          IterableEquality().equals(_tokens, other._tokens) &&
          _pos == other._pos;

  @override
  int get hashCode => _tokens.hashCode ^ _pos.hashCode;

  @override
  String toString() {
    return 'SimpleTokenReader{_tokens: $_tokens, _pos: $_pos}';
  }
}
