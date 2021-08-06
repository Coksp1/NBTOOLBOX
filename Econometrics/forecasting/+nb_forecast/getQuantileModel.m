function model = getQuantileModel(options,model,quantile)
% Syntax:
%
% model = nb_forecast.getQuantileModel(options,model,quantile)
%
% Description:
%
% Get the median model when it is estimated with quantile regression.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind = options(end).quantile == quantile;
    if ~any(ind)
        if quantile == 0.5
            error([mfilename ':: To produce point forecast you need to estimate the coefficients at the median (0.5 quantile). ',...
                             'Set draws to a number greater than 1 to produce a forecast of each estimated quantile.'])
        else
            error([mfilename ':: No quantile ' num2str(quantile) ' found for this model.'])
        end
    end
    model.A   = model.A(:,:,:,ind);
    model.B   = model.B(:,:,:,ind);
    model.C   = model.C(:,:,:,ind);
    model.vcv = model.vcv(:,:,:,ind);
    
end
