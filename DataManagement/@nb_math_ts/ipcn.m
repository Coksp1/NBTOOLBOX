function obj = ipcn(obj,initialValues,periods,startAtNaN)
% Syntax:
%
% obj = ipcn(obj)
% obj = ipcn(obj,initialValues,periods,startAtNaN)
%
% Description:
%
% Construct indicies based on inital values and timeseries wich 
% represent the series growth. Inverse of percentage log approx. 
% growth, i.e. the inverse method of the pcn method of the 
% nb_math_ts class
% 
% Input:
% 
% - obj               : An object of class nb_math_ts
% 
% - InitialValues     : A nb_math_ts object with a bigger window than obj,
%                       or a scalar or a double with the initial 
%                       values of the indicies. Must be of the same 
%                       size as the number of variables of the 
%                       nb_math_ts object. If not provided 100 is 
%                       default.
%
%                       Caution : If periods > 1 the initialValues input
%                                 must be given, and has at least have
%                                 periods number of rows.
% 
% - periods           : The number of periods the initial series
%                       has been taken growth over.
% 
% Output:
% 
% - Output            : An nb_math_ts object with the indicies.
% 
% Examples:
%
% obj = ipcn(obj);
% obj = ipcn(obj,100);
% obj = ipcn(obj,[78,89]);
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
            initialValues = repmat(100,[1,obj.dim2,obj.dim3]);  
        else
            error([mfilename ':: When the periods input is not equal to 1 the initialValues must be provided.'])
        end 
    end
    
    if isa(initialValues,'nb_math_ts')
        
        if isempty(initialValues)
            error([mfilename ':: The initialValues input cannot be a empty nb_math_ts object.'])
        end
        
        if initialValues.startDate > obj.startDate
            error([mfilename ':: The initialValues input must have a start date (' toString(initialValues.startDate) ') that is before '...
                             'the start date of this object (' toString(obj.startDate) ').'])
        end
        
        neededS = getRealStartDate(obj,'nb_date');
        if startAtNaN
            initEnd = initialValues.getRealEndDate('nb_date');
            needed  = initEnd - (periods - 1);
            if initialValues.startDate > needed
                error([mfilename ':: The initialValues input must start at ' toString(needed) '.'])
            end
            t    = (needed - obj.startDate) + 1;
            d0   = double(window(initialValues,needed,initEnd));
            data = double(obj);
            data = data(t:end,:,:);
        else
            needed  = neededS + (periods - 1);
            if isempty(needed)
                needed = obj.startDate + (periods - 1);
            else
                if initialValues.endDate < needed
                    error([mfilename ':: The initialValues input must have at least observation until ' toString(needed) '.'])
                end
            end
            d0           = double(window(initialValues,neededS,needed));
            data         = double(window(obj,neededS,''));
            nAppendFirst = obj.dim1 - size(data,1);
            t            = 1;
        end
        
    else
        if startAtNaN
            error('The startAtNaN is not supported when initialValues is not given as a nb_math_ts object.')
        end
        d0           = initialValues;
        t            = 1;
        nAppendFirst = 0;
        data         = obj.data;
        
    end
    
    if t == 1
        obj.data = igrowthnan(data./100,d0,periods);
        obj.data = [nan(nAppendFirst,obj.dim2,obj.dim3); obj.data];
    else
        d                   = igrowthnan(data./100,d0,periods);
        obj.data(1:t-1,:,:) = initialValues.data(1:t-1,:,:);
        obj.data(t:end,:,:) = d;
    end

end
