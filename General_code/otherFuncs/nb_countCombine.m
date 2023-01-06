function num = nb_countCombine(n,nMin,nMax)
% Syntax:
%
% num = nb_countCombine(nMin,nMax)
%
% Description:
%
% This is the number of combinations of N things taken nMin to nMax at a 
% time. I.e. the sum of n!/k!(n-k)! for k = nMin,...,nMax.
% 
% Input:
% 
% - n    : An integer.
%
% - nMin : An integer.
%
% - nMax : An integer.
% 
% Output:
% 
% - num  : An integer.
%
% See also:
% nchoosek
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    num = 0; 
    for q = nMin:nMax
        num = num + nchoosek(n,q);
    end
    
end
