function obj = append(obj,aObj,priority)
% Syntax:
%
% obj = append(obj,aObj)
% obj = append(obj,aObj,priority)
%
% Description:
%
% Append aObj to obj with a given priority.
% 
% Input:
% 
% - obj      : A nObs1 x nVar x nPages nb_math_ts object.
%
% - aObj     : A nObs2 x nVar x nPages nb_math_ts object.
%
% - priority : 'first' or 'second'. If 'first' all the observation fra obj
%              is used before the observations from aObj, otherwise it is
%              reverse. 'first' is default.
% 
% Output:
% 
% - obj      : A nObs x nVar x nPages nb_math_ts object.
%
% Examples:
% 
% obj  = nb_math_ts(zeros(10,2),'2018Q1');
% aObj = nb_math_ts([nan(2,1),ones(2,1);ones(6,2)],'2020Q1');
% new1 = append(obj,aObj);
% new2 = append(obj,aObj,'second');
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        priority = 'first';
    end
    
    if obj.dim2 ~= aObj.dim2 
        error([mfilename ':: The number of variables of the two objects must be the same.'])
    end
    if obj.dim3 ~= aObj.dim3 
        error([mfilename ':: The number of pages of the two objects must be the same.'])
    end
    
    if strcmpi(priority,'second')
        
        sDate = getRealStartDate(aObj,'nb_date');
        aObj  = window(aObj,sDate);
        if sDate > obj.endDate + 1
            error([mfilename ':: The time-span of the two objects are not overlapping.'])
        end
        s1            = sDate - obj.startDate;
        s2            = (obj.endDate - sDate) + 1;
        data1         = obj.data(1:s1,:,:);
        data12        = obj.data(s1+1:end,:,:);
        data21        = aObj.data(1:s2,:,:);
        data2         = aObj.data(s2+1:end,:,:);
        isNaN         = isnan(data21);
        data21(isNaN) = data12(isNaN);
        obj.data      = [data1;data21;data2];
        obj.endDate   = aObj.endDate;
        
    else
        
        sDate = getRealStartDate(aObj,'nb_date');
        if isempty(sDate)
            % All observation of aObj are missing
            obj = expand(obj,aObj.startDate,aObj.endDate,'nan','off');
            return
        end
        aObj  = window(aObj,sDate);
        if sDate > obj.endDate + 1
            error([mfilename ':: The time-span of the two objects are not overlapping.'])
        end
        s1            = sDate - obj.startDate;
        s2            = (obj.endDate - sDate) + 1;
        data1         = obj.data(1:s1,:,:);
        data12        = obj.data(s1+1:end,:,:);
        data21        = aObj.data(1:s2,:,:);
        data2         = aObj.data(s2+1:end,:,:);
        isNaN         = isnan(data12);
        data12(isNaN) = data21(isNaN);
        obj.data      = [data1;data12;data2];
        obj.endDate   = aObj.endDate;
        
    end

end
