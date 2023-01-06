function ret = isStateSpaceModel(obj)
% Syntax:
%
% ret = isStateSpaceModel(obj)
%
% Description:
%
% Check if a nb_model_generic object is a state-space model or not. 
% 
% Input:
% 
% - obj : A scalar nb_model_generic object.
% 
% Output:
% 
% - ret : true or false. true if the estimation settings is so that the
%         solution to the model is a state-space model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if any(~issolved(obj))
        error('All elements of the input must be solved!')
    end
    
    [s1,s2,s3] = size(obj);
    obj        = obj(:);
    ret        = false(s1*s2*s3,1);
    for ii = 1:s1*s2*s3
        ret(ii) = isfield(obj(ii).solution,'A');
    end
    ret = reshape(ret,[s1,s2,s3]);

end
