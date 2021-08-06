function names = getModelNames(obj)
% Syntax:
%
% names = getModelNames(obj)
%
% Description:
%
% Get model names, if some model names are empty, they will be given
% the default name 'Model<ii>'.
% 
% Input:
% 
% - obj   : A N x M nb_model_forecast object.
% 
% Output:
% 
% - names : A N x M cellstr.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    siz   = size(obj);
    obj   = obj(:);
    names = arrayfun(@getName,obj,'uniformOutput',false);
    ind   = find(cellfun(@isempty,names))';
    if ~isempty(ind)
        for ii = ind
            names{ii} = ['Model' int2str(ii)];
        end
    end
    names = reshape(names,siz);
    
end
