function [diffStr1, diffStr2, sameStr] = getDiff(cellstr1,cellstr2)
% Syntax:
%
% [diffStr1, diffStr2] = nb_bd.getDiff(cellstr1,cellstr2)
%
% Description:
%
% Compare two cell arrays of strings, and return the strings which 
% differs
% 
% Input:
% 
% - cellstr1      : An array of strings
% 
% - cellstr2      : An array of strings
% 
% Output:
% 
% - diffStr1      : An array of the strings from cellstr1 which 
%                   differs from cellstr2
%                   
% - diffStr2      : An array of the strings from cellstr2 which 
%                   differs from cellstr1
%
% - sameStr       : An array of the string from both the cellstr1
%                   and cellstr2
%                   
% Examples:
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    found = zeros(size(cellstr1));
    for ii = 1:length(cellstr1)
        found(ii) = sum(strcmp(cellstr1{ii},cellstr2));
    end
    diffStr1 = cellstr1(~found);

    found = zeros(size(cellstr2));
    for ii = 1:length(cellstr2)
        found(ii) = sum(strcmp(cellstr2{ii},cellstr1));
    end
    diffStr2 = cellstr2(~found);

    if nargout == 3
        sameStr = cellstr2(found);
    end

end
