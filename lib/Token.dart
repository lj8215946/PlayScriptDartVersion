enum TokenType {
  Indentify,
}

class Token {

  final TokenType type;
  final String value;

  Token(this.type, this.value);

}