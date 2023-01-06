function newFile = nb2RisePreparser(rise_file,silent,macroProcessor,macroVars)
% Syntax:
%
% newFile = nb_dsge.nb2RisePreparser(rise_file,silent,macroProcessor,...
%                                           macroVars)
%
% Description:
%
% This static method may be useful to convert a nb model file to a rise 
% model file.
% 
% Caution: This is provided with no garanti it will work, and a lot of the
%          special options in a nb model file is not supported in RISE, and
%          thise options are not ckeck by this method!
%
% Input:
% 
% - rise_file      : A .mod or .nb file with the model to run in RISE 
%                    instead of using the NB toolbox parser and solver.
% 
% - silent         : If the preparsing should be silent or not.
%
% - macroProcessor : Run NB macroprocessor before writing it to a .rs file.
%
% - macroVars      : A vector of nb_macro objects. Use for the
%                    macroprocessing. Default is an empty nb_macro array. 
%
% Output:
% 
% - newFile        : A .rs file with the file you can run with RISE.
%
% See also:
% nb_dsge
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        macroVars = nb_macro.empty();
        if nargin < 3
            macroProcessor = false;
            if nargin < 2
                silent = true;
            end
        end
    end

    if ~silent
        tic;
        disp(' ')
        disp('Run converter from NB Toolbox file to RISE file: ')
    end

    % Read file and remove NB-IGNORE statements, but not comments!
    nbFile = nb_model_parse.readFile(rise_file,false);
    
    % Run macroproccessor if wanted
    if macroProcessor
        
        if ~silent
            tic;
            disp('+ Run macro processing using NB Toolbox: ')
        end
        
        % Remove leading and trailing white space as this is needed in 
        % the macroprocessing
        %nbFile(:,1) = strtrim(nbFile(:,1));
        
        % Make sure the macroVars options is correct
        if ~isa(macroVars,'nb_macro')
            try
                macroVars = nb_macro.interpret(macroVars);
            catch Err
                error(strrep(Err.message,'input','macroVars'));
            end
        end
        
        % Add predefined macro variable isnb if not already defined
        if ~ismember('isnb',{macroVars.name})
            isnb      = nb_macro('isnb',true);
            macroVars = [isnb,macroVars];
        end
        
    end
    
    % Write .rs file
    [p,f]  = fileparts(rise_file);
    if isempty(p)
        newFile = [f,'.rs'];
    else
        newFile = [p,filesep,f,'.rs'];
    end
    nb_cellstr2file(nbFile(:,1),newFile,true);
    pause(0.5); % Pause to be sure that the file is on the path before we continue!!

    if ~silent
        elapsedTime = toc;
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
        disp(' ')
    end
    
end
