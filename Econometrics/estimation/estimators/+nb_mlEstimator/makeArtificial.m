function YDRAW = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% YDRAW = nb_mlEstimator.makeArtificial(model,options,results,...
%              method,draws,iter)
%
% Description:
%
% Make artificial data from model by simulation.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    error([mfilename ':: Make artificial data from model by simulation for models estimated with maximum likelihood is not supported.'])
      
end
