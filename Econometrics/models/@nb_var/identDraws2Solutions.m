function sol = identDraws2Solutions(obj)
% Syntax:
%
% sol = identDraws2Solutions(obj)
%
% Description:
%
% This function assumes that you have used the set_identification function
% with the input 'type' set to 'combination'.
% 
% Input:
% 
% - obj : An object of class nb_var.
% 
% Output:
% 
% - sol : A struct storing the solution of the model. Same format
%         as the solution property of the nb_var class.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    solAll = obj.solution;
    num    = size(solAll.C,4);
    sol    = solAll; 
    sol.C  = solAll.C(:,:,:,1);
    sol    = sol(ones(1,num),1);
    for ii = 2:num
        sol(ii).C = solAll.C(:,:,:,ii);
    end
    
end
