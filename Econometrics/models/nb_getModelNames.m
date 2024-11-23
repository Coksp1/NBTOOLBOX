function names = nb_getModelNames(varargin)
% Syntax:
%
% names = nb_getModelNames(varargin)
%
% Description:
%
% Get model names, if some model names are empty, they will be given
% the default name 'Model<ii>'.
% 
% Input:
% 
% - varargin  : Each input must be an object of class nb_model_generic
%               or nb_model_group
% 
% Output:
% 
% - names     : A 1 x N cellstr.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    names = cell(1,nargin);
    for ii = 1:nargin
        obj       = varargin{ii};
        names{ii} = obj.name;
        if isempty(names{ii})
            names{ii} = ['Model' int2str(ii)];
        end
    end
    
end
