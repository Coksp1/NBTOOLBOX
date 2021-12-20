function y0 = removeExoFromTVPVAR(options,model,y0,iter)
% Syntax:
%
% y0 = nb_forecast.removeExoFromTVPVAR(options,model,y0,iter)
%
% Description:
%
% Produce forecast of measurment equation of a factor model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nInit = size(y0,2);
    nBack = size(y0,2) + options.nLags - 1;
    if options.constant
        X0 = ones(1,nBack);
    else
        X0 = zeros(0,nBack);
    end
    if options.time_trend
        error('Cannot forecast a VAR estimated with the ''tvpmfsv'' estimator.')
    end
    if ~isempty(options.exogenous)
        if options.recursive_estim
            tRec = options.recursive_estim_start_ind + iter - options.estim_start_ind;
        else
            tRec = options.estim_end_ind - options.estim_start_ind + 1;
        end
        [~,indX0] = ismember(options.exogenous,options.dataVariables);
        X0Exo     = options.data(tRec-nBack+1:tRec,indX0);
        X0        = [X0;X0Exo'];
    end
    FX0     = model.F(:,:,iter)*X0;
    nDep    = size(y0,1)/options.nLags;
    FXContr = zeros(size(y0,1),nInit);
    for ii = 1:options.nLags
        ind            = nDep*(ii-1) + 1:nDep*ii; 
        FXContr(ind,:) = FX0(:,ii:ii+nInit-1);
    end
    y0 = y0 - FXContr;
    
end
