import 'package:PlayScriptDartVersion/PlayScriptParser.dart';
import 'package:test/test.dart';

void main() {
  test('ParserAST_MultiStatementTest', () {
    final parser = Parser();
    const script = 'int age = 45+2; age= 20; age+10*2;';
    print('解析：$script \n');
    final dumpASTStr = dumpAST(parser.parse(script), '');
    print(dumpASTStr);
    expect(dumpASTStr,
        '''ASTNodeType.ProgramEntry pwc
	ASTNodeType.IntDeclaration age
		ASTNodeType.Additive +
			ASTNodeType.IntLiteral 45
			ASTNodeType.IntLiteral 2
	ASTNodeType.AssignmentStmt age
		ASTNodeType.IntLiteral 20
	ASTNodeType.Additive +
		ASTNodeType.Identifier age
		ASTNodeType.Multiplicative *
			ASTNodeType.IntLiteral 10
			ASTNodeType.IntLiteral 2\n''');
  });

  //测试异常语法
  test('ParserAST_MultiStatementTest', () {
    try {
      final parser = Parser();
      const script = '2+3+;';
      print('\n解析：$script \n');
      expect(parser.parse(script), throwsA(TypeMatcher<WrongGrammarException>()));
    } on WrongGrammarException catch (e) {
      print('$e \n');
    }
  });


  test('ParserAST_MultiStatementTest', () {
    try {
      final parser = Parser();
      const script = '2+3*;';
      print('\n解析：$script \n');
      expect(parser.parse(script), throwsA(TypeMatcher<WrongGrammarException>()));
    } on WrongGrammarException catch (e) {
      print('$e \n');
    }
  });

}
