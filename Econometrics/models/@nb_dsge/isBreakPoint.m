function ret = isBreakPoint(obj)
% Syntax:
%
% ret = isBreakPoint(obj)
%
% Description:
%
% Is the nb_dsge object using the NB Toolbox solver for DSGE models with
% unanticipated break points or not.
% 
% Input:
% 
% - obj : A nb_dsge object.
% 
% Output:
% 
% - ret : 1 if true, else 0.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

	[s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if ~isempty(obj(ii,jj,kk).estOptions.parser)
                    ret(ii,jj,kk) = ~nb_isempty(obj(ii,jj,kk).estOptions.parser.breakPoints);
                end
            end
        end
    end
    
end
