function ret = isStationary(obj)
% Syntax:
%
% ret = isforecasted(obj)
%
% Description:
%
% Is the nb_model_forecast object forecasted or not.
% 
% Input:
% 
% - obj : A nb_model_forecast object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = true(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if ~isempty(obj(ii,jj,kk).parser.unitRootVars)
                    ret(ii,jj,kk) = obj.isStationarized;
                end
            end
        end
    end
    
end
