terminals = {'<n>', '<star>', '<plus sign>', '<right paren>', '<left paren>'}
nonterminals = {'<T>', '<T 1>', '<E 1>', '<E>', '<F>'}
table = {('<E>', '<n>'): ['<T>', '<E 1>'], ('<E>', '<left paren>'): ['<T>', '<E 1>'], ('<E 1>', '<plus sign>'): ['<plus sign>', '<T>', '<E 1>'], ('<E 1>', 'END'): [], ('<E 1>', '<right paren>'): [], ('<T>', '<n>'): ['<F>', '<T 1>'], ('<T>', '<left paren>'): ['<F>', '<T 1>'], ('<T 1>', '<star>'): ['<star>', '<F>', '<T 1>'], ('<T 1>', 'END'): [], ('<T 1>', '<plus sign>'): [], ('<T 1>', '<right paren>'): [], ('<F>', '<n>'): ['<n>'], ('<F>', '<left paren>'): ['<left paren>', '<E>', '<right paren>']}
axiom = '<E>'
