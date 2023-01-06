function Y = nb_simulateFromDensity(density,int,nDraws)
% Syntax:
%
% Y = nb_simulateFromDensity(density,int,nDraws)
%
% Description:
%
% Simulate from known densities.
%
% Inspired by the function density2Simulation from the PROFOR Team.
% 
% Input:
% 
% - density : One of:
%             > A 1 x nVars x nPer cell. Each element consist of a nHor x
%             nDomain double storing the densities evaluated at a domain
%             with nDomain elements at all forecasting horizons nHor. The
%             dimension 2 of each element of the density cell matrix must 
%             match match the dimension 2 of each element of the cell
%             matrix int.
%             > A nHor x nDomain x nPer double (int must also be a double).
%
% - int     : A 1 x nVars x nPer cell. Each element must store a 1 x
%             nDomain or a nHor x nDomain double, storing the domain of 
%             the density located at the same location in the density 
%             input.
%             > A nHor x nDomain x nPer double.
%
% - nDraws  : An integer. Default is 1000.
% 
% Output:
% 
% - Y       : Dependent on input: 
%             > cell   : A nHor x nVars x nPer x nDraws double.
%             > double : A nHor x nDraws x nPer 
%
% See also:
% nb_model_group.combineForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        nDraws = 1000;
    end
    
    if isnumeric(density)
        
        [nHor,~,nPer] = size(density);
        if size(int,1) == 1
            int = int(ones(1,nHor),:);
        end
        Y         = nan(nHor,nDraws,nPer);
        randDraws = rand(nHor,nDraws,nPer);
        for i = 1:nPer

            for j = 1:nHor

                binsLength = int(j,2,i) - int(j,1,i); 
                dens       = density(j,:,i);
                densCdf    = bsxfun(@times,cumsum(dens,2),binsLength); 
                topCDF     = max(densCdf(binsLength > eps^(1/5),:),[],2);
                if any(topCDF < nb_kernelCDFBounds(1)) || any(topCDF > nb_kernelCDFBounds(0))
                    error([mfilename ':: One CDF of the density forecast does not sum to 1!'])
                end
                if ~isnan(densCdf(1,:))
                    for k = 1:nDraws
                        diffWithCdf = (densCdf - randDraws(j,k,i)).^2;
                        [~, index]  = min(diffWithCdf,[],2);   
                        simD        = int(j,index,i);
                        Y(j,k,i)    = simD;
                    end
                end
                
            end

        end
        
    else
    
        [~,nVars,nPer] = size(density);
        nHor           = size(density{1,1},1);
        Y              = nan(nHor,nVars,nPer,nDraws);
        randDraws      = rand(nHor,nVars,nPer,nDraws);
        for i = 1:nPer

            for j = 1:nVars

                domain     = int{1,j,i};
                binsLength = domain(:,2) - domain(:,1); 
                dens       = density{1,j,i};
                densCdf    = bsxfun(@times,cumsum(dens,2),binsLength); 
                topCDF     = max(densCdf(binsLength > eps^(1/5),:),[],2);
                if any(topCDF < nb_kernelCDFBounds(1)) || any(topCDF > nb_kernelCDFBounds(0))
                    error([mfilename ':: One CDF of the density forecast does not sum to 1!'])
                end

                if size(domain,1) == 1
                    domain = domain(ones(1,nHor),:);
                end
                if ~isnan(densCdf(1,:) )
                    for k = 1:nDraws
                        for h = 1:nHor
                            diffWithCdf = (densCdf(h,:) - randDraws(h,j,i,k)).^2;
                            [~, index]  = min(diffWithCdf,[],2);   
                            simD        = domain(h,index);
                            Y(h,j,i,k)  = simD;
                        end
                    end
                end

            end

        end
        
    end
    
end
    
% All attempt to vectorize just uses more time:
%==============================================
%     [~,nVars,nPer]  = size(density);
%     nHor            = size(density{1,1},1);
%     Y               = nan(nHor,nVars,nPer,nDraws);
%     for i = 1:nPer
%         
%         for j = 1:nVars
%     
%             domain      = int{j,i};
%             nDomain     = length(domain);
%             binsLength  = domain(1,2) - domain(1,1); 
%             dens        = density{j,i};
%             densCdf     = cumsum(dens,2)*binsLength;                                
%             densCdf     = densCdf(:,:,ones(1,nDraws)); % Short for repmat
%             randDraws   = rand(nHor,1,nDraws);
%             randDraws   = randDraws(:,ones(1,nDomain),:);
%             diffWithCdf = (densCdf - randDraws).^2;
%             [~, index]  = min(diffWithCdf,[],2);   
%             index       = index(:);
%             simD        = domain(index);
%             simD        = reshape(simD,[nHor,1,1,nDraws]);
%             Y(:,j,i,:)  = simD;
%             
%         end
%         
%     end         
