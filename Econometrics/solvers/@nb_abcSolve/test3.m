function [x,fval,exitflag] = test3(varargin)
% Syntax:
%
% [x,fval,exitflag] = nb_abcSolve.test3(varargin)
%
% Description:
%
% Test method for solving
%
% max(min(x(1) + x(2),0.01),-0.01) = 0
% x(1).^2 - x(2) = 0
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

    options           = nb_abcSolve.optimset('cutLimit',10,'maxSolutions',2,...
                            'toleranceX',1e-3,'maxTime',60,'newtonShare',0.5,...
                            varargin{:});
    f                 = @(x)[max(min(x(1) + x(2),0.01),-0.01);x(1).^2-x(2)];                    
    [x,fval,exitflag] = nb_abcSolve.call(f,ones(2,1),ones(2,1)*-2.048,ones(2,1)*2.048,options);

end
