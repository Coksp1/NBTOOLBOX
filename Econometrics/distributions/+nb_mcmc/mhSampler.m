function output = mhSampler(objective,beta,sigma,varargin)
% Syntax:
%
% output = nb_mcmc.mhSampler(objective,beta,sigma,varargin)
%
% Description:
%
% Implimentation of the Metropolis-Hastings algorithm.
% 
% Input:
% 
% - objective : A function handle that represents a function that is
%               proportional to the target distribution. Takes one input,
%               and that are the simulated random variables, which has the  
%               same type and size as the beta input.
% 
% - beta      : Inital values of the random variables to draw from. E.g. 
%               the mode found under optimization in the case of parameter 
%               estimates from a DSGE model. As a 1 x numVar double.
%
% - sigma     : Inital guess on the covariance matrix of the random
%               variables. E.g. the inverted Hessian found during
%               estimation of parameters of a DSGE model. As a numVar x
%               numVar double matrix.
%
% Optional input:
%
% - 'accTarget' : Sets the prefered acceptance ratio when 'adaptive' is 
%                 set to 'target' or 'recTarget'. Default is 0.5. 
%
% - 'accScale'  : The value to re-scale the cholesky factorization of 
%                 the covariance matrix with when acceptance ratio is less
%                 or greater than the target ('accTarget'). I.e. 
%                 exp(accScale*a), where a is incremented by +/- 1 if
%                 acceptance ratio is higher/lower than the target.
%
% - 'adaptive'  : Either;
%                 > 'recursive' : Calculates the covariance matix based 
%                                 on the simulated observation from the 
%                                 target function. Uses the approach
%                                 suggested by Haario et al. (2001).
%                                 Use the 'weight' input to adjust the
%                                 weight on the initial covariance matrix.
%                 > 'recTarget' : Combining the approaches in 'recursive'
%                                 and 'target'.
%                 > 'target'    : Scales the initial covariance matrix with
%                                 a constant (that changes) to get the 
%                                 wanted acceptance rate. See 'accTarget'
%
%                 'recursive' is default.
%
%                 Caution: Only applies for when the 'qFunction' input  
%                           is set to 'arw'. For more see the 
%                           nb_mcmc.adaptiveRandomWalk and 
%                           nb_mcmc.adaptiveRandomWalkUpdate function.
%
% - 'burn'      : The number of burned simulation in the start of the M-H
%                 algorithm. Default is 4000.
%
% - 'chains'    : The number of M-H chains to run. Default is 1. If 
%                 'parallel' is set to true, this also will be the number 
%                 of parallel workers.
%
% - 'covrepair' : Give true to secure that the provided covariance matrix
%                 is positive semi-definite. If false (default), then an
%                 error will be thrown if the covariance matrix is not
%                 positive definite.
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
% - 'minIter'   : A user defined treshold value that can be used by the
%                 function given by the 'qFunction' input. 
%
%                 If 'qFunction' is set to 
%                 > 'arw' : An 'adaptive' is set to 'recursive' this
%                           options sets how many past burning simulation
%                           that must be done before the calculation of
%                           the covariance matrix used by the 'phi' input
%                           does not use the burn in simulations.
%
%                 Default is 20.
%
% - 'parallel'  : Set to true to run M-H in parallel using parfor.
%
% - 'phi'       : A function handle that simulates eps from the wanted
%                 distribution, i.e. the distribution to draw from when 
%                 simulating the jump in the random variables at a 
%                 iteration of the Metropolis - Hastings algorithm. 
%                 Default is @(x)nb_mcmc.mvnRandChol(x).
%
%                 Caution : The x input is the same struct that is given 
%                           by the output.
%
% - 'qFuncPDF'  : The PDF of the suggested conditional distribution that 
%                 is assign to the 'qFunction' input. Only needed if 
%                 'qFunction' is not symmetric. If provided it must be  
%                 a function handle that takes the output struct as its 
%                 only input.
%
%                 This function must provide 2 outputs. The first is the
%                 value of qFunction(betaDraw,betaLast), and the second is 
%                 the value of qFunction(betaLast,betaDraw).
%                 
% - 'qFunction' : A string or a function handle with how to draw the  
%                 candidate distribution conditional on past draw. Either:
%                 > 'rw'   : Random-walk. beta(i+1) = beta(i) + eps, where
%                            eps ~ phi(0,sigma).
%                 > 'arw'  : Adaptive random-walk. beta(i+1) = beta(i) + 
%                            eps, where eps ~ phi(0,sigma(i)). In this case  
%                            sigma(i) is an estimate of the covariance
%                            matrix of the sampled values of beta. 
%                 > handle : A function handle taking 1 input. The input is 
%                            on the same format as the output of this
%                            function.
%                 
%                 Default is to use 'rw'.
%
%                 This function must return 2 outputs; the candidate draw
%                 of the random variables with same size as the beta input,
%                 and it must return the input given to this function, as
%                 you may have alter it when constructing the candidate
%                 draw. For examples see; nb_mcmc.randomWalk or 
%                 nb_mcmc.adaptiveRandomWalk.
%
% - 'storeAt'   : The number of simulations before the draws are stored 
%                 to a file during the M-H algorithm. Default is 1000000.
%
%                 Caution: In this case the names of the files that the 
%                          draws are in can be found in the field files,
%                          while the beta output will be empty.
%
% - 'storeFile' : Prefix of the names of the .mat files stored with the
%                 posterior draws. Include path if wanted. Caution:
%                 should not end with \. Defualt is 'mh_sampler'.
%
% - 'thin'      : The number of simulations before a draw is kept during
%                 the M-H algorithm. Default is 10.
%
% - 'ub'        : Upper bound on the variables. As a 1 x numVar double.
%                 Default is [], i.e. no lower bound on any variable.
%
% - 'waitbar'   : Give true to include waitbar.
%
% - 'weight'    : The weight put on the initial covariance matrix when
%                 'qFunction' is set to 'arw' and 'adaptive' is set to
%                 'recursive'. Default is 0.05 (the smalles possible 
%                 value).
%
% Output:
% 
% - output : A 1 x number of chains struct array with the following fields
%            > beta  : A draws x numVar double. Empty if 'storeAt' is so
%                      small that the sampler start storing to files.
%            > files : The names of the files for where the draws are saved
%                      in the case tha the 'storeAt' limit is reached.
%
% See also:
% nb_mcmc.randomWalk, nb_mcmc.adaptiveRandomWalk,
% nb_mcmc.adaptiveRandomWalkUpdate, nb_mcmc.geweke, nb_mcmc.gelmanRubin,
% nb_mcmc.nutSampler, nb_waitbar
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
    if isstruct(varargin{1})
        varargin{1} = nb_rmfield(varargin{1},'sampler');
    end
    
    default = {'accScale',         0.1,                 {@nb_isScalarNumber,'&&',{@gt,0},'&&',{@lt,1}};...
               'accTarget',        0.5,                 {@nb_isScalarNumber,'&&',{@gt,0},'&&',{@lt,1}};...
               'adaptive',         'recursive',         {{@nb_ismemberi,{'recursive','recTarget','target'}}};...
               'burn',             4000,                {@nb_isScalarInteger,'&&',{@ge,0}};...
               'chains',           1,                   {@nb_isScalarInteger,'&&',{@gt,0}};...
               'covrepair',        'cov',               {{@nb_ismemberi,{'cov','covrepair'}}};...
               'draws',            10000,               {@nb_isScalarInteger,'&&',{@gt,0}};...
               'lb',               [],                  @isnumeric;...
               'log',              false,               @nb_isScalarLogical;...
               'minIter',          [],                  {@nb_isScalarInteger,'&&',{@gt,0}};...
               'parallel',         false,               @nb_isScalarLogical;...
               'phi',              [],                  {@ischar,'||',{@isa,'function_handle'},'||',@isempty};...
               'qFuncPDF',         [],                  {{@isa,'function_handle'},'||',@isempty};...
               'qFunction',        'rw',                {@ischar,'||',{@isa,'function_handle'}};...
               'storeAt',          1000000,             {@nb_isScalarInteger,'&&',{@gt,999}};...
               'storeFile',        [pwd '\mhSampler'],  @ischar;...
               'thin',             10,                  {@nb_isScalarInteger,'&&',{@gt,0}};...
               'ub',               [],                  @isnumeric;...
               'waitbar',          [],                  @nb_isScalarLogical;...
               'weight',           0.05,                {@nb_isScalarNumber,'&&',{@ge,0.05},'&&',{@lt,1}}};
           
    [output,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if output.covrepair
        output.covrepair = 'covrepair';
    else
        output.covrepair = 'cov';
    end
    
    % Pre-allocation and assignment of starting values
    try
        fValLast = objective(beta);
    catch Err
        nb_error(['The function_handle given by the objective input gave an error for the '...
                 'initial values provided by beta. Remember that this input is called in the ',...
                 'following way; fVal = objective(beta)'],Err);
    end
    
    numberOfRows            = min(output.draws,output.storeAt);
    output.numVar           = size(beta,2);
    output.objective        = objective;
    output.beta             = nan(numberOfRows,output.numVar);
    output.betaBurn         = nan(output.burn,output.numVar);
    output.betaLast         = beta;
    output.sigma            = sigma;
    output.sigmaLast        = sigma;
    output.sigmaChol        = nb_chol(sigma,output.covrepair);
    output.sigmaCholLast    = output.sigmaChol;
    output.fVal             = nan(numberOfRows,1);
    output.fValLast         = fValLast;
    output.acceptRatio      = nan(numberOfRows,1);
    output.acceptRatioBurn  = nan(output.burn,1);
    output.index            = 1;
    output.numberOfAccepted = 0;
    output.acceptedOneIter  = 0;
    output.triesOneIter     = 0;
    output.a                = 1/output.accScale;
    
    if isempty(output.minIter)
        output.minIter = min(output.numVar*2,5);
    end
    
    if output.log 
        output.randFunc = @(x)log(rand(x));
    else
        output.randFunc = @(x)rand(x);
    end
    
    if ~isempty(output.lb)
        output.lb = output.lb(:)';
        if ~all(size(output.lb) == [1,output.numVar])
            error([mfilename ':: The ''lb'' input must match the beta input.'])
        end
    end
    if ~isempty(output.ub)
        output.ub = output.ub(:)';
        if ~all(size(output.ub) == [1,output.numVar])
            error([mfilename ':: The ''ub'' input must match the beta input.'])
        end
    end
    
    % Get default distributions
    output = getDefaultDist(output);
    
    % Run sampling
    if output.parallel 
        output = doParallel(output);
    else
        output = doNormal(output);
    end
    
    % Finish up
    [output(:).index] = deal(output(1).index - 1);
    for ii = 1:output(1).chains
        output(ii).sigmaLast = output(ii).sigmaCholLast'*output(ii).sigmaCholLast;
    end
    output = rmfield(output,{'betaLast','fValLast','sigmaChol','sigmaCholLast','sigmaLast','acceptedOneIter',...
                             'triesOneIter','index','numberOfAccepted','randFunc','acceptFunction'});
                        
end

%==========================================================================
function output = doNormal(output)

    % Waitbar
    %------------------------------  
    draws = output.draws;
    if output.waitbar
        text   = {'Burning...';' ';'Acceptance ratio (chain 1): 0'};
        total  = (output.burn + draws*output.thin)*output.chains;
        h      = nb_waitbar([],'Metropolis-Hastings',total,false,true);
        h.text = text;
        note   = nb_when2Notify(total);
    end
    
    % Metropolis - Hastings steps
    %------------------------------
    output.files = {};
    output       = output(ones(1,output.chains));
    for ww = 1:output(1).chains
    
        % Burn and adaption
        for ii = 1:output(ww).burn
            output(ww).triesOneIter                      = output(ww).triesOneIter + 1;
            output(ww)                                   = doOneIteration(output(ww));
            output(ww).betaBurn(output(ww).index,:)      = output(ww).betaLast;
            output(ww).acceptRatioBurn(output(ww).index) = output(ww).numberOfAccepted/ii;
            output(ww).index                             = output(ww).index + 1;
            
            % Update waitbar
            if output(ww).waitbar
                if rem(ii,note) == 0
                    text{3}  = ['Acceptance ratio (chain ' int2str(ww) '): ' num2str(output(ww).acceptRatioBurn(output(ww).index-1))];
                    h.text   = text;
                    h.status = h.status + note;
                end
            end
            
        end
        
    end
    
    % Update text on waitbar
    if output(1).waitbar
        text   = {'Drawing...';' ';'Acceptance ratio (chain 1): 0'};
        h.text = text;
    end
    
    % Draw
    for ww = 1:output(1).chains

        % Start storing simulations
        output(ww).qFunction        = 'rw'; % The adaption takes only place during burn in!
        output(ww)                  = getDefaultDist(output(ww));
        output(ww).numberOfAccepted = 0;
        output(ww).index            = 1;
        ii                          = 1;
        fileNr                      = 1;
        madeDraws                   = 1;
        while madeDraws <= draws

            output(ww) = doOneIteration(output(ww));
            if rem(ii,output(ww).thin) == 0
                output(ww).beta(output(ww).index,:)      = output(ww).betaLast;
                output(ww).fVal(output(ww).index)        = output(ww).fValLast;
                output(ww).acceptRatio(output(ww).index) = output(ww).numberOfAccepted/ii;
                output(ww).index                         = output(ww).index + 1;
                madeDraws                                = madeDraws + 1;
            end
            ii = ii + 1;

            % Update waitbar
            if output(ww).waitbar
                if rem(ii,note) == 0
                    text{3}  = ['Acceptance ratio (chain ' int2str(ww) '): ' num2str(output(ww).acceptRatio(output(ww).index-1))];
                    h.text   = text;
                    h.status = h.status + note;
                end
            end
            
            if rem(output(ww).index - 1,output(ww).storeAt) == 0 && output(ww).index - 1 ~= 0
                [output(ww),fileNr] = storDrawsToFile(output(ww),ww,fileNr);
                output(ww).index    = 1;
            end
            
        end
        
        % Store the final draws as well
        if output(ww).index > 1 && madeDraws > output(ww).storeAt
            output(ww).beta = output(ww).beta(1:output(ww).index-1,:);
            output(ww)      = storDrawsToFile(output(ww),ww,fileNr);
        end
        if fileNr > 1 % Some of the draws where saved to file, so we don't return the beta output in this case.
            output(ww).beta = [];
            output(ww).fVal = [];
        end
            
    end
    
    if output(1).waitbar
        delete(h)
    end

end

%==========================================================================
function output = doParallel(output)

    % Open parallel pool
    %----------------------------------------
    if output.chains > nb_availablePoolSize()
        error([mfilename ':: The number of selected chains (' int2str(output.chains) ') cannot exeed ' int2str(nb_availablePoolSize()) '.'])
    end
    ret = nb_openPool(output.chains);

    % Waitbar
    %------------------------------
    draws = output.draws;
    if output.waitbar
        text   = {'Burning...';' ';'Acceptance ratio (chain 1): 0'};
        total  = (output.burn + draws*output.thin)*output.chains;
        h      = nb_waitbar([],'Parallel Metropolis-Hastings',total,false,true);
        h.text = text;
        note   = nb_when2Notify(total);
        D      = parallel.pool.DataQueue;
        afterEach(D,@(x)nUpdateWaitbar(x,h));
    else
        note   = [];
        D      = [];
    end

    % Metropolis - Hastings steps
    %------------------------------
    s      = struct('note',note,'acceptRatio',[],'chain',num2cell(1:output.chains));
    output = output(ones(1,output.chains));
    parfor ww = 1:output(1).chains
    
        % Burn and adaption
        for ii = 1:output(ww).burn
            output(ww).triesOneIter                      = output(ww).triesOneIter + 1;
            output(ww)                                   = doOneIteration(output(ww));
            output(ww).betaBurn(output(ww).index,:)      = output(ww).betaLast;
            output(ww).acceptRatioBurn(output(ww).index) = output(ww).numberOfAccepted/ii;
            output(ww).index                             = output(ww).index + 1;
            
            % Update waitbar
            if output(ww).waitbar
                if rem(ii,note) == 0
                    s(ww).acceptRatio = output(ww).acceptRatioBurn(output(ww).index-1);
                    send(D,s(ww));
                end
            end
            
        end
        
    end
    
    % Update text on waitbar
    if output(1).waitbar
        h.text = {'Drawing...';' ';'Acceptance ratio (chain 1): 0'};
    end
    
    % Draw
    parfor ww = 1:output(1).chains

        % Start storing simulations
        output(ww).qFunction        = 'rw'; % The adaption takes only place during burn in!
        output(ww)                  = getDefaultDist(output(ww));
        output(ww).numberOfAccepted = 0;
        output(ww).index            = 1;
        ii                          = 1;
        fileNr                      = 1;
        madeDraws                   = 1;
        while madeDraws <= draws

            output(ww) = doOneIteration(output(ww));
            if rem(ii,output(ww).thin) == 0
                output(ww).beta(output(ww).index,:)      = output(ww).betaLast;
                output(ww).fVal(output(ww).index)        = output(ww).fValLast;
                output(ww).acceptRatio(output(ww).index) = output(ww).numberOfAccepted/ii;
                output(ww).index                         = output(ww).index + 1;
                madeDraws                                = madeDraws + 1;
            end
            ii = ii + 1;

            % Update waitbar
            if output(ww).waitbar
                if rem(ii,note) == 0
                    s(ww).acceptRatio = output(ww).acceptRatio(output(ww).index-1); %#ok<PFOUS>
                    send(D,s(ww));
                end
            end
            
            if rem(output(ww).index - 1,output(ww).storeAt) == 0 && output(ww).index - 1 ~= 0
                [output(ww),fileNr] = storDrawsToFile(output(ww),ww,fileNr);
                output(ww).index    = 1;
            end
            
        end
        
        % Store the final draws as well
        if output(ww).index > 1 && madeDraws > output(ww).storeAt
            output(ww).beta = output(ww).beta(1:output(ww).index-1,:);
            output(ww)      = storDrawsToFile(output(ww),ww,fileNr);
        end
        if fileNr > 1 % Some of the draws where saved to file, so we don't return the beta output in this case.
            output(ww).beta = [];
            output(ww).fVal = [];
        end
        
    end

    if output(1).waitbar
        delete(h)
    end
    
    nb_closePool(ret);
    
end

%==========================================================================
function output = doOneIteration(output)

    % Candidate draw
    [betaDraw,output] = output.qFunction(output);

    % Acceptance probability
    [fVal,alpha] = output.acceptFunction(output,betaDraw);

    % Update
    if output.randFunc(1) <= alpha 
        output.numberOfAccepted = output.numberOfAccepted + 1;
        output.acceptedOneIter  = output.acceptedOneIter + 1;
        output.betaLast         = betaDraw;
        output.fValLast         = fVal;
    end
    
end

%==========================================================================
function output = getDefaultDist(output)

    if ischar(output.qFunction)
        
        switch lower(output.qFunction)
            
            case 'rw'
                
                output.qFunction = @(x)nb_mcmc.randomWalk(x);
                output.phi       = @(x)nb_mcmc.mvnRandChol(x);
                
            case 'arw'
                
                if strcmpi(output.adaptive,'recursive')
                    output.qFunction = @(x)nb_mcmc.adaptiveRandomWalk(x);
                elseif strcmpi(output.adaptive,'target')
                    output.qFunction = @(x)nb_mcmc.adaptiveRandomWalkTarget(x);
                elseif strcmpi(output.adaptive,'recTarget')
                    output.qFunction = @(x)nb_mcmc.adaptiveRandomWalkRecTarget(x);   
                else
                    error([mfilename ':: Unsupported option given to the ''adaptive'' input.'])
                end
                
            otherwise
                error([mfilename ':: Unsupported options ''' output.qFunction ''' given to the ''qFunction'' input.'])
        end
        output.phi = @(x)nb_mcmc.mvnRandChol(x);
        
    else
        if isempty(output.phi)
            output.phi = @(x)nb_mvnrand(1,1,0,x);
        end
    end
    
    if output.log
        if isempty(output.qFuncPDF)
            output.acceptFunction = @(x,beta)acceptFunctionSymmetricLog(x,beta);
        else
            output.acceptFunction = @(x,beta)acceptFunctionUnsymmetricLog(x,beta);
        end
    else
        if isempty(output.qFuncPDF)
            output.acceptFunction = @(x,beta)acceptFunctionSymmetric(x,beta);
        else
            output.acceptFunction = @(x,beta)acceptFunctionUnsymmetric(x,beta);
        end
    end

end

%==========================================================================
function [fVal,alpha] = acceptFunctionSymmetric(output,betaDraw)

    fVal  = output.objective(betaDraw);
    alpha = min(fVal/output.fValLast,1);

end

%==========================================================================
function [fVal,alpha] = acceptFunctionSymmetricLog(output,betaDraw)

    fVal  = output.objective(betaDraw);
    alpha = min(fVal - output.fValLast,0);

end

%==========================================================================
function [fVal,alpha] = acceptFunctionUnsymmetric(output,betaDraw)

    [phiVal1,phiVal2] = output.qFuncPDF(output);
    fVal              = output.objective(betaDraw);
    alpha             = min((fVal/output.fValLast)*(phiVal1/phiVal2),1);

end

%==========================================================================
function [fVal,alpha] = acceptFunctionUnsymmetricLog(output,betaDraw)

    [phiVal1,phiVal2] = output.qFuncPDF(output);
    phiVal1Log        = log(phiVal1);
    phiVal2Log        = log(phiVal2);
    fVal              = output.objective(betaDraw);
    alpha             = min(fVal - output.fValLast + phiVal1Log - phiVal2Log,0);

end

%==========================================================================
function nUpdateWaitbar(s,h)

    h.status = h.status + s.note;
    text     = h.text;
    text{3}  = ['Acceptance ratio (chain ' int2str(s.chain) '): ' num2str(s.acceptRatio)];
    h.text   = text;
    
end

%==========================================================================
function [output,fileNr] = storDrawsToFile(output,chain,fileNr)

    filename     = [output.storeFile,'_chain_' int2str(chain) ,'_' int2str(fileNr) '.mat'];
    beta         = output.beta; %#ok<NASGU>
    fVal         = output.fVal; %#ok<NASGU>
    save(filename, 'beta','fVal');
    output.files = [output.files,filename];
    fileNr       = fileNr + 1;
    
end
