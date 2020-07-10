import 'package:PlayScriptDartVersion/Lexer.dart';
import 'package:PlayScriptDartVersion/Token.dart';

/// A [Token] stream created by [Lexer] .
abstract class TokenReader {

  /// Return current [Token] in token stream and current position move to next. if token stream is empty return null .
  Token read();

  /// Return current [Token] in token stream but current position do not move. if token stream is empty return null .
  Token peek();

  /// Current position in token stream go back by one step .
  void unread();

  /// Return current position in token stream .
  int getPosition();

  /// Set current position to [position] .
  void setPosition(int position);

}