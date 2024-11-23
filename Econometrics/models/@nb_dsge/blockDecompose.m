function obj = blockDecompose(obj,inEst,doPrologue)
% Syntax:
%
% obj = blockDecompose(obj,inEst)
% obj = blockDecompose(obj,inEst,doPrologue)
%
% Description:
%
% Block decompose model before solving. This will remove the epilogue
% from the model.
% 
% Caution: This method will be called inside nb_dsge.solve automatically,
%          if the 'blockDecompose' option is set to true. But you can
%          use this method to see how efficient the block decomposition
%          is for your model by calling it before solving.
%
% Caution: The jacobian is evaluated at the values provided by 
%          the steady-state.
%
% Input:
% 
% - obj        : A scalar object of class nb_dsge.
%
% - inEst      : Give true if it is called inside estimation, as in this 
%                case we need to calculate the steady-state and the 
%                derivatives.
%
% - doPrologue : Give true to also separate out prologue. Default is false.
%
% Output:
% 
% - obj      : A scalar object of class nb_dsge, where the parser property 
%              has been updated with the block decomposition of the model.
%
% See also:
% nb_dsge, nb_dsge.parse, nb_dsge.solve, nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        doPrologue = false;
    end
    
    silent = obj.options.silent;
    if ~silent
        t = tic;
        disp('Block decompose model:')
    end
    
    if inEst
        
        % Solve for the steady-state
        oldSilent          = obj.options.silent;
        obj.options.silent = true;
        if ~obj.steadyStateSolved
            obj = checkSteadyState(obj);
        end

        % Compute derivatives of the dynamic model, if not already calculated
        if ~obj.takenDerivatives 
            obj = derivative(obj);       
        end
        obj.options.silent = oldSilent;
        
    end
    
    % Get the jacobian
    obj.parser = nb_rmfield(obj.parser,'block');
    if isfield(obj.parser,'isMultiplier')
        % Remove multipliers when already solved under optimal monetary
        % policy
        obj.parser.leadCurrentLag = obj.parser.leadCurrentLag(~obj.parser.isMultiplier,:);
    end
    JAC             = obj.solution.jacobian;
    [Alead,A0,Alag] = nb_dsge.jacobian2StructuralMatricesNB(JAC,obj.parser);
    Alead           = sparse(Alead);
    Alag            = sparse(Alag);
    [Alead,A0,Alag] = roundToZero(obj.options.blockTol,Alead,A0,Alag);
    
    % Separate out epilogue
    if doPrologue
        [prologue,pVarsInd] = separatePrologue(obj,Alead,A0,Alag);
    else
        prologue = [];
        pVarsInd = [];
    end

    % Separate out epilogue
    [epilogue,eVarsInd,obj] = separateEpilogue(obj,inEst,Alead,A0,Alag);
    
    % Store some information on epilogue for later
    if ~inEst
        % We don't add the block field during estimation, so it does 
        % not remove the observables from the structural equations in 
        % nb_dsge.jacobian2StructuralMatricesNB later on.
        block.epiEndo    = eVarsInd;
        block.epiEqs     = epilogue;
        block.proEndo    = pVarsInd;
        block.proEqs     = prologue;
        obj.parser.block = block;
    end
        
    % Report
    if ~silent
        elapsedTime = toc(t);
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
end

%==========================================================================
function [prologue,pVarsInd] = separatePrologue(obj,Alead,A0,Alag)

    % Identify intial guess of prologue
    prologue = sum(abs(Alead)>0,2) == 0 & sum(abs(A0)>0,2) == 1;
    prologue = full(prologue);
    proLoc   = find(prologue);
    for ii = 1:length(proLoc)
        if ~all(Alag(proLoc(ii),:))
            if any(find(A0(proLoc(ii),:)) ~= find(Alag(proLoc(ii),:)))
                prologue(proLoc(ii)) = false;
            end
        end
    end
    
    % Remove based one symbolic stuff
    proLoc  = find(prologue);
    if any(obj.parser.isAuxiliary)
        eqs = obj.parser.equationsParsed(prologue);
    else
        eqs = obj.parser.equations(prologue);
    end
    endo    = obj.parser.endogenous;
    eqs     = regexprep(eqs,'(?<=[^+-\*\^])\({1}[+]{1}\d{1,2}\){1}','');
    eqs     = regexprep(eqs,'(?<=[^+-\*\^])\({1}[-]{1}\d{1,2}\){1}','');
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    for ii = 1:length(eqs)
        if sum(ismember(unique(matches{ii}),endo)) > 1
            prologue(proLoc(ii)) = false;
        end
    end
    proLoc  = find(prologue);
    
    % Get the variables of the prologue
    pVarsInd = false(size(A0,2),1);
    for ii = 1:length(proLoc)
        ind           = A0(proLoc(ii),:) > 0;
        pVarsInd(ind) = true;
    end
    

end

%==========================================================================
function [epilogue,eVarsInd,obj] = separateEpilogue(obj,inEst,Alead,A0,Alag)

    % Identify epilogue
    varsOnlyOneEqAndStatic = find(sum(abs(Alead)>0,1) == 0 & sum(abs(A0)>0,1) == 1 & sum(abs(Alag)>0,1) == 0 );
    if obj.parser.optimal
        % Cannot remove the variables in the loss function!
        varsOnlyOneEqAndStatic = setdiff(varsOnlyOneEqAndStatic,obj.parser.lossVariablesIndex);
    end
    
    % Don't remove auxiliary variables
    varsOnlyOneEqAndStatic = setdiff(varsOnlyOneEqAndStatic,find(obj.parser.isAuxiliary));
    
    % Get the epilogue
    epilogue = false(size(A0,1),1);
    eVarsInd = false(size(A0,2),1);
    ind      = zeros(length(varsOnlyOneEqAndStatic),1);
    for ii = 1:length(varsOnlyOneEqAndStatic)
        ind(ii)           = find(A0(:,varsOnlyOneEqAndStatic(ii)) > 0);
        epilogue(ind(ii)) = true;
    end                    
    eVarsInd(varsOnlyOneEqAndStatic) = true;

    % During estimation we don't need the epilogue, except the equations
    % that defines the observables
    if inEst
       
        % Remove the variables in the epilogue that are not in the
        % observables
        eVarsInd              = eVarsInd(~obj.parser.isAuxiliary);
        endo                  = obj.parser.endogenous(~obj.parser.isAuxiliary);
        isObs                 = ismember(endo,obj.observables.name)';
        indKeep               = ~eVarsInd | isObs;
        obj.parser.endogenous = endo(indKeep);
        eVarsInd(~indKeep)    = [];
        
        % Remove the equations, except the observation equations
        % (The observation equations that are in the epilogue are
        % the only equations that stays in the epilogue)
        indV                             = ismember(varsOnlyOneEqAndStatic,find(isObs));
        removeEqsI                       = ind(~indV);
        epilogue(removeEqsI)             = [];
        obj.parser.equations(removeEqsI) = [];
        nAuxiliary                       = sum(obj.parser.isAuxiliary) - 1;
        epilogue(end-nAuxiliary:end)     = [];
        
        % Update the eqFunction (less derivatives to compute!)
        obj.parser = nb_dsge.getLeadLag(obj.parser);
        obj        = createEqFunction(obj);
        nAuxiliary = sum(obj.parser.isAuxiliary);
        epilogue   = [epilogue;false(nAuxiliary,1)];
        eVarsInd   = [eVarsInd;false(nAuxiliary,1)];
        
        % Fix an issue with variables in equations they don't affect
        % when linearized
        ss          = zeros(length(obj.parser.endogenous),1);
        [~,~,ssAll] = nb_dsge.getOrderingNB(obj.parser,ss);
        cont        = true;
        while cont
            try
                obj.parser.eqFunction(ssAll,obj.results.beta);
                cont = false;
            catch Err
                var = regexp(Err.message,'\''.+\''','match');
                eqF = func2str(obj.parser.eqFunction);
                var = strcat('(?<![A-Za-z_])',strrep(var{1},'''',''),'(_lead)*(_lag)*(?![A-Za-z_0-9])');
                eqF = regexprep(eqF,var,'1');
                obj.parser.eqFunction = str2func(eqF);
            end
        end
        
        % Update loss variables index
        if obj.parser.optimal
            [~,obj.parser.lossVariablesIndex] = ismember(obj.parser.lossVariableNames,obj.parser.endogenous);
        end
        
    end

end

function varargout = roundToZero(tol,varargin)

    varargout = varargin;
    for ii = 1:nargin-1
        indY = abs(varargin{ii}) < tol;
        varargout{ii}(indY) = 0;
        varargout{ii}(abs(varargout{ii})>0) = 1;
    end

end
