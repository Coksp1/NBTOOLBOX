function ret = handleMissing(obj) 
% Syntax:
%
% ret = handleMissing(obj)
%
% Description:
%
% Check if a nb_model_estimate object handle missing observations. 
% 
% Input:
% 
% - obj : A scalar nb_model_etimate object.
% 
% Output:
% 
% - ret : true or false. true if the estimation settings is so that the
%         model handle missing data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ret = obj.options.handleMissing;
    
end
