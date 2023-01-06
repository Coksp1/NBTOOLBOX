function obj = transLeadLag(obj)
% Syntax:
%
% obj = transLeadLag(obj)
%
% Description:
%
% Rename Var(+1) and Var(-1) to Var_lead and Var_lag
% The part (?<=[^+-\*\^]) is to prevent matches with ^(-1) and so forth.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.equations = regexprep(obj.equations,'(?<=[^+-\*\^])\({1}[+]{1}\d{1,2}\){1}','_lead');
    obj.equations = regexprep(obj.equations,'(?<=[^+-\*\^])\({1}[-]{1}\d{1,2}\){1}','_lag');

end
