function [hyperParam,nCoeff,init,lb,ub,paramMin,paramMax] = getInitAndHyperParam(options,throwErr)
% Syntax:
%
% [hyperParam,nCoeff,init,lb,ub,paramMin,paramMax] = ...
%    nb_bVarEstimator.getInitAndHyperParam(options,throwErr)
%
% Description:
%
% Get hyperparameters, inital values and bounds
% 
% See also:
% nb_bVarEstimator.doEmpiricalBayesian, nb_bVarEstimator.print
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        throwErr = true;
    end

    options.prior = nb_defaultField(options.prior,'optParam',{});
    options.prior = nb_defaultField(options.prior,'logTransformation',false);
    switch lower(options.prior.type)
        case 'jeffrey'
            [hyperParam,lb,ub,paramMin,paramMax] = addHyperpriors(options.prior,{},nan(1,0),nan(1,0),nan(0,1),nan(0,1),options.prior.optParam);
        case {'minnesota','minnesotamf'} 
            hyperParam = {'ARcoeff','a_bar_1','a_bar_2','a_bar_3','S_scale'};
            lb         = [-1,0.0001,0.0001,0.0001,0.0001];
            ub         = [ 1,   inf,   inf,   inf,   inf];
            if options.prior.logTransformation
                paramMax = [ 1;  1000;  1000;  1000;  1000];
                paramMin = [-1;0.0001;0.0001;0.0001;0.0001];
            else
                paramMax = nan(5,1);
                paramMin = nan(5,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end
            [hyperParam,lb,ub,paramMin,paramMax] = addHyperpriors(options.prior,hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam); 
        case {'inwishart','inwishartmf'}
            hyperParam = {'V_scale','S_scale'};
            lb         = [0.0001,0.0001];
            ub         = [inf,inf];
            if options.prior.logTransformation
                paramMax = [10000;1000];
                paramMin = [0.0001;0.0001];
            else
                paramMax = nan(2,1);
                paramMin = nan(2,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end
        case {'dsge'} 
            hyperParam = {'lambda'};
            lb         = 0;
            ub         = inf;
            if options.prior.logTransformation
                paramMax = 100000000;
                paramMin = 0.0001;
            else
                paramMax = nan(1,1);
                paramMin = nan(1,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end   
        case {'glp','glpmf'} 
            hyperParam = {'ARcoeff','lambda','Vc','S_scale'};
            lb         = [-1,0.0001,0.0001,0.0001];
            ub         = [1,5,inf,inf];
            if options.prior.logTransformation
                paramMax = [1;5;100000000;1000];
                paramMin = [-1;0.0001;0.0001;0.0001];
            else
                paramMax = nan(4,1);
                paramMin = nan(4,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end
            [hyperParam,lb,ub,paramMin,paramMax] = addHyperpriors(options.prior,hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
        case {'nwishart','nwishartmf'}
            hyperParam = {'V_scale','S_scale'};
            lb         = [0.0001,0.0001];
            ub         = [inf,inf];
            if options.prior.logTransformation
                paramMax   = [10000;1000];
                paramMin   = [0.0001;0.0001];
            else
                paramMax = nan(2,1);
                paramMin = nan(2,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end
            [hyperParam,lb,ub,paramMin,paramMax] = addHyperpriors(options.prior,hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);

        case {'horseshoe'}
            hyperParam = {'S_scale'};
            lb         = 0.0001;
            ub         = inf;
            if options.prior.logTransformation
                paramMax = 1000;
                paramMin = 0.0001;
            else
                paramMax = nan(1,1);
                paramMin = nan(1,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end
            
        case {'laplace'}
            hyperParam = {'lambda'};
            lb         = 0.0001;
            ub         = 10000;
            if options.prior.logTransformation
                paramMax   = 10000;
                paramMin   = 0.0001;
            else
                paramMax = nan(1,1);
                paramMin = nan(1,1);
            end
            if ~isempty(options.prior.optParam)
                [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,options.prior.optParam);
            end

        otherwise
            error([mfilename ':: Unsupported prior type ' options.prior.type ' for empirical bayesian estimation.'])
    end
    
    % Do we not optimize over some hyperparameters?
    N   = length(hyperParam);
    ind = true(N,1);
    if options.hyperprior
        for ii = 1:N
            hyperprior = options.prior.([hyperParam{ii} 'Hyperprior']);
            if isempty(hyperprior)
                % Remove hyperprior from optimization
                ind(ii) = false; 
            end
        end
    end
    hyperParam = hyperParam(ind);
    if isempty(hyperParam)
        if throwErr
            error([mfilename ':: Cannot apply a empricial bayesian approach ',...
                'if no hyperparameters are selected for optimization.'])
        end
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
function [hyperParam,lb,ub,paramMin,paramMax] = addHyperpriors(prior,hyperParam,lb,ub,paramMin,paramMax,optParam)

    if prior.SVD && (isempty(optParam) || any(strcmpi('rho',optParam)))
        lbEta      = 1;
        ubEta      = 500;
        nEta       = size(prior.eta,1);
        lbEta      = lbEta(:,ones(nEta,1));
        ubEta      = ubEta(:,ones(nEta,1));
        if nEta ~= 0
            hyperParam = [hyperParam,{'rho','eta'}];
        else
            hyperParam = [hyperParam,{'rho'}];
        end
        lb = [lb,0.005,lbEta];
        ub = [ub,0.995,ubEta];
        if prior.logTransformation
            paramMin = [paramMin;0.005;lbEta'];
            paramMax = [paramMax;0.995;ubEta'];
        else
            paramMin = [paramMin;nan(length(lbEta) + 1,1)];
            paramMax = [paramMax;nan(length(lbEta) + 1,1)];
        end
    end
    if prior.LR && (isempty(optParam) || any(strcmpi('phi',optParam)))
        hyperParam = [hyperParam,'phi'];
        lb         = [lb,repmat(0.00001,[1,length(prior.phi)])];
        ub         = [ub,repmat(50,[1,length(prior.phi)])];
        if prior.logTransformation
            paramMin = [paramMin;repmat(0.00001,[length(prior.phi),1])];
            paramMax = [paramMax;repmat(50,[length(prior.phi),1])];
        else
            paramMin = [paramMin;nan(length(prior.phi),1)];
            paramMax = [paramMax;nan(length(prior.phi),1)];
        end
    elseif prior.SC && (isempty(optParam) || any(strcmpi('mu',optParam)))
        hyperParam = [hyperParam,'mu'];
        lb         = [lb,0.00001];
        ub         = [ub,50];
        if prior.logTransformation
            paramMin = [paramMin;0.00001];
            paramMax = [paramMax;50];
        else
            paramMin = [paramMin;nan];
            paramMax = [paramMax;nan];
        end
    end
    if prior.DIO && (isempty(optParam) || any(strcmpi('delta',optParam)))
        hyperParam = [hyperParam,'delta'];
        lb         = [lb,0.00001];
        ub         = [ub,50];
        if prior.logTransformation
            paramMin   = [paramMin;0.00001];
            paramMax   = [paramMax;50];
        else
            paramMin = [paramMin;nan];
            paramMax = [paramMax;nan];
        end
    end

end

%==========================================================================
function [hyperParam,lb,ub,paramMin,paramMax] = selectOptHyperParam(hyperParam,lb,ub,paramMin,paramMax,optParam)

    if ~iscellstr(optParam)
        error('The prior option optIndex must be a cell array')
    end
    optIndex   = nb_ismemberi(hyperParam,optParam);
    hyperParam = hyperParam(optIndex);
    lb         = lb(optIndex);
    ub         = ub(optIndex);
    paramMin   = paramMin(optIndex);
    paramMax   = paramMax(optIndex);
                
end
