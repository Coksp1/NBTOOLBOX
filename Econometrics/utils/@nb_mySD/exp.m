function obj = exp(obj)
% Syntax:
%
% obj = exp(obj)
%
% Description:
%
% Exponential.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    objDeriv     = nb_mySD.addPar(obj.derivatives,true); 
    objStrInFunc = nb_mySD.addPar(obj.values,false);
    for ii = 1:length(objDeriv)
        if strcmp(objDeriv{ii},'1')
            obj.derivatives{ii} = strcat('exp', objStrInFunc);
        else
            obj.derivatives{ii} = strcat(objDeriv{ii} ,'.*exp', objStrInFunc);
        end
    end
    obj.values = ['exp' objStrInFunc];
    
end
