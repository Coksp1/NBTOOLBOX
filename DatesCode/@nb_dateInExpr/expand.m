function obj = expand(obj,~,newEndDate,~,~)
% Syntax:
%
% obj = expand(obj,newStartDate,newEndDate,type,warningOff)
%
% Description:
%
% This method expands a nb_math_ts object, which means we need to take
% max of existing end date and the new end date.
% 
% Input:
% 
% - obj          : An object of class nb_dateInExpr
% 
% - newStartDate : Any
% 
% - newEndDate   : The wanted new end date of the data.
% 
% - type         : Any
% 
% - warningOff   : Any
% 
% Output:
% 
% - obj          : An nb_dateInExpr object.
% 
% Examples:
%
% obj = expand(obj,'1900Q1','2050Q1');
% obj = expand(obj,'1900Q1','2050Q1','zeros');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ischar(newEndDate)
        newEndDate = nb_date.date2freq(newEndDate);
    elseif isa(newEndDate,'nb_date')
        % Do nothing
    elseif isnumeric(newEndDate)
        newEndDate = nb_year(newEndDate);
    else 
        error([mfilename ':: the newEndDate input must either be an ',...
            'object of class nb_date, a one line char or an integer.'])
    end
    obj.date = nb_date.max(obj.date,newEndDate);

end
