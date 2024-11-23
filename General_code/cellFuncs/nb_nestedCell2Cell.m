function C = nb_nestedCell2Cell(nested)
% Syntax:
%
% c = nb_nestedCell2Cell(nested)
%
% Description:
%
% Transform a nested cell array to a cell array
% 
% Input:
% 
% - nested : A nested cell array. E.g. {{'Var1','Var2'},{'Var3'}}
% 
% Output:
% 
% - C      : A cell array. E.g. {'Var1','Var2','Var3'}
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    C = {};
    for i = 1:numel(nested)
        
        if ~iscell(nested{i})
            C = cat(2, C, nested(i));
        else
            Ctemp = nb_nestedCell2Cell(nested{i});
            C     = cat(2, C, Ctemp);
        end
        
    end 

end
