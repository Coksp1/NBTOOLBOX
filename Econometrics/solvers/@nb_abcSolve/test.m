function [x,fval,exitflag] = test()
% Syntax:
%
% [x,fval,exitflag] = nb_abcSolve.test()
%
% Description:
%
% Test the ABC algorithm on the Rosenbrock Vally function;
%
% f = 100*(x(2) - x(1)^2)^2 + (x(1) - 1)^2
%
% The solver stops when it is 60 second since last time the minimum 
% where updated.
% 
% Output:
% 
% - [x,fval,exitflag] : See the nb_abcSolve.call method for more  
%                       on these outputs.
%
% See also:
% nb_abcSolve.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options           = nb_abcSolve.optimset('cutLimit',10,'maxSolutions',60,...
                            'maxTime',20,'maxSolutions',1);
    [x,fval,exitflag] = nb_abcSolve.call(@(x)rosenbrockVally(x),zeros(1,1),ones(1,1)*-2.048,ones(1,1)*2.048,options);

end

function f = rosenbrockVally(x)
    f = 100*(1 - x(1)^2)^2 + (x(1) - 1)^2;
end
