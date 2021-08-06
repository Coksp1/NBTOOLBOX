function [A,B,C,CE,ss,parser,err] = selectSolveAlgorithm(parser,solution,options,expandedOnly)
% Syntax:
%
% [A,B,C,CE,ss,parser,err] = nb_dsge.selectSolveAlgorithm(parser,...
%                            solution,options,expandedOnly)
%
% Description:
%
% This method select the wanted algorithm to solve the model. This is a
% private static method of the nb_dsge class.
% 
% See also:
% nb_dsge.solveNB, nb_dsge.solveOneRegime
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    B = [];
    if parser.optimal % Find solution under optimal monetary policy 

        if parser.hasExpectedBreakPoints
            error([mfilename ':: Cannot solve optimal policy when dealing with expected break points.'])
        end
        
        if parser.isBackwardOnly
            error([mfilename ':: Cannot solve purly backward loooking models under optimal monetary policy.'])
        end
        
        if isempty(options.optimal_algorithm)
            if options.lc_commitment == 1
                algorithm = 'klein';
            else
                algorithm = 'dmn';
            end
        else
            algorithm = options.optimal_algorithm;
        end

        if strcmpi(algorithm,'klein')
            [A,C,CE,parser,err] = nb_dsge.optimalMonetaryPolicySolver(parser,solution,options,expandedOnly);
        elseif strcmpi(algorithm,'dmn')
            [A,C,CE,parser,err] = nb_dsge.looseOptimalMonetaryPolicySolver(parser,solution,options,expandedOnly);
        else
            error([mfilename ':: Unsupported algorithm ''' algorithm ''' for solving the model under optimal policy.'])
        end
        
    elseif parser.hasExpectedBreakPoints
        
        [A,B,C,CE,parser,err] = nb_dsge.expectedBreakPointSolver(parser,solution,options,expandedOnly);
        
    elseif parser.optimalSimpleRule

        error('nb_dsge:solve:optimalDiscretionaryRules',['The model cannot be resolved when dealing with optimal ',...
              'simple rules. Use optimalSimpleRules method instead.'])    

    else
        if parser.isBackwardOnly
            [A,C,CE,err] = nb_dsge.backwardSolver(parser,solution,options,expandedOnly);
        else
            [A,C,CE,err] = nb_dsge.rationalExpectationSolver(parser,solution,options,expandedOnly);
        end
    end
    
    % Do we discount the anticipated shocks?
    if ~isempty(options.numAntSteps) && isfield(options.shockProperties,'Discount')
        indA             = solution.activeShocks;
        activeShockProps = options.shockProperties(indA);
        activeRes        = solution.res(indA);
        alpha            = [activeShockProps.Discount];
        for vv = 1:length(activeShockProps)
            indRes = strcmp(activeShockProps(vv).Name, activeRes);
            if ~any(indRes)
                error(['The exogenous variable (shock) ' activeShockProps(vv).Name ' is not an active shock of the model.'])
            end
            for tt = 2:size(CE,3)
                CE(:,indRes,tt) = alpha(vv)^(tt-1)*CE(:,indRes,tt);
            end
        end
    end
        
    % Do we have a observation block to add?
    if isempty(err) && ~isempty(parser.obs_equations)
        [A,B,C,CE,ss,err] = nb_dsge.addObsModelSolver(A,C,CE,parser,solution,options,expandedOnly);
    else
        if isempty(B)
            B = nan(size(A,1),0);
        end
        ss = solution.ss;
    end
    
end
