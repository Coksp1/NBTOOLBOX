function eqs = transLeadLag(eqs)
% Syntax:
%
% eqs = nb_dsge.transLeadLag(eqs)
%
% Description:
%
% Rename Var(+1) and Var(-1) to Var_lead and Var_lag
% The part (?<=[^+-\*\^]) is to prevent matches with ^(-1) and so forth.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c)  2019, Norges Bank

    eqs = regexprep(eqs,'(?<=[^+-\*\^\(])\({1}[+]{1}\d{1,2}\){1}','_lead');
    eqs = regexprep(eqs,'(?<=[^+-\*\^\(])\({1}[-]{1}\d{1,2}\){1}','_lag');

end
