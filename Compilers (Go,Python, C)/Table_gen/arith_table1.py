terminals = {'<left paren>', '<n>', '<right paren>', '<star>', '<plus sign>'}
nonterminals = {'<T 1>', '<E>', '<T>', '<F>', '<E 1>'}
table = {('<E>', '<n>'): ['<T>', '<E 1>'], ('<E>', '<left paren>'): ['<T>', '<E 1>'], ('<E 1>', '<plus sign>'): ['<plus sign>', '<T>', '<E 1>'], ('<E 1>', 'END'): [], ('<E 1>', '<right paren>'): [], ('<T>', '<n>'): ['<F>', '<T 1>'], ('<T>', '<left paren>'): ['<F>', '<T 1>'], ('<T 1>', '<star>'): ['<star>', '<F>', '<T 1>'], ('<T 1>', 'END'): [], ('<T 1>', '<right paren>'): [], ('<T 1>', '<plus sign>'): [], ('<F>', '<n>'): ['<n>'], ('<F>', '<left paren>'): ['<left paren>', '<E>', '<right paren>']}
axiom = '<E>'
