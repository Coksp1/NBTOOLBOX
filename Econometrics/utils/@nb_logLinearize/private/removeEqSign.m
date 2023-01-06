function obj = removeEqSign(obj)
% Syntax:
%
% obj = removeEqSign(obj)
%
% Description:
%
% Remove equality sign and update the property eqSign.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    eqs            = obj.equations;
    eqs            = regexprep(eqs,'\s','');
    ind            = strfind(eqs,'=');
    locCheck       = find(~cellfun(@isempty,ind));
    nEqs           = size(eqs,1);
    obj.eqInd      = nan(nEqs + length(locCheck),1);
    obj.eqRevInd   = nan(nEqs + length(locCheck),1);
    obj.eqFound    = false(nEqs + length(locCheck),1);
    newEqs         = cell(nEqs + length(locCheck),1);
    newEqs(1:nEqs) = eqs;
    for ii = 1:length(locCheck)
        
        loc = locCheck(ii);
        if numel(ind{loc}) > 1
            error([mfilename ':: Equation number ' int2str(ii) ' has more than one equality sign; ' eqs{ii}])
        else
            
            % Split equation at =
            eqT             = eqs{loc};
            eqLHS           = eqT(1:ind{loc}-1);
            eqRHS           = eqT(ind{loc}+1:end);
            newEqs{loc}     = eqRHS;
            newEqs{nEqs+ii} = eqLHS;
            
            % Update properties, so to be able to pair the expressions
            % later on
            obj.eqInd(nEqs+ii)         = loc;
            obj.eqRevInd(loc)          = nEqs + ii;
            obj.eqFound([loc,nEqs+ii]) = true;
        end
        
    end
    obj.equations = newEqs;

end
