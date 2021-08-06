function reportStatus(obj,state)
% Syntax:
%
% reportStatus(obj,state)
%
% Description:
%
% Call the update method on the nb_optimizerDisplayer to report 
% results to user.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    resForDisplay = struct('iteration',obj.iterations,'fval',obj.minFunctionValue);
    update(obj.displayer,obj.minXValue,resForDisplay,state);

end
