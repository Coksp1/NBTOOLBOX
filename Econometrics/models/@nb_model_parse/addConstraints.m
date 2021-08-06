function obj = addConstraints(obj,constraints)
% Syntax:
% 
% obj = addConstraints(obj,constraints)
%
% Description:
%
% Add (more) constraints to the parameters during estimation. The 
% constraints can only include parameters (and numbers).
% 
% Input:
% 
% - obj         : An object of class nb_dsge or nb_nonLinearEq.
%
% - constraints : A N x M char array or a N x 1 (or 1 x N) cellstr array.
%                 Each element will be counted as a new constraint.
%
% Output:
% 
% - obj         : An object of class nb_dsge or nb_nonLinearEq.
%
% See also:
% nb_dsge.parse, nb_nonLinearEq.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(constraints)
        return
    end

    if numel(obj) ~= 1
        error([mfilename ':: The obj input must be a scalar nb_dsge object.'])
    end
    
    if ischar(constraints)
        constraints = cellstr(constraints);
    elseif iscellstr(constraints)
        constraints = constraints(:);
    else
        error([mfilename ':: The constraints input must be either a char array or a cellstr array.'])
    end
    
    % Add the new equation
    if isempty(obj.parser.constraints)
        obj.parser.constraints = constraints;
    else
        obj.parser.constraints = [obj.parser.constraints;constraints];
    end
    
end
