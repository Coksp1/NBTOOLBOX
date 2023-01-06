function [test,pval] = nb_dieboldMarianoTest(y1,y2,actual,bandWidth,bandWidthCrit,varargin)
% Syntax:
%
% [test,pval] = nb_dieboldMarianoTest(y1,y2,actual,bandWidth,...
%       bandWidthCrit)
% [test,pval] = nb_dieboldMarianoTest(y1,y2,actual,bandWidth,...
%       bandWidthCrit,varargin)
%
% Description:
%
% Diebold-Mariano test. The null is that the models produce equally good 
% forecast.
%
% Implements section of Timmermann and Zhu (2019), Comparing Forecasting 
% Performance with Panel Data when multivariate is set to true.
%
% Caution: Handle nan values in y1, y2 and actual.
% 
% Input:
% 
% - y1            : Forecast of model 1. A double with size nobs x nvar x 
%                   nhor.
%
% - y2            : Forecast of model 2. A double with size nobs x nvar x 
%                   nhor.
%
% - actual        : Actual data. A double with size nobs x nvar.
% 
% - bandWidth     : The selected band width of the frequency zero
%                   spectrum estimation. Default is to use a automatic
%                   selection criterion. See the bandWithCrit input.
%                   Must be set to an integer greater then 0.
%
% - bandWidthCrit : Band with selection criterion. Either:
% 
%                   > 'nw'   : Newey-West selection method. 
%                              Default.
%
%                   > 'a'    : Andrews selection method. AR(1)
%                              specification.
%
% Optional inputs:
%
% - 'multivariate' : Set to true to do the multivariate test, i.e. test
%                    for equal panel forecast. Default is to test each 
%                    variable separatly. 
%
% Output:
% 
% - test : Test statistic. As a nhor x nvar (1) double.
%
% - pval : P-value of test statistic. As a nhor x nvar (1) double.
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        bandWidthCrit = 'nw';
        if nargin < 4
            bandWidth = [];
        end
    end
    multivariate = nb_parseOneOptional('multivariate',false,varargin{:});
    
    if ~isempty(bandWidth)
        bandWidthCrit = '';
    else
        if isempty(bandWidthCrit)
            error([mfilename ':: The inputs bandWidth and bandWidthCrit inputs cannot both be empty.'])
        end
    end
    
    nhor = size(y1,3);
    n    = size(y1,2);
    kk2  = size(y2,2);
    if n ~= kk2
        error([mfilename ':: The input y1 and y2 must have the same number of variables'])
    end
    if multivariate
    
        test = nan(nhor,1); 
        pval = nan(nhor,1); 
        for h = 1:nhor
            dL       = (y1(:,:,h) - actual).^2 - (y2(:,:,h) - actual).^2;
            ind      = ~any(isnan(dL),2);
            dL       = dL(ind,:); % Remove all obs where some data or forecast is missing.
            dL_bar_n = sum(dL,2);
            deltaL   = sum(dL_bar_n,1);
            T        = size(dL,1);
            dL_bar   = dL_bar_n/n;
            R        = n^0.5*dL_bar;
            Rbar     = ones(T,1)*mean(R);
            variance = nb_zeroSpectrumEstimation(R - Rbar,'bartlett',bandWidth,bandWidthCrit)/T;
            test(h)  = ((n*T)^(-0.5)*(deltaL/sqrt(variance)))^2;
            pval(h)  = 1 - nb_distribution.chis_cdf(test(h),1); 
        end
        
    else
        test = nan(nhor,n); 
        pval = nan(nhor,n); 
        for h = 1:nhor

            for ii = 1:n

                y1_        = y1(:,ii,h);
                y2_        = y2(:,ii,h);
                act        = actual(:,ii);
                ind        = not(isnan(y1_) | isnan(y2_) | isnan(act));
                y1_        = y1_(ind,1);
                y2_        = y2_(ind,1);
                act        = act(ind,1);
                y          = (y1_ - act).^2 - (y2_ - act).^2;
                if all(y == 0)
                    error('You are comparing two equal models (At least when it comes to forecast.)')
                end
                T          = size(y,1);
                yMean      = sum(y)/T;
                ybar       = ones(T,1)*yMean;
                variance   = nb_zeroSpectrumEstimation(y - ybar,'bartlett',bandWidth,bandWidthCrit)/T;
                test(h,ii) = (yMean/sqrt(variance))^2; 
                pval(h,ii) = 1 - nb_distribution.chis_cdf(test(h,ii),1); 

            end

        end
        
    end
    
end
