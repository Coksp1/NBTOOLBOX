function [x,fval,exitflag,hessian] = testSave()
% Syntax:
%
% nb_abc.test()
%
% Description:
%
% Test the ABC algorithm on the Rosenbrock Vally function;
%
% f = 100*(x(2) - x(1)^2)^2 + (x(1) - 1)^2
%
% The optimizer stops when it is 60 second since last time the minimum 
% where updated.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Do 10 sek first
    options                   = nb_abc.optimset('cutLimit',10,'maxTimeSinceUpdate',60,'maxTime',10,'saveTime',7,'saveName','saved');
    [x,fval,exitflag,hessian] = nb_abc.call(@(x)rosenbrockVally(x),zeros(2,1),ones(2,1)*-2.048,ones(2,1)*2.048,options);
    %close all;
    
    % Then reload from the object saved at 7 sek
    abc                       = nb_load('saved');
    [x,fval,exitflag,hessian] = restart(abc);
    
    delete('saved');

end

function f = rosenbrockVally(x)
    f = 100*(x(2) - x(1)^2)^2 + (x(1) - 1)^2;
end
