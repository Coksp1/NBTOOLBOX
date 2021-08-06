function f = pdf(obj,x,type)
% Syntax:
%
% f = pdf(obj,x,type)
%
% Description:
%
% Evaluate the pdf of the given distribution at the value(s) x.
% 
% To condition on a value for a given marginal distribution, see the 
% conditionalValue property of nb_distribution.
%
% Input:
% 
% - obj  : An object of class nb_copula
%
% - x    : A double size TxN, where N is the dimension of the multivariate
%          distribution.
%
%          Caution : If 'type' is set to 'conditional' N is equal to the
%                    number of multivariate distribution not conditioned 
%                    on.
%
% - type  : See output f.
%
% Output:
% 
% - f   : Dependent on the type input:
%
%         > 'full'        : A Tx1 double with the multivariate  
%                           probabilities at the wanted points of the 
%                           multivariate domain. Default.
%
%         > 'marginals'   : A TxN double with the marginal probabilities at 
%                           the wanted points of the multivariate domain.
%
%         > 'conditional' : Calculate the conditional probability for the
%                           multivariate probabilities at the wanted points 
%                           of the multivariate domain. The variables 
%                           to condition on are identified by the
%                           the distribution which the conditionalValue  
%                           property is set to a number.
%
%         > 'log'         : Log of the likelihood.
%                         
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
            
            % Map the x observations to its own marginal cdf and pdf
            nDist = length(obj.distributions);
            u     = x;
            fi    = x;
            for ii = 1:nDist
                u(:,ii)   = cdf(obj.distributions(ii),x(:,ii));
                fi(:,ii)  = pdf(obj.distributions(ii),x(:,ii));
            end
            
            z               = nb_distribution.normal_icdf(u,0,1);
            R               = nb_chol(obj.sigma,'cov'); 
            logSqrtDetSigma = sum(log(diag(R))); % Lower triangular matrix so sum(diag(R)) and det(R) is the same!
            zz              = z/R;
            ck              = exp(-0.5.*sum(zz.^2 - z.^2,2)  - logSqrtDetSigma );
            f               = ck.*prod(fi,2);
          
        case 'log'
            
            % Check the inputs
            [~,dim2] = size(x);
            if dim2 ~= length(obj.distributions)
                error([mfilename ':: The x input must have size(x,2) equal to the dimension of the'...
                                 ' multivariate distribution (' int2str(length(obj.distributions)) ').'])
            end
            
            % Map the x observations to its own marginal cdf and pdf
            nDist = length(obj.distributions);
            u     = x;
            fi    = x;
            for ii = 1:nDist
                u(:,ii)   = cdf(obj.distributions(ii),x(:,ii));
                fi(:,ii)  = log(pdf(obj.distributions(ii),x(:,ii)));
            end
            
            z               = nb_distribution.normal_icdf(u,0,1);
            R               = chol(obj.sigma); 
            logSqrtDetSigma = sum(log(diag(R))); % Lower triangular matrix so sum(diag(R)) and det(R) is the same!
            zz              = z/R;
            ck              = -0.5.*sum(zz.*z,2) - logSqrtDetSigma;
            f               = ck + sum(fi,2);
            
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
            u     = x;
            fi    = x;
            for ii = 1:nDist
                u(:,ii)   = cdf(distr(ii),x(:,ii));
                fi(:,ii)  = pdf(distr(ii),x(:,ii));
            end
            indU   = find(~iCond);
            indC   = find(iCond);
            ind    = [indU,indC];
            sigmaA = obj.sigma(ind,ind);
            
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
            sigmaC = obj.sigma(iCond,iCond);
            
            % Copula pdf for all 
            x               = nb_distribution.normal_icdf(uAll,0,1);
            R               = nb_chol(sigmaA,'cov'); 
            logSqrtDetSigma = sum(log(diag(R))); % Lower triangular matrix so prod(diag(R)) and det(R) is the same!
            z               = x/R;
            cAll            = exp(-0.5.*sum(z.^2 - x.^2,2)  - logSqrtDetSigma);
            
            % Copula pdf for conditional variables 
            x               = nb_distribution.normal_icdf(uCond,0,1);
            R               = nb_chol(sigmaC,'cov'); 
            logSqrtDetSigma = sum(log(diag(R))); % Lower triangular matrix so prod(diag(R)) and det(R) is the same!
            z               = x/R;
            cCond           = exp(-0.5.*sum(z.^2 - x.^2,2)  - logSqrtDetSigma);
            
            % Conditional multivariate PDF
            f               = prod(fi,2)*cAll/cCond;
            
        case 'marginals'
            
            % Check the inputs
            [dim1,dim2] = size(x);
            if dim2 ~= length(obj.distributions)
                error([mfilename ':: The x input must have size(x,2) equal to the dimension of the'...
                                 ' multivariate distribution (' int2str(length(obj.distributions)) ').'])
            end
            
            f = nan(dim1,dim2);
            for ii = 1:size(x,2)
                f(:,ii) = pdf(obj.distributions(ii),x(:,ii));
            end
            
    end

end
