function [obj,loss] = calculateLoss(obj,varargin)
% Syntax:
%
% [obj,loss] = calculateLoss(obj,varargin)
%
% Description:
%
% Calculate loss given a specified loss function.
% 
% Input:
% 
% - obj           : A N x M matrix of class nb_dsge.
% 
% Optional inputs:
%
% - 'simulations' : An nb_ts object with the simulate data from the model.
%                   If this option is not given, it will calculate the
%                   loss analytically.
%
% - The rest of the optional inputs will be passed on to the nb_dsge.set.
%
% Output:
% 
% - obj  : A N x M matrix of class nb_dsge. Where the results.loss is 
%          updated.
%
% - loss : A N x M double with the calculated loss.
%
% See also:
% nb_dsge.setLossFunction
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(obj.parser,'lossFunction')
        error([mfilename ':: The loss function must be specified. See the setLossFunction method.'])
    end

    % Parse optional inputs
    [simulations,varargin] = nb_parseOneOptional('simulations',[],varargin{:});
    obj                    = set(obj,varargin{:});

    % Calculate loss in loop if dealing with more objects
    if numel(obj) > 1
        obj     = nb_callMethod(obj,@calculateLoss,@nb_dsge,varargin{:});
        [s1,s2] = size(obj);
        loss    = nan(s1,s2);
        for ii = 1:s1
            for jj = 1:s2
                loss(ii,jj) = obj(ii,jj).results.loss;
            end
        end
        return
    end

    if ~isfield(obj.solution,'W')
        if obj.parser.optimal
            error([mfilename ':: You have set a loss function and that has triggered solving the model under optimal monetary policy. ',...
                             'Use the solve method first or set the third input to the setLossFunction to false.'])
        else
            obj.solution = nb_dsge.derivativeLossFunction(obj.parser,obj.solution,obj.results.beta);
        end
    end
    
    if isempty(simulations)
        
        % Calculate loss analytically
        [loss,failed] = nb_dsge.calculateLossCommitment(obj.options,obj.solution,obj.parser);
        if failed
            error([mfilename ':: Solving the lyaponov equation failed. Model is not stable.'])
        end
        obj.results.loss = loss;
        return
        
    end

    error([mfilename ':: Calculate loss based on simulations is not yet supported.'])

end
