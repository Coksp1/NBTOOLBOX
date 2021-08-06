function [A,B,C,CE,ss,err] = addObsModelSolver(A,C,CE,parser,solution,options,expandedOnly)
% Syntax:
%
% [A,B,C,CE,err] = nb_dsge.addObsModelSolver(A,B,C,CE,parser,solution,...
%                       options,expandedOnly)
%
% Description:
%
% Expand core model with obs_model equations.
% 
% Input:
% 
% - A            : Transition matrix of core model, as a nEndo x nEndo.
%
% - C            : Shock impact matrix of core model as a nEndo x nExo.
%
% - CE           : Shock impact matrix of core model as a nEndo x nExo x 
%                  nHor, when solved with anticipated shocks, otherwise [].
%
% - parser       : See nb_dsge.solveNB
%
% - solution     : See nb_dsge.solveNB
%
% - options      : See nb_dsge.solveNB
% 
% - expandedOnly : true if only the expanded solution is to be solved for.
%
% Output:
% 
% - A        : Transition matrix, as a nEndoAll x nEndoAll.
%
% - B        : Constant term as a nEndoAll x 1.
%
% - C        : Shock impact matrix as a nEndoAll x nExoAll - 1.
%
% - CE       : Shock impact matrix as a nEndoAll x nExoAll - 1 x nHor,  
%              when solved with anticipated shocks, otherwise [].
%
% - ss       : Steady state, as a nEndo x 1 double.
%
% See also:
% nb_solveLinearRationalExpModel, nb_dsge.selectSolveAlgorithm
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    err  = ''; 
    if ~expandedOnly
        
        % Get the structural representation of obs_model
        jacobian         = full(solution.obsJacobian);
        lcl              = parser.obs_leadCurrentLag;
        nBackward        = sum(lcl(:,3));
        nEndo            = size(lcl,1);
        nEq              = size(jacobian,1);
        startExo         = nEndo + nBackward + 1;
        Alag             = zeros(nEq,nEndo);
        A0               = jacobian(:,1:nEndo);
        Alag(:,lcl(:,3)) = jacobian(:,nEndo+1:nEndo+nBackward);
        Cobs             = jacobian(:,startExo:end);
        
        % Expand and reorder the solution of core model
        nEqCore      = size(A,1);
        nExo         = size(Cobs,2);
        [~,loc]      = ismember(parser.endogenous,parser.all_endogenous);
        [~,locE]     = ismember(parser.exogenous,parser.all_exogenous);
        AAlag        = zeros(nEqCore,nEndo);
        CC           = zeros(nEqCore,nExo);
        AAlag(:,loc) = A;
        CC(:,locE)   = C;
        AA0          = zeros(nEqCore,nEndo);
        AA0(:,loc)   = eye(nEqCore);
        
        % Combine the equations of both models
        F0 = [AA0;A0];
        FB = [AAlag;-Alag];
        FU = [CC;-Cobs];
        
        % Solve the full model
        if rcond(F0) < eps^(0.5)
            ind  = any(F0,2);
            ind2 = any(F0,1);
            if any(~ind)
                eqs     = [parser.equations; parser.obs_equations];
                message = {'The following equations only contain lags of variables (Please lead the equations!):'};
                eqs     = eqs(~ind);
                message = [message,eqs];
                err     = [mfilename ':: ' nb_cellstr2String(message,nb_newLine)];
            elseif any(~ind2)
                message = {'The following variables do not affect the model:'};
                vars    = model.all_endogenous(~ind2);
                message = [message,vars];
                err     = [mfilename ':: ' nb_cellstr2String(message,nb_newLine)];
            else
                err = [mfilename ':: The model cannot be solved as some of the equations are linearly dependent.'];
            end
            
            if nargout < 4
                error(err)
            else
                [A,B,C,CE] = errorReturn();
                return    
            end
            
        end
        F0inv = F0\eye(size(F0));
        
        % Find the transition matrix
        A = F0inv*FB;
        
        % The innovation (exogenous variables)
        C  = F0inv*FU;
         
    end

    % Separate out the constant term
    [B,C,ss] = correctGivenObsModel(parser,C,solution.ss);
    
    % Do we want the expanded solution?
    if ~isempty(options.numAntSteps) && ~isempty(options.shockProperties)
        error([mfilename ':: Cannot solve models using the obs_model block with anticpated shocks.'])
    end
    
end

%==========================================================================
function [B,C,ssObs] = correctGivenObsModel(parser,C,ss)

    % Separate constant term as exogenous and not a innovation, so
    % to keep it in line with other model classes
    indC = strcmp(parser.all_exogenous,'Constant');
    B    = C(:,indC);
    C    = C(:,~indC);

    % Expand steady-state solution with zeros for the observation model
    nEndo      = size(parser.all_endogenous,2);
    ssObs      = zeros(nEndo,1);
    ind        = ismember(parser.all_endogenous,parser.endogenous);
    ssObs(ind) = ss;
    
end

%==========================================================================
function [A,B,C,CE] = errorReturn()

    A  = [];
    B  = [];
    C  = [];
    CE = [];
    
end
