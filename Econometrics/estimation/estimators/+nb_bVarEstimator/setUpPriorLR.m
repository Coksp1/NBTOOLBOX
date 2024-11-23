function [yPlus,xPlus] = setUpPriorLR(prior,y,x,lags,constant,timeTrend)
% Syntax:
%
% [yPlus,XPlus] = nb_bVarEstimator.setUpPriorLR(prior,y,x,lags,...
%                       constant,timeTrend)
%
% Description:
%
% Set up artificial series when using a prior for the long run as in 
% Giannone et. al (2014).
% 
% See also:
% nb_bVarEstimator.applyDummyPrior
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if timeTrend
        error(['If you apply the prior for the long run you cannot ',...
            'include a time trend.'])
    end
    if isfield(prior,'phi')
        phi = prior.phi;
    else
        error(['If you apply the prior for the long run you need to ',...
            'specify the phi option.'])
    end
    if isfield(prior,'H')
        H = prior.H;
    else
        error(['If you apply the prior for the long run you need to ',...
            'specify the H option.'])
    end
    
    % Remove missing observations at the start
    y(any(isnan(y),2),:) = [];
    if isempty(x)
        x(any(isnan(x),2),:) = [];
    end
    
    % Form the artificial data
    n     = size(y,2);
    phi   = nb_bVarEstimator.testLRPriorPhi(phi,n);
    H     = nb_bVarEstimator.testLRPriorH(H,n);
    Hinv  = H\eye(size(H,1)); 
    y0    = mean(y(1:lags,:),1);
    Hy0   = H*y0';
    yPlus = diag(Hy0./phi)*Hinv';
    xPlus = repmat(yPlus,[1,lags]);
    if ~isempty(x)
        xPlus = [repmat(mean(x(1:lags,:),1),[n,1]),xPlus];
    end
    if constant
        xPlus = [zeros(n,1),xPlus];
    end

end
