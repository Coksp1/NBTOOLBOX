function variableName = findVariableName(obj,mnemonics)
% Syntax:
%
% variableName = nb_graph.findVariableName(obj,mnemonics)
%
% Description:
%
% Look up a mnemonics and find the matching description. If not 
% found this method will return the mnemonics.
%
% This method uses the lookUpMatrix property of the input given by
% obj to match the mnemonics with a description.
%
% Input:
%
% - obj          : An object which is of a subclass of the nb_graph 
%                  class.
%
% - mnemonics    : The mnemonics to look up. As a string.
% 
% Output:
%
% - variableName : The description matching the mnemonics. If the
%                  mnemonics is not found in the lookUpMatrix
%                  property of the object given as input, it will
%                  just return the mnemonics. As a string.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~ischar(mnemonics)
        variableName = mnemonics;
        return
    elseif size(mnemonics,1) > 1
        variableName = mnemonics;
        return
    end

    stringInd = find(strcmp(mnemonics,obj.lookUpMatrix(:,1)),1,'last');
    if ~isempty(stringInd)
        switch obj.language
            case {'norsk','norwegian'}
                variableName = obj.lookUpMatrix{stringInd,3};
            case {'english','engelsk'}
                variableName = obj.lookUpMatrix{stringInd,2};
            otherwise
                error([mfilename, ':: Language ' obj.language ' is not supported by this function'])
        end
    else
        variableName = mnemonics;
    end

end
