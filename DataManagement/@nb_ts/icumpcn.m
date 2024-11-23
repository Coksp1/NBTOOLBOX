function obj = icumpcn(obj,initialValues)
% Syntax:
%
% obj = icumpcn(obj,initialValues)
%
% Description:
%
% Construct indicies based on initial values and timeseries wich 
% represent the series cumulative growth. Inverse of percentage log 
% approx. cumulative growth, i.e. the inverse method of the cumpcn method 
% of the nb_ts class
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
% Output:
% 
% - Output            : An nb_ts object with the indicies.
% 
% Examples:
%
% obj = icumpcn(obj);
% obj = icumpcn(obj,100);
% obj = icumpcn(obj,[78,89]);
% 
% See also
% nb_ts.cumpcn, nb_ts.pcn
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        initialValues = [];
    end

    [d0,t] = checkInverseMethodsInput(obj,initialValues,[],false);
    if t == 1  
        obj.data = nb_icumpcn(obj.data,d0,true);
    else
        d                   = obj.data(t:end,:,:);
        d                   = nb_icumpcn(d,d0,true);
        obj.data(1:t-1,:,:) = initialValues.data(1:t-1,:,:);
        obj.data(t:end,:,:) = d;
    end

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@icumpcn,{initialValues});
        
    end

end
