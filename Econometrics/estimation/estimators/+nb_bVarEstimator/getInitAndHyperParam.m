function [hyperParam,nCoeff,init,lb,ub] = getInitAndHyperParam(options)
% Syntax:
%
% [hyperParam,nCoeff,init,lb,ub] = ...
%    nb_bVarEstimator.getInitAndHyperParam(options)
%
% Description:
%
% Get hyperparameters, inital values and bounds
% 
% See also:
% nb_bVarEstimator.doEmpiricalBayesian, nb_bVarEstimator.print
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(options.prior.type)
        case {'glp','glpmf'} 
            hyperParam               = {'ARcoeff','lambda','Vc','S_scale'};
            lb                       = [-2,0.0001,0.0001,0.0001];
            ub                       = [2,5,inf,inf];
            [hyperParam,lb,ub]       = addHyperpriors(options.prior,hyperParam,lb,ub);
        case 'nwishart'
            hyperParam               = {'V_scale','S_scale'};
            lb                       = [0.0001,0.0001];
            ub                       = [inf,inf];
            [hyperParam,lb,ub]       = addHyperpriors(options.prior,hyperParam,lb,ub);
        otherwise
            error([mfilename ':: Unsupported prior type ' options.prior.type ' for empirical bayesian estimation.'])
    end

    % Do we not optimize over some hyperparameters?
    N   = length(hyperParam);
    ind = true(N,1);
    for ii = 1:N
        hyperprior = options.prior.([hyperParam{ii} 'Hyperprior']);
        if isempty(hyperprior)
            % Remove hyperprior from optimization
            ind(ii) = false; 
        end
    end
    hyperParam = hyperParam(ind);
    if isempty(hyperParam)
        error([mfilename ':: Cannot apply a empricial bayesian approach if no hyperparameters ',...
                         'are selected for optimization.'])
    end
    
    N      = length(hyperParam);
    nCoeff = zeros(N,1);
    for ii = 1:N
        nCoeff(ii) = size(options.prior.(hyperParam{ii}),1);
    end
    
    locB = nan(sum(nCoeff),1);
    kk   = 1;
    loc  = find(ind)';
    for ii = 1:size(loc,2)
        jj       = kk:kk + nCoeff(ii) - 1;
        locB(jj) = loc(ii):loc(ii) + nCoeff(ii) - 1;
        kk       = kk + nCoeff(ii);
    end
    lb = lb(locB);
    ub = ub(locB);
    
    if nargout > 2

        init = zeros(sum(nCoeff),1);
        kk   = 1;
        for ii = 1:N
            jj       = kk:kk + nCoeff(ii) - 1;
            init(jj) = options.prior.(hyperParam{ii});
            kk       = kk + nCoeff(ii);
        end

        if options.hyperprior
            for ii = 1:N
                % Test prior
                hyperprior = options.prior.([hyperParam{ii} 'Hyperprior']);
                try
                    hyperprior(1); % Should always work for 1 I think...
                catch Err
                    nb_error([mfilename ':: Cannot evaluate the hyperprior for the parameter ' ,...
                              hyperParam{ii} '.'],Err);
                end
            end
        end
        
    end
    
end

%==========================================================================
function [hyperParam,lb,ub] = addHyperpriors(prior,hyperParam,lb,ub)

    if prior.LR
        hyperParam = [hyperParam,'phi'];
        lb         = [lb,repmat(0.00001,[1,length(prior.phi)])];
        ub         = [ub,repmat(50,[1,length(prior.phi)])];
    elseif prior.SC
        hyperParam = [hyperParam,'mu'];
        lb         = [lb,0.00001];
        ub         = [ub,50];
    elseif prior.DIO
        hyperParam = [hyperParam,'delta'];
        lb         = [lb,0.00001];
        ub         = [ub,50];
    end

end
