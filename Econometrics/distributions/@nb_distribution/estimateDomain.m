function xi = estimateDomain(x,numberOfStd,numDomain)
% Syntax:
%
% xi = nb_distribution.estimateDomain(x)
% xi = nb_distribution.estimateDomain(x,numberOfStd,numDomain)
%
% Description:
%
% Estimate the domain of a distribution. Caulculated as; 
%
% xi   = min(x) - std(x):incr:max(x) + std(x) 
%
% Where;
%
% incr = (xi(end) - xi(1))/999
%
% Caution: The estimated domain will be estimated separatly for each
%          variable.
%
% Input:
% 
% - x           : The assumed random observation of the distribution. 
%                 As a nobs x nvars double.
% 
% - numberOfStd : Number of added space in the tails. In terms of the
%                 standard deviation. Default is 1.
%
% - numDomain   : Number of points of the returned domain. Default is
%                 1000.
%
% Output:
% 
% - xi : The domain of the distribution, as 1000 x nvars double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        numDomain = 1000;
        if nargin < 2
            numberOfStd = 1;
        end
    end

    stdX = std(x,0,1);
    maxX = max(x,[],1) + numberOfStd*stdX;
    minX = min(x,[],1) - numberOfStd*stdX;
    incr = (maxX - minX)/(numDomain - 1);
    n    = size(x,2);
    xi   = nan(1000,n);
    for ii = 1:n
        try
            xi(:,ii) = minX(ii):incr(ii):maxX(ii);
        catch
            error([mfilename ':: One of the variables are constant.'])
        end
    end
    
end
