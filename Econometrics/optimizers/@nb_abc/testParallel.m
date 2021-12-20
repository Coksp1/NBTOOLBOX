function [x,fval,exitflag,hessian] = testParallel()
% Syntax:
%
% nb_abc.testParallel()
%
% Description:
%
% Test the ABC algorithm in parallel on the Rosenbrock Vally function;
%
% f = 100*(x(2) - x(1)^2)^2 + (x(1) - 1)^2
% 
% Output:
% 
% - [x,fval,exitflag,hessian] : See the nb_abc.call method for more on 
%                               these outputs.
%
% See also:
% nb_abc.call
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options                   = nb_abc.optimset('useParallel',true);
    [x,fval,exitflag,hessian] = nb_abc.call(@(x)rosenbrockVally(x),zeros(2,1),ones(2,1)*-2.048,ones(2,1)*2.048,options);

end

function f = rosenbrockVally(x)
    f = 100*(x(2) - x(1)^2)^2 + (x(1) - 1)^2;
end
