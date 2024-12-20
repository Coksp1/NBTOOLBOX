function list = funclist(type)
% Syntax:
%
% list = funclist(type)
%
% Description:
%
% Part of DAG.
% 
% Written by Andreas Haga Raavand 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

if strcmpi(type,'nb_ts')
    list = {'abs';
            'acos';
            'acot';
            'acsc';
            'asec';
            'asin';
            'atan';
            'bkfilter';
            'bkfilter1s';
            'cos';
            'cot';
            'csc';
            'cumprod';
            'cumsum';
            'diff';
            'egrowth';
            'epcn';
            'exp';
            'growth';
            'hpfilter';
            'hpfilter1s';
            'iegrowth';
            'iepcn';
            'igrowth';
            'ipcn';
            'lag';
            'lead';
            'log';
            'mavg';
            'max';
            'mean';
            'median';
            'min';
            'minus';
            'mstd';
            'pcn';
            'plus';
            'power';
            'q2y';
            'ret';
            'sec';
            'sin';
            'skewness';
            'std';
            'stdise';
            'sum';
            'sumOAF';
            'tan';
            'times';
            'var';
            'uminus';
            'uplus';
            '/';
            '*';
            '+';
            '-';
            '^'};
else
    list = {'abs';
            'acos';
            'acosd';
            'acosh';
            'acot';
            'acotd';
            'acoth';
            'acsc';
            'acscd';
            'acsch';
            'asec';
            'asecd';
            'asech';
            'asin';
            'asind';
            'asinh';
            'atan';
            'atan2';
            'atan2d';
            'atand';
            'atanh';
            'ceil';
            'conj';
            'cos';
            'cosd';
            'cosh';
            'cot';
            'cotd';
            'coth';
            'csc';
            'cscd';
            'csch';
            'cumprod';
            'cumsum';
            'diff';
            'exp';
            'expm1';
            'filter';
            'floor';
            'log';
            'log10';
            'log1p';
            'log2';
            'max';
            'min';
            'minus';
            'plus';
            'pow2';
            'power';
            'prod';
            'real';
            'reallog';
            'realpow';
            'realsqrt';
            'round';
            'sec';
            'secd';
            'sech';
            'sin';
            'sind';
            'sinh';
            'sort';
            'sqrt';
            'sum';
            'tan';
            'tand';
            'tanh';
            'times';
            'uminus';
            'uminus';
            '/';
            '*';
            '+';
            '-';
            '^'};
            
end
        
