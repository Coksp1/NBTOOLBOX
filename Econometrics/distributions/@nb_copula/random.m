function D = random(obj,nrow,npage)
% Syntax:
%
% D = random(obj,nrow,npage)
%
% Description:
%
% Draw random numbers from the multivariate distribution represented by the
% nb_copula object. I.e. uses a guassian copula to draw correlated draws
% from each marginal distribution.
% 
% Caution: If numel(obj) > 1 the number of marginal distribution of each
%          copula must be the same.
%
% Caution: If some of the marginal distributions objects has set the
%          conditonalValue property to some number, the random numbers
%          are generated conditional on this value(s).
%
% Input:
% 
% - obj   : An object of class nb_copula
%
% - nrow  : The number of rows of the draws output
%
% - npage : The number of pages of the draws output
% 
% Output:
% 
% - D     : A nrow x N x npage x nobj1 x nobj2 double with the draws from  
%           the multivariate distribution, where N is the number of 
%           marginal distributions.
%
% Examples:
% 
%   distr = nb_distribution.initialize('type',{'normal','gamma'},...
%                                      'parameters',{{6,2},{2,2}});
%   obj   = nb_copula(distr,'type','kendall','sigma',[1,0.5;0.5,1]);
%   D     = random(obj,100);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        npage = 1;
        if nargin < 2
            nrow = 1;
        end
    end
    
    [dim1,dim2] = size(obj);
    D           = nan(nrow,length(obj(1,1).distributions),npage,size(obj,1),size(obj,2));
    for ii = 1:dim1
        
        for jj = 1:dim2
            
            objT  = obj(ii,jj);
            if isempty(objT.sigma)
                error([mfilename ':: The sigma property of the copula (' int2str(dim1) 'x' int2str(dim2) ') is empty.'])
            end
            condV = [objT.distributions.conditionalValue];
            if isempty(condV)
                
                % Draw from the copula
                U = nb_copularnd(nrow,npage,objT.sigma,objT.type);

                % Convert to draws from the marginals
                for kk = 1:length(objT.distributions) 
                    D(:,kk,:,ii,jj) = icdf(objT.distributions(kk),U(:,kk,:));
                end
                
            else
                
                % Draw from the conditional copula
                vCond         = [objT.distributions.conditionalValue]; 
                vCondUni      = vCond;
                iCond         = ~cellfun(@isempty,{objT.distributions.conditionalValue});
                condDistr     = objT.distributions(iCond);
                uncondDistr   = objT.distributions(~iCond);
                for dd = 1:length(condDistr)
                    vCondUni(dd) = cdf(condDistr(dd),vCond(dd)); % Convert to [0,1]
                end
                U = nb_copulacondrnd(nrow,npage,objT.sigma,iCond',vCondUni',objT.type);
                
                % Convert to draws from the marginals
                Duncond = nan(nrow,length(uncondDistr),npage);
                for kk = 1:length(uncondDistr) 
                    Duncond(:,kk,:,ii,jj) = icdf(uncondDistr(kk),U(:,kk,:));
                end
                
                % Merge draws and conditional observations
                D             = nan(nrow,length(objT.distributions),npage);
                D(:,~iCond,:) = Duncond;
                D(:,iCond,:)  = vCond(ones(1,nrow),:,ones(1,npage));
                
            end
            
        end
        
    end
    
end
