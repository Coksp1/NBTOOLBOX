function int = nb_getDensityPoints(Y,bins,scale)
% Syntax:
%
% int = nb_getDensityPoints(Y,bins,scale)
%
% Description:
%
% Get selected bins of the distribution. I.e. the stored points of the
% distribution
% 
% Input:
% 
% - Y    : A nHor x nVar x nDraws double with the simulated forecasts.
%
% - bins : The length between the points of the distribution. 
%
%          > []      : The domain will be found. (default is that 1000
%                      observations of the density is stored).
%
%          > integer : The min and max is found but the length of the bins
%                      is given by the provided integer.
%                                 
%          > cell    : Must be on the format:
%
%                      {indVar1,lowerLimit1,upperLimit1,binsL1;
%                       indVar2,lowerLimit2,upperLimit2,binsL2;
%                       ...}
%
%                       - lowerLimit1 : An integer, can be nan, i.e. will
%                                       be found.
%
%                       - upperLimit1 : An integer, can be nan, i.e. will 
%                                       be found.
%
%                       - binsL1      : An integer with the length of the
%                                       bins. Can be nan. I.e. bins length
%                                       will be adjusted to create a 
%                                       domain of 1000 elements.
% 
% - scale : Number of standard deviation to add at ends of the domain.
%           Default is 2;
%
% Output:
% 
% - int  : A 1 x nVar cell with the selected evaluation points of the
%          density. (Which is yet to be found, see 
%          nb_estimateKernelDensity)
%
% See also:
% nb_estimateKernelDensity, nb_evaluateDensityForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        scale = 2;
    end

    nVars  = size(Y,2);
    nSteps = size(Y,1);
    maxim  = ceil(max(Y,[],3)*100)/100;
    minim  = floor(min(Y,[],3)*100)/100;
    delta  = std(Y,0,3)*scale;
    maxim  = maxim + delta;
    minim  = minim - delta;
    
    if iscell(bins)

        maxim = max(maxim,[],1);
        minim = min(minim,[],1);
        try
            
            int      = cell(1,nVars);
            provided = false(1,nVars);
            for ii = 1:size(bins,1)

               varInd = bins{ii,1};
               minimV = bins{ii,2};
               maximV = bins{ii,3};
               binLV  = bins{ii,4};

               if isnan(minimV)
                   minimV = minim(varInd);
               end
               
               if isnan(maximV)
                   maximV = maxim(varInd);
               end
               
               if isnan(binLV)
                   binLV = (maximV - minimV)./999; % Default is to store 1000 points of the density  
               end
               
               int{ii}          = minimV:binLV:maximV;
               provided(varInd) = true;
               
            end
            
            notInd = 1:nVars;
            notInd = notInd(~provided);
            for ii = notInd                
                binsLV  = (maxim(ii) - minim(ii))/999;
                int{ii} = minim(1,ii):binsLV:maxim(1,ii);                
            end
            
        catch Err
            nb_error([mfilename ':: Wrong input bins.'],Err)
        end
        
    else
        
        if isempty(bins)
            
            % Individual domain at all horizons
            bins = (maxim - minim)./999; % Default is to store 1000 points of the density 
            int  = cell(1,nVars);
            for ii = 1:nVars
                domain = nan(nSteps,1000);
                for hh = 1:nSteps
                    if bins(hh,ii) < eps
                        mi           = min(minim(:,ii));
                        ma           = max(maxim(:,ii));
                        bin          = (ma - mi)/999;
                        domain(hh,:) = mi:bin:ma;
                    else
                        domain(hh,:) = minim(hh,ii):bins(hh,ii):maxim(hh,ii);
                    end
                end
                int{ii} = domain;
            end
            
        elseif numel(bins) == 1
            
            % Shared domain at all horizons
            bins = repmat(bins,[1,nVars]);
            int  = cell(1,nVars);
            for ii = 1:nVars
                int{ii} = min(minim(:,ii)):bins(ii):max(maxim(:,ii));
            end
            
        else
            error([mfilename ':: Wrong input given to the bins input.'])
        end

    end
    
end
