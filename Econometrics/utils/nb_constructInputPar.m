function inputs = nb_constructInputPar(vars,pars)
% Syntax:
%
% inputs = nb_constructInputPar(vars,pars)
%
% Description:
%
% Construct inputs enclosed in parenthesis. E.g. '(var1,var2,par1,par2)'.
% 
% Input:
% 
% - vars : A cellstr with the variables.
%
% - pars : A cellstr with the parameters.
% 
% Output:
% 
% - inputs : A one line char. See description.
%
% See also:
% nb_cell2func
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    all    = [vars,pars];
    all    = strcat(all,',');
    inputs = [all{:}];
    inputs = ['(',inputs(1:end-1),')'];

end
