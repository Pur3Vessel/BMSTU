import self_table
from table_generator.gen_lexer import Lexer_self
from predicrer import Predicter
import table_generator.table_generator

if __name__ == "__main__":
    with open('input/input_grammar.txt') as f:
        text1 = f.read()
    with open('input/input_grammar1.txt') as f:
        text2 = f.read()

    lexer_grammar = Lexer_self(text1 + "$")
    lexer_grammar_self = Lexer_self(text2 + "$")
    try:
        iterator_grammar = lexer_grammar.tokenize()
        iterator_grammar_self = lexer_grammar_self.tokenize()
        terminals_grammar, nonterminals_grammar, table_grammar, axiom_grammar = self_table.terminals, self_table.nonterminals, self_table.table, self_table.axiom
        predicter_grammar = Predicter(iterator_grammar, terminals_grammar, nonterminals_grammar, table_grammar,
                                      axiom_grammar)
        predicter_grammar_self = Predicter(iterator_grammar_self, terminals_grammar, nonterminals_grammar,
                                           table_grammar, axiom_grammar)

        root = predicter_grammar.top_down_parse()
        root_self = predicter_grammar_self.top_down_parse()

        with open('graphs/graph1.dot', 'w') as f:
            f.write('digraph {\n')
            root.print_graph(f)
            f.write('}')
        with open('graphs/graph_self1.dot', 'w') as f:
            f.write('digraph {\n')
            root_self.print_graph(f)
            f.write('}')


        terminals, nonterminals, rules, axiom = table_generator.table_generator.expand_grammar(root)
        terminals_self, nonterminals_self, rules_self, axiom_self = table_generator.table_generator.expand_grammar(
            root_self)

        first = table_generator.table_generator.make_first(nonterminals, terminals, rules)
        first_self = table_generator.table_generator.make_first(nonterminals_self, terminals_self, rules_self)

        follow = table_generator.table_generator.make_follow(nonterminals, terminals, rules, axiom, first)
        follow_self = table_generator.table_generator.make_follow(nonterminals_self, terminals_self, rules_self,
                                                                  axiom_self, first_self)

        table_generator.table_generator.make_table(terminals, nonterminals, rules, first, follow, axiom,
                                                   "arith_table1.py")
        table_generator.table_generator.make_table(terminals_self, nonterminals_self, rules_self,
                                                   first_self, follow_self, axiom_self, "self_table1.py")



    except ValueError as v:
        print(v)
