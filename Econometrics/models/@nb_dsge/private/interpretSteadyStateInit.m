function obj = interpretSteadyStateInit(obj)
% Syntax:
%
% obj = interpretSteadyStateInit(obj)
%
% Description:
%
% Translate the steady_state_init function before solving the stochastic 
% version of the model.
% 
% See also:
% nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isfield(obj.parser,'steadyStateInitUsed')

        if obj.parser.steadyStateInitUsed
            
            if ~isfield(obj.parser,'equationsParsed')
                % In this case we have already fixed this issue...
                return 
            end
            
            % In this case we recreate the eqFunction, as the stochastic
            % solver does not handle the steadt_state_init function.
            eqs          = obj.parser.equationsParsed;
            ssInitNames  = {};
            for ii = 1:size(eqs,1)
        
                % Subst steady_state_init(X) with X_SS_INIT
                m = regexp(eqs{ii},'steady_state_init\([^\)]+\)','match');
                if ~isempty(m)
                    s     = cellfun(@(x)x(19:end-1),m,'UniformOutput',false);
                    sFull = strcat(s,'_SS_INIT');
                    for jj = 1:length(m)
                        eqs{ii} = strrep(eqs{ii},m{jj},sFull{jj});
                    end
                    ssInitNames = [ssInitNames,s];  %#ok<AGROW>
                end

            end
            
            % Update the parameter vector with the inital steady-state
            % values
            ssInitNames  = unique(ssInitNames);
            ssInitValues = obj.options.steady_state_default(length(ssInitNames),1);
            for ii = 1:length(ssInitNames)
                if isfield(obj.options.steady_state_init,ssInitNames{ii})
                    ssInitValues(ii) = obj.options.steady_state_init.(ssInitNames{ii});
                end
            end
            obj.results.beta            = [obj.results.beta; ssInitValues];
            [obj.parser.parameters,ind] = sort([obj.parser.parameters, strcat(ssInitNames, nb_dsge.steadyStateInitPostfix)]);
            obj.results.beta            = flip(obj.results.beta(ind),1);
            obj.parser.parameters       = flip(obj.parser.parameters,2);
            
            % Update the eqFunction
            obj.parser.equationsParsed = eqs;
            obj.parser                 = nb_dsge.eqs2func(obj.parser);
            obj.parser                 = rmfield(obj.parser,'equationsParsed');
            
        end

    end
    
end
