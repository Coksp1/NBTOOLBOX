function [Y,X] = map2Density(dist,Y,X,nDep)
% Syntax:
%
% [Y,X] = nb_forecast.map2Density(dist,Y,X)
%
% Description:
%
% Map normalized data to estimated distribution.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Transform the dependent variables of the model
    distY = dist(1,1:nDep);
    for ii = 1:nDep
        y         = permute(Y(ii,:,:),[2,1,3]);
        y         = nb_distribution.normal_cdf(y,0,1);
        y         = icdf(distY(1,ii),y);
        Y(ii,:,:) = permute(y,[2,1,3]);
    end

    % Transform the exogenous variables of the model
    % What about constant, timeTrend and seasonals!!!
    nExo  = size(X,1);
    distX = dist(1,end-nExo+1:end);
    if ~isempty(distX)
        start = size(X,1) - nExo + 1;
        kk    = 1;
        for ii = start:size(X,1)
            x       = permute(X(ii,:,:),[2,1,3]);
            x       = nb_distribution.normal_cdf(x,0,1);
            x       = icdf(distX(1,kk),x);
            X(ii,:) = permute(x,[2,1,3]);
            kk      = kk + 1;
        end
    end
    
end
