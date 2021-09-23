function [out,parser] = interpretSteadyStateChange(parser,inputValue,inParsing)
% Syntax:
%
% [out,parser] = nb_dsge.interpretSteadyStateChange(parser,inputValue,...
%                       inParsing)
%
% Description:
%
% Interpret and check the steady_state_change option.
% 
% See also:
% nb_model_estimate.set, nb_dsge.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(inputValue)
        out = inputValue;
        return
    end

    if nargin < 3
        inParsing = false;
    end
    if inParsing
        str = 'block';
    else
        str = 'option';
    end

    if ~inParsing
    
        if nb_isempty(parser)
            error([mfilename ':: Cannot set the ''steady_state_change'' options before a model file is parsed.'])
        end

        if ~iscellstr(inputValue)
            error([mfilename ':: The ''steady_state_change'' options must be a N x 2 cellstr.'])
        end
        if size(inputValue,2) ~= 2
            error([mfilename ':: The ''steady_state_change'' options must be a N x 2 cellstr.'])
        end
        
    end
    
    out.parameters = inputValue(:,1);
    out.endogenous = inputValue(:,2);
    
    out.indParam = ismember(parser.parameters,out.parameters);
    test         = ismember(out.parameters,parser.parameters);
    if any(~test)
        error(['The ''steady_state_change'' ' str ' provided some parameter that are not part of the model; '...
               toString(out.parameters(~test)) '.'])
    end
    
    out.indEndo = ismember(parser.endogenous,out.endogenous);
    test        = ismember(out.endogenous,parser.endogenous);
    if any(~test)
        error(['The ''steady_state_change'' ' str ' provided some endogenous variables that are not part of the model; '...
               toString(out.endogenous(~test)) '.'])
    end
    parser.createStatic = true;
    
end
