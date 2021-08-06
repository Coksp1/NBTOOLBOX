function obj = iepcn(obj,initialValues,periods)
% Syntax:
%
% obj = iepcn(obj,initialValues,periods)
%
% Description:
%
% Construct indicies based on inital values and timeseries which 
% represent the series growth. Inverse of exact percentage growth, 
% i.e. the inverse method of the epcn method of the nb_data class
% 
% Input:
% 
% - obj               : An object of class nb_data
% 
% - InitialValues     : A nb_data object with a bigger window than obj,
%                       or a scalar or a double with the initial 
%                       values of the indicies. Must be of the same 
%                       size as the number of variables of the 
%                       nb_data object. If not provided 100 is 
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
% - Output            : An nb_data object with the indicies.
% 
% Examples:
%
% obj = iepcn(obj);
% obj = iepcn(obj,100);
% obj = iepcn(obj,[78,89]);
%
% See also:
% nb_data.epcn
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin < 3
        periods = 1;
    end
    
    if nargin < 2
        if periods == 1
            initialValues = repmat(100,[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]); 
        else
            error([mfilename ':: When the periods input is not equal to 1 the initialValues must be provided.'])
        end
    end
    
    if isa(initialValues,'nb_data')
        
        if isempty(initialValues)
            error([mfilename ':: The initialValues input cannot be a empty nb_data object.'])
        end
        
        if initialValues.startObs > obj.startObs
            error([mfilename ':: The initialValues input must have a start obs (' toString(initialValues.startObs) ') that is before '...
                             'the start obs of this object (' toString(obj.startObs) ').'])
        end
        needed = obj.getRealStartObs() + (periods - 1);
        if initialValues.endObs < needed
            error([mfilename ':: The initialValues input must have at least observation until ' toString(needed) '.'])
        end
        d0 = double(window(initialValues,obj.startObs,needed));
        
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
    obj.data = iegrowthnan(obj.data./100,d0,periods);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@iepcn,{initialValues,periods});
        
    end

end