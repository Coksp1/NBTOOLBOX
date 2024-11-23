function [obj,ind] = sort(obj)
% Syntax:
%
% [obj,ind] = sort(obj)
%
% Description:
%
% Sort a vector of nb_date objects.
% 
% Input:
% 
% - obj : A vector of nb_date objects.
% 
% Output:
% 
% - obj : A sorted vector of nb_date objects.
%
% - ind : The index of the sorting.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= length(obj)
        error([mfilename ':: The obj input must be a vector.'])
    end
    switch class(obj)
        case 'nb_year'
            [~,ind] = sort([obj.yearNr]);
        case 'nb_semiAnnual'
            [~,ind] = sort([obj.halfYearNr]);
        case 'nb_quarter'
            [~,ind] = sort([obj.quarterNr]);
        case 'nb_month'
            [~,ind] = sort([obj.monthNr]);
        case 'nb_week'
            [~,ind] = sort([obj.weekNr]);
        case 'nb_day'
            [~,ind] = sort([obj.dayNr]);
    end
    obj = obj(ind);
    
end
