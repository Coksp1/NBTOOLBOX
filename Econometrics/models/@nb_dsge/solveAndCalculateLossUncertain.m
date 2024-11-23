function L = solveAndCalculateLossUncertain(srCoeff,srInd,param,parser,sol,options)
% Syntax:
%
% L = nb_dsge.solveAndCalculateLossUncertain(srCoeff,srInd,param,...
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nDraws = size(param,2);
    if strcmpi(options.osr_type,'discretion')
        
        L = nan(1,nDraws);
        for ii = 1:nDraws
        
            % Find the structural representation
            jacobian                                  = nb_dsge.solveSimpleRule(parser,sol(ii),srCoeff,srInd,param(:,ii));
            [sol(ii).Alead,sol(ii).A0,sol(ii).Alag,B] = nb_dsge.jacobian2StructuralMatricesNB(jacobian,parser);
            if ~parser.firstStep 
                sol(ii).C = B;
            end
            
            [L(ii),failed] = nb_dsge.calculateLossDiscretion(options,sol(ii),true);
            if failed
                L = 1e3;
                return
            end
            
        end
        L = mean(L);
        
    else
        
        L = nan(1,nDraws);
        for ii = 1:nDraws
        
            % Find the solution using the Klein's algorithm
            [sol(ii).A,sol(ii).C,~,err] = nb_dsge.solveSimpleRule(parser,sol(ii),srCoeff,srInd,param(:,ii));
            if ~isempty(err)
                % Model is unstable at the given coefficients
                L = 1e3;
                return
            end
            [L(ii),failed] = nb_dsge.calculateLossCommitment(options,sol(ii),parser);
            if failed
                L = 1e3;
                return
            end
            
        end
        L = mean(L);
        
    end

end
