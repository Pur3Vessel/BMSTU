grammar Reg;
s : 'a' t | 'b' s | EOF;
t : 'a' s | 'b' t |;
