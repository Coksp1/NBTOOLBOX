function [A,B,C,CE,parser,err] = expectedBreakPointSolver(parser,solution,options,expandedOnly)
% Syntax:
%
% [A,B,C,CE,parser,err] = 
%   nb_dsge.expectedBreakPointSolver(parser,solution,options,expandedOnly)
%
% Description:
%
% This static method of the nb_dsge class implements the algorithm 
% presented by; Kulish and Pagan (2017), "Estimation ans Solution of  
% Models with Expectations and Structural Changes". 
%
% Input:
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
% - A        : Transition matrix, as a 1 x nStates cell array. Each  
%              element is a nEndo x nEndo double matrix.
%
% - B        : Constant term in the solution, as a 1 x nStates cell array.  
%               Each element is a nEndo x 1 double vector.
%
% - C        : Shock impact matrix, as a 1 x nStates cell array. Each 
%              element is a nEndo + nMult x nExo.
%
% - CE       : Shock impact matrix, as a 1 x nStates cell array. Each 
%              element is a nEndo x nExo x nHor, when solved with 
%              anticipated shocks, otherwise [].
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if parser.nBreaks > 1
        error([mfilename ':: It is only possible to solve for a model with one expected break. ',...
                         int2str(parser.nBreaks) ' are added.'])
    end
    
    % Preallocate space for solution in each regime
    JAC   = cell(1,parser.nBreaks + 1);
    ss    = cell(1,parser.nBreaks + 1);
    A     = cell(1,parser.nBreaks + 1);
    B     = cell(1,parser.nBreaks + 1);
    C     = cell(1,parser.nBreaks + 1); 
    Alead = cell(1,parser.nBreaks + 1);
    A0    = cell(1,parser.nBreaks + 1);
    Alag  = cell(1,parser.nBreaks + 1);
    D     = cell(1,parser.nBreaks + 1);
    O     = cell(1,parser.nBreaks + 1);
    
    % Solve for the other regimes
    parser.hasExpectedBreakPoints = false;
    params                        = parser.parameters;
    options.parser                = parser;
    beta                          = parser.beta; % Temporarily stored here during solving
    for ii = 1:parser.nBreaks+1
        
        % Get the parameter values for this regime
        betaRegime = beta;
        if ii ~= 1
            ind             = ismember(params,parser.breakPoints(ii-1).parameters);
            betaRegime(ind) = parser.breakPoints(ii-1).values;
        end
        
        % Calculate steady-state, jacobain and find solution in each regime
        [A{ii},C{ii},~,ss{ii},JAC{ii},err] = nb_dsge.solveOneRegime(options,betaRegime);
        if ~isempty(err)
            return
        end
        
        % Get the structural representation of each regime
        [Alead{ii},A0{ii},Alag{ii},D{ii}] = nb_dsge.jacobian2StructuralMatricesNB(JAC{ii},parser);
        
        % Solve for the contant term
        O{ii} = solveForConstantTerm(Alead{ii},A0{ii},Alag{ii},ss{ii});
        
    end
    
    % Apply the Kulish and Pagan (2017) algorithm
    % ---------------------------------------------------------------------
    nEndo = size(A{1},1);
    I     = eye(nEndo);
    for ii = parser.nBreaks:-1:1
        
        % Solve backward for the transition and shock impact matrices in 
        % the transition periods to the new break point
        periods      = (parser.breakPoints(ii).date - parser.breakPoints(ii).expectedDate) + 1;
        ATrans       = cell(1,periods);
        ATrans{end}  = A{ii+1};
        CTrans       = cell(1,periods);
        CTrans{end}  = C{ii+1};
        OMEGA        = cell(1,periods);
        K            = cell(1,periods);
        LAMBDAEND    = Alead{ii+1}*A{ii+1} + A0{ii+1};
        LAMBDAENDINV = LAMBDAEND\I;
        OMEGA{end}   = -LAMBDAENDINV*Alead{ii+1};
        K{end}       = -LAMBDAENDINV*O{ii+1};
        BTrans       = cell(1,periods);
        BTrans{end}  = (I - OMEGA{end})\K{end};
        for tt = periods-1:-1:1
            LAMBDA     = Alead{ii}*ATrans{tt+1} + A0{ii};
            LAMBDAINV  = LAMBDA\I;
            ATrans{tt} = -LAMBDAINV*Alag{ii};
            CTrans{tt} = -LAMBDAINV*D{ii};
            OMEGA{tt}  = -LAMBDAINV*Alead{ii};
            K{tt}      = -LAMBDAINV*O{ii};
        end
        
        % Solve forward for the contant term in the solution in the 
        % transition
        for tt = 1:periods-1
            BTrans{periods-tt} = forwardRecursion(OMEGA,K,periods-tt,BTrans{end});
        end
        
    end
    
    % Wrap up
    parser = rmfield(parser,'beta');
    
end

%==========================================================================
function O = solveForConstantTerm(Alead,A0,Alag,ss)
    O = -(Alead + A0 + Alag)*ss;
end

%==========================================================================
function B = forwardRecursion(OMEGA,K,tt,BStar)

    B       = K{tt};
    periods = size(OMEGA,2);
    if tt + 1 == periods
        F = eye(size(OMEGA{end},1));
    else
        for ss = tt+1:periods-1
            F = OMEGA{tt};
            for dd = tt+1:ss-1
                F = F*OMEGA{dd};
            end
            B = B + F*K{ss};
        end
    end
    
    % From here on we end up in the absorbing regime
    B = B + F*OMEGA{periods-1}*BStar;

end
