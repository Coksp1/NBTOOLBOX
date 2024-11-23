function fh = getOutputFunction(obj)
% Syntax:
%
% fh = getOutputFunction(obj)
%
% Description:
%
% Get function handle that can be assign to the field OutputFcn of the
% options struct given to the given optimizer (fminsearch, fmincon, 
% fminunc) or solver (fsolve).
% 
% Input:
% 
% - obj : An object of class nb_optimizerDisplayer.
% 
% Output:
% 
% - fh  : A function_handle object.
%
% See also:
% optimset, fminsearch, fmincon, fminunc, fsolve, nb_solver
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    fh = @(x,optVal,state,varargin)obj.update(x,optVal,state,varargin);

end
