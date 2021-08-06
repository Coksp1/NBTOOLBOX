function ssExo = getSteadyStateExo(parser,options)
% Syntax:
%
% ssExo = nb_dsge.getSteadyStateExo(parser,options)
%
% Description:
%
% Interpret the 'steady_state_exo' option.
% 
% See also:
% nb_dsge.solveSteadyStateStatic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ssExo = zeros(length(parser.exogenous),1);
    if isfield(options,'steady_state_exo')
        if ~isempty(options.steady_state_exo)
            ssExoStruct = options.steady_state_exo;
            if ~isstruct(ssExoStruct)
                error([mfilename ':: The ''steady_state_exo'' input must be a struct.'])
            end
            given      = fieldnames(ssExoStruct);
            [test,loc] = ismember(given,parser.exogenous);
            if any(~test)
                error([mfilename ':: The following variables given to the ''steady_state_exo'' option is not part of the model; ',...
                       toString(given(~test))])
            end
            values     = cell2mat(struct2cell(ssExoStruct));
            ssExo(loc) = values;
        end   
    end
    
end
