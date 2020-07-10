enum TokenType {
  Plus, // +
  Minus, // -
  Star, // *
  Slash, // /

  GE, // >=
  GT, // >
  EQ, // ==
  LE, // <=
  LT, // <

  SemiColon, // ;
  LeftParen, // (
  RightParen, // )

  Assignment, // =

  If,
  Else,

  Int,
  Identifier,
  IntLiteral,
  StringLiteral
}

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);
}
