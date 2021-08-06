function E = nb_bootstrap(resid,replic,method)
% Syntax:
%
% E = nb_bootstrap(resid,replic,method)
%
% Description:
%
% Bootstrap residuals
% 
% Input:
% 
% - resid  : A nobs x nEq double
%
% - replic : The number of bootstrapped residuals. As an integer
%
% - method : 
%
%     > 'bootstrap'              : Classical bootstrap by drawing a sample
%                                  with replacement.
%
%     > 'wildBootstrap'          : Create artificial data by wild 
%                                  bootstrap.
%
%     > 'blockBootstrap'         : Create artificial data by 
%                                  non-overlapping block bootstrap.
%
%     > 'mBlockBootstrap'        : Create artificial data by 
%                                  overlapping block bootstrap.
%
%     > 'rBlockBootstrap'        : Create artificial data by 
%                                  overlapping random block length  
%                                  bootstrap.
% 
%     > 'dependentWildBootstrap' : Create artificial data by dependent  
%                                  wild bootstrap.
%
%
%     > 'wildBlockBootstrap'     : Create artificial data by wild
%                                  overlapping random block length  
%                                  bootstrap.
%
% Output:
% 
% - E : A nEq x replic x nobs double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    replic     = ceil(replic);  
    [nobs,nEq] = size(resid);

    if strcmpi(method,'bootstrap') || isempty(method)
        
        % Standard bootstrap
        E = reshape(resid(ceil(nobs*rand(nobs*replic,1)),:)',[nEq,replic,nobs]);
        
    elseif strcmpi(method,'wildBootstrap')
         
        % Wild bootstrap using Rademacher distribution
        U       = rand(nEq,replic,nobs);
        ind     = U <= 0.5;
        U(ind)  = -1;
        U(~ind) = 1;
        residM  = permute(resid,[2,3,1]);
        residM  = residM(:,ones(1,replic),:); 
        E       = residM.*U; 
        
    elseif strcmpi(method,'dependentWildBootstrap')
        
        % Dependent Wild bootstrap using Rademacher distribution
        U       = rand(nobs,nEq,replic);
        ind     = U <= 0.5;
        U(ind)  = -1;
        U(~ind) = 1;
        residM  = resid(:,:,ones(1,replic)); 
        E       = residM.*U; 
        
        % From the kernel which should preserv the autocorrelation
        rows        = 1:nobs;
        rows        = rows(ones(1,nobs),:);
        cols        = rows';
        K           = nb_quadraticSpectralKernel(abs(rows-cols));
        K(isnan(K)) = 1;
        L           = chol(K,'lower');
        for jj = 1:nEq
            for ii = 1:replic
                W          = diag(resid(:,jj));
                E(:,jj,ii) = W*L*E(:,jj,ii);
            end
        end
        E  = permute(E,[2,3,1]);
        
    elseif strncmpi(method,'blockBootstrap',14)
        
        blockLength = findBlockLength(method);
        
        % Block bootstrap using non-overlapping blocks, the length is
        % selected by nobs^.(1/3), or by the user
        E = nb_blockBootstrap(resid,replic,'nonoverlapping',blockLength);
        E = permute(E,[2,4,1,3]);
        
    elseif strncmpi(method,'mBlockBootstrap',15)
        
        blockLength = findBlockLength(method);
        
        % Block bootstrap using overlapping blocks, the length is
        % selected by nobs^.(1/3), or by the user
        E = nb_blockBootstrap(resid,replic,'overlapping',blockLength);
        E = permute(E,[2,4,1,3]);
        
    elseif strncmpi(method,'rBlockBootstrap',15)
        
        blockLength = findBlockLength(method); % Mean block length
        
        % Block bootstrap using random length blocks with overlapping
        E = nb_blockBootstrap(resid,replic,'random',blockLength);
        E = permute(E,[2,4,1,3]);
      
    elseif strncmpi(method,'wildBlockBootstrap',18)
        
        blockLength = findBlockLength(method); % Mean block length
        
        % Block bootstrap using random length blocks with overlapping
        E = nb_blockBootstrap(resid,replic,'wildrandom',blockLength);
        E = permute(E,[2,4,1,3]); 
        
    elseif strncmpi(method,'copulaBootstrap',15)
        
        length = findBlockLength(method); % Autocorr length
        E      = nb_copulaBootstrap(resid,replic,'autocorr',length);
        E      = permute(E,[2,4,1,3]);
        
    else
        error([mfilename ':: Unsupported method ' method])
    end
    
end

%==========================================================================
% SUB
%==========================================================================
function blockLength = findBlockLength(method)

    indPar1 = strfind(method,'(');
    if isempty(indPar1)
        blockLength = [];
    else
        indPar2 = strfind(method,')');
        if isempty(indPar2)
            error([mfilename ':: Undifined bootstrap method ' method])
        end

        blockLength = ceil(str2double(method(indPar1 + 1:indPar2 - 1)));
        if isnan(blockLength)
            error([mfilename ':: Undifined bootstrap method ' method])
        end

    end

end
