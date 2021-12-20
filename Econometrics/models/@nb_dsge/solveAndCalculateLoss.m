function L = solveAndCalculateLoss(srCoeff,srInd,param,parser,sol,options)
% Syntax:
%
% L = nb_dsge.solveAndCalculateLoss(srCoeff,srInd,param,...
%               parser,sol,options)
%
% Description:
%
% Calculate loss of the authorities given the current values of the 
% coefficients of the simple rules under commitment.
% 
% See also:
% nb_dsge.optimalSimpleRules, nb_dsge.calculateLossCommitment
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(options.osr_type,'discretion')
        
        jacobian                      = nb_dsge.solveSimpleRule(parser,sol,srCoeff,srInd,param);
        [sol.Alead,sol.A0,sol.Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(jacobian,parser);
        if ~parser.firstStep 
            sol.C = B;
        end
        [L,failed] = nb_dsge.calculateLossDiscretion(options,sol,true);
        
    else
        
        % Find the solution using the Klein's algorithm
        [sol.A,sol.C,~,err] = nb_dsge.solveSimpleRule(parser,sol,srCoeff,srInd,param);
        if ~isempty(err)
            % Model is unstable at the given coefficients
            L = 1e3;
            return
        end
        [L,failed] = nb_dsge.calculateLossCommitment(options,sol,parser);
        
    end
    if failed
        L = 1e3;
        return
    end
    
end
