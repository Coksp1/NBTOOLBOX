function [realD,imagD,modulus] = nb_calcRoots(A)
% Syntax:
%
% [realD,imagD,modulus] = nb_calcRoots(model)
%
% Description:
%
% Calculates the roots of the companion from of the model.
% 
% If the modulus is larger than 1 for any of the roots the model
% is not stable.
%
% Input:
% 
% - A : The transition matrix of the model.
% 
% Output:
% 
% - realD   : The real part of the roots.
%
% - imagD   : The imaginary part of the roots.
%
% - modulus : The modulus of the roots.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [s,~,p] = size(A);
    eigVal  = nan(s,1,p);
    for ii = 1:p
        eigVal(:,:,ii) = eig(A(:,:,ii));
    end
    realD   = real(eigVal);
    imagD   = imag(eigVal);
    modulus = sqrt(realD.^2 + imagD.^2);
    
end
