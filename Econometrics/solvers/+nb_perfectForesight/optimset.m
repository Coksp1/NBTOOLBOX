function opt = optimset(solver)
% Syntax:
%
% opt = nb_getDefaultOptimset(solver)
%
% Description:
%
% Get default options for solving the perfect foresight problem.
%
% Input:
% 
% - solver : Name of the solver to be used. Use nb_solve.optimset('help')
%            or nb_abcSolve.optimset('help') for more on the different
%            options.
%
% Output:
% 
% - opt    : A struct with the options used by the solver.
%
% See also:
% nb_solve.optimset, nb_abcSolve.optimset
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin == 0
        solver = 'nb_solve';
    end
    if strcmpi(solver,'nb_abcSolve')
        opt = nb_abcSolve.optimset;
    elseif strcmpi(solver,'nb_solve')
        opt         = nb_solve.optimset;
        opt.method  = 'newton';
        opt.maxIter = 100;
    end
    
end
