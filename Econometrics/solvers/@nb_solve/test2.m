function solver = test2(varargin)
% Syntax:
%
% solver = nb_solve.test2(varargin)
%
% Description:
%
% Solve the following problem:
%
% x(1)^2-x(2) = 0
% x(1)*x(2)   = 0
%
% Which has the trivial solution [0;0].
%
% Optional input:
%
% - varargin : Optional inputs given to the set method.
%
% Output:
% 
% - solver : An object of class nb_solve.
%
% See also:
% nb_solve, nb_solve.call
%
% Written by Kenneth Sæterhagen Paulsen

    solver = nb_solve(@(x)[x(1)^2-x(2);x(1)*x(2)],ones(2,1)*2,[],@(x)[2*x(1),-1;x(2),x(1)]);
    set(solver,varargin{:});
    solve(solver);

end
