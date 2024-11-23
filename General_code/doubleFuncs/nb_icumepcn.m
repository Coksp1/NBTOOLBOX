function dout = nb_icumepcn(din,d0,omitnan)
% Syntax: 
%
% - dout = nb_icumepcn(din,d0,omitnan)
%
% Description:
%
% Inverse of the percentage cumulative growth method nb_cumepcn
% 
% Input:
%
% - din     : A double matrix with dimensions [r,c,p].
%
% - d0      : A double matrix with dimensions [r,c,p]. Initial values
% 
% - omitnan : Set to true to make the function robust for trailing and 
%             leading NaNs, but it does not handle missing observation 
%             in the middle. In the last case nan is returned.  
%
% Output:
% 
% - dout    : A double matrix with dimensions [r,c,p].
%
% See also:
% epcn, nb_icumepcn
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        omitnan = false;
    end
    dout = nb_icumegrowth(din/100,d0,omitnan);
    
end