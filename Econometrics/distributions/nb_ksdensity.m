function [f,x,u] = nb_ksdensity(yData,varargin)
% Syntax:
%
% [f,x,u] = nb_ksdensity(yData,varargin)
% [f,x,u] = nb_ksdensity(yData,domain,varargin)
%
% Description:
%
% Kernel density estimation. 
%
% Input:
% 
% - yData       : A numVar x numSim double. 
%
% - domain      : Same as the 'domain' input.
%
% Optional input:
%
% - 'domain'    : Either a 1 x numDomain or a numVar x numDomain double 
%                 with the point for where to evaluate the function f.  
%                 Can be empty, and in this case it will be estimated.
%
% - 'bandWidth' : Sets the bandwidth to use during kernel density 
%                 estimation. If given as a number less then or equal to
%                 0, the default value is used; sigma*(4/(3*N))^(1/5), 
%                 where sigma is the standard deviation of the xi input 
%                 calculated using mean absolute deviation and N is the 
%                 size(yData,2). The default value is found for each 
%                 function separately (numVar).
%
% - 'numDomain' : This option will set the number of values for where the 
%                 function f are to be evaluated if domain is not provided. 
%                 Default is 1000.
% 
% Output:
% 
% - f : A numVar x numDomain double with the estimated density function. 
%
% - x : A numVar x numDomain double with the domain of the density 
%       function f.
%
% - u : A numVar x 1 double with the selected band widths.
%
% See also:
% ksdensity, Distribution.ksdensity, Distribution.ksdomain
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin > 1
        if isnumeric(varargin{1})
            varargin = ['domain',varargin];
        end
    end

    default = {'bandWidth',         [],         @isnumeric;...
               'domain',            [],         @isnumeric;...
               'numDomain',         1000,       {@nb_isScalarInteger,'&&',{@gt,0}}};       
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end

    numVar = size(yData,1);
    sigma  = mad(yData,1,2)/0.6745;
    N      = size(yData,2);

    % Individual domain for all variables
    if isempty(inputs.domain)

        maxim = ceil(max(yData,[],2)*100)/100;
        minim = floor(min(yData,[],2)*100)/100;
        maxim = maxim + sigma*2;
        minim = minim - sigma*2;
        if any(sigma == 0)
            ind = find(sigma == 0);
            error([mfilename ':: No variation in the data at rows ' toString(ind) '.']) 
        end

        bins = (maxim - minim)./(inputs.numDomain - 1); % Default is to store 1000 points of the density 
        x    = nan(numVar,inputs.numDomain);
        for ii = 1:numVar
            x(ii,:) = minim(ii):bins(ii):maxim(ii);
        end
        indSigma = false(numVar,1);

    else

        x = inputs.domain;
        if size(inputs.domain,1) == 1
            x = x(ones(numVar,1),:);
        elseif numVar ~= size(x,1)
            error([mfilename ':: The size of the first dimension of the ''domain'' input does not match the data.'])
        end
        indSigma        = sigma == 0;
        sigma(indSigma) = 1;

    end

    % Calculate band width
    M = size(x,2);
    if isempty(inputs.bandWidth)
        u = sigma.*(4.0/(3.0*N))^0.2;
    else
        u = inputs.bandWidth;
    end
    uPerm = permute(u,[3,2,1]);
    uPerm = uPerm(ones(N,1),ones(M,1),:);

    % Estimate the kernel density
    yData  = permute(yData,[2,3,1]);
    yData  = yData(:,ones(M,1),:);
    domain = permute(x,[3,2,1]);
    domain = domain(ones(N,1),:,:);
    f      = sum(normKernel((domain - yData)./uPerm),1);
    f      = permute(f./(uPerm(1,:,:)*N),[3,2,1]);
    if any(indSigma)
        % "Constant" distribution
        f(indSigma,:) = 0;
        locSigma      = find(indSigma);
        for ii = 1:length(locSigma)
            loc = find(x(locSigma(ii),:) >= yData(1,1,locSigma(ii)),1);
            if ~isempty(loc)
                f(locSigma(ii),loc) = 1/(x(ii,2) - x(ii,1));
            else
                error([mfilename ':: Fatal error when calculating the kernel density function.'])
            end
        end
    end

end

function f = normKernel(x)

    f = exp(-0.5*x.^2)./sqrt(2*pi);

end
