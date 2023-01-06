function obj = stationarize(obj,varargin)
% Syntax:
%
% obj = stationarize(obj,varargin)
%
% Description:
%
% Stationarize model.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
% 
% Optional input:
%
% - 'waitbar' : Give this to trigger waitbar during stationarization.
%
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@stationarize,@nb_dsge,varargin{:});
        return
    end
    
    if obj.isStationarized
       return 
    end
    
    % Add waitbar
    simplify = nb_parseOneOptionalSingle('simplify',false,true,varargin{:});
    waitbar  = nb_parseOneOptionalSingle('waitbar',false,true,varargin{:}) && simplify;
    if waitbar
        h                = nb_waitbar5([],['Stationarize ', obj.name]);
        h.maxIterations1 = 3;
        h.text1          = 'Stationarize the equations symbolically.';
    else
        h = [];
    end
    
    if ~obj.balancedGrowthSolved
        obj = solveBalancedGrowthPath(obj);
    end
    
    % Create function handle of non-stationary model, see
    % obj.parser.eqFunction
    obj = createEqFunction(obj);
    
    % Get ordering
    [order,type] = getDerivOrder(obj);
    endoLCL      = order(type~=2);
    endoLCL      = regexprep(endoLCL,'_lead$','');
    endoLCL      = regexprep(endoLCL,'_lag$','');
    exo          = order(type==2);
    param        = obj.parameters.name';
    leadOrLag    = type(type ~= 2);
     
    % Correct auxiliary lag variables, so they lagged one more period than
    % stored in the lead, current and lagged indicies
    indAux = not(cellfun(@(x)isempty(x),regexp(endoLCL,'^AUX_LAG')));
    if any(indAux)
        auxVars           = endoLCL(indAux);
        lags              = regexp(auxVars,'_(\d)$','tokens');
        lags              = [lags{:}];
        lags              = [lags{:}];
        lagsNum           = str2num(char(lags')); %#ok<ST2NM>
        leadOrLag(indAux) = leadOrLag(indAux) - lagsNum';
        auxVars           = cellfun(@(x,y)x(9:end-size(y,2)-1),auxVars,lags,'uniformOutput',false);
        endoLCL(indAux)   = auxVars;
    end
    
    % Get the growth rates
    lcl  = obj.parser.leadCurrentLag;
    if isfield(obj.parser,'isMultiplier')
        % Remove multipliers if model has been solve under optimal monetary
        % policy already.
        lcl  = lcl(~obj.parser.isMultiplier,:);
    end
    bgp = obj.solution.bgp;
    bgp = [bgp(lcl(:,1));bgp(lcl(:,2));bgp(lcl(:,3))];
     
    % Which are the unit root variables?
    indUnitRoot = ismember(endoLCL,obj.parser.unitRootVars);
    
    % Stationarize the model using the nb_st class
    endoG = nb_stTerm(endoLCL(~indUnitRoot),log(bgp(~indUnitRoot)),...
                      leadOrLag(~indUnitRoot));
    exoG  = nb_stTerm(exo,zeros(size(exo)));
    unitG = nb_stTerm(endoLCL(indUnitRoot),log(bgp(indUnitRoot)),...
                      leadOrLag(indUnitRoot),true);
                               
    numE               = size(endoLCL,2);              
    vars(numE,1)       = nb_stTerm();
    vars(indUnitRoot)  = unitG;
    vars(~indUnitRoot) = endoG;
    vars               = [vars;exoG];
    pars               = nb_stParam(param,obj.results.beta);
    
    % Translate into stationary equations
    stationaryObj = obj.parser.eqFunction(vars,pars);
    stationaryEqs = {stationaryObj.string}';
    err           = {stationaryObj.error}';
    indErr        = ~cellfun(@(x)isempty(x),err);
    if any(indErr)
        eqs    = obj.parser.equations;
        indErr = indErr(1:length(eqs));
        errEqs = eqs(indErr);
        errEqs = [errEqs';strcat({'Error:: '},err(indErr))';repmat({' '},[1,length(errEqs)])];
        errEqs = strcat(errEqs,{'\n '});
        errEqs = [errEqs{:}];
        error('nb_dsge:solvingSteadyStateFailed',['The following equations gave an error during detrending:\n\n',errEqs],'');
    end
    
    % Simplify the model equation
    if waitbar
        h.status1 = 1;
        h.text1   = 'Simplify the equations symbolically...';
    end
    if simplify
        obj.parser.stationaryEquations = nb_term.simplify(stationaryEqs,h);
    else
        obj.parser.stationaryEquations = stationaryEqs;
    end
    
    % Remove auxiliary variables and equations
    nNormalEqs                     = size(obj.parser.equations,1);
    obj.parser.stationaryEquations = obj.parser.stationaryEquations(1:nNormalEqs);
    obj.parser.endogenous          = obj.parser.endogenous(~obj.parser.isAuxiliary);
    
    % Remove the unit root variables
    indUnitRoot           = ismember(obj.parser.endogenous,obj.parser.unitRootVars);
    obj.parser.endogenous = obj.parser.endogenous(~indUnitRoot);
    
    % Append growth variables
    if waitbar
        h.status1 = 2;
        h.text1   = 'Store results to object.';
    end
    obj.parser.endogenous = [obj.parser.endogenous,obj.parser.growthVariables];
    
    % Update lead/lag incidence, and create the equationsParsed field that
    % stores all the equations of the model. Auxiliary variables and
    % equations are re-created here as well
    obj.parser = nb_dsge.getLeadLag(obj.parser);
    if ~isempty(obj.parser.obs_equations)
        obj.parser = nb_dsge.getLeadLagObsModel(obj.parser,true);
    else
        obj.parser.all_endogenous  = obj.parser.endogenous;
        obj.parser.all_exogenous   = obj.parser.exogenous;
        obj.parser.all_isAuxiliary = obj.parser.isAuxiliary;
    end
    
    % Update the dependent property
    varsWithTrend                = regexprep(obj.parser.growthVariables,['^', nb_dsge.growthPrefix],'');
    indUnitRoot                  = ismember(varsWithTrend,obj.parser.unitRootVars);
    indG                         = ismember(obj.parser.all_endogenous,obj.parser.growthVariables);
    [indKeep,locKeep]            = ismember(obj.dependent.name,obj.parser.all_endogenous);
    locKeep                      = locKeep(indKeep);
    texNamesUpdated              = obj.parser.all_endogenous;
    texNamesUpdated(locKeep)     = obj.dependent.tex_name(indKeep);
    indVarsWithTrend             = ismember(obj.parser.all_endogenous,varsWithTrend(~indUnitRoot));
    texNamesGrowth               = cell(size(varsWithTrend));
    texNamesGrowth(~indUnitRoot) = strcat({'\delta '},texNamesUpdated(indVarsWithTrend));
    texNamesGrowth(indUnitRoot)  = strcat({'\delta '},obj.unitRootVariables.tex_name);
    texNamesUpdated(indG)        = texNamesGrowth;
    obj.dependent.name           = obj.parser.all_endogenous;
    obj.dependent.tex_name       = texNamesUpdated;
    obj.dependent.number         = length(obj.parser.all_endogenous);
    obj.dependent.isAuxiliary    = obj.parser.all_isAuxiliary';
    obj.endogenous               = obj.dependent;
    
    % Indicate that the model is stationarized
    obj.isStationarized = true;
    
    % Indicate that the rest of the solving process must be done
    obj.needToBeSolved    = true;
    obj.steadyStateSolved = false;
    obj.takenDerivatives  = false;
    
    % Clean up waitbar
    if waitbar
        h.status1 = 3;
        delete(h);
    end
    
end
