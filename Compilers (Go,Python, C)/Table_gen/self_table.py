terminals = {'<dot>', '<tokens>', '<start>', '<comma>', '<is>', '<name>'}
nonterminals = {'<BLOCKS>', '<TERMS>', '<RULES>', '<BLOCK>', '<RULE>', '<AXIOM>', '<TOKENS>', '<NAMES>', '<GRAMMAR>'}
table = {('<GRAMMAR>', '<tokens>'): ['<BLOCK>', '<BLOCKS>', '<AXIOM>'], ('<BLOCKS>', '<tokens>'): ['<BLOCK>', '<BLOCKS>'], ('<BLOCKS>', '<start>'): [], ('<BLOCK>', '<tokens>'): ['<TOKENS>', '<RULE>', '<RULES>'], ('<TOKENS>', '<tokens>'): ['<tokens>', '<name>', '<TERMS>'], ('<TERMS>', '<comma>'): ['<comma>', '<name>', '<TERMS>'], ('<TERMS>', '<dot>'): ['<dot>'], ('<RULES>', '<name>'): ['<RULE>', '<RULES>'], ('<RULES>', '<start>'): [], ('<RULES>', '<tokens>'): [], ('<RULE>', '<name>'): ['<name>', '<is>', '<NAMES>', '<dot>'], ('<NAMES>', '<name>'): ['<name>', '<NAMES>'], ('<NAMES>', '<dot>'): [], ('<AXIOM>', '<start>'): ['<start>', '<name>', '<dot>']}
axiom = '<GRAMMAR>'
