function varargout = empiricalMoments(obj,varargin)
% Syntax:
%
% [m,c]             = empiricalMoments(obj,varargin)
% [m,c,ac1]         = empiricalMoments(obj,varargin)
% [m,c,ac1,ac2]     = empiricalMoments(obj,varargin)
% [m,c,ac1,ac2,...] = empiricalMoments(obj,varargin)
%
% Description:
%
% Calculate empirical moments; I.e. mean, covariance/correlation, 
% autocovariance/autocorrelation of the data of the nb_model_group 
% object. The options.data property of the model property must contain 
% the selected variables!
%
% Caution: This method only works on time-series models
% 
% Input:
% 
% - obj         : An object of class nb_model_recursive_detrending.
%
% Optional inputs;
%
% - 'vars'      : A cellstr with the wanted variables.
%
% - 'output'    : Either 'nb_cs' or 'double'. Default is 'nb_cs'.
%
% - 'stacked'   : I the output should be stacked in one matrix or 
%                 not. true or false. Default is false.
%
% - 'nLags'     : Number of lags to compute when 'stacked' is set to 
%                 true. 
% 
% - 'type'      : Either 'covariance' or 'correlation'. Default is 
%                 'correlation'.
%
% - 'startDate' : The start date of the calculations. Default is the start
%                 date of the options.data property. Only for time-series!
%                 Must be a string or a nb_date object.
%
% - 'endDate'   : The end date of the calculations. Default is the end
%                 date of the options.data property. Only for time-series!
%                 Must be a string or a nb_date object.
%
% - 'demean'    : true (demean data during estimation of the 
%                 autocovariance matrix), false (do not). Defualt is true.
%
% Output:
% 
% - varargout{1} : The mean, as a 1 x nVar nb_cs object or double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(obj.modelIter)
        error([mfilename ':: You must first call the createVariables method on the object.'])
    end
    [varargout{1:naegout}] = empiricalMoments(obj.modelIter(end),varargin{:});
    
end
