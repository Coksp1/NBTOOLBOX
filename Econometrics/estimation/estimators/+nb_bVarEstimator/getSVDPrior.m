function options = getSVDPrior(options,y)
% Syntax:
%
% options = nb_bVarEstimator.getSVDPrior(options,y)
%
% Description:
%
% Get prior mode and hyper prior distributions.
% 
% See also:
% nb_bVarEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(options.prior.dateSVD)
        error('You have not provided a value to the dateSVD field of the prior option.')
    end
    if ~nb_isScalarInteger(options.prior.periodsMax,0)
        error('The periodsMax field of the prior option must be set to an integer.')
    end

    startEst             = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
    dateSVD              = nb_date.toDate(options.prior.dateSVD,startEst.frequency);
    T                    = size(y,1);
    TC                   = dateSVD - startEst + 1;
    TCE                  = min(TC + options.prior.periodsMax - 1,T);
    options.prior.obsSVD = TC;
    if TC <= size(y,1)
        options.prior.eta = mean(abs(y(TC:TCE,:) - y(TC-1:TCE-1,:)),2)./...
            mean(mean(abs(y(2:TC-1,:) - y(1:TC-2,:))));
    else
        options.prior.eta = [];
    end
    options.prior.etaHyperprior = @(x)(x).^(-2);

end
