function f = cdf(obj,x,type)
% Syntax:
%
% f = cdf(obj,x,type)
%
% Description:
%
% Evaluate the cdf of the given distribution at the value(s) x.
%
% The value is only an approximation!
% 
% Input:
% 
% - obj   : An object of class nb_copula
%
% - x     : A double size TxN, where N is the dimension of the multivariate
%           distribution.
%
% - type  : See output f.
% 
% Output:
% 
% - f   : Dependent on the type input:
%
%         > 'full'        : A Tx1 double with the multivariate cumulative   
%                           probabilities at the wanted points of the 
%                           multivariate domain. Default.
%
%         > 'marginals'   : A TxN double with the marginal cumulative  
%                           probabilities at the wanted points of the 
%                           multivariate domain.
%
%         > 'conditional' : Calculate the conditional probability for the
%                           multivariate probabilities at the wanted points 
%                           of the multivariate domain. The variables
%                            to condition on are identified by the
%                           the distribution which the conditionalValue  
%                           property is set to a number.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: The input obj must be a scalar nb_copula object.'])
    end

    if nargin < 3
        type = 'full';
    end
    
    switch lower(type)
        
        case 'full'
            
            % Check the inputs
            [~,dim2] = size(x);
            if dim2 ~= length(obj.distributions)
                error([mfilename ':: The x input must have size(x,2) equal to the dimension of the'...
                                 ' multivariate distribution (' int2str(length(obj.distributions)) ').'])
            end
            
            % Map the x observations to its own marginal cdf
            nDist = length(obj.distributions);
            u     = x;
            for ii = 1:nDist
                u(:,ii) = cdf(obj.distributions(ii),x(:,ii));
            end
            
            % See https://en.wikipedia.org/wiki/Copula_%28probability_theory%29
            u = nb_distribution.normal_icdf(u,0,1);
            f = nb_mvncdf(u,zeros(1,nDist),obj.sigma);
             
        case 'conditional'
            
            vCond = [obj.distributions.conditionalValue];
            iCond = ~cellfun(@isempty,{obj.distributions.conditionalValue});
            
            % Check the inputs
            distr    = obj.distributions(~iCond);
            nDist    = length(distr);
            [~,dim2] = size(x);
            if dim2 ~= nDist
                error([mfilename ':: The x input must have size(x,2) equal to the dimension of the'...
                                 ' conditional multivariate distribution (' int2str(length(obj.distributions)) ').'])
            end
            
            % Map the x observations to its own marginal cdf and pdf of 
            % the unconditional distributions
            u = x;
            for ii = 1:nDist
                u(:,ii)   = cdf(distr(ii),x(:,ii));
            end
            indU   = find(~iCond);
            indC   = find(iCond);
            ind    = [indU,indC];
            sigmaA = obj.sigma(ind,ind);
            sigmaC = obj.sigma(iCond,iCond);
            
            % Map conditonal distributions to its cdf
            nPoints   = size(x,1);
            condDistr = obj.distributions(iCond);
            nCondDist = length(condDistr);
            uCond     = ones(1,nCondDist);
            for ii = 1:nCondDist
                uCond(:,ii) = cdf(condDistr(ii),vCond(:,ii));
            end
            uCond  = uCond(ones(1,nPoints),:);
            uAll   = [u,uCond];
            %uCond  = [ones(1,nDist),uCond];
            
            % Copula cdf for all 
            x    = nb_distribution.normal_icdf(uAll,0,1);
            cAll = nb_mvncdf(x,zeros(1,length(obj.distributions)),sigmaA);
            
            % Copula pdf for conditional variables 
            x     = nb_distribution.normal_icdf(uCond,0,1);
            cCond = nb_mvncdf(x,zeros(1,length(x)),sigmaC);
            
            % Conditional multivariate CDF
            f     = cAll/cCond;    
            
        case 'marginals'
            
            % Check the inputs
            [dim1,dim2] = size(x);
            if dim2 ~= length(obj.distributions)
                error([mfilename ':: The x input must have size(x,2) equal to the dimension of the'...
                                 ' multivariate distribution (' int2str(length(obj.distributions)) ').'])
            end
            
            f = nan(dim1,dim2);
            for ii = 1:size(x,2)
                f(:,ii) = cdf(obj.distributions(ii),x(:,ii));
            end
            
    end

end
