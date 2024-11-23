function pit = nb_calculatePIT(density,domain,actual,fcst)
% Syntax:
%
% pit = nb_calculatePIT(density,domain,actual)
% pit = nb_calculatePIT(density,domain,actual,fcst)
%
% Description:
%
% Calculate PIT of a density forecast given actual data. If the density
% forecasts are well calibrated, the returned output should be distributed
% uniformly.
% 
% Input:
% 
% - density : A nHor x nDomain double with the forecast density at forecast
%             horizons 1 to nHor.
%
%             Or a 1 x nHor cell, where each element is a 1 x 2 cell array
%             on the format {typeOfDistribution,parameters}. E.g.
%             {'normal',{0,1}}. See the nb_distribution class for more.
%             the properties type and parameters.
%
% - domain  : A nHor x nDomain double storing the domain of the density
%             forecast. I.e.
%
%             Caution : Can also be of size 1 x nDomain, but then it is 
%                       assumed that the domain is the same at all 
%                       horizons!
%
%             Caution : It is assumed that the domain is equally spaced.
%
% - actual  : A nHor x 1 double with the actual data for the horizon of
%             interest
% 
% - fcst    : If the density is taken from another forecast we need the
%             difference in the mean forecast to move the domain  
%             accordingly. A nHor x 1 double.
%
% Output:
% 
% - pit     : A nHor x 1 double with the PITs
%
% See also:
% nb_model_generic.getPIT
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        fcst = [];
    end

    if size(domain,1) == 1 % Old version
        domain = domain(ones(1,size(density,1)),:);
    end
        
    % Get the cdf of the density
    if iscell(density)
        % Parametrized distribution
        dens    = density;
        nHor    = size(density,1);
        density = nan(nHor,size(domain,2));
        for hh = 1:nHor
            dist          = nb_distribution('type',dens{hh}{1},...
                                            'parameters',dens{hh}{2});
            density(hh,:) = pdf(dist,domain(hh,:));
        end
    end
    incr    = domain(:,2) - domain(:,1);
    densCDF = bsxfun(@times,cumsum(density,2),incr);
    
    % Get the domain closest to the actual data and use the CDF to get the
    % PIT
    if ~isempty(fcst)

        nHor = size(density,1);
        pit  = nan(nHor,1);
        for ii = 1:nHor
            domainT   = domain(ii,:) - fcst(ii);
            [~,index] = min((domainT - actual(ii)).^2);
            pit(ii)   = densCDF(ii,index);
        end
        
    else
        
        nHor = size(density,1);
        pit  = nan(nHor,1);
        for ii = 1:nHor
            [~,index] = min((domain(ii,:) - actual(ii)).^2);
            pit(ii)   = densCDF(ii,index);
        end
        
    end
    
    pit(isnan(actual)) = nan;

end
