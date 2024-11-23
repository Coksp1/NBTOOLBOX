function [obj,nbFile] = parseMacro(obj,nbFile)
% Syntax:
%
% [obj,nbFile] = parseMacro(obj,nbFile)
%
% Description:
%
% No doc provided. Used by nb_dsge.parse. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~obj.options.silent
        tic;
        disp('Run macro processing using NB Toolbox: ')
    end

    % Make sure the macroVars options is correct
    if ~isa(obj.options.macroVars,'nb_macro')
        try
            obj.options.macroVars = nb_macro.interpret(obj.options.macroVars);
        catch Err
            error(strrep(Err.message,'input','macroVars'));
        end
    end

    % Add predefined macro variable isnb if not already defined
    if ~ismember('isnb',{obj.options.macroVars.name})
        isnb                  = nb_macro('isnb',true);
        obj.options.macroVars = [isnb,obj.options.macroVars];
    end

    [obj.options.macroVars,nbFile] = parse(obj.options.macroVars,nbFile);
    if ~obj.options.silent
        elapsedTime = toc;
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
end
