function obj = perc2Dist(perc,values,nDraws,gridpoints,iter,varargin)
% Syntax:
%
% obj = nb_distribution.perc2Dist(perc,values,nDraws,gridpoints,iter,...
%                                 varargin)
%
% Description:
%
% This method makes draws from the percentiles, and do a kernel density
% estimation based on those draws.
%
% Be aware that there is no unique solution to this problem, as the
% estimated kernel density is only one of possible many distribution with
% the wanted percentiles!
% 
% Input:
% 
% - perc       : The percentiles to fit. Must at least provide 3 
%                percentiles. E.g. [10,30,50,70,90]
% 
% - values     : The values of the distribution at the given percentiles.
%
% - nDraws     : Number of draws.
%
% - gridpoints : The number of grid points of the domain. Default is 1000.
%
% - iter       : The number of iteration of the algorithm. Default is 1.
%
% - varargin   : Optional input given to the nb_ksdensity function. Please 
%                see help for that function.
%
% Output:
% 
% - obj        : An object of class nb_distribution
%
% Examples:
%
% obj = nb_distribution.perc2Dist([10,30,50,70,90],[1,4,6,7,8],1000);
% plot(obj)
%
% See also:
% nb_distribution.perc2DistCDF
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        iter = 1;
        if nargin < 5
            gridpoints = 1000;
        end
    end

    if isempty(gridpoints)
        gridpoints = 1000;
    elseif gridpoints < 100
        error([mfilename ':: The gridpoints must at least be 100.'])
    end
    
    if length(perc) < 3
        error([mfilename ':: At least 3 percentiles of the distribution must be provided.'])
    end
    
    if length(perc) ~= length(values)
        error([mfilename ':: The perc and values input must have same size'])
    end
    
    % Check that the optional input 'function' is not used
    ind = strcmpi('function',varargin);
    if any(ind)
        error([mfilename ':: The '''' function '''' input is not supported as a optional input to the ksdensity function'])
    end

    % Check inputs
    [~,ind]  = sort(perc);
    [~,ind2] = sort(ind);
    if any(ind~=ind2)
        error([mfilename ':: The perc input must be be increasing'])
    end
    
    [~,ind]  = sort(values);
    [~,ind2] = sort(ind);
    if any(ind~=ind2)
        error([mfilename ':: The values input must be be increasing'])
    end
    
    % Scale to prevent it to be skewed against the right tail
    if size(perc,1) > 1
        perc = perc';
    end
    randDraws = rand(nDraws,1);
    perc      = perc/100;
    densCdf   = perc/perc(end);
    
    % Make draws
    draws = nan(1,nDraws);
    for ii = 1:nDraws
        diffWithCdf = (densCdf - randDraws(ii)).^2;
        [~, index]  = min(diffWithCdf);   
        draws(ii)   = values(index);
    end

    % Estimate the distribution using a kernel density estimator, this
    % will also estimate the domain (with 1000 datapoints)
    for ii = 1:iter
    
        [f,xi]    = nb_ksdensity(draws,'numDomain',gridpoints,varargin{:});
        randDraws = rand(1,nDraws);
        binsL     = xi(2) - xi(1);
        densCdf   = cumsum(f)*binsL; 
        draws     = nan(1,nDraws);
        for jj = 1:nDraws
            diffWithCdf = (densCdf - randDraws(jj)).^2;
            [~, index]  = min(diffWithCdf);   
            draws(jj)   = xi(index);
        end
           
    end
    
    % Check that the density sums to 1
    binsL   = xi(2) - xi(1);
    testCDF = cumsum(f)*binsL; 
    topCDF  = max(testCDF);
    if topCDF > 1.01 || topCDF < 0.99
        error([mfilename ':: A CDF return by the ksdensity function did not sum to 1, which is not possible by definition of a density. '...
                         'Is (' num2str(topCDF) '). This is probably due to a mispecified domain.']);
    end
    
    % Make a nb_distribution object and assign properties
    obj            = nb_distribution();
    obj.parameters = {xi',f'};
    obj.type       = 'kernel';
    
end
