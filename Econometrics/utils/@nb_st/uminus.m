function obj = uminus(obj)
% Syntax:
%
% obj = uminus(obj)
%
% Description:
%
% Uniary minus (-).
% 
% Input:
% 
% - obj : A nb_st object.
% 
% Output:
% 
% - obj : An object of class nb_stParam or nb_stTerm.
%
% See also:
% nb_stTerm, nb_stParam, nb_st.plus
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end

    str = ['-' nb_mySD.addPar(obj.string,true)]; 
    if isa(obj,'nb_stParam') 
        obj.value  = -obj.value;
        obj.string = str;
    else
        obj = nb_stTerm(str,obj.trend);
    end
    
end
