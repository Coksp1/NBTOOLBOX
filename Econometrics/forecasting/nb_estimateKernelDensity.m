function density = nb_estimateKernelDensity(Y,int,varargin)
% Syntax:
%
% density = nb_estimateKernelDensity(Y,int,varargin)
%
% Description:
%
% Get kernel density estimate given forecast and evalutaion points
% 
% Input:
% 
% - Y        : A nHor x nVar x nDraws double with the simulated forecasts.
%
% - int      : The output from nb_getDensityPoints
%
% - varargin : Optional inputs given to the nb_ksdensity function
% 
% Output:
% 
% - density : A 1 x nVar cell with the stored densities of the forecast.
%
% See also:
% nb_getDensityPoints, nb_evaluateDensityForecast, ksdensity
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [~,nVar,~] = size(Y);
    density    = cell(1,nVar);
    for ii = 1:nVar
        
        domain = int{ii};
        try
            binsL = domain(:,2) - domain(:,1);
        catch %#ok<CTCH>
            error([mfilename ':: The variable number ' int2str(ii) ' has no variation in the forecast. No density can be estimated.']) 
        end
        empDens = permute(Y(:,ii,:),[1,3,2]);
        if license('test','statistics_toolbox')
            nHor    = size(Y,1);
            nPoints = size(domain,2);
            dens    = nan(nHor,nPoints);
            if size(domain,1) == 1
                for hh = 1:nHor
                    dens(hh,:) = ksdensity(empDens(hh,:),domain);
                end
            else
                % Separate domains for each horizon
                for hh = 1:nHor
                    if any(~isfinite(empDens(hh,:)))
                        dens(hh,:) = nan;
                    elseif std(empDens(hh,:)) < eps^(1/3) % Constant distribution
                        domain(hh,:) = domain(end,:);
                        binsL(hh,:)  = binsL(end,:);
                        dens(hh,:)   = 0;
                        [~,ind]      = min(abs(domain(hh,:) - Y(hh,ii,1)));
                        dens(hh,ind) = 1/binsL(hh,:);    
                    else
                        dens(hh,:) = ksdensity(empDens(hh,:),domain(hh,:));
                    end
                end
                
            end
        else
            % Slower, but make it possible to run without the statistics
            % toolbox
            dens = nb_ksdensity(empDens,'domain',domain);
        end
        
        % Check the density estimate
        if any(min(dens,[],2) < 0)
            error([mfilename ':: Negative values for a pdf was return by the ksdensity function, which is not possible.']);
        end  
        if size(binsL,1) == 1 && size(dens,1) ~= 1
            binsL = binsL(ones(1,size(dens,1)),:);
        end
        isNaN   = any(isnan(dens),2);
        testCDF = cumsum(dens(~isNaN,:),2).*binsL(~isNaN,ones(1,size(int{ii},2))); 
        topCDF  = max(testCDF,[],2);
        if any(topCDF > nb_kernelCDFBounds(0) | topCDF < nb_kernelCDFBounds(1))
            
            ind        = find(any(topCDF > nb_kernelCDFBounds(0) | topCDF < nb_kernelCDFBounds(1),2));
            minEmpDens = min(min(empDens,[],2));
            maxEmpDens = max(max(empDens,[],2));
            error(['A CDF return by the ksdensity function did not sum to 1, \n',...
                   'which is not possible. It summed to ' num2str(topCDF(ind(1))) '. \n'...
                   'This is probably due to a mispecified domain. \n',...
                   '(At horizon ' toString(ind(1)) ' and variable ' toString(ii) ')\n',...
                   'The density forecast is bounded to [' num2str(minEmpDens) ',' num2str(maxEmpDens) '].'],'');
        end 
        
        density{ii} = dens;
        
    end

end
