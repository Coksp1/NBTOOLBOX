function c = nb_strcomb(c1,c2,sep)
% Syntax:
%
% c = nb_strcomb(c1,c2)
% c = nb_strcomb(c1,c2,sep)
%
% Description:
%
% Create all combinations of two cellstr.
% 
% Input:
% 
% - c1 : A cellstr with size N x 1
%
% - c2 : A cellstr with size M x 1
%
% - sep : A string with the seperator between the two concatenated strings.
%         Default is '_'.
% 
% Output:
% 
% - c  : A cellstr with size N*M
%
% Examples:
%
% c1 = {'T';'G';'F'};
% c2 = {'a';'b';'c'};
% c  = nb_strcomb(c1,c2)
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        sep = '_';
    end

    [N,N2] = size(c1);
    [M,M2] = size(c2);
    
    if N2 > 1
        error([mfilename ':: The input c1 must be a column vector.']);
    end
    if M2 > 1
        error([mfilename ':: The input c2 must be a column vector.']);
    end
    
    c = cell(N*M,1);   
    for ii = 1:N
        ind    = M*(ii-1) + 1:M*ii; 
        c(ind) = strcat(c1{ii},sep,c2);
    end

end
