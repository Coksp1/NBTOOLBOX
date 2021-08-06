function results = nb_automaticModelSelection(y,X,varargin)
% Syntax:
%
% results = nb_automaticModelSelection(y,X,varargin)
%
% Description:
%
% Automatic model selection for single-equation models.
% 
% References:
%
% - G. Sucarrat and A. Escribano (2011): "Automated Model Selection 
% in Finance: General-to-Specific Modelling of the Mean and 
% Volatility Specifications"
%
% - D. F. Hendry and H.-M. Krolzig (2005): "The Properties of 
% Automatic Gets Modelling." Economic Journal 115, C32-C61.
%
% - D. F. Hendry and H.-M. Krolzig (2001): "Automatic Econometric 
% Model Selection using PcGets". London: Timberlake Consultants 
% Press.
%
% Input:
% 
% - y : A nobs x neqs double. (Dependent variables)
%
% - X : A nobs x nvar double. Regressors.
% 
% Optional input:
%
% - 'alpha'     : Significance level of the arch, normality and 
%                 autocorrelation test statistics used for 
%                 validating models.
%
% - 'constant'  : 1 if you want to include constant, else 0. Default
%                 is 1.
%
% - 'lags'      : A double vector with the lags to test out. E.g.
%                 1:10 or [1,3,4,5-6]
%
% - 'criterion' : Criterion to use to select models from the
%                 sample of valid models.
%
% - 'fixed'     : The regressors to force to include in the model, and not
%                 append, lags.
%
% - 'start'     : The index to start the estimation from. Be aware that
%                 if you set this to 1 and maxLagLength > 0, then
%                 the data will include nan values, so startInd should be
%                 at least 1 + max(lags).
%
% Output:
% 
% - results     : A struct with the model selection results
%
% Original code by Junior Maih (autmatic_model_selection method of the
% ts class of the RISE toolbox.). Modified by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Parse optional inputs
    %--------------------------------------------------------------
    opt = parseInput(varargin{:});
    if isempty(opt.fixed)
        opt.fixed = false(1,size(X,2));
    end
    
    % Check some inputs
    %--------------------------------------------------------------
    [nobsExo,~]        = size(X);
    [nobsEndo,numEndo] = size(y);
    
    if any(X(:) - real(X(:)))
        error([mfilename,':: The estimation data is not real.'])
    end

    if nobsExo ~= nobsEndo
        error([mfilename ':: The y and X vectors must have the same first dimension.'])
    end
    
    % Check that a constant is not included
    first_row = X(1,:);
    test      = sum(abs(bsxfun(@minus,X,first_row)),1);
    if any(test == 0)
        error([mfilename,':: One variable is constant, please remove it'])
    end
    
    % Start looping through each equations (endogenous == dependent)
    %==============================================================
    results = cell(1,numEndo);
    T       = nobsEndo;
    lags    = opt.lags;
    for iloop = 1:numEndo
        
        % Get the data 
        %----------------------------------------------------------
        y0 = y(:,iloop);
        
        % Fixed variables
        xf = X(:,opt.fixed);
        x0 = X(:,~opt.fixed);
        
        % Add the lags
        nlags = numel(lags);
        if lags(1) == 1
            x = x0;
        else
            x = [];
        end
        numExo  = size(x0,2);
        lagsInd = zeros(1,nlags*numExo + opt.constant);
        start   = numExo;
        for ilag = 1:nlags
            
            lag_i = lags(ilag);
            
            % Add the lags of the other exogenous variables
            x_i = [nan(lag_i,numExo);x0(1:T - lag_i,:)];
            x   = [x, x_i]; %#ok<AGROW>
            
            % Store lag index for later
            lagsInd(start:start + numExo - 1) = lag_i;
            start = start + numExo;
            
        end
        
        % Add the constant term at the end if wanted
        if opt.constant
            x = [x,ones(nobsExo,1)]; %#ok<AGROW>
        end
        
        % Store the regressors for later
        x  = [xf,x]; %#ok<AGROW>
        xs = x;
        
        if isempty(opt.start)
            startInd = opt.maxLags + 1;
        else
            startInd = opt.start;
        end
        
        % Now adjust sample according to the number of lags
        y0      = y0(startInd:end);
        x       = x(startInd:end,:);
        fixed   = 1:size(xf,2);
        lagsInd = [zeros(1,size(xf,2)),lagsInd]; %#ok<AGROW>
        
        % Do the autometrics on the equation
        %----------------------------------------------------------
        results{iloop} = block_autometrics(y0,x,opt.alpha,fixed,opt.criterion);
        
        % Add the selected model as matrices
        %----------------------------------------------------------
        xSize      = size(x,2);
        final_list = results{iloop}.list;
        final_lag  = lagsInd(final_list);
        if isempty(opt.start)
            final_max_lag = max(final_lag);
        else
            final_max_lag = startInd - 1;
        end
       
        % Get the selected lags for each variable
        %----------------------------------------------------------
        nlags     = cell(1,numExo);
        final_ind = [];
        kk        = 1;
        for ii = size(xf,2)+1:numExo+size(xf,2)
           
            exoInd          = ii:numExo:xSize - 1;
            ind             = ismember(final_list,exoInd);
            nlags{kk}       = unique(final_lag(ind)); 
            final_list_temp = final_list(ind);
            final_ind       = [final_ind,final_list_temp(:)']; %#ok<AGROW>
            kk              = kk + 1;
            
        end
        nlags = [repmat({0},1,size(xf,2)),nlags]; %#ok<AGROW>
        
        % Check if the constant is included in the final model
        %----------------------------------------------------------
        if opt.constant
            
            if any(xSize == final_list)
                results{iloop}.constant = 1;
            else
                results{iloop}.constant = 0;
            end
            
        else
            results{iloop}.constant = 0;
        end
        
        % Assign output strucutre
        %----------------------------------------------------------
        final_ind            = [1:size(xf,2),final_ind]; %#ok<AGROW>
        results{iloop}.X     = xs(final_max_lag + 1:end,final_ind);
        results{iloop}.y     = y(final_max_lag + 1:end,iloop);
        results{iloop}.nlags = nlags;
        
    end

end

%==================================================================
% SUB
%==================================================================
function inputs = parseInput(varargin)

    inputs = struct('constant',  1,...
                    'criterion', 'aic',...
                    'lags',      1:10,...
                    'fixed',     [],...
                    'alpha',     0.05,...
                    'start',     []);

    if rem(length(varargin),2) ~= 0
        error([mfilename ':: Optional inputs must come in pairs.'])
    end
    
    for ii = 1:2:size(varargin,2)
        
        inputName  = varargin{ii};
        inputValue = varargin{ii + 1};
        
        switch lower(inputName)
            
            case 'alpha'
                
                if ~isnumeric(inputValue) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.alpha = inputValue;
                
            case 'constant'
                
                if (~isnumeric(inputValue) && ~islogical(inputValue)) || ~isscalar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a number.'])
                end
                
                inputs.constant = inputValue;
                
            case 'criterion'
                
                if ~ischar(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''aic'', ''bic'' or ''hqc''.'])
                end
                
                ind = strcmpi(inputValue,{'aic','aicc','sic','hqc','maic','msic','mhqc',''});
                if isempty(ind)
                    error([mfilename ':: The input ' inputName ' must be set to a string. Either ''aic'', ''bic'', ''hqc'', ''aicc'', ''maic'', ''msic'', ''mhqc'' or empty.'])
                end
                
                inputs.lagLengthCrit = inputValue;    
                
            case 'fixed'
                
                if ~isnumeric(inputValue) && ~islogical(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to a double array.'])
                end
                
                inputs.fixed = inputValue;
                
            case 'lags'
                
                if ~isnumeric(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to double (scalar or vector).'])
                end
                
                inputs.lags = inputValue;  
                
            case 'start'
                
                if ~isnumeric(inputValue)
                    error([mfilename ':: The input ' inputName ' must be set to double (scalar or vector).'])
                end
                
                inputs.start = inputValue;     
                
            otherwise
                
                error([mfilename ':: Bad optional input ' inputName])
                
        end
        
    end
    
    % Check the lags input
    inputs.lags = unique(sort(inputs.lags(:)));
    if any(inputs.lags < 0) 
        error([mfilename,':: No leads (negative lags) allowed.'])
    end
    inputs.maxLags = max(inputs.lags);

    if ~isempty(inputs.start)
        if inputs.start < inputs.maxLags + 1
            error([mfilename ':: The start (' int2str(inputs.start) ') index is less then max number of lags selected + 1 (' int2str(inputs.maxLags + 1) ')'])
        end
    end
    
    % Should it be possible to set these?
    inputs.diagnostics = {'normality','autocorrelation','arch'};
    
end

function final_model = block_autometrics(y,x,alpha,prefixed,criterion)

    pa    = alpha;
    [T,k] = size(x);
    S0    = prefixed; % candidate set
    kf    = numel(prefixed);% number of terms that are forced in all models

    % Decide whether to block it or not. Allow for 10 degrees of 
    % freedom...
    use_blocks = T - k < 10; % k/T>0.9;
    last_fixed = prefixed;
    if use_blocks
        
        BBAR_S        = setdiff(1:k,S0);
        ii            = 0;
        stage         = 'A';
        not_converged = true;
        pa_1          = pa;
        pa_2          = pa;
        shrinkage     = 1; % s in paper
        Jsteps        = 10;
        while not_converged
            
            [Omitted,shrinkage] = expansion_step(y,x,BBAR_S,S0,T,kf,Jsteps,shrinkage,pa_1,pa_2,criterion);
            if ii == 0 && numel(Omitted)/numel(BBAR_S) < 0.1
                shrinkage = 8*shrinkage;
            end

            % find S_{i+1} from model selection on union(S_{i},Oi)
            S0Oi = union(S0,Omitted);
            S1   = reduction_step(y,x,S0Oi,S0,pa_1,criterion);

            [chk_conv,stage,pa_1,pa_2] = change_stage(stage,pa,S0,S1);
            if chk_conv
                not_converged =~ isequal(S0,S1);
            end
            ii     = ii + 1;
            S0     = S1;
            BBAR_S = setdiff(1:k,S0);
            
        end
        
        for ii = 1:numel(prefixed)
            last_fixed(ii) = find(prefixed(ii) == S1);
        end
        
    else
        S1 = 1:k;
    end
    
    final_model = myautometrics(y,x(:,S1),pa,last_fixed,true,criterion);

end

function [chk_conv,stage,pa_1,pa_2] = change_stage(stage,pa,S0,S1)
        
    chk_conv=false;
    switch stage
        
        case 'A'
            
            stage = 'B';
            pa_1  = pa;
            pa_2  = pa_1;
            
        case 'C'
            
            stage = 'D';
            pa_1  = 4*pa;
            pa_2  = pa;
            
        otherwise
            
            if isequal(S1,S0)
                
                if strcmp(stage,'B')
                    stage = 'C';
                    pa_1  = 2*pa;
                    pa_2  = pa_1;
                else
                    chk_conv = true;
                    pa_1     = pa;
                    pa_2     = pa;
                end
                
            else
                
                pa_1 = pa;
                pa_2 = pa;
                
            end
            
    end

end

function [Omitted,shrinkage] = expansion_step(y,x,BBAR_S,S0,T,kf,Jsteps,shrinkage,pa_1,pa_2,criterion)

    jj = 0;
    not_converged_expansion = jj < Jsteps;
    while not_converged_expansion
        
        [BBAR_S,c0] = block_partitions(BBAR_S,S0,T,kf);
        
        % 1- Run B0 reductions union(B01,S1),...,union(B0B0,S1) keeping S1
        % fixed
        restricted_indexes = S0;
        B1 = [];
        for ib = 1:numel(BBAR_S)
            
            if jj==0
                BBAR_S{ib} = reduction_step(y,x,union(BBAR_S{ib},S0),restricted_indexes,shrinkage*pa_1,criterion);
            else
                BBAR_S{ib} = reduction_step(y,x,union(BBAR_S{ib},S0),restricted_indexes,shrinkage*pa_2,criterion);
            end
            
            % 2- let B1 be the selected regressors from all B0k,k=1,2,...,B0
            B1 = union(B1,BBAR_S{ib});
            
        end
        
        [flag,k0j] = small_enough(B1,c0);
        if flag
            % 3- stop if dim(B1) small enough
            jj = Jsteps;
        else
            
            % restart using B1 blocks B1 (if necessary shrinking p-value)
            jj = jj + 1;
            if k0j >= 4*c0
                shrinkage = min(shrinkage/16,1);
            elseif k0j >= 3*c0
                shrinkage = min(shrinkage/8,1);
            elseif k0j >= 2*c0
                shrinkage = min(shrinkage/4,1);
            else
                shrinkage = min(shrinkage/2,1);
            end
            
        end
        BBAR_S = B1;
        not_converged_expansion = jj < Jsteps;
        
    end
    
    % 4- upon convergence after J steps, Oi=BJ
    Omitted = BBAR_S;
    
end

function [flag,k0j] = small_enough(BB,c0)
        
    k0j  = numel(BB);
    flag = k0j <= c0; % the paper says ci, is it a typo?

end

function [Bout,c0] = block_partitions(Bin,S0,T,kf)

    ki    = numel(S0);
    c0    = min(128,round(0.4*(T-kf)));
    kb    = round(max([c0-ki,c0/4,2]));
    nn    = numel(Bin);
    Bin   = Bin(randperm(nn));
    nbins = ceil(nn/kb);
    Bout  = cell(1,nbins);
    for ic = 1:nbins
        Bout{ic} = Bin((ic-1)*kb + 1:min(nn,ic*kb));
    end
    
end

function new_indexes = reduction_step(y,x,indexes,fixed,pval,criterion)

    fixity = nan(size(fixed));
    for id = 1:numel(fixity)
        fixity(id) = find(fixed(id) == indexes);
    end
    tempModel   = myautometrics(y,x(:,indexes),pval,fixity,true,criterion);
    new_indexes = indexes(tempModel.list);
    
end 

function final_model = myautometrics(y,x,alpha,fixed,isGUM,criterion)

    if nargin<5
        isGUM = true;
        if nargin<4
            fixed = [];
        end
    end
    
    k          = size(x,2);
    list       = (1:k);
    restricted = fixed;
    if ~isempty(restricted) && ~all(ismember(restricted,list))
        error([mfilename,':: Fixed variables not in the list'])
    end

    % 1- check whether the unrestricted GUM is valid. Let k be the 
    % number of regressors including the constant. Then k=k0+k1+1, 
    % where k1 is the number of insignificant regressors. The 
    % constant is never removed...
    GUM = struct('list',        list,...
                 'active',      true,...
                 'duplicated',  false,...
                 'restricted',  restricted,...
                 'Results',     []);
                   
    [GUM,isvalid,disabled] = estimate(y,x,GUM,[],alpha);

    switch isvalid
        
        case {0,1} % it is either good or some tests have failed
            
            k1 = GUM.Results.insignificant;
            
            % 2- if the GUM is valid, define the number of insignificant variables
            % to be the number of search paths, that is k1.
            if k1
                
                Models = struct('list',{},'active',{},'duplicated',{},'restricted',{},'Results',{});
                for ii = 1:k1
                    
                    leader                = list(GUM.Results.rank == ii);
                    Models(ii).list       = setdiff(list,leader);
                    Models(ii).active     = true;
                    Models(ii).duplicated = false;
                    Models(ii).restricted = restricted;
                    
                end
                
                % 3- after removal of the first variable in a path, 
                % subsequent simplication in each path is 
                % undertaken using "single-path" GETS search,
                % where the regressor with the highest p-value is
                % sought deleted at  each simplification.
                while any([Models.active])
                    
                    for ii = 1:numel(Models)
                        
                        list_i = Models(ii).list;
                        for jj = ii + 1:numel(Models)
                            
                            if isequal(Models(jj).list,list_i)
                                Models(ii).duplicated = true;
                                break
                            end
                            
                        end
                        
                        if Models(ii).active && ~Models(ii).duplicated
                            Models(ii) = evolve_single_path(y,x,Models(ii),disabled,alpha);
                        end
                        
                    end
                    
                    duplicated = find([Models.duplicated]);
                    if ~isempty(duplicated)

                        Models(duplicated) = [];
                        
                    end
                    
                end

                if numel(Models) == 0 % no reduction path was successful
                    final_model = GUM;
                elseif numel(Models) == 1
                    final_model = Models;
                else
                    
                    if isGUM
                        
                        % Create a general GUM of all final models 
                        % and run again
                        newgum = [];
                        for ii = 1:numel(Models)
                            newgum = union(newgum,Models(ii).list);
                        end
                        
                        second_fixed = fixed;
                        for ii = 1:numel(second_fixed)
                            second_fixed(ii )= find(fixed(ii)==newgum);
                        end
                        second_round = myautometrics(y,x(:,newgum),alpha,second_fixed,false,criterion);
                        
                        % Adjust for the variable list
                        final_model      = second_round;
                        final_model.list = newgum(second_round.list);
                        
                    else
                        
                        % Now select by information criterion
                        switch criterion
                            case 'aic'
                                crit = Models(1).Results.aic;
                            case {'sic','bic'}
                                crit = Models(1).Results.sic;
                            case 'hqc'
                                crit = Models(1).Results.hqc;
                            case 'aicc'
                                crit = Models(1).Results.aicc;
                            otherwise
                                error([mfilename ':: Criterion ' criterion ' is not supported.'])
                        end
                        
                        final_model = Models(1);
                        for ii = 2:numel(Models)
                            
                            switch criterion
                                case 'aic'
                                    critT = Models(ii).Results.aic;
                                case {'sic','bic'}
                                    critT = Models(ii).Results.sic;
                                case 'hqc'
                                    critT = Models(ii).Results.hqc;
                                case 'aicc'
                                    critT = Models(ii).Results.aicc;
                                otherwise
                                    error([mfilename ':: Criterion ' criterion ' is not supported.'])
                            end
                            
                            if critT < crit
                                crit        = critT;
                                final_model = Models(ii);
                            end
                            
                        end
                        
                    end
                    
                end
                
            else
                
                % All regressors are significant
                final_model = GUM;
                
            end
            
        otherwise
            error([mfilename,':: Too few observations even after blocking'])
    end

end

function M = evolve_single_path(y,x,M,disabled,alpha)

    % we attempt to delete one variable
    if isempty(M.Results)
        
        [M0,is_still_valid] = estimate(y,x,M,disabled,alpha);
        if is_still_valid
            M = M0;
        else
            % Mark the path for deletion
            M.duplicated = true;
            return
        end
        
    end
    
    next     = next_candidate(M,alpha);
    M.active =~ isempty(next);
    if M.active
        
        newlist             = setdiff(M.list,next);
        M2                  = M; 
        M2.list             = newlist;
        [M2,is_still_valid] = estimate(y,x,M2,disabled,alpha);
        if is_still_valid
            % check whether the next candidate is part of the
            % restriced list. It might be the case that because of
            % some collinearity problem it was not possible to
            % delete it earlier but that now it makes sense to do
            % so.
            loc = find(M2.restricted == next);
            if ~isempty(loc)
                M2.restricted(loc)=[];
                % alternatively, one could just say that the guys
                % that are in the restricted list can never be
                % deleted. In that case, the search would stop when
                % the next candidate is in the restricted list.
                % But just how does that happen in the first place?
                % another thing to do is to differentiate between
                % the variables that have been imposed by the user
                % and cannot be deleted and the variables that can
                % be deleted because the algorithm at some step,
                % found them deletable even if at some earlier
                % stage this was not the case.
                warning('nb_automaticModelSelection:removedFixed',[mfilename ':: Variable ',int2str(next),' removed from the restricted list and from the model'])
            end
            M = M2;
            
        else
            
            if ismember(next,M.restricted)
                warning('nb_automaticModelSelection:removedFixed',[mfilename ':: Attempting to put variable ',int2str(next),' back into the list. Path will end here.'])
                M.active = false;
            else
                M.restricted = union(M.restricted,next);
            end
            
        end
        M = rank_variables(M,alpha);
        
    end
    
end

function next = next_candidate(M,alpha)
% Chooses the next candidate for deletion

    next     = [];
    position = M.Results.rank == 1;
    if M.Results.pval(position) > alpha && ~ismember(M.list(position),M.restricted)
        next = M.list(position);
    end
    
end

function [Model,isvalid,failed_tests] = estimate(y,x,Model,disabled,alpha)

    if nargin<2
        disabled = [];
    end

    ki           = numel(Model.list);
    isvalid      = ki > 0;
    failed_tests = [];
    if isvalid

        first_check = numel(y) >= ki;
        isvalid     = first_check - ~first_check;
        if isvalid == -1
            error([mfilename,':: The sample is too short.'])
        end

        if isvalid == 1

            res = struct();
            
            % Estimate the model at the current selection
            [beta,~,res.tstat,res.pval,resi] = nb_ols(y,x(:,Model.list));
            
            % Get the test-statistics
            T                     = size(y,1);
            numCoeff              = size(beta,1);
            logLikelihood         = nb_olsLikelihood(resi);
            res.aic               = nb_infoCriterion('aic',logLikelihood,T,numCoeff);
            res.sic               = nb_infoCriterion('sic',logLikelihood,T,numCoeff);
            res.hqc               = nb_infoCriterion('hqc',logLikelihood,T,numCoeff);
            [~,archPval]          = nb_archTest(resi,5);
            [~,autocorrPval]      = nb_autocorrTest(resi,5);
            [~,normalityPval]     = nb_normalityTest(resi);
            Model.Results         = res;
            
            % Rank the model after tstat(p-values) of the 
            % individual coefficients
            Model = rank_variables(Model,alpha);

            % Check if the 
            tests_pval = [normalityPval,autocorrPval,archPval];
            if isempty(disabled)
                disabled = false(size(tests_pval));
            end
            failed_tests = tests_pval < alpha;
            isvalid      =~ any(failed_tests(~disabled));
            
        end

    end

end

function Model = rank_variables(Model,alpha)
% Rank the regressor after the t-statistics

    tmp         = Model.Results.tstat;
    params_pval = Model.Results.pval;
    tmp         = abs(tmp);
    
    % The fixed regressor are given value which must outscore the
    % rest
    tmp(ismember(Model.list,Model.restricted))         = inf;
    params_pval(ismember(Model.list,Model.restricted)) = 0;
    
    [~,tag]   = sort(tmp);
    rank      = tmp;
    rank(tag) = 1:numel(tmp);
    
    Model.Results.rank(tag)     = rank;
    Model.Results.insignificant = sum(params_pval >= alpha);
    
end  
