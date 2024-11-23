function obj = removeBreakPoints(obj)
% Syntax:
%
% obj = removeBreakPoints(obj)
%
% Description:
%
% Remove all break-points added to the structural parameters of the model.
%
% Input:
% 
% - obj : An object of class nb_dsge.
%
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_dsge.addBreakPoint
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nb_isempty(obj.estOptions.parser)
        error([mfilename ':: This DSGE model is not formulated.'])
    end
    obj.estOptions.parser.nBreaks     = 0;
    obj.estOptions.parser.breakPoints = [];
    
    % Indicate the model need to be resolved
    obj = indicateResolve(obj);
    
end
