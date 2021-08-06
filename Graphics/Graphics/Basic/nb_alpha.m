function c = nb_alpha(c1,c2,alpha1,alpha2)
% Syntax:
%
% c = nb_alpha(c1,c2,alpha1,alpha2)
%
% Description:
%
% Alpha blending of two colors.
% 
% Input:
% 
% - c1     : A 1x3 double with the RGB color.
%
% - c1     : A 1x3 double with the RGB color.
%
% - alpha1 : A 1x1 double between 0 and 1.
%
% - alpha2 : A 1x1 double between 0 and 1.
% 
% Output:
% 
% - c      : A 1x3 double with the alpha blended RGB color.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    alpha = alpha1 + alpha2*(1-alpha1);
    c     = (c1*alpha1 + c2*alpha2*(1-alpha1))/alpha;
    
end
