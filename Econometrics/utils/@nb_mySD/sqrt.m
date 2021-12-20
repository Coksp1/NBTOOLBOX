function obj = sqrt(obj)
% Syntax:
%
% obj = sqrt(obj)
%
% Description:
%
% Square root.
% 
% Input:
% 
% - obj : An object of class nb_mySD.
%
% Output:
% 
% - obj : An object of class nb_mySD.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    objDeriv     = nb_mySD.addPar(obj.derivatives,true); 
    objStr       = nb_mySD.addPar(obj.values,true);
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    for ii = 1:length(objDeriv)
        if strcmp(objDeriv{ii},'1')
            obj.derivatives{ii} = strcat('0.5.*', objStr ,'.^-0.5');
        else
            obj.derivatives{ii} = strcat('0.5.*',objDeriv{ii} ,'.*', objStr ,'.^-0.5');
        end
    end
    obj.values = ['sqrt' objStrInFunc];
    
end
