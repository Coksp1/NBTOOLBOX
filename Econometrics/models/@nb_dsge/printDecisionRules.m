function str = printDecisionRules(obj,variables,precision,asCell)
% Syntax:
%
% str = printDecisionRules(obj)
% str = printDecisionRules(obj,variables)
% str = printDecisionRules(obj,variables,precision,asCell)
%
% Description:
%
% Print decision rules.
%
% If the model is solved by RISE this calls the dsge.print_solution
% method made by Junior Maih, which is part of the RISE toolbox.
% 
% Input:
% 
% - obj       : An object of class nb_dsge.
%
% - variables : A cellstr with the variables to print the solution for.
%
% - precision : The precision of the printed decision rules.
% 
% - asCell    : Give true to return decion rules table as cell. Not
%               supported if numel(obj) > 1 && (length(variables) > 1
%               || length(variables) == 0). Default is false.
%
% Output:
% 
% - str : A char with the printed decision rules of the model. If 
%         numel(obj) > 1 the output will be a 1 x nobj cell array.
%
%         If asCell is set to true it will be a cell array instead.
%
% See also:
% nb_dsge.solve, nb_dsge.findRESolution, dsge.print_solution
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        asCell = false;
        if nargin < 3
            precision = '';
            if nargin < 2
                variables = {};
            end
        end
    end

    if isempty(precision)
        precision = '%8.6f';
    else
        if ~ischar(precision)
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
        precision(isspace(precision)) = '';
        if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
           ~isstrprop(precision(end),'alpha')
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
    end
    
    if ischar(variables)
        variables = cellstr(variables);
    elseif ~iscellstr(variables)
        error([mfilename ':: The variables input must be a cellstr.'])
    end
    
    isBreakP = isBreakPoint(obj);
    if any(isBreakP)
        if numel(obj) > 1
            error([mfilename ':: If any of the given nb_dsge objects uses break-points, it cannot be a vector, sorry!'])
        end
        obj = split(obj);
    end

    nobj = numel(obj);
    if nobj > 1
        
        obj   = obj(:);
        names = getModelNames(obj);
        isSol = issolved(obj);
        if any(~isSol)
            error([mfilename ':: The following models are not solved: ' toString(names(~isSol))])
        end
        if all(isNB(obj)) && length(variables) == 1
            table = printManyDecisionRulesNB(obj,variables{1},precision);
            if ~asCell
                str = cell2charTable(table);
            else
                str = table;    
            end
        else
            str = '';
            for ii = 1:nobj
                str = char(str,names{ii});
                str = char(str,printDecisionRules(obj(ii),variables,precision));
                str = char(str,' ');
            end
            str = str(2:end,:);
        end
        return
        
    end
    
    if isRise(obj)
        printedCell = print_solution(obj.estOptions.riseObject,variables,[],[],precision);
        str         = char(printedCell);
    elseif isNB(obj)
        table = printDecisionRulesNB(obj,variables,precision);
    else
        error([mfilename ':: If the model is solved with dynare the decision rules cannot be re-printed.'])
    end
    
    if isNB(obj)
        if ~asCell
            str = cell2charTable(table);
        else
            str = table;
        end
    end

end

%==========================================================================
function table = printDecisionRulesNB(obj,variables,precision)

    if ~isfield(obj.solution,'A')
        error([mfilename ':: The model is not solved for the decision rules. See nb_dsge.solve.'])
    end
    if ~isempty(obj.parser.obs_equations)
        [~,loc]     = ismember(obj.parser.endogenous,obj.parser.all_endogenous);
        stateI      = obj.parser.obs_leadCurrentLag(:,3);
        stateI(loc) = stateI(loc) | obj.parser.isBackwardOrMixed;
    else
        stateI = obj.parser.isBackwardOrMixed;
    end
    gy     = obj.solution.A(:,stateI);
    gu     = obj.solution.C;
    order  = obj.solution.endo;
    exo    = obj.solution.res;
    state  = order(stateI);
    ss     = obj.solution.ss;
    if ~isempty(variables)
        [test,locV] = ismember(variables,order);
        if any(~test)
            error([mfilename ':: The following variables are not part of the model; ' toString(variable(~test))])
        end
        gy    = gy(locV,:);
        gu    = gu(locV,:);
        order = order(locV);
        ss    = ss(locV);
    end
    state = strcat(state,'(-1)');
    table = [{''},              order;...
             {'Steady-state'},  nb_double2cell(ss',precision);...
             state',            nb_double2cell(gy',precision);...
             exo',              nb_double2cell(gu',precision)];
    
    if ~isempty(obj.parser.obs_equations)
        if ~isempty(obj.solution.exo)
            table = [table;
                     {'Constant'},  nb_double2cell(obj.solution.B(locV)',precision)];
        end
    end
         
end

%==========================================================================
function table = printManyDecisionRulesNB(obj,variable,precision)

    if ~any(issolved(obj))
        obj   = obj(~issolved(obj));
        names = getModelNames(obj);
        error([mfilename ':: The models ' toString(names) ' are not solved for the decision rules. See nb_dsge.solve or nb_dsge.findRESolution.'])
    end
    names  = getModelNames(obj);
    nobj   = size(obj,1);
    state  = cell(1,nobj);
    exo    = state;
    indV   = state;
    stateI = state;
    for ii = 1:nobj
        order    = obj(ii).solution.endo;
        indV{ii} = strcmpi(variable,order);
        if all(~indV{ii})
            error([mfilename ':: The following variable is not part of the model ' names{1} '; ' variable])
        end
        if ~isempty(obj(ii).parser.obs_equations)
            [~,loc]         = ismember(obj(ii).parser.endogenous,obj(ii).parser.all_endogenous);
            stateI{ii}      = obj(ii).parser.obs_leadCurrentLag(:,3);
            stateI{ii}(loc) = stateI{ii}(loc) | obj(ii).parser.isBackwardOrMixed;
        else
            stateI{ii} = obj(ii).parser.isBackwardOrMixed;
        end
        state{ii}  = order(stateI{ii});
        exo{ii}    = obj(ii).solution.res;
    end
    
    uState = unique(nb_nestedCell2Cell(state));
    ind    = nb_contains(uState,'mult_');
    uState = [uState(~ind),uState(ind)]; % Order multipliers last
    uExo   = unique(nb_nestedCell2Cell(exo));
    gy     = zeros(length(uState),nobj);
    gu     = zeros(length(uExo),nobj);
    ss     = zeros(1,nobj);
    for ii = 1:nobj
        [~,locS]    = ismember(state{ii},uState);
        gy(locS,ii) = obj(ii).solution.A(indV{ii},stateI{ii})';
        [~,locE]    = ismember(exo{ii},uExo);
        gu(locE,ii) = obj(ii).solution.C(indV{ii},:);
        ss(ii)      = obj(ii).solution.ss(indV{ii});
    end
    
    uState = strcat(uState,'(-1)');
    table  = [{variable},        names';...
              {'Steady-state'},  nb_double2cell(ss,precision);...
              uState',           nb_double2cell(gy,precision);...
              uExo',             nb_double2cell(gu,precision)];

end
