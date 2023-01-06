function ret = handleCondInfo(obj) 
% Syntax:
%
% ret = handleCondInfo(obj)
%
% Description:
%
% Check if a nb_model_estimate object handle conditional info. 
% 
% Input:
% 
% - obj : A scalar nb_model_etimate object.
% 
% Output:
% 
% - ret : true or false. true if the estimation settings is so that the
%         model handle conditional info.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ret = obj.options.handleCondInfo;

end
