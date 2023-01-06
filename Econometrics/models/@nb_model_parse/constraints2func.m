function constrFunc = constraints2func(parser,pars)
% Syntax:
%
% constrFunc = nb_model_parse.constraints2func(parser)
% constrFunc = nb_model_parse.constraints2func(parser,pars)
%
% Description:
%
% Convert constraints to function handle.
% 
% See also:
% nb_nonLinearEq.parse, nb_dsge.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        pars = parser.parameters;
    end

    if ~isfield(parser,'constraints')
        constrFunc = [];
        return
    end

    if isempty(parser.constraints) 
        constrFunc = [];
        return
    end

    ind           = strfind(parser.constraints,'>=');
    indInequality = ~cellfun(@isempty,ind);
    if any(indInequality)
        error([mfilename ':: Cannot use inequality >=, rewrite constraint to read with <= instead!'])
    end

    % What type of constraint are we dealing with?
    ind           = strfind(parser.constraints,'<=');
    indInequality = ~cellfun(@isempty,ind);
    
    % Convert equality constraints to function handle
    constrEq      = parser.constraints(~indInequality);
    [pars,paramN] = nb_model_parse.getParamTranslation(parser.parameters);
    if isempty(constrEq)
        constrFuncEq = @(pars)returnEmpty(pars);
    else
        
        % Remove equality
        constrEq = nb_model_parse.removeEquality(constrEq);

        % Create a function handle of equality constraints
        matches  = regexp(constrEq,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
        matchesU = unique(horzcat(matches{:}));
        test     = ismember(matchesU,parser.parameters);
        if any(~test)
            error(['The constrainst can only contain parameters. The following are not parameters: ' toString(matchesU(~test))])
        end
        nConstr       = size(constrEq,1);
        out           = cell(nConstr,1);
        for ii = 1:nConstr

            c        = constrEq{ii};
            matchesT = matches{ii};
            ind      = ismember(pars,matchesT);
            paramT   = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
            paramNT  = paramN(ind);
            for pp = 1:length(paramT) % They already are of inverse order
                c = regexprep(c,paramT{pp},paramNT{pp});
            end
            out{ii} = c;

        end
        out          = strcat(out,';');
        out          = [out{:}];  
        constrFuncEq = str2func(['@(pars)[', out(1:end-1) ,']']);
    
    end
    
    % Convert inequality constraints to function handle
    constrIneq = parser.constraints(indInequality);
    if isempty(constrIneq)
        constrFuncIneq = @(pars)returnEmpty(pars);
    else
    
        % Remove inequality
        constrIneq = nb_model_parse.removeInequality(constrIneq);

        % Create a function handle of equality constraints
        matches  = regexp(constrIneq,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
        matchesU = unique(horzcat(matches{:}));
        test     = ismember(matchesU,parser.parameters);
        if any(~test)
            error(['The constrainst can only contain parameters. The following are not parameters: ' toString(matchesU(~test))])
        end
        nConstr = size(constrIneq,1);
        out     = cell(nConstr,1);
        for ii = 1:nConstr

            c        = constrIneq{ii};
            matchesT = matches{ii};
            ind      = ismember(pars,matchesT);
            paramT   = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
            paramNT  = paramN(ind);
            for pp = 1:length(paramT) % They already are of inverse order
                c = regexprep(c,paramT{pp},paramNT{pp});
            end
            out{ii} = c;

        end
        out            = strcat(out,';');
        out            = [out{:}];  
        constrFuncIneq = str2func(['@(pars)[', out(1:end-1) ,']']);
    
    end
    
    % Assign the constraints
    constrFunc = @(pars,varargin)nb_model_parse.constraints(pars,constrFuncEq,constrFuncIneq,varargin{:});
    
end

%==========================================================================
function out = returnEmpty(~)
    out = [];
end
