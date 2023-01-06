function Y = normalSolutionStochInitVal(obj,Y,inputs,funcs)
% Syntax:
%
% [YT,err] = nb_perfectForesight.normalSolutionStochInitVal(obj,Y,...
%               inputs,funcs)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    silentOld          = obj.options.silent;
    obj.options.silent = true;
    
    if isa(inputs.waitbar,'nb_waitbar')
        waitbar  = inputs.waitbar;
        deleteWB = false;
    else
        waitbar  = nb_waitbar([],'Solve...',inputs.draws);
        deleteWB = true;
    end
    Y       = Y(:,:,ones(1,inputs.draws));
    inputsT = inputs;
    keep    = true(1,inputs.draws);
    incr    = 10;
    for ii = 1:inputs.draws
        
        % Select the initial value to use
        inputsT.initVal = inputs.initVal(ii);
        
        % Solve for one draw of the initial condition
        try
            Y(:,:,ii) = nb_perfectForesight.normalSolution(obj,Y(:,:,ii),inputsT,funcs);
        catch
            % Just delete failed simulations? Redraw instead?
            keep(ii) = false;
        end
        
        % Report status
        if rem(ii,incr) == 0
            waitbar.status = waitbar.status + incr;
        end
        
    end
    Y = Y(:,:,keep);
    
    % Remove failed inital values
    inputs.initValDraws = inputs.initValDraws(keep,:);
    
    % Clean up waitbar
    if deleteWB
        delete(waitbar);
    end
    obj.options.silent = silentOld;
    
end
