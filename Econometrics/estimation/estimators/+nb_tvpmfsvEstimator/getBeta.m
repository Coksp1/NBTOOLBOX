function beta = getBeta(options,results)
% Syntax:
%
% beta = nb_tvpmfsvEstimator.getBeta(options,results)
%
% Description:
%
% Get all estimated coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nRec = size(results.T,3);
    
    % Loadings
    if strcmpi(options.class,'nb_var') || strcmpi(options.class,'nb_mfvar')
        L        = nan(0,1,nRec);
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            nFactors = options.nFactors; 
        else
            nFactors = length(options.dependent);
        end
    else
        nFactors           = options.nFactors;         
        L                  = results.Z(:,1:nFactors,:);
        L                  = reshape(L,[size(L,1)*size(L,2),1,nRec]);
        L(all(L==0,3),:,:) = [];
    end
    
    % Measurement errors
    if strcmpi(options.class,'nb_var') || strcmpi(options.class,'nb_mfvar')
        R = nan(0,1,nRec);
    else
        nObsVars = length(options.observables);
        R        = nan(nObsVars,1,nRec);
        for ii = 1:nRec
           R(:,:,ii) = diag(results.R(:,:,ii)); 
        end
    end
    
    % Transtion of factors coefficients
    T = reshape(results.T(1:nFactors,:,:),[nFactors*size(results.T,2),1,nRec]);
    
    % Covariance matrix of transition equation
    Q = reshape(results.Q,[nFactors*nFactors,1,nRec]);
    
    if isempty(results.C)
        C = nan(0,1,nRec);
    else
        C = results.C;
    end
    if isempty(results.S)
        S = nan(0,1,nRec);
    else
        S = results.S;
    end
    
    % Concatenate all
    beta = [...
        C;
        S;
        L;
        R;
        T;
        Q];

end
