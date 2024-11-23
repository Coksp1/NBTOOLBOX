function params = getBreakTimingParameters(parser,init)
% Syntax:
%
% params = nb_dsge.getBreakTimingParameters(parser,init)
%
% Description:
%
% Get break point timing parameters names.
% 
% Input:
% 
% - parser : See the nb_dsge.parser property.
% 
% - init   : Give true to use the date prior to estimation.
%
% Output:
% 
% - params : A nParam x 1 cellstr with the names of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if init
        params = strcat('break_',cellstr(toString([parser.breakPoints.initDate]))');
    else
        params = strcat('break_',cellstr(toString([parser.breakPoints.date]))');
    end
    
end
