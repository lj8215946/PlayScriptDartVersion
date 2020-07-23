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

  @override
  String toString() {
    return 'Token{type: $type, value: $value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}
