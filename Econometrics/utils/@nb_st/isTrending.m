function ret = isTrending(obj)
% Syntax:
%
% ret = isTrending(obj)
%
% Description:
%
% Test if nb_st object is trending.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = abs(obj.trend) > obj.tolerance;

end
        
