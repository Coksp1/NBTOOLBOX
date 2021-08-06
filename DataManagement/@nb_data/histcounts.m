function obj = histcounts(obj,interval,centered)
% Syntax:
%
% obj = histcounts(obj,interval,centered)
%
% Description:
%
% Order the observation (dim1) into bins using the specified interval
% 
% Input:
% 
% - obj      : An object of class nb_data
%
% - interval : A 1 x nBins double
%
% - centered : A 1 x nBins double with the centered bins value.
% 
% Output:
% 
% - obj      : An object of class nb_data
%
% Examples:
%
% obj = nb_data.rand(1,100,4,2);
% obj = histcounts(obj,0.1:0.1:1)
% obj = histcounts(obj,0.1:0.1:1,0.05:0.1:1)
%
% See also:
% nb_histcount
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        centered = [];
    end
    
    intervalT = interval';
    nBins     = length(intervalT);
    dat       = obj.data;
    index     = zeros(nBins,obj.numberOfVariables,obj.numberOfDatasets);
    for ii = 2:nBins
        index(ii,:,:) = sum(dat < intervalT(ii-1),1);
    end
    index(1:end-1,:,:) = diff(index);
    
    for ii = 1:obj.numberOfDatasets
        for jj = 1:obj.numberOfVariables
            index(end,jj,ii) = obj.numberOfObservations - sum(isnan(dat(:,jj,ii))) - sum(index(1:end-1,jj,ii));
        end
    end
    
    if isempty(centered)
        centered = intervalT;
    end
    if size(centered,2) > 1
        centered = centered';
    end
    
    % Assign object properties
    dat                      = [centered(:,:,ones(1,obj.numberOfDatasets)),index];
    vars                     = ['Interval',obj.variables];
    sVars                    = sort(vars);
    [~,indV]                 = ismember(sVars,vars);
    obj.data                 = dat(:,indV,:);
    obj.variables            = sVars;
    obj.startObs             = 1;
    obj.endObs               = nBins;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@histcounts,{interval,centered});
        
    end 

end
