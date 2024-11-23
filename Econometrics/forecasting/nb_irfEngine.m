function [irfData,paused] = nb_irfEngine(solution,options,results,inputs)
% Syntax:
%
% [irfData,paused] = nb_irfEngine(solution,options,inputs)
%
% Description:
%
% Calculate irfs (with error bands) with a model written on a companion 
% form.
%
% Caution : If recursive estimation is done, only the last estimated model
%           will be used.
%
% Input:
% 
% - solution  : A struct storing the companion form of the model. See the 
%               help on the property nb_model_generic.solution for more
%               on this input.
%
% - options   : Estimation options. Output from the estimator functions.
%               E.g. nb_olsEstimator.estimate.
%
% - results   : Estimation results. Output from the estimator functions.
%               E.g. nb_olsEstimator.estimate.
%
% - inputs    : A struct with different inputs. See nb_model_genric.irf.
%
% Output:
% 
% - irfData : If perc is empty; A periods + 1 x nVar x nShocks
%             otherwise; A periods + 1 x nVar x nShocks x nPerc + 1, where  
%             the mean will be at irfData(:,:,:,end)
%
% - paused  : true or false
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options = nb_defaultField(options,'class','');
    inputs  = nb_defaultField(inputs,'normalizeTo','draws');

    % Check inputs
    %--------------------------------------------------------------
    method = inputs.method;
    if strcmpi(options.estimType,'bayesian')
        if isempty(method)
            method = 'posterior';
        elseif ~(strcmpi(method,'posterior') || strcmpi(method,'identdraws'))
            error([mfilename ':: Density IRF method ''posterior'' is the only supported method for bayesian models.']) 
        end
    else
        if isempty(method)
            method = 'bootstrap';
        elseif strcmpi(method,'posterior')
            error([mfilename ':: Density IRF method ''posterior'' is only supported for bayesian methods.']) 
        end
    end  

    % Produce IRFs
    %----------------------------------------------------------------------
    paused = false;   
    if inputs.replic == 1 && isempty(inputs.foundReplic)% Not produce error bands
        
        irfData = nb_irfEngine.irfPoint(solution,options,inputs,results); 
        
    else % Produce error bands
        
        % Then we calculate the error bands and mean IRF
        if ~isempty(inputs.foundReplic)
        
            % Here we use already found solutions of the model given as 
            % set of parameter draws
            modelDraws = inputs.foundReplic;
            replic     = numel(modelDraws);
            nVars      = length(inputs.variables) + length(inputs.variablesLevel);
            nShocks    = length(inputs.shocks);
            irfDataD   = nan(inputs.periods+1,nVars,nShocks,replic);
            for ii = 1:replic
                irfDataD(:,:,:,ii) = nb_irfEngine.irfPoint(modelDraws(ii),options,inputs,results); 
            end
            inputs.replic = replic;
        
        else
            
            switch lower(method)
                case {'bootstrap','wildbootstrap','blockbootstrap','mblockbootstrap','rblockbootstrap','wildblockbootstrap','copulabootstrap'}
                    if isfield(solution,'G') % Factor model
                        % Factor models are much harder to bootstrap, as also
                        % the factors needs to be bootstrapped
                        [irfDataD,paused] = nb_irfEngine.irfFactorModelBootstrap(solution,options,results,method,inputs);
                    else
                        [irfDataD,paused] = nb_irfEngine.irfBootstrap(solution,options,results,inputs);
                    end
                case 'identdraws'
                    irfDataD = nb_irfEngine.irfIdentDraws(solution,options,results,inputs);
                case 'posterior'
                    [irfDataD,paused] = nb_irfEngine.irfPosterior(solution,options,results,inputs);
                otherwise
                    error([mfilename ':: Unsupported error band method; ' method '.'])
            end
            
        end
        
        % Get the actual lower and upper percentiles
        %...........................................
        perc  = nb_interpretPerc(inputs.perc,false);
        nPerc = size(perc,2);
        if isempty(perc) || inputs.replic == 1 || paused
            irfData                          = irfDataD;
            irfData(:,:,:,size(irfData,4)+1) = median(irfDataD,4);
        else
            
            % Get the percentiles and median
            %...............................
            nVars         = length(inputs.variables) + length(inputs.variablesLevel);
            nShocks       = length(inputs.shocks);
            irfData       = nan(inputs.periods+1,nVars,nShocks,nPerc+1);
            for ii = 1:nPerc
                irfData(:,:,:,ii) = prctile(irfDataD,perc(ii),4);
            end
            irfData(:,:,:,end) = median(irfDataD,4);
            
        end
        
    end
    
    % Normalize to mean
    irfData = nb_irfEngine.normalizeToMean(options,inputs,irfData);

end
