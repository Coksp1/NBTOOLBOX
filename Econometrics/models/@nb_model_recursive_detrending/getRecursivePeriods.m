function [periods,dates,obj] = getRecursivePeriods(obj)
% Syntax:
%
% periods             = getRecursivePeriods(obj)
% [periods,dates,obj] = getRecursivePeriods(obj)
%
% Description:
%
% Get the number of recursive periods to be looped.
% 
% Input:
% 
% - obj     : An object of class nb_model_recursive_detrending.
% 
% Output:
% 
% - periods : The number of recursive periods, as a scalar double.
%
% - obj     : An object of class nb_model_recursive_detrending where the
%             options property is updated with the corrected 
%             fields 'recursive_start_date'.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(obj.options.recursive_start_date)
        error([mfilename ':: The recursive_start_date options cannot be empty!'])
    end
    if ischar(obj.options.recursive_start_date)
        obj.options.recursive_start_date = nb_date.date2freq(obj.options.recursive_start_date);
    elseif ~isa(obj.options.recursive_start_date,'nb_date')
       error([mfilename ':: The recursive_start_date options must either be set to a string date or an object of a subclass of the nb_date class.']) 
    end
    periods = obj.getRecursiveEndDate() - obj.options.recursive_start_date + 1;
    if nargout > 1
       dates = obj.options.recursive_start_date:obj.getRecursiveEndDate();
    end
    
end
