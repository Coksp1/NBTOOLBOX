function [x,fval,exitflag] = test2local(varargin)
% Syntax:
%
% [x,fval,exitflag] = nb_abcSolve.test2local(varargin)
%
% Description:
%
% Test method for solving 
%
% min(x(1) + x(2),0.01) = 0
% x(1).^2 - x(2) = 0
% 
% without bounds, i.e. a local method must be used.
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

    options           = nb_abcSolve.optimset('maxSolutions',1,...
                            'toleranceX',1e-3,'maxTime',60,...
                            'newtonStop',true,'local',true,varargin{:});
    f                 = @(x)[min(x(1) + x(2),0.01);x(1).^2-x(2)];                    
    [x,fval,exitflag] = nb_abcSolve.call(f,ones(2,1),[],[],options);

end
