function [YDRAW,start,finish,indY,startEst] = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% [YDRAW,start,finish,indY,startEst] = nb_ridgeEstimator.makeArtificial(...
%                                       model,options,results,method,...
%                                       draws,iter)
%
% Description:
%
% Make artificial data from model by simulation.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    error('Cannot make artificial data from a model estimated with RIDGE')
    
end
