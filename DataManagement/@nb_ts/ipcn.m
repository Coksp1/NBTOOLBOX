function obj = ipcn(obj,initialValues,periods,startAtNaN)
% Syntax:
%
% obj = ipcn(obj,initialValues)
% obj = ipcn(obj,initialValues,periods,startAtNaN)
%
% Description:
%
% Construct indicies based on inital values and timeseries wich 
% represent the series growth. Inverse of percentage log approx. 
% growth, i.e. the inverse method of the pcn method of the nb_ts 
% class
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
%                       has been taken growth over.
% 
% - startAtNaN        : true or false. If true it will start taking the
%                       inverse growth when the nb_ts object with 
%                       initialValues are nan, instead using the first
%                       not nan observation in the same input. Default
%                       is false.
%
% Output:
% 
% - Output            : An nb_ts object with the indicies.
% 
% Examples:
%
% obj = ipcn(obj);
% obj = ipcn(obj,100);
% obj = ipcn(obj,[78,89]);
% 
% See also:
% nb_ts.pcn
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        startAtNaN = false;
        if nargin < 3
            periods = 1;
        end
    end
    
    if nargin < 2
        if periods == 1
            initialValues = repmat(100,[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]); 
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
        
        if startAtNaN
            initEnd = initialValues.getRealEndDate('nb_date');
            needed  = initEnd - (periods - 1);
            if initialValues.startDate > needed
                error([mfilename ':: The initialValues input must start at ' toString(needed) '.'])
            end
            t  = (needed - obj.startDate) + 1;
            d0 = double(window(initialValues,needed,initEnd));
        else
            needed = obj.getRealStartDate('nb_date') + (periods - 1);
            if initialValues.endDate < needed
                error([mfilename ':: The initialValues input must have at least observation until ' toString(needed) '.'])
            end
            t  = 1;
            d0 = double(window(initialValues,obj.startDate,needed));
        end
        
    else
        if startAtNaN
            error('The startAtNaN is not supported when initialValues is not given as a nb_ts object.')
        end
        t  = 1;
        d0 = initialValues;
    end

    if size(d0,2) ~= obj.numberOfVariables
        error([mfilename ':: The ''initialValues'' has not the same number of columns as the given object.'])
    elseif size(d0,3) ~= obj.numberOfDatasets
        error([mfilename ':: The ''initialValues'' has not the same number of pages as the given object.'])
    elseif size(d0,1) < periods
        error([mfilename ':: The ''initialValues'' must has the same number of rows as the periods input indicates (I.e. ' int2str(periods) '.).'])
    end
    if t == 1  
        obj.data = igrowthnan(obj.data./100,d0,periods);
    else
        d                   = obj.data(t:end,:,:);
        d                   = igrowthnan(d./100,d0,periods);
        obj.data(1:t-1,:,:) = initialValues.data(1:t-1,:,:);
        obj.data(t:end,:,:) = d;
    end
        
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@ipcn,{initialValues,periods,startAtNaN});
        
    end

end
