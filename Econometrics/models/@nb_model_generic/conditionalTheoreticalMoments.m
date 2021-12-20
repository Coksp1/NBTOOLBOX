function c = conditionalTheoreticalMoments(obj,varargin)
% Syntax:
%
% c = conditionalTheoreticalMoments(obj,varargin)
%
% Description:
%
% Calculate conditional theoretical moments; I.e. 
% (auto)covariance/(auto)correlation matrix.
% 
% Caution : This method stack all autocorrelations in one matrix. 
%           Equivalent to the output of the theoreticalMoments method
%           when the 'stacked' input is set to true.
% 
% Caution : For recursivly estimated model only the full sample estimation
%           results is used.
%
% Input:
% 
% - obj     : An object of class nb_model_generic
%
% Optional inputs;
%
% - 'vars'    : Either 'dependent' or 'full'. 'dependent' will return
%               the moment of the dependent variables of the model without
%               lag, while full will include all lags as well. 'dependent'
%               is default.
%
%               Can also be a cellstr, with a subset of variables
%               from 'full'.
%
% - 'output'  : Either 'nb_cs' or 'double'. Default is 'nb_cs'.
%
% - 'type'    : Either 'covariance' or 'correlation'. Default is 
%               'correlation'.
%
% - 'pDraws'  : Number of parameter draws. Default is 1. I.e. to use the
%               estimate parameters.
%
% - 'perc'    : Error band percentiles. As a 1 x numErrorBand double.
%               E.g. [0.3,0.5,0.7,0.9]. Default is []. I.e. return the
%               all draws.
%
%               Caution: 'draws' must be set to a number > 1.
%
% - 'method'  : The selected method to make the parameter draws.
%               Default is ''. See below for what that means.
%
%      > 'bootstrap'         : Create artificial data to bootstrap
%                              the estimated parameters. Default
%                              for models estimated with classical
%                              methods.
%
%     > 'wildBootstrap'      : Create artificial data by wild 
%                              bootstrap, and then "draw" paramters
%                              based on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
% 
%     > 'blockBootstrap'     : Create artificial data by 
%                              non-overlapping block bootstrap,
%                              and then "draw" paramters based 
%                              on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'mBlockBootstrap'    : Create artificial data by 
%                              overlapping block bootstrap,
%                              and then "draw" paramters based 
%                              on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'rBlockBootstrap'    : Create artificial data by 
%                              overlapping random block length  
%                              bootstrap, and then "draw" paramters 
%                              based  on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
%
%     > 'wildBlockBootstrap' : Create artificial data by wild
%                              overlapping random block length  
%                              bootstrap. , and then "draw" paramters 
%                              based  on estimation on these data. 
%                              Only an option for models estimated
%                              with classical methods.
% 
%     > 'posterior'          : Posterior draws. Only for models 
%                              estimated with bayesian methods. 
%                              Default for models estimated with 
%                              bayesian methods.
% 
%                              Caution : Posterior draws is 
%                                        already made at the  
%                                        estimation stage.
%
% - 'nSteps'    : Number of steps ahead. As an integer.
%
% Output:
% 
% - varargout{1} : The mean, as a 1 x nVar x draws nb_cs object or double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargout < 1
        return
    end

    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior',''};   
    default = {'method',       '',              {@ischar,'&&',{@nb_ismemberi,methods}};...
               'vars',         'dependent',     {@ischar,'&&',{@nb_ismemberi,{'dependent','full',''}},'||',@iscellstr};...
               'pDraws',       1,               {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'nSteps',       1,               {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'output',       'nb_cs',         {{@nb_ismemberi,{'nb_cs','double'}}};...
               'type',         'correlation',   {{@nb_ismemberi,{'correlation','covariance'}}};...
               'perc',         [],              {@isnumeric,'&&',@isrow,'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar nb_model_generic object.'])
    end
    
    model   = obj.solution;
    options = obj.estOptions(end);
    
    try
        model.A;
    catch %#ok<CTCH>
        error([mfilename ':: The model is not solved.'])
    end
    
    % Make draws of the model if wanted
    if inputs.pDraws > 1
        
        if options.recursive_estim
            error([mfilename ':: Cannot produce error band for recursivly estimated models.'])
        end
        model = parameterDraws(obj,inputs.pDraws,inputs.method,'solution',true);
        
    end
    if iscellstr(inputs.vars)
        dep = inputs.vars;
    elseif strcmpi(inputs.vars,'full')
        dep = obj.solution.endo;
    else
        dep = obj.dependent.name;
    end
    [test,depInd] = ismember(dep,obj.solution.endo);
    if any(~test)
        error([mfilename ':: Some of the variables in the ''vars'' input is not part of the endogenous variables of the model; ' toString(dep(~test))])
    end
    nDep          = length(dep);

    % Find the mean of the exogenous variables based on historical
    % observations
    exo      = model.exo;
    ind      = nb_ismemberi(exo,{'Constant','Time-trend'});
    [~,indX] = ismember(exo(~ind),options.dataVariables);
    X        = options.data(options.estim_start_ind:options.estim_end_ind,indX);
    
    % Find the variance of the exogenous variables based on historical
    % observations
    varX = cov(X);
    if isempty(varX)
        varX = [];
    end
    
    nSteps = inputs.nSteps;
    pDraws = inputs.pDraws;
    c      = zeros(nDep*nSteps,nDep*nSteps,pDraws);
    for jj = 1:pDraws
    
        try
            A   = model(jj).A;
            B   = model(jj).B;
            C   = model(jj).C;
            vcv = model(jj).vcv;
        catch %#ok<CTCH>
            error([mfilename ':: Model is not solved'])
        end
        
        if isfield(model,'CE')
            C = model.CE;
        end
        
        % If we are dealing with a MS model we need to integrate over different
        % regimes
        if isfield(model(jj),'Q')
            [A,B,C] = ms.integrateOverRegime(model(jj).Q,A,B,C);
        end
        
        % Only use the full sample estimates
        if size(A,3) ~= 1 % Shocks may be excpected
            C = C(:,:,end);
        end
        A    = A(:,:,end);
        B    = B(:,:,end);
        B    = B(:,~ind);
        vcv  = vcv(:,:,end);
        
        % Do the calculations
        c(:,:,jj) = nb_conditionalSecondOrderMoments(A,B,C,vcv,[],varX,nSteps,inputs.type,depInd);
    
    end
    
    % Remove really small numbers
    c(abs(c)<eps^(2/3)) = 0;
    
    % Return in the wanted format
    if isempty(inputs.perc)
        names = cell(1,pDraws);
        for ii = 1:pDraws
           names{ii} = ['Parameter draw ' int2str(ii)]; 
        end
    else
        perc  = nb_interpretPerc(inputs.perc,false);
        nPerc = size(perc,2);
        cTemp = nan(nDep,nDep,nPerc);
        for ii = 1:nPerc
            cTemp(:,:,ii) = prctile(c,perc(ii),3);
        end
        c = cTemp;
        
        names = cell(1,nPerc);
        for ii = 1:nPerc
           names{ii} = ['Percentile' num2str(perc(ii))]; 
        end
        
    end
    
    if strcmpi(inputs.output,'nb_cs')
        if size(dep,1) > 1
            dep = dep';
        end
        sDep        = [strcat(dep,'_lag0'),nb_cellstrlag(dep,nSteps-1,'varFast')];
        sDep        = strrep(sDep,'_lag','_period');
        c           = nb_cs(c,'',sDep,sDep,false);
        c.dataNames = names;
        
    end
    
end
