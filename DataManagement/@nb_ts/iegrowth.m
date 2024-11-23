function obj = iegrowth(obj,initialValues,periods,startAtNaN)
% Syntax:
%
% obj = iegrowth(obj,initialValues,periods)
% obj = iegrowth(obj,initialValues,periods,startAtNaN)
%
% Description:
%
% Construct indicies based on inital values and timeseries wich 
% represent the series growth. Inverse of exact growth, i.e. 
% the inverse method of the egrowth method of the nb_ts class
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
% obj = iegrowth(obj);
% obj = iegrowth(obj,100);
% obj = iegrowth(obj,[78,89]);
% 
% See also
% nb_ts.egrowth, nb_ts.igrowth, nb_ts.growth 
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        startAtNaN = false;
        if nargin < 3
            periods = 1;
            if nargin < 2
                initialValues = [];
            end
        end
    end
    
    [d0,t] = checkInverseMethodsInput(obj,initialValues,periods,startAtNaN);
    if t == 1  
        obj.data = iegrowthnan(obj.data,d0,periods);
    else
        d                   = obj.data(t:end,:,:);
        d                   = iegrowthnan(d,d0,periods);
        obj.data(1:t-1,:,:) = initialValues.data(1:t-1,:,:);
        obj.data(t:end,:,:) = d;
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@iegrowth,{initialValues,periods,startAtNaN});
        
    end

end
