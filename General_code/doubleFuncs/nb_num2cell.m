function c = nb_num2cell(d)
% Syntax:
%
% c = nb_num2cell(d)
%
% Description:
%
% Convert rows of a double matrix into a cell array.
% 
% Input:
% 
% - d : A N x Q x M double
% 
% Output:
% 
% - c : A N x 1 cell array, each element stores a 1 x Q x M double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    c = cell(size(d,1),1);
    for ii = 1:size(d,1)
        c{ii} = d(ii,:,:);
    end
    
end
