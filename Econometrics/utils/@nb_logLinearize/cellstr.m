function eqs = cellstr(obj,type)
% Syntax:
%
% eqs = cellstr(obj)
%
% Description:
%
% Get the equations as a cellstr.
% 
% Input:
% 
% - obj  : An object of class nb_logLinearize
% 
% - type : Either 'logLinEq' (log-linearized equations, default), 
%          'equations' (original equations) or 'ssEq' (equations in 
%          steady-state)
%
% Output:
% 
% - eqs : A cellstr.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
           
    if nargin < 2
        type = 'logLinEq';
    end
    
    supported = {'logLinEq','equations','ssEq'};
    ind       = strcmpi(type,supported);
    if ~any(ind)
        error([mfilename ':: The type input must be either ''logLinEq'',''equations'' or ''ssE''.'])
    end
    eqs = obj.(supported{ind});

end
