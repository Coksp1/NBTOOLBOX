function [betaD,sigmaD,posterior] = sampler(posterior,draws)
% Syntax:
%
% [betaD,sigmaD,posterior] = ...
%           nb_statespaceEstimator.sampler(posterior,draws)
%
% Description:
%
% Sample from the posterior of a estimated state space model.
% 
% See also:
% nb_drawFromPosterior, nb_statespaceEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        draws = [];
    end

    if isempty(draws)
        draws = 1000;
    end
    
    % Sample 
    if ischar(posterior.options.sampler)
        samplerFunc = str2func(posterior.options.sampler);
    elseif isa(posterior.options.sampler,'function_handle')
        samplerFunc = posterior.options.sampler;
    else
        error([mfilename 'The ''sampler'' field of the ''sampler_options'' option must be ',...
                         'either a string with the name of the function or a function_handle.'])
    end
    opt   = posterior.options;
    omega = posterior.omega;
    cont  = false;
    if ~nb_isempty(posterior.output)
        % Continue from one of the converged smapling chains
        opt           = posterior.options;
        opt.chains    = 1;
        opt.draws     = draws;
        opt.qFunction = 'rw';
        opt.burn      = 0; 
        opt.storeAt   = inf; % Prevent storing to files!
        omega         = posterior.output(1).sigma;
        cont          = true;
    end
    output = samplerFunc(posterior.objective,posterior.betaD(:,:,end)',omega,opt); 
         
    if cont
        % In this case we keep all
        betaD = permute(output(1).beta,[2,3,1]); % nParam x 1 x draws
    else
        % Randomly select ammong the sampled draws from chain 1.
        randInd = ceil(opt.draws*rand(draws,1));
        if isempty(output(1).files)  
            betaD   = permute(output(1).beta(randInd,:),[2,3,1]); % nParam x 1 x draws
        else
            % Draws are stored to files, so we load them up in a loop to
            % pick some draws at random
            files  = output(1).files;
            ub     = unique([output(1).storeAt:output(1).storeAt:output(1).draws,output(1).draws]);
            lb     = [0, ub(1:end-1)];
            ub     = ub + 1;
            nParam = size(omega,1);
            betaD  = nan(nParam,1,draws);
            for ii = 1:length(files)
               loaded         = load(files{ii},'beta');
               ind            = randInd > lb(ii) & randInd < ub(ii);
               betaD(:,:,ind) = permute(loaded.beta(randInd(ind) - lb(ii),:),[2,3,1]);
            end
        end
    end
    sigmaD = nan(0,1,draws);               
                   
    % Return all needed information to do posterior draws
    %----------------------------------------------------
    if nargout > 2
        
        output = rmfield(output,{'betaBurn','acceptRatioBurn'});
        for ii = 1:length(output)
            output(ii).acceptRatio = output(ii).acceptRatio(end);
        end
        if nb_isempty(posterior.output)
            posterior.output = output;
        end
        posterior.betaD  = betaD;
        posterior.sigmaD = sigmaD;
        
    end
    
end
