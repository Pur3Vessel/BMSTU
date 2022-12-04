from copy import deepcopy


class Rule:
    def __init__(self, left, rights):
        assert len(rights) > 0
        self.left = left
        if set(rights) == {Epsilon()}:
            self.rights = [Epsilon()]
        else:
            self.rights = list(filter(lambda x: x != Epsilon(), rights))

    def __hash__(self):
        return len(str(self.left)) + len(str(self.rights))

    def __eq__(self, o):
        return isinstance(o, Rule) and self.left == o.left and self.rights == o.rights

    def __repr__(self):
        return f'{str(self.left)} -> {"".join(map(str, self.rights))}'

    def __str__(self):
        return f'{str(self.left)} -> {"".join(map(str, self.rights))}'


class Term:
    def __init__(self, symbol):
        assert ord('a') <= ord(symbol) <= ord('z') or symbol == '$'
        self.symbol = symbol

    def __hash__(self):
        return ord(self.symbol)

    def __eq__(self, o):
        return isinstance(o, Term) and self.symbol == o.symbol

    def __repr__(self):
        return self.symbol

    def __str__(self):
        return self.symbol


class Nterm:
    def __init__(self, name):
        self.name = name

    def __hash__(self):
        return ord(self.name[-1])

    def __eq__(self, o):
        return isinstance(o, Nterm) and self.name == o.name

    def __repr__(self):
        return self.name

    def __str__(self):
        return self.name


class Epsilon:
    def __init__(self):
        self.symbol = 'ε'

    def __hash__(self):
        return ord(self.symbol)

    def __eq__(self, o):
        return isinstance(o, Epsilon) and self.symbol == o.symbol

    def __repr__(self):
        return self.symbol

    def __str__(self):
        return self.symbol


class Grammar:
    def __init__(self, rules, start):
        self.k = None
        self.parent_relations = None
        self.child_relations = None
        self.rules = rules
        self.terminals = self.get_terminals()
        self.nonterminals = self.get_nonterminals()
        self.start = start
        self.build_dependency_graph()
        self.epsilon_generators = None
        self.fill_epsilon_generators()
        self.first = None
        self.follow = None
        self.first_k = None

    def __repr__(self):
        return '\n'.join(map(str, self.rules))

    def __str__(self):
        return '\n'.join(map(str, self.rules))

    def get_terminals(self):
        terms_set = set()
        for rule in self.rules:
            rule_list = [rule.left] + rule.rights
            for tnt in rule_list:
                if isinstance(tnt, Term):
                    terms_set.add(tnt)
        return terms_set

    def get_nonterminals(self):
        nterms_set = set()
        for rule in self.rules:
            rule_list = [rule.left] + rule.rights
            for tnt in rule_list:
                if isinstance(tnt, Nterm):
                    nterms_set.add(tnt)
        return nterms_set

    def build_dependency_graph(self):
        child_relations = {}
        parent_relations = {}
        for rule in self.rules:
            left = rule.left
            rights = list(filter(lambda x: isinstance(x, Nterm), rule.rights))

            if left not in child_relations:
                child_relations[left] = set(rights)
            else:
                child_relations[left].update(rights)

            for right in rights:
                if right not in parent_relations:
                    parent_relations[right] = {left}
                else:
                    parent_relations[right].add(left)

        parent_relations[Epsilon()] = set([])
        eps_rules = set(filter(lambda x: x.rights == [Epsilon()], self.rules))
        for rule in eps_rules:
            child_relations[rule.left].add(Epsilon())
            parent_relations[Epsilon()].add(rule.left)

        self.child_relations = child_relations
        self.parent_relations = parent_relations

    def fill_epsilon_generators(self):
        self.epsilon_generators = set()
        for nonterm in self.nonterminals:
            if Epsilon() in self.child_relations[nonterm]:
                self.epsilon_generators.add(nonterm)
        while True:
            power = len(self.epsilon_generators)
            for rule in self.rules:
                left = rule.left
                rights = rule.rights
                if all(map(lambda x: isinstance(x, Nterm), rights)) and all(map(lambda x: x in self.epsilon_generators, rights)):
                    self.epsilon_generators.add(left)
            new_power = len(self.epsilon_generators)
            if new_power == power:
                break

    def remove_nongenerating_rules(self):
        genetaring_nterm = set()
        for rule in self.rules:
            left = rule.left
            rights = rule.rights
            if all(map(lambda x: isinstance(x, Term), rights)):
                genetaring_nterm.add(left.name)
        while True:
            power = len(genetaring_nterm)
            for rule in self.rules:
                left = rule.left
                rights = rule.rights
                flag = True
                for r in rights:
                    if isinstance(r, Nterm) and not r.name in genetaring_nterm:
                        flag = False
                        break
                if flag:
                    genetaring_nterm.add(left.name)

            new_power = len(genetaring_nterm)
            if power == new_power:
                break
        new_rules = []
        for rule in self.rules:
            rights = rule.rights
            if any(map(lambda x: isinstance(x, Nterm) and not x.name in genetaring_nterm, rights)):
                continue
            new_rules.append(rule)
        return Grammar(new_rules, self.start)

    def remove_unreachable_symbols(self):
        reachable = {self.start}
        unallocated = self.nonterminals.difference(reachable)

        while True:
            power = len(unallocated)

            unallocated_copy = deepcopy(unallocated)
            for nterm in unallocated_copy:
                if nterm in self.parent_relations and set(self.parent_relations[nterm]) & reachable:
                    reachable.add(nterm)
                    unallocated.remove(nterm)

            new_power = len(unallocated)

            if new_power == power:
                break

        new_rules = set(filter(
            lambda x: x.left in reachable,
            self.rules
        ))

        return Grammar(new_rules, self.start)

    def make_first(self):
        self.first = {}
        for nonterm in self.nonterminals:
            self.first[nonterm] = set()
        changed = True
        while changed:
            changed = False
            for nonterm in self.nonterminals:
                power = len(self.first[nonterm])
                if nonterm in self.epsilon_generators:
                    self.first[nonterm].add(Epsilon())
                n_rules = set(filter(lambda x: x.left == nonterm, self.rules))
                for rule in n_rules:
                    for right in rule.rights:
                        if isinstance(right, Term):
                            self.first[nonterm].add(right)
                            break
                        if isinstance(right, Nterm):
                            self.first[nonterm] = self.first[nonterm].union(self.first[right])
                            if right not in self.epsilon_generators:
                                break
                new_power = len(self.first[nonterm])
                if new_power != power:
                    changed = True

    def make_follow(self):
        self.follow = {}
        for nonterm in self.nonterminals:
            self.follow[nonterm] = set()
        changed = True
        self.follow[self.start].add(Term('$'))
        while changed:
            changed = False
            for rule in self.rules:
                left = rule.left
                for i, right in enumerate(rule.rights):
                    if isinstance(right, Nterm):
                        power = len(self.follow[right])
                        for j in range(i + 1, len(rule.rights) + 1):
                            if j == len(rule.rights):
                                self.follow[right] = self.follow[right].union(self.follow[left])
                            else:
                                next_symbol = rule.rights[j]
                                if isinstance(next_symbol, Term):
                                    self.follow[right].add(next_symbol)
                                    break
                                if isinstance(next_symbol, Nterm):
                                    self.follow[right] = self.follow[right].union(self.first[next_symbol]).difference({Epsilon()})
                                    if next_symbol not in self.epsilon_generators:
                                        break
                        new_power = len(self.follow[right])
                        if new_power != power:
                            changed = True

    def make_first_k(self, k):
        assert k > 0
        self.k = k
        self.first_k = {}
        for nonterm in self.nonterminals:
            self.first_k[nonterm] = set()
        changed = True
        while changed:
            changed = False
            for nonterm in self.nonterminals:
                power = len(self.first_k[nonterm])
                if nonterm in self.epsilon_generators:
                    self.first_k[nonterm].add(Epsilon())
                n_rules = set(filter(lambda x: x.left == nonterm, self.rules))
                for rule in n_rules:
                    candidates = {''}
                    for right in rule.rights:
                        if isinstance(right, Term):
                            candidates_copy = deepcopy(candidates)
                            for candidate in candidates_copy:
                                candidates.discard(candidate)
                                candidate += str(right)
                                if len(candidate) == k:
                                    self.first_k[nonterm].add(candidate)
                                else:
                                    candidates.add(candidate)
                        if isinstance(right, Nterm):
                            candidates_copy = deepcopy(candidates)
                            for candidate in candidates_copy:
                                if right not in self.epsilon_generators:
                                    candidates.discard(candidate)
                                copy = deepcopy(self.first_k[right])
                                for s in copy:
                                    if isinstance(s, Epsilon):
                                        continue
                                    other_candidate = candidate + str(s)
                                    if len(other_candidate) == k:
                                        self.first_k[nonterm].add(other_candidate)
                                    elif len(other_candidate) > k:
                                        self.first_k[nonterm].add(other_candidate[:k])
                                    else:
                                        candidates.add(other_candidate)
                        if len(candidates) == 0:
                            break
                    candidates.discard('')
                    self.first_k[nonterm] = self.first_k[nonterm].union(candidates)
                new_power = len(self.first_k[nonterm])
                if new_power != power:
                    changed = True

    def print_first(self):
        print('FIRST:')
        for nonterm, first_set in self.first.items():
            print(f'{nonterm}: {first_set}')

    def print_follow(self):
        print('FOLLOW:')
        for nonterm, follow_set in self.follow.items():
            print(f'{nonterm}: {follow_set}')

    def print_first_k(self):
        print(f'FIRST {self.k}:')
        for nonterm, first_set in self.first_k.items():
            print(f'{nonterm}: {first_set}')