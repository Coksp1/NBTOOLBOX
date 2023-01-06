function S = toStructure(obj)
% Syntax:
%
% S = toStructure(obj)
% 
% Description:
%
% Transform the object to a structure. Data will be saved in its expanded
% form (i.e. filled with NaNs in place of missing values like nb_ts).
% 
% Input: 
% 
% - obj       : An object of class nb_bd
% 
% Output:
% 
% - S   : A structure with fieldnames given by the object
%         variables and varible data contained in the field.
%                        
% Examples:
% 
% obj = nb_bd(ones(7,1),'','2012Q1',{'Var1'},[zeros(4,1);1;zeros(3,1)],0);
% s   = obj.toStructure()
% s = 
% 
%               Var1: [8x1 double]
%          variables: {'Var1'}
%          startDate: [1x1 nb_quarter]
%          ignorenan: 1
%              class: 'nb_bd'
%           userData: ''
%     localVariables: []
%             sorted: 1
%
% See also:
% nb_bd.struct
%
% Written by Per Bjarne Bye                     

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    S    = struct();
    data = getFullRep(obj); 
    
    for ii = 1:size(obj.variables,2)
        S.(['Var' int2str(ii)]) = data(:,ii,:);
    end
    
    S.variables      = obj.variables;
    S.startDate      = obj.startDate;
    S.ignorenan      = obj.ignorenan;
    S.class          = 'nb_bd';
    S.userData       = obj.userData;
    S.localVariables = obj.localVariables;
    S.sorted         = obj.sorted;

end
