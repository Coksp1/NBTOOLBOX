function solvers = nb_getSolvers()
% Syntax:
%
% solvers = nb_getSolvers()
%
% Description:
%
% Get the solvers that solves systems of nonlinear equations of several 
% variables.
% 
% This function also tries to detect solvers of other toolboxes, such 
% as csolve (Chris Sims). You need to add these optimimzer separately, 
% as they are not part of NB toolbox.
% 
% Output:
% 
% - solvers : A cellstr with the supported solvers. 
%
% See also:
% fsolve, nb_getDefaultOptimset
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    solvers = {};
    if license('test','optimization_toolbox')
        solvers = [solvers,{'fsolve'}];
    end
    if exist('csolve.m','file')
        solvers = [solvers,'csolve'];
    end
    solvers = [solvers,{'nb_solve','nb_abcSolve'}];

end
