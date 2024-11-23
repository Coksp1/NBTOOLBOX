function obj = log(obj)
% Syntax:
%
% obj = log(obj)
%
% Description:
%
% Natural logarithm.
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
% nb_stTerm, nb_stParam, nb_st.exp
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    str = ['log', nb_mySD.addPar(obj.string,false)]; 
    if isa(obj,'nb_stParam')
        obj.value  = log(obj.value);
        obj.string = str;
    else
        if isTrending(obj)
            obj.error = [mfilename ':: It is not possible to take log on a trending ',...
                                   'variable/term; ', obj.string];
            return   
        end
        obj = nb_stTerm(str,obj.trend);
    end

end
