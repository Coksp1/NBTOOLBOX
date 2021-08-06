function obj = checkModel(obj)
% Syntax:
%
% obj = checkModel(obj)
%
% Description:
%
% Secure that the object is up to date when it comes to the options,
% estOptions and results struct properties.
% 
% Input:
% 
% - obj : An object of class nb_model_recursive_detrending.
% 
% Output:
% 
% - obj : An object of class nb_model_recursive_detrending.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj.model = checkModel(obj.model);

end
