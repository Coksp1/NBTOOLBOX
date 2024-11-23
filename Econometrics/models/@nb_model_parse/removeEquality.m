function eqs = removeEquality(eqs)
% Syntax:
% 
% eqs = nb_model_parse.removeEquality(eqs)
%
% Description:
%
% Remove equality signs from equations. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    eqs      = regexprep(eqs,'\s','');
    ind      = strfind(eqs,'=');
    indCheck = ~cellfun(@isempty,ind);
    locCheck = find(indCheck);
    for ii = 1:length(locCheck)
        
        loc = locCheck(ii);
        if numel(ind{loc}) > 1
            error([mfilename ':: Equation number ' int2str(ii) ' has more than one equality sign; ' eqs{ii}])
        else
            eqT      = eqs{loc};
            eqLHS    = eqT(1:ind{loc}-1);
            eqRHS    = eqT(ind{loc}+1:end);
            eqs{loc} = [eqLHS '-(' eqRHS ')'];
        end
        
    end

end

