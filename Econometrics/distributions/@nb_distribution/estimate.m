function obj = estimate(x,xi,varargin)
% Syntax:
%
% obj = nb_distribution.estimate(x,xi,varargin)
%
% Description:
%
% Estimate a distribution using kernel density estimation.
% 
% Input:
% 
% - x        : The assumed random observations of the distribution. As a 
%              nobs x 1 double.
%
% - xi       : The points where the distribution should be evaluated, i.e.  
%              the domain of the distribution. As a nobs x 1 double.
%
%              If not provided or given as empty the method 
%              nb_distribution.estimateDomain will be used.
%
% - varargin  : Optional input given to the nb_ksdensity function. Please 
%               see help for that function.
% 
% Output:
% 
% - obj : A nb_distribution object. See the property domain for the
%         distributions domain, and density to see its PDF.
%
% Examples:
%
% x   = randn(100,1);
% obj = nb_distribution.estimate(x);
%
% See also:
% nb_distribution.estimateDomain
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Find the domain of the distribution
    if nargin < 2
        xi = nb_distribution.estimateDomain(x);
    else
        if isempty(xi)
            xi = nb_distribution.estimateDomain(x);
        end
    end
    
    % Check that the optional input 'function' is not used
    ind = strcmpi('function',varargin);
    if any(ind)
        error([mfilename ':: The '''' function '''' input is not supported as a optional input to the ksdensity function'])
    end
    [T,N] = size(x);
    if T > 1 && N > 1
        error([mfilename ':: x must be a vector.'])
    elseif N > 1
        x = x';
    end
    [T,N] = size(xi);
    if T > 1 && N > 1
        error([mfilename ':: xi must be a vector.'])
    elseif N > 1
        xi = xi';
    end
    
    % Estimate the distribution using a kernel density estimater
    f  = nb_ksdensity(x',xi',varargin{:});
    
    % Check that the density sums to 1
    binsL   = xi(2) - xi(1);
    testCDF = cumsum(f)*binsL; 
    topCDF  = max(testCDF);
    if topCDF > 1.01 || topCDF < 0.99
        
        xi      = nb_distribution.estimateDomain(x,2);
        f       = nb_ksdensity(x',xi',varargin{:});
        binsL   = xi(2) - xi(1);
        testCDF = cumsum(f)*binsL; 
        topCDF  = max(testCDF);
        if topCDF > nb_kernelCDFBounds(0) || topCDF < nb_kernelCDFBounds(1)
            warning([mfilename ':: A CDF return by the ksdensity function did not sum to 1, which is not possible by definition of a density. '...
                             'Is (' num2str(topCDF) '). This is probably due to a mispecified domain.']);
        end
        
    end
    
    % Make a nb_distribution object and assign properties
    obj            = nb_distribution();
    obj.parameters = {xi,f'};
    obj.type       = 'kernel';
    
end
