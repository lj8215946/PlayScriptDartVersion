import 'package:PlayScriptDartVersion/Lexer.dart';
import 'package:PlayScriptDartVersion/Token.dart';
import 'package:PlayScriptDartVersion/TokenReader.dart';
import 'package:test/test.dart';

void main() {
  test('LexerTokenize_Assignment', () {
    final lexer = Lexer();
    const script = 'int age = 45;';
    expect(
        lexer.tokenize(script),
        SimpleTokenReader([
          Token(TokenType.Int, 'int'),
          Token(TokenType.Identifier, 'age'),
          Token(TokenType.Assignment, '='),
          Token(TokenType.IntLiteral, '45'),
          Token(TokenType.SemiColon, ';')
        ]));
  });

  test('LexerTokenize_Assignment', () {
    final lexer = Lexer();
    const script = 'inta age = 45;';
    expect(
        lexer.tokenize(script),
        SimpleTokenReader([
          Token(TokenType.Identifier, 'inta'),
          Token(TokenType.Identifier, 'age'),
          Token(TokenType.Assignment, '='),
          Token(TokenType.IntLiteral, '45'),
          Token(TokenType.SemiColon, ';')
        ]));
  });

  test('LexerTokenize_Assignment', () {
    final lexer = Lexer();
    const script = 'in age = 45;';
    expect(
        lexer.tokenize(script),
        SimpleTokenReader([
          Token(TokenType.Identifier, 'in'),
          Token(TokenType.Identifier, 'age'),
          Token(TokenType.Assignment, '='),
          Token(TokenType.IntLiteral, '45'),
          Token(TokenType.SemiColon, ';')
        ]));
  });

  test('LexerTokenize_Assignment', () {
    final lexer = Lexer();
    const script = 'age >= 45;';
    expect(
        lexer.tokenize(script),
        SimpleTokenReader([
          Token(TokenType.Identifier, 'age'),
          Token(TokenType.GE, '>='),
          Token(TokenType.IntLiteral, '45'),
          Token(TokenType.SemiColon, ';')
        ]));
  });

  test('LexerTokenize_Assignment', () {
    final lexer = Lexer();
    const script = 'age > 45;';
    expect(
        lexer.tokenize(script),
        SimpleTokenReader([
          Token(TokenType.Identifier, 'age'),
          Token(TokenType.GT, '>'),
          Token(TokenType.IntLiteral, '45'),
          Token(TokenType.SemiColon, ';')
        ]));
  });
}

void dump(TokenReader tokenReader) {
  print('text\ttype\n');
  Token token;
  while ((token = tokenReader.read()) != null) {
    print('$token\n');
  }
}
