function [irfs,irfsBands,plotter] = irf(obj,varargin)
% Syntax:
%
% [irfs,irfsBands,plotter] = irf(obj,varargin)
%
% Description:
%
% Produce IRFs of the model(s) represented by nb_model_group 
% object.
% 
% Input:
%
% - obj : A nb_model_group object.
%
% Optional input:
% 
% - varargin                 : See the the irf method of the 
%                              nb_model_generic class.
% 
% Output:
% 
% - [irfs,irfsBands,plotter] : See the the irf method of the 
%                              nb_model_generic class.
%
% See also:
% nb_model_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: This function only handles one nb_model_group object'])
    end
    ind = cellfun(@(x)isa(x,'nb_model_group'),obj.models);
    if any(~ind)
        error([mfilename ':: This method only handles when each of the models of the group ar nb_model_generic objects.'])
    end

    [irfs,irfsBands,plotter] = irf([obj.models{:}],varargin{:});

end
