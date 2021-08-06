function ret = isTrending(obj)
% Syntax:
%
% ret = isTrending(obj)
%
% Description:
%
% Test if nb_st object is trending.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ret = abs(obj.trend) > obj.tolerance;

end
        
