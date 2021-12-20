function output = nutSampler(objective,beta,~,varargin)
% Syntax:
%
% output = nb_mcmc.nutSampler(objective,beta,sigma,varargin)
%
% Description:
%
% Implementation of the No U-turn (NUT) sampler algorithm.
%
% This uses the functions nb_mcmc.NUTS and nb_mcmc.dualAveraging made by
% Matthew D. Hoffman.
% 
% Input:
% 
% - objective : A function handle that represents a function that is
%               proportional to the target distribution. Takes one input,
%               and that are the simulated random variables, which has the  
%               same type and size as the beta input. 
%
%               Caution : This function may also return the gradient of the
%                         objective. It must have size numVar x 1.
% 
% - beta      : Inital values of the random variables to draw from. E.g. 
%               the mode found under optimization in the case of parameter 
%               estimates from a DSGE model. As a 1 x numVar double.
%
% - sigma     : Not used. Only to make it generic to other samplers...
%
% Optional input:
%
% - 'accTarget' : Sets the prefered acceptance ratio when 'adaptive' is 
%                 set to 'target' or 'recTarget'. Default is 0.8. 
%
% - 'burn'      : The number of burned simulation in the start of the M-H
%                 algorithm. Default is 4000.
%
% - 'chains'    : The number of M-H chains to run. Default is 1. If 
%                 'parallel' is set to true, this also will be the number 
%                 of parallel workers.
%
% - 'draws'     : The number of draws returned for each chain. As a scalar
%                 integer. Default is 10000.
%
% - 'lb'        : Lower bound on the variables. As a 1 x numVar double.
%                 Default is [], i.e. no lower bound on any variable.
%
% - 'log'       : Give true if the objective function is in log. Default 
%                 is false.
%
% - 'parallel'  : Set to true to run M-H in parallel using parfor.
%
% - 'thin'      : The number of simulations between storing a draw during
%                 the NUT algorithm. Default is 10.
%
% - 'ub'        : Upper bound on the variables. As a 1 x numVar double.
%                 Default is [], i.e. no lower bound on any variable.
%
% - 'waitbar'   : Give true to include waitbar.
%
% Output:
% 
% - output : A 1 x number of chains struct array with the following fields
%            > beta : A draws x numVar double.
%
% See also:
% nb_mcmc.NUTS, nb_mcmc.dualAveraging, nb_mcmc.mhSampler, nb_waitbar
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(objective,'function_handle')
        error([mfilename ':: The objective input must be a function_handle object.'])
    end
    if ~isnumeric(beta)
        error([mfilename ':: The beta input must be a double row vector.'])
    end
    if size(beta,1) > 1 || size(beta,3) > 1
        error([mfilename ':: The beta input must be a double row vector.'])
    end
    beta = beta(:); % nb_mcmc.NUTS uses a column!
    
    if isstruct(varargin{1})
        varargin{1} = nb_rmfield(varargin{1},'sampler');
    end
    
    default = {'accTarget',        0.8,         {@nb_isScalarNumber,'&&',{@gt,0},'&&',{@lt,1}};...
               'burn',             4000,        {@nb_isScalarInteger,'&&',{@ge,0}};...
               'chains',           1,           {@nb_isScalarInteger,'&&',{@gt,0}};...
               'draws',            10000,       {@nb_isScalarInteger,'&&',{@gt,0}};...
               'lb',               [],          @isnumeric;...
               'log',              false,       @nb_isScalarLogical;...
               'maxTreeDepth',     12,          {@nb_isScalarInteger,'&&',{@gt,0}};...
               'parallel',         false,       {{@ismember,[0,1,2]}};...
               'thin',             10,          {@nb_isScalarInteger,'&&',{@gt,0}};...
               'ub',               [],          @isnumeric;...
               'waitbar',          [],          @nb_isScalarLogical};
           
    [output,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Secure that the function is returned in logs
    if ~output.log
        objective = @(x)log(objective(x));
    end
    
    % Pre-allocation and assignment of starting values
    returnsGrad = true;
    try 
        [fValLast,gradLast] = objective(beta);
    catch
        returnsGrad = false;
        try
            fValLast = objective(beta);
        catch Err
            nb_error(['The function_handle given by the objective input gave an error for the '...
                     'initial values provided by beta. Remember that this input is called in the ',...
                     'following way; fVal = objective(beta)'],Err);
        end
    end
    
    if ~isscalar(fValLast)
        error([mfilename ':: The output return by the objective must be a scalar.'])
    end
    
    if ~returnsGrad
        % If gradient is not returned by the objective we add it to the
        % function_handle using a numerical approximation.
        objective = @(x)deal(objective(x),nb_gradient(objective,x));
    else
        if ~all(size(gradLast) == size(beta(:)))
            error([mfilename ':: The objective must return a gradient with size numVar x 1. '...
                             '(is ' int2str(size(gradLast,1)) 'x' int2str(size(gradLast,2))])
        end
    end
    
    output.numVar    = size(beta,1);
    output.objective = objective;
    output.beta      = nan(output.numVar,output.draws);
    output.betaBurn  = nan(output.numVar,output.burn);
    output.grad      = nan(output.numVar,output.draws);
    output.fVal      = nan(output.draws,1);
    output.index     = 1;
    output.epsilon   = nan(1,1);
    
    if ~isempty(output.lb)
        output.lb = output.lb(:);
        if ~all(size(output.lb) == [output.numVar,1])
            error([mfilename ':: The ''lb'' input must match the beta input.'])
        end
    end
    if ~isempty(output.ub)
        output.ub = output.ub(:);
        if ~all(size(output.ub) == [output.numVar,1])
            error([mfilename ':: The ''ub'' input must match the beta input.'])
        end
    end
    
    % Run sampling
    if output.parallel 
        output = doParallel(output,beta);
    else
        output = doNormal(output,beta);
    end
    
    % Finish up
    [output(:).index] = deal(output(1).index - 1);
    for ii = 1:output(1).chains
        output(ii).beta     = output(ii).beta';
        output(ii).betaBurn = output(ii).betaBurn';
        output(ii).grad     = output(ii).grad';
        output(ii).ub       = output(ii).ub';
        output(ii).lb       = output(ii).lb';
    end
    
end

%==========================================================================
function output = doNormal(output,betaInit)

    % Waitbar
    %------------------------------  
    draws = output.draws;
    if output.waitbar
        total  = (output.burn + output.thin*draws)*output.chains;
        h      = nb_waitbar([],'No U-turn Sampling',total,false,true);
        h.text = 'Burning...';
        note   = nb_when2Notify(total);
    else
        h      = false;
        note   = [];
    end
    
    % Metropolis - Hastings steps
    %------------------------------
    output  = output(ones(1,output.chains));
    for ww = 1:output(1).chains
        % Burn and adaption
        [output(ww).betaBurn, output(ww).epsilon,~,~, fValLast, gradLast] = nb_mcmc.dualAveraging(output(ww).objective,...
            betaInit, output(ww).accTarget, output(ww).burn, output(ww).maxTreeDepth, output(ww).lb, output(ww).ub, note, h); 
    end
    
    % Update text on waitbar
    if output(1).waitbar
        h.text = 'Drawing...';
    end
    
    % Draw
    for ww = 1:output(1).chains

        % Get start from burn in sample
        betaLast = output(ww).betaBurn(:,end);
        
        % Start storing simulations
        kk = 1;
        for ii = 1:draws*output(ww).thin
            
            % Do one step of the NUTS algorithm
            [betaLast,~,~,fValLast,gradLast] = nb_mcmc.NUTS(output(ww).objective, output(ww).epsilon, betaLast, ...
                    output(ww).maxTreeDepth, output(ww).lb, output(ww).ub, fValLast, gradLast);

            % Store
            if rem(ii,output(ww).thin) == 0
                output(ww).beta(:,kk) = betaLast;
                output(ww).fVal(:,kk) = fValLast;
                output(ww).grad(:,kk) = gradLast;
                kk                    = kk + 1;
            end
                
            % Update waitbar
            if output(ww).waitbar
                if rem(ii,note) == 0
                    h.status = h.status + note;
                end
            end
            
        end
        
    end
    
    if output(1).waitbar
        delete(h)
    end

end

%==========================================================================
function output = doParallel(output,betaInit)

    % Open parallel pool
    %----------------------------------------
    if output.chains > nb_availablePoolSize()
        error([mfilename ':: The number of selected workers (' int2str(output.workers) ') cannot exeed ' int2str(nb_availablePoolSize()) '.'])
    end
    ret = nb_openPool(output.chains);

    % Waitbar
    %------------------------------
    draws = output.draws;
    if output.waitbar
        total  = (output.burn + draws*output.thin)*output.chains;
        h      = nb_waitbar([],'Parallel No U-turn Sampling',total,false,true);
        h.text = 'Burning...';
        note   = nb_when2Notify(total);
        D      = parallel.pool.DataQueue;
        afterEach(D,@(x)nUpdateWaitbar(x,h));
    else
        note   = [];
        D      = false;
    end
    
    % NUT steps
    %------------------------------
    output   = output(ones(1,output.chains));
    fValLast = nan(1,output(1).chains);
    gradLast = nan(1,output(1).chains);
    parfor ww = 1:output(1).chains
         % Burn and adaption
        [output(ww).betaBurn, output(ww).epsilon,~,~, fValLast(ww), gradLast(ww)] = nb_mcmc.dualAveraging(output(ww).objective,...
            betaInit, output(ww).accTarget, output(ww).burn, output(ww).maxTreeDepth, output(ww).lb, output(ww).ub, note, D); 
    end
    
    % Update text on waitbar
    if output(1).waitbar
        h.text = 'Drawing...';
    end
    
    % Draw
    parfor ww = 1:output(1).chains

        % Get start from burn in sample
        betaLast = output(ww).betaBurn(:,end);
        
        % Start storing simulations
        kk = 1;
        for ii = 1:draws*output(ww).thin
            
            % Do one step of the NUTS algorithm
            [betaLast,~,~,fValLast(ww),gradLast(ww)] = nb_mcmc.NUTS(output(ww).objective, output(ww).epsilon, betaLast, ...
                    output(ww).maxTreeDepth, output(ww).lb, output(ww).ub, fValLast(ww), gradLast(ww)); %#ok<PFOUS>

            % Store
            if rem(ii,output(ww).thin) == 0
                output(ww).beta(:,kk) = betaLast;
                output(ww).fVal(:,kk) = fValLast(ww);
                output(ww).grad(:,kk) = gradLast(ww);
                kk                    = kk + 1;
            end
                
            % Update waitbar
            if output(ww).waitbar
                if rem(ii,note) == 0
                    send(D,note);
                end
            end
            
        end
        
    end

    if output(1).waitbar
        delete(h)
    end
    nb_closePool(ret);
    
end

%==========================================================================
function nUpdateWaitbar(note,h)
    h.status = h.status + note;  
end
