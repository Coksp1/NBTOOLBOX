function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_tvpmfsvEstimator.estimate(options)
%
% Description:
%
% Estimate a dynamic factor model with the algorithm of Schröder and 
% Eraslan (2021), "Nowcasting GDP with a large factor model space".
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_tvpmfsvEstimator.template. See also 
%              nb_tvpmfsvEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : Some options may be updated.
%
% See also:
% nb_tvpmfsvEstimator.print, nb_tvpmfsvEstimator.help, 
% nb_tvpmfsvEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen and Maximilian Schröder

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % set the lower bounds for the forgetting factors. This section is
    % eventually to be moved to the prior template later
    options.prior.l_1_lower_bound = 0.8;
    options.prior.l_2_lower_bound = 0.8;
    options.prior.l_3_lower_bound = 0.8;
    options.prior.l_4_lower_bound = 0.8;
   
    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    
    options = nb_defaultField(options,'class','');
    options = nb_defaultField(options,'blocks',[]);
    options = nb_defaultField(options,'smoothShocks',true);
    options = nb_defaultField(options,'smoothParam',false);
    options = nb_defaultField(options,'removeZeroRegressors',false);
    options = nb_defaultField(options,'set2nan',struct());
    options = nb_defaultField(options,'mixing',{});
    options = nb_defaultField(options,'indObservedOnly',false(1,0));
    
    % Get the estimation options
    %------------------------------------------------------
    if isempty(options.data)
        error([mfilename ':: Cannot estimate without data.'])
    end
    if strcmpi(options.class,'nb_mfvar')  
        options.observables   = options.dependent;
        options.missingMethod = 'kalman';
        if ~isempty(options.block_exogenous)
            error(['The estimator tvpmfsv does not support block ',...
                   'exogenous variables. Set the block_exogenous options ',...
                   'to empty.'])
        end
    elseif strcmpi(options.class,'nb_var')
        options.observables   = options.dependent;
        [~,freq]              = nb_date.date2freq(options.dataStartDate);
        options.frequency     = num2cell(freq(1,ones(1,length(options.dependent))));
        map                   = {'end'}; % This should not matter, just to prevent error in getFrequency
        options.mapping       = map(1,ones(1,length(options.dependent)));
        options.missingMethod = 'kalman'; % Notify forecast routine that we may deal with missing observations!
        if ~isempty(options.block_exogenous)
            error(['The estimator tvpmfsv does not support block ',...
                   'exogenous variables. Set the block_exogenous options ',...
                   'to empty.'])
        end
    else
        options.missingMethod = 'kalman';
        options.observables   = cellstr(options.observables);
        if isempty(options.observables)
            error([mfilename ':: The observables must be given!.'])
        end
        if ~isempty(options.blocks)
            error(['The estimator tvpmfsv does not blocking of the measurement ',...
                   'equation. Set the blocks options to empty.'])
        end
    end
    options.exogenous = cellstr(options.exogenous);

    % Get the estimation data
    %------------------------------------------------------
    % Shorten sample (Missing observation is no issue here!)
    if isempty(options.estim_start_ind)
        options.estim_start_ind = 1;
    end
    if isempty(options.estim_end_ind)
        options.estim_end_ind = size(options.data,1);
    end
    options = nb_dfmemlEstimator.removeLeadingAndTrailingNaN(options);
    
    % Get frequency and sort variables accordingly
    options = getFrequency(options);
    
    % Do the estimation
    if options.recursive_estim
        [results,options] = nb_tvpmfsvEstimator.recursiveEstimation(options);
    else % Not recursive
        [results,options] = nb_tvpmfsvEstimator.normalEstimation(options);
    end

    % Assign generic results
    results.includedObservations = options.estim_end_ind - options.estim_start_ind + 1;
    results.elapsedTime          = toc(tStart);
    
    % Reorder the observables back to original
    options = reorderObservables(options);
    
    % Assign results
    options.estimator = 'nb_tvpmfsvEstimator';
    options.estimType = 'bayesian';

end

%==========================================================================
function options = getFrequency(options)

    % Store original ordering
    options.observablesOrig = options.observables; 
    
    % Get the frquency of each variable
    N        = size(options.observables,2);
    [~,freq] = nb_date.date2freq(options.dataStartDate);
    freq     = freq(1,ones(1,N));
    for ii = 1:N
        if ~isempty(options.frequency{ii})
           freq(ii) = options.frequency{ii};
        end
    end
    
    % Reorder so that the lower frequency variables comes last
    [freq,i]            = sort(freq,'descend');
    options.observables = options.observables(i); 
    options.frequency   = options.frequency(i);
    options.mapping     = options.mapping(i);
    
    % Reorder mixing information 
    if any(options.indObservedOnly) && ~isempty(options.mixing)
       options.indObservedOnly = options.indObservedOnly(i); 
       options.mixing          = options.mixing(i);
       options.mixingSettings  = getMixingSettings(options);
    end
    
    % How many series of each frequency do we have?
    options.n = length(freq);
    if ~any(ismember(freq,[4,12]))
        error([mfilename ':: Mixed frequency dynamic factor model is only supported for monhtly and quarterly frequencies.'])
    end
    options.nMonth   = sum(freq == 12);
    options.nQuarter = sum(freq == 4);
    if options.nMonth == 0 || options.nQuarter == 0
        options.mixedFrequency = false;
    else
        options.mixedFrequency = true;
    end
    
    if options.mixedFrequency
        if options.nLags < 5
            error('The aggregation scheme require that the number of lags must be equal or greater than 5')
        end
    end
    
    % Reorder index
    [~,options.reorderLoc] = ismember(options.observablesOrig,options.observables);
    
end

%==========================================================================
function options = reorderObservables(options)

    options.observables = options.observablesOrig;
    options             = rmfield(options,'observablesOrig');
    
end

function mixing = getMixingSettings(options)

    mixing.indObservedOnly = options.indObservedOnly;
    vars                   = [options.observables,options.exogenous];
    varsMixing             = vars(~mixing.indObservedOnly);
    [~,mixing.loc]         = ismember(options.mixing(options.indObservedOnly),vars);
    [~,mixing.locLow]      = ismember(vars(options.indObservedOnly),vars);
    [~,mixing.locIn]       = ismember(options.mixing(options.indObservedOnly),varsMixing);
    mixing.frequency       = [options.frequency{options.indObservedOnly}];
        
end
