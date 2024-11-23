function parser = updateLeadLagGivenOptimalPolicy(parser,Alead,Alag)
% Syntax:
%
% parser = nb_dsge.updateLeadLagGivenOptimalPolicy(parser,Alead,Alag)
%
% Description:
%
% Update lead and lag incident given added mulitplier when model is 
% solved under optimal monetary policy.
%
% See also:
% nb_dsge.updateGivenOptimalPolicy
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isfield(parser,'block')
        if ~nb_isempty(parser.block)
            % Remove the variables of the epilogue
            leadCLag = parser.leadCurrentLag(~parser.block.epiEndo,:);
        else
            leadCLag = parser.leadCurrentLag;
        end
    else
        leadCLag = parser.leadCurrentLag;
    end
    
    [nMult,nEndo]         = size(Alead);
    isF                   = any(Alead,2);
    isB                   = any(Alag,2);
    leadCLagMult          = [false(nMult,1),true(nMult,1),false(nMult,1)]; 
    leadCLagMult(isF,3)   = true; % If lagged multiplier on leaded variables
    leadCLagMult(isB,1)   = true; % If leaded multiplier on lagged variables
    parser.leadCurrentLag = [leadCLag;leadCLagMult];
    parser                = nb_dsge.updateClassifications(parser);
    parser.isMultiplier   = [false(nEndo,1);true(nMult,1)];
    
end
