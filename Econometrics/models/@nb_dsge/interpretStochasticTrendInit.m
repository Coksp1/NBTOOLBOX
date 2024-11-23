function stInit = interpretStochasticTrendInit(parser,stochasticTrendInit,beta)
% Syntax:
%
% stInit = nb_dsge.interpretStochasticTrendInit(parser,...
%                   stochasticTrendInit,beta)
%
% Description:
%
% Interpret the stochasticTrendInit options. 
% 
% Input:
%
% - parser              : A struct. See the property nb_dsge.parser.
%
% - stochasticTrendInit : Either a struct or function_handle. See the
%                         examples in the folder Examples\Econometrics\...
%                         DSGE\StochasticTrend for both options.
%
% - beta                : A nParam x 1 double with the parameter values.
%                         In the case that the stochasticTrendInit input
%                         is a function handle these are passed as a 
%                         struct, where the fieldnames are the parameter 
%                         names and the field are their values. 
% 
% - parameters          : A nParam x 1 cellstr with the parameter names.
%
% Output:
% 
% - stInit : A nEndo x 1 double with the inital condition. Useful for
%            models with level variables.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(stochasticTrendInit,'function_handle') || ischar(stochasticTrendInit)
        if ischar(stochasticTrendInit)
            stochasticTrendInit = str2func(stochasticTrendInit);
        end
        p    = cell2struct(num2cell(beta),parser.parameters);
        init = stochasticTrendInit(p);
        if ~isstruct(init)
            error([mfilename ':: The ''stochasticTrendInit'' option must ',...
                'return a struct if it is a function name or a function_handle.'])
        end
    elseif isstruct(stochasticTrendInit)
        init = stochasticTrendInit;
    else
        error([mfilename ':: The ''stochasticTrendInit'' option must either ',...
                         'be a struct, function name or a function_handle.'])
    end
    if isempty(parser.all_endogenous)
        nEndo = size(parser.endogenous,2);
    else
        nEndo = size(parser.all_endogenous,2);
    end
    stInit = zeros(nEndo,1);
    fields = fieldnames(init);
    if ~isempty(fields)
        test   = ismember(fields,parser.obs_endogenous);
        if any(~test)
            error([mfilename ':: Cannot add inital values for the following variables; ' toString(fields(~test))])
        end
        [~,loc]     = ismember(fields,parser.all_endogenous);
        stInit(loc) = cell2mat(struct2cell(init));
    end
    
end
