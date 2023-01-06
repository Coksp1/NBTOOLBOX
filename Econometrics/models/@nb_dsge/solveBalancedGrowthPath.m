function obj = solveBalancedGrowthPath(obj)
% Syntax:
%
% obj = solveBalancedGrowthPath(obj)
%
% Description:
%
% Solve for the balanced growth path of the model.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
% 
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_dsge.stationarize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if obj.balancedGrowthSolved
        return
    end
    
    if isempty(obj.parser.unitRootVars)
        error([mfilename ':: No unit root variables selected. Cannot solve for the balanced growth path.'])
    end
    
    % Remove growth variables from endogenous, if they have been added in
    % a previous call
    if isfield(obj.parser,'growthVariables')
        obj = revert2NonStationary(obj);
    else
        obj.parser.originalEndogenous = obj.parser.endogenous(~obj.parser.isAuxiliary);
    end
    
    % Initial check and create the eqFunction to evaluate derivatives
    % and steady-state
    obj = checkModelEqs(obj);
    
    % Create function handle of non-stationary model, see
    % obj.parser.eqFunction
    oldEqs = obj.parser.equationsParsed;
    if ~isempty(obj.parser.static)
        obj.parser.equationsParsed(obj.parser.staticLoc) = obj.parser.static; 
        obj.parser.equationsParsed(obj.parser.growthLoc) = obj.parser.growth;
    end
    obj = createEqFunction(obj);
    
    % Get ordering
    [order,type] = getDerivOrder(obj);
    endoLCL      = order(type~=2);
    endoLCL      = regexprep(endoLCL,'_lead$','');
    endoLCL      = regexprep(endoLCL,'_lag$','');
    exo          = order(type==2);
    param        = obj.parameters.name';
    
    % Convert to nb_bgrowth objects
    endoLCLG  = nb_bgrowth(endoLCL,false);
    exoG      = nb_bgrowth(exo,true);
    vars      = [endoLCLG;exoG];
    paramG    = nb_bgrowth(param,true);
    
    % Translate into growth equations
    eqGrowthObj = obj.parser.eqFunction(vars,paramG);
    eqGrowth    = {eqGrowthObj.equation}';

    % Make into a function handle
    [~,paramNS,pars]  = nb_createGenericNames(obj.parser.parameters,'pars');
    [~,varsNS,vars,~] = nb_createGenericNames(strcat(nb_dsge.growthPrefix,obj.parser.endogenous),'vars');
    eqGrowthTrans     = translateEq(eqGrowth,pars,paramNS,vars,varsNS,true(size(vars)));
    growthEq          = nb_cell2func(eqGrowthTrans,'(vars,pars)');
    
    % Take derivatives (These are linear equations so the values is not 
    % important)
    myDeriv   = myAD(ones(size(obj.parser.endogenous,2),1));
    derivator = growthEq(myDeriv,obj.results.beta);
    growthJAC = getderivs(derivator);
    if any(isnan(growthJAC(:)))
        if any(isnan(obj.results.beta(obj.parameters.isInUse)))
            extra = ' Have you assign the parameters any values?';
        else
            extra = '';
        end
        error([mfilename ':: The jacobian of the growth equations returned nan.' extra])
    end
    
    % Append the restrictions created by the unit root variables
    [nEq,nVar]         = size(growthJAC);
    nUnitRoot          = length(obj.parser.unitRootVars);
    nEndo              = nVar - nUnitRoot;
    indUR              = ismember(obj.parser.endogenous, obj.parser.unitRootVars);
    A                  = [growthJAC;zeros(nUnitRoot,nVar)];
    A(nEq+1:end,indUR) = diag(ones(nUnitRoot,1));
    
    % Check the rank condition for BGP
    rankA = rank(full(A));
    if rankA < nVar
        [~,varInd] = find(A);
        varIndLeft = setdiff(1:nVar,varInd);
        nAdded     = length(varIndLeft);
        if nAdded == nVar - rankA
            % Add seperate equations for these variables, i.e. set the
            % growth rate of these variable to zero as they are
            % unrestricted
            A                              = [A(1:nEq,:);zeros(length(varIndLeft),nVar);A(nEq+1:end,:)];
            A(nEq+1:nEq+nAdded,varIndLeft) = diag(ones(nAdded,1));
        else
            disp(eqGrowth)
            error([mfilename ':: No balanced growth path exist, as the rank of the model growth equations (',...
                   int2str(rank(full(A)) + nAdded) ') is less then the number of variables (' int2str(nVar) ') ',...
                   '(including unit root variables)'])
        end
    end
    
    % Solve for the BGP (in log diff)
    nEq            = size(A,1) - nUnitRoot;
    G              = zeros(nEq+nUnitRoot,1);
    detTrendGrowth = log(1.01); % Just set it to a value to be able to identify the basis
    G(nEq+1:end)   = detTrendGrowth;
    BGP            = A\G;
    r2zero         = abs(BGP) < obj.options.steady_state_tol;
    BGP(r2zero)    = 0;
    
    % Have we found a solution?
    if any(abs(BGP(nEndo+1:end) - G(nEq+1:end)) > obj.options.steady_state_tol)
        
        % Remove equations with no information
%         ind = sum(abs(A)>0,2) == 0;
%         A   = A(~ind);
        
        % Find the variables that are certain to not trend
%         ind = find(sum(abs(A)>0,2) == 1);
%         [~,varInd] = find(A(ind,:));
        disp(eqGrowth)
        error([mfilename ':: No balanced growth path exist. See the equations that must hold above.'])
    end
    
    % Assign temporary solution
    obj.solution.bgp = exp(BGP);
    
    % Indentify the basis for the growth equations
    indV          = r2zero(1:nEndo);
    ARed          = A(1:nEq,~indV);
    indZ          = any(abs(ARed) > obj.options.steady_state_tol,2);
    ARed          = ARed(indZ,:);
    eqGrowth      = eqGrowth(indZ);
    [~,ind]       = unique(ARed,'rows');
    indU          = false(size(ARed,1),1);
    indU(ind)     = true;
    ARed          = ARed(indU,:);
    eqGrowth      = eqGrowth(indU);
    if size(ARed,1) < size(ARed,2)
        rest = strcat('\n ',eqGrowth);
        rest = horzcat(rest{:});
        vars = obj.dependent.name(~indV);
        vars = strcat('\n ',vars);
        vars = horzcat(vars{:});
        error('solveBalancedGrowthPath:TooFewRestrictions',['Cannot find a basis for the growth equations as there ',...
            'are more trending variables (' int2str(size(ARed,2)) '): ', vars,... 
            '\n\nthan unique restrictions (',...
            int2str(size(ARed,1)) '): ' rest])
    end
    i = nb_findBasis(ARed);
    
    % Get a function handle representing the growth equations
    eqGrowth      = eqGrowth(i);
    eqGrowthTrans = translateEq(eqGrowth,pars,paramNS,vars,varsNS,true(size(vars)));
    growthEq      = nb_cell2func(eqGrowthTrans,'(vars,pars)');
    num           = size(obj.parser.endogenous,2);
    clearvars vars;
    
    % Get the symbolic representation of the growth equations
    vars(num,1)                = nb_base;
    vars(r2zero)               = nb_num(0);
    vars(~r2zero)              = nb_base(strcat('log(',nb_dsge.growthPrefix,obj.parser.endogenous(~r2zero)',')'));
    pars                       = nb_base(obj.parser.parameters');
    obj.parser.growthEquations = cellstr(growthEq(vars,pars));
    
    % Then we add the growth processes
    obj.parser.growthVariables = strcat(nb_dsge.growthPrefix,obj.parser.endogenous(~r2zero));
    
    % Do we have some auxiliary equations we want to get rid of?
    indRemove                  = nb_contains(obj.parser.growthVariables,'D_Z_AUX_');
    obj.parser.growthVariables = obj.parser.growthVariables(~indRemove);
    numRemoved                 = sum(indRemove);
    
    % The auxiliary variables are allways added last, so we just remove
    % those
    obj.parser.growthEquations = obj.parser.growthEquations(1:end - numRemoved);
    
    % Wrap up
    obj.parser.equationsParsed = oldEqs;
    obj.balancedGrowthSolved   = true;
    
end

%==========================================================================
function out = translateEq(eqs,pars,paramN,vars,varsN,r2zero)

    % Get variable and parameter matches per equation
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    
    % Translate the equations of one period
    out = cell(length(eqs),1);
    for ii = 1:length(eqs)
    
        eq       = eqs{ii};
        matchesT = matches{ii};
        ind      = ismember(pars,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',pars(ind),'(?![A-Za-z_0-9])');
        paramNT  = paramN(ind);
        for pp = 1:length(paramT) % They already are of inverse order
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        
        indV    = ismember(vars,matchesT);
        r2zeroT = r2zero(indV);
        varsT   = strcat('(?<![A-Za-z_])',vars(indV),'(?![A-Za-z_0-9])');
        varsNT  = varsN(indV);
        for vv = length(varsT):-1:1
            if r2zeroT(vv)
                eq = regexprep(eq,varsT{vv},varsNT{vv});
            else
                eq = regexprep(eq,varsT{vv},['(' varsNT{vv} '-1)']);
            end
        end
        out{ii} = eq;
        
    end
    
end
