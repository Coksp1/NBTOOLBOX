function obj = removeObservations(obj,numPer,vars)
% Syntax: 
%
% obj = removeObservations(obj,numPer,vars)
%
% Description:
%
% Remove the number of wanted observation from each series, or a subset of
% variables. If one variable contain less observation than another it will
% still be removed another observation, so as to preserve the ragged edge
% of the data.
% 
% Input: 
%
% - obj    : A nb_ts object
% 
% - numPer : The amount of observations to remove at the end of the sample
%            for each series. By removal we meen setting it to nan.
%
% - vars   : A cellstr with the variables to perform the method on.
%            Can be empty, in which case the method will be performed on  
%            all variables in the object, which is the default.
% 
% Output: 
%
% - obj    : A nb_ts object
% 
% Examples: 
%
% obj = nb_ts.rand(1,4,3);
% obj = removeObservations(obj,1)
% obj = removeObservations(obj,1,{'Var1','Var2'})
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        vars = {};
    end
    
    if ischar(vars)
        vars = cellstr(vars);
    end

    if isempty(vars)
        loc = 1:obj.numberOfVariables;
    else
        [t,loc] = ismember(vars,obj.variables);
        if any(~t)
            error([mfilename ':: The following variables are not part of the data of the object; ' toString(vars(~t))])
        end
    end
    
    for ii = loc
        
        for pp = 1:obj.numberOfDatasets
        
            dataT = obj.data(:,ii,pp);
            if ~isnan(dataT(end))
                last = obj.numberOfObservations;
            else
                last = find(~isnan(dataT),1,'last');
            end
            if last-numPer+1 < 1
                error([mfilename ':: Could not remove ' int2str(numPer) ' observations from variable ' obj.variables{ii} '.'])
            end
            obj.data(last-numPer+1:last,ii,pp) = nan;
            
        end
        
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. 
        obj = obj.addOperation(@removeObservations,{numPer,vars});
        
    end
    
end
