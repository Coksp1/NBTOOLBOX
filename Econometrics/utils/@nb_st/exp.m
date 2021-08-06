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
% - obj : A nb_st object.
% 
% Output:
% 
% - obj : An object of class nb_stParam or nb_stTerm.
%
% See also:
% nb_stTerm, nb_stParam, nb_st.log
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if ~isempty(obj.error)
        return
    end
    
    str = ['exp', nb_mySD.addPar(obj.string,false)]; 
    if isa(obj,'nb_stParam')
        obj.value  = exp(obj.value);
        obj.string = str;
    else
        if isTrending(obj)
            obj.error = [mfilename ':: It is not possible to take exp on a trending ',...
                                   'variable/term; ', obj.string];
            return   
        end
        obj = nb_stTerm(str,obj.trend);
    end

end
