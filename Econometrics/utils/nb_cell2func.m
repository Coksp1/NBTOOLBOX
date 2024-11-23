function func = nb_cell2func(eqs,inputs)
% Syntax:
%
% func = nb_cell2func(eqs,inputs)
%
% Description:
%
% Convert equations to function handle.
% 
% Input:
% 
% - eqs    : A cellstr with the equations.
%
% - inputs : A one line char with the inputs to the created function 
%            handle. E.g. '(x,y)'.
% 
% Output:
% 
% - func   : A function handle.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    eqs  = strcat(eqs,';');
    eqs  = [eqs{:}];
    Fstr = ['@', inputs, '[', eqs(1:end-1) ,']'];
    func = str2func(Fstr);

end
