from nodes import *


class Parser():
    def __init__(self, token_iterator):
        self.token_iterator = token_iterator
        self.s = None
        self.NTerms = set()
        self.Terms = set()
        self.Rules = set()
        self.Rules_Nterms = set()

    def next_token(self):
        self.s = next(self.token_iterator)

    def check_NTerms(self):
        if len(self.NTerms.intersection(self.Terms)) != 0:
            raise ValueError("Есть непустое пересечение множества нетерминалов и множества терминалов")
        for c in self.Rules_Nterms:
            if c not in self.NTerms:
                raise ValueError("Был встречен неизвестный символ")

    # TOKENS -> 'tokens' NAME (',' NAME)* '.'
    def parse_tokens(self):
        if self.s.token_type == "tokens":
            self.next_token()
        else:
            self.raise_error()

        if self.s.token_type == "NAME":
            self.Terms.add(self.s.value)
            self.next_token()
        else:
            self.raise_error()

        while True:
            if self.s.token_type == "DOT":
                self.next_token()
                break
            elif self.s.token_type == "COMMA":
                self.next_token()
                if self.s.token_type == "NAME":
                    self.Terms.add(self.s.value)
                    self.next_token()
                else:
                    self.raise_error()
            else:
                self.raise_error()

    # RULE -> NAME 'is' TREE? '.'
    def parse_rule(self):
        left = None
        right = []
        if self.s.token_type == "NAME":
            left = self.s.value
            self.NTerms.add(left)
            self.next_token()
        else:
            self.raise_error()

        if self.s.token_type == "IS":
            self.next_token()
        else:
            self.raise_error()

        if self.s.token_type == "DOT":
            right.append(EmptyNode())
            self.Rules.add((left, right))
            self.next_token()
        else:
            right = tuple(self.parse_tree())
            t = (left, right)
            self.Rules.add(t)
            if self.s.token_type == "DOT":
                self.next_token()
            else:
                self.raise_error()

    # TREE_NODE -> 'repeat' '(' TREE ')' | 'alt' '(' TREE? ',' TREE? (',' TREE?)* ')' | NAME
    def parse_tree_node(self):
        if self.s.token_type == "NAME":
            value = self.s.value
            self.next_token()
            if value in self.Terms:
                return TermNode(value)
            else:
                self.Rules_Nterms.add(value)
                return NTermNode(value)
        elif self.s.token_type == "REPEAT":
            self.next_token()
            if self.s.token_type == "LEFT_PAREN":
                self.next_token()
            else:
                self.raise_error()
            node = self.parse_tree()
            if len(node) == 0:
                self.raise_error()
            if self.s.token_type == "RIGHT_PAREN":
                self.next_token()
            else:
                self.raise_error()
            return RepeatNode(node)
        elif self.s.token_type == "ALT":
            self.next_token()
            if self.s.token_type == "LEFT_PAREN":
                self.next_token()
            else:
                self.raise_error()
            alt_node = set()
            tree = self.parse_tree()
            if len(tree) == 0:
                alt_node.add(EmptyNode())
            else:
                alt_node.add(tuple(tree))
            if self.s.token_type == "COMMA":
                self.next_token()
            else:
                self.raise_error()
            tree = self.parse_tree()
            if len(tree) == 0:
                alt_node.add(EmptyNode())
            else:
                alt_node.add(tuple(tree))
            while self.s.token_type == "COMMA":
                self.next_token()
                tree = self.parse_tree()
                if len(tree) == 0:
                    alt_node.add(EmptyNode())
                else:
                    alt_node.add(tuple(tree))
            if self.s.token_type == "RIGHT_PAREN":
                self.next_token()
            else:
                self.raise_error()
            return AltNode(alt_node)
        else:
            return None

    #TREE -> TREE_NODE+
    def parse_tree(self):
        nodes = []
        node = self.parse_tree_node()
        while node is not None:
            nodes.append(node)
            node = self.parse_tree_node()
        return nodes

    # GRAMMAR -> TOKENS RULE+ END
    def parse(self):
        self.next_token()
        self.parse_tokens()
        self.parse_rule()
        while self.s.token_type != "END":
            self.parse_rule()
        self.check_NTerms()
        return self.Terms, self.NTerms, self.Rules

    def raise_error(self):
        raise ValueError(f"Возникла ошибка с токеном {self.s.token_type}: ({self.s.line}, {self.s.position})")
