function c = nb_double2cell(d,precision)
% Syntax:
%
% c = nb_double2cell(d,precision)
%
% Description:
%
% Convert a double matrix to a cellstr matrix with a given 
% precision.
% 
% Input:
% 
% - d         : A double.
%
% - precision : E.g. '%6.6f' or 4 (number of digits)
% 
% Output:
% 
% - c         : A cell matrix
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    c = cell(size(d));
    for ii = 1:size(d,2)    
        c(:,ii) = cellstr(num2str(d(:,ii),precision));        
    end
    
end
