function obj = parcorr(obj,numLags,errorBound,alpha,varargin)
% Syntax:
%
% obj = parcorr(obj,numLags)
% obj = parcorr(obj,numLags,errorBound,alpha)
% 
% Description:
%
% Compute the sample partial autocorrelation function (PACF) of all  
% the variables stored in the nb_data object, and return a nb_data 
% object with the results. 
%
% Reference:
%
%   [1] Box, G. E. P., G. M. Jenkins, and G. C. Reinsel. Time 
%       Series Analysis: Forecasting and Control. 3rd edition. 
%       Upper Saddle River, NJ: Prentice-Hall, 1994.
%
% Input:
%
% - obj          : An object of class nb_data.
%
%                  Caution : This method does not handle nan or 
%                            infinite for any of the stored data
%                            of the nb_data object!
%
% - numLags      : Positive integer indicating the number of lags 
%                  of the PACF to compute. If empty or missing, the 
%                  default is to compute the PACF at lags 1. 
%                  Since PACF is symmetric about lag zero, negative 
%                  lags are ignored. Must be a scalar.
%
% - errorBound : A string. The data must be stationary. Either:
%
%                > ''               : No errorbounds calculated.
%
%                > 'asymtotic'      : Using asymptotically derived 
%                                     formulas.
%
%                > 'bootstrap'      : Calculated by estimating the
%                                     data generating process. And 
%                                     use the fitted model to 
%                                     simulate artifical 
%                                     time-series. Then the error
%                                     bands are constructed by
%                                     the wanted percentile.
%
%                > 'blockbootstrap' : Calculated by blocking the
%                                     observed series and using
%                                     these blocks to simulate
%                                     artificial time-series. Then
%                                     the error bands are 
%                                     constructed by the wanted
%                                     percentile.
%
% - alpha       : Significance value. As a scalar. Default is 0.05.
%
% Optional inputs:
%
% - 'maxAR'     : As an integer. See the nb_arima function. Defualt
%                 is 3.
%
% - 'maxMA'     : As an integer. See the nb_arima function. Defualt
%                 is 3.
%
% - 'criterion' : As a string. See the nb_arima function. Defualt
%                 is 'aicc'.
%
% - 'method'    : As a string. See the nb_arima function. Defualt
%                 is 'hr'.
%
% Output:
%
% - obj         : An nb_data object with the partial autocorrelations 
%                 stored in the dataset 'Autocorrelations'.
%
%                 If the errorbounds are to be calculated they are stored
%                 in the datasets 'Error bound (lower)' and 'Error bound
%                 (upper)'
%
% Examples:
%
% obj = parcorr(obj)
% obj = parcorr(obj,10)
% 
% See also:
% nb_data, nb_cs, corr, nb_parcorr
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        alpha = 0.05;
        if nargin < 3
            errorBound = 'asymtotic';
            if nargin < 2
                numLags = 1;
            end
        end
    end
    
    oldObj = obj;
    
    % Test the inputs
    %--------------------------------------------------------------
    if isscalar(numLags) && isnumeric(numLags)
        if numLags < 0       
            error([mfilename ':: Negativ numLags argument is not allowed.'])  
        elseif round(numLags) ~= numLags        
           error([mfilename ':: numLags argument must be an integer.'])       
        end
    else
        if isempty(numLags)
            numLags = 1;
        else
            error([mfilename ':: numLags must be an integer.']) 
        end
    end
    
    % Compute the partial autocorrelation function
    %--------------------------------------------------------------
    if ~isempty(errorBound)
        [pacf,lBound,uBound] = nb_parcorr(obj.data,numLags,errorBound,alpha,varargin{:});
    else
        pacf = nb_parcorr(obj.data,numLags);
    end
    
    % Pack things together
    %--------------------------------------------------------------
    if ~isempty(errorBound)

        [dim1,dim2]   = size(pacf);
        data          = nan(dim1,dim2,3); 
        data(:,:,1)   = pacf;
        data(:,:,2)   = lBound;
        data(:,:,3)   = uBound;
        obj           = nb_data(data,'',1,obj.variables,obj.sorted);
        obj.dataNames = {'Partial autocorrelations','Error bound (lower)','Error bound (upper)'};

    else 
        obj = nb_data(pacf,'Partial autocorrelations',1,obj.variables,obj.sorted);
    end
    
    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@parcorr,{numLags,errorBound,alpha,varargin{:}}); %#ok<CCAT>
        links  = oldObj.links;
        obj    = obj.setLinks(links);
        
    end
    
end
