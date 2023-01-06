function obj = map2Distribution(obj,dist,varargin)
% Syntax:
%
% obj = map2Distribution(obj,dist)
% obj = map2Distribution(obj,dist,varargin)
%
% Description:
%
% Map observation to the distributions given by dist.
%
% The current distribution of the data is estimated using a kernel density
% estimator. The data must be strongly stationary. I.e. the unkown
% distribution from where the data has been drawn must not depend on time.
% 
% Input:
% 
% - obj  : An object of class nb_dataSource.
%
% - dist : An object of class nb_distribution with size 1 x size(obj,2).
% 
% Optional inputs:
%
% - See the optional inputs of the nb_distribution.estimate function.
%
% Output:
% 
% - obj  : An object of class nb_dataSource.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(obj,2) ~= size(dist,2)
        error([mfilename ':: The dist input must have size 1 x ' int2str(size(obj,2))])
    end
    if size(dist,1) > 1
        error([mfilename ':: The dist input must have size 1 x ' int2str(size(obj,2))])
    end

    if obj.numberOfDatasets > 1
        error([mfilename ':: This function only supports one paged nb_dataSource object.'])
    end
    Y = obj.data;
    if ~isnumeric(Y)
        error([mfilename ':: This method only handles data that are numbers (are ' class(Y) ').'])
    end
    if any(isnan(Y(:)))
        error([mfilename ':: This method only handles data without missing values.'])
    end
    
    % Estimate distribution of current observations
    distE(1,size(obj,2)) = nb_distribution;
    for ii = 1:size(obj,2)
        distE(1,ii) = nb_distribution.estimate(Y(:,ii),[],varargin{:});
    end
    
    % Transform the dependent variables of the model
    for ii = 1:size(obj,2)
        y       = Y(:,ii);
        y       = cdf(distE(1,ii),y);
        Y(:,ii) = icdf(dist(1,ii),y);
    end
    
    obj.data = Y;
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@map2Distribution,[{dist},varargin]);
    end

end
