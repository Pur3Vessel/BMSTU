from grammar import Term, Nterm, Rule, Grammar, Epsilon


class Parser:

    def __init__(self, string):
        self.string = ''.join(filter(lambda x: not str.isspace(x), string))
        self.start = False

    def glance(self):
        if self.string == '':
            return False
        return self.string[0]

    def next(self):
        if self.string == '':
            return False
        ret = self.string[0]
        self.string = self.string[1:]
        return ret

    def get_term_or_nonterm_or_eps(self):
        if self.glance() == 'ε':
            self.next()
            return Epsilon()
        if self.glance().isalpha():
            next_sym = self.next()
            if str.isupper(next_sym):
                if not self.start:
                    self.start = Nterm(next_sym)
                return Nterm(next_sym)
            else:
                return Term(next_sym)
        return False

    def get_arrow(self):
        if self.glance() == '-':
            if self.next() == '-' and self.next() == '>':
                return '->'
            else:
                raise Exception('Not arrow')

        return False

    def parse_seq(self):
        things = []
        while self.string:
            to_append = self.get_term_or_nonterm_or_eps() or self.get_arrow()
            if not to_append:
                break
            things.append(to_append)

        assert self.string == ''
        return list(filter(bool, things))

    def parse_rules(self):
        seq = self.parse_seq()
        rules_set = set()
        rules_raw = []
        arrow_index = -1
        while arrow_index:
            try:
                arrow_index = seq.index('->')
                second_arrow_index = seq.index('->', arrow_index + 1)
            except:
                rules_raw.append(seq)
                break

            rules_raw.append(seq[:second_arrow_index - 1])
            seq = seq[second_arrow_index - 1:]

        for rule_list in rules_raw:
            assert rule_list[1] == '->'
            new_rule = Rule(rule_list[0], rule_list[2:])
            rules_set.add(new_rule)

        return Grammar(rules_set, self.start)
