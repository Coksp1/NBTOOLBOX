function [DB,plotter] = tracePlot(obj)
% Syntax:
%
% [DB,plotter] = tracePlot(obj)
%
% Description:
%
% Redirect to checkPosteriors.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isa(obj,'nb_model_generic')
        error([mfilename ':: The input must be of class nb_model_generic.'])
    end
    [DB,plotter] = checkPosteriors(obj);
    
end
