function obj = undiff(obj,initialValues,periods)
% Syntax:
%
% obj = undiff(obj,initialValues,periods)
%
% Description:
%
% Construct indicies based on inital values and timeseries wich 
% represent the series diff. Inverse of the diff method.
% 
% Input:
% 
% - obj               : An object of class nb_ts
% 
% - InitialValues     : A nb_ts object with a bigger window than obj,
%                       or a scalar or a double with the initial 
%                       values of the indicies. Must be of the same 
%                       size as the number of variables of the 
%                       nb_ts object. If not provided 100 is 
%                       default.
%
%                       Caution : If periods > 1 the initialValues input
%                                 must be given, and has at least have
%                                 periods number of rows.
% 
% - periods           : The number of periods the initial series
%                       has been taken diff over.
% 
% Output:
% 
% - Output            : An nb_ts object with the indicies.
% 
% Examples:
%
% obj = undiff(obj);
% obj = undiff(obj,100);
% obj = undiff(obj,[78,89]);
% 
% See also
% nb_ts.diff
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 1;
    end
    
    if nargin < 2
        if periods == 1
            initialValues = repmat(100,[1,obj.numberOfVariables,obj.numberOfDatasets]); 
        else
            error([mfilename ':: When the periods input is not equal to 1 the initialValues must be provided.'])
        end
    end
    
    if isa(initialValues,'nb_ts')
        
        if isempty(initialValues)
            error([mfilename ':: The initialValues input cannot be a empty nb_ts object.'])
        end
        
        if initialValues.startDate > obj.startDate
            error([mfilename ':: The initialValues input must have a start date (' toString(initialValues.startDate) ') that is before '...
                             'the start date of this object (' toString(obj.startDate) ').'])
        end
        needed = obj.getRealStartDate('nb_date') + (periods - 1);
        if initialValues.endDate < needed
            error([mfilename ':: The initialValues input must have at least observation until ' toString(needed) '.'])
        end
        d0 = double(window(initialValues,obj.startDate,needed));
        
    else
        d0 = initialValues;
    end

    if size(d0,2) ~= obj.numberOfVariables
        error([mfilename ':: The ''initialValues'' has not the same number of columns as the given object.'])
    elseif size(d0,3) ~= obj.numberOfDatasets
        error([mfilename ':: The ''initialValues'' has not the same number of pages as the given object.'])
    elseif size(d0,1) < periods
        error([mfilename ':: The ''initialValues'' must has the same number of rows as the periods input indicates (I.e. ' int2str(periods) '.).'])
    end
    obj.data = nb_undiff(obj.data,d0,periods);
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@undiff,{initialValues,periods});
    end

end
