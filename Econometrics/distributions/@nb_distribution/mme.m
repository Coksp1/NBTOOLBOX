function [obj,params] = mme(x,dist,lb,ub)
% Syntax:
%
% [obj,params] = nb_distribution.mme(x,dist,lb,ub)
%
% Description:
%
% Estimate a distribution using metods of moment estimator.
% 
% Input:
% 
% - x    : The assumed random observation of the distribution. As a
%          nobs x 1 double.
%
% - dist : A string with the distribution to match to the data.
%
%          The supported distributions are:
%          > 'beta'
%          > 'chis' 
%          > 'constant'
%          > 'exp'
%          > 'f'
%          > 'gamma'
%          > 'invgamma'
%          > 'laplace'
%          > 'logistic'
%          > 'lognormal'
%          > 'normal'
%          > 't'
%          > 'tri'
%          > 'uniform'
%          > 'wald'
%
%          Type <help nb_distribution.type> to get a description of the
%          of the different distributions.
% 
% Output:
% 
% - obj    : A nb_distribution object.
%
% - params : The hyperparameters as a cell array
%
% Examples:
%
% x   = randn(100,1);
% obj = nb_distribution.mme(x,'normal');
%
% See also:
% nb_distribution.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        ub = [];
        if nargin < 4
            lb = [];
        end
    end

    me   = mean(x,1);
    v    = var(x,0,1);
    s    = skewness(x,0,1);
    k    = kurtosis(x,0,1);
    dist = lower(dist);
    try
        [obj, params] = nb_distribution.parameterization(me,v,dist,lb,ub,s,k);
    catch Err
        if strcmpi('parametrization:unsupportedDistribution',Err.identifier)
            error('mme:unsupportedDistribution',[mfilename ':: mme is not supported for the distribution ' dist])
        else
            rethrow(Err)
        end
    end
    
end

