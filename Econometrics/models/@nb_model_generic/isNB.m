function ret = isNB(obj)
% Syntax:
%
% ret = isNB(obj)
%
% Description:
%
% This will return true for all objects except nb_dsge objects!
%    
% For nb_dsge objects it will return true if the DSGE model is 
% parsed/solved using the NB Toolbox solver for DSGE models, otherwise
% it will return false.
%
% Input:
% 
% - obj : A M x N x Q nb_model_generic object.
% 
% Output:
% 
% - ret : A M x N x Q logical. An element is set to true if the model uses
%         a NB toolbox solver. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

	[s1,s2,s3] = size(obj);
    ret        = true(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if isa(obj(ii,jj,kk),'nb_dsge')
                    ret(ii,jj,kk) = ~nb_isempty(obj(ii,jj,kk).estOptions.parser);
                end
            end
        end
    end
    
end
