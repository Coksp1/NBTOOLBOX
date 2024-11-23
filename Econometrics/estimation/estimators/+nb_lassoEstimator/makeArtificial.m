function [YDRAW,start,finish,indY,startEst] = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% [YDRAW,start,finish,indY,startEst] = nb_lassoEstimator.makeArtificial(...
%                                       model,options,results,method,...
%                                       draws,iter)
%
% Description:
%
% Make artificial data from model by simulation.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    error('Cannot make artificial data from a model estimated with LASSO')
    
end
