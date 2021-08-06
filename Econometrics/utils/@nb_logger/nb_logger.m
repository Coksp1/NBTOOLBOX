classdef nb_logger < handle
% Description:
%
% A class for logging.
%
% Superclasses:
%
% handle
%
% Constructor:
%
%   logger = nb_logger(folder,level)
% 
%   Input:
%
%   - folder : Spesify the folder to log to. Will set the environment 
%              variable 'LOGGERFILE'.
%
%   - level  : Level of logging. Default is 0, i.e. to log everything.
%              Will set the environment variable 'LOGGERLEVEL'.
% 
%   Output:
% 
%   - logger : A nb_logger object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 

    properties (Constant)
        ALL     = 0;
        DEFAULT = 0;
        INFO    = 1;
        DEBUG   = 2;
        WARN    = 3;
        ERROR   = 4;
        OFF     = 5;
    end

    methods 
        
        function obj = nb_logger(folder,level)
            if nargin > 0
                setenv('LOGGERFOLDER',folder);
            end
            if nargin > 1
                setenv('LOGGERLEVEL',level);
            end
        end
        
    end
    
    methods (Static=true)
        
        function folder = getLoggerFolder()
        % Syntax:
        % 
        % folder = nb_logger.getLoggerFolder()
        %
        % Description:
        %
        % Get logger folder.
        % 
        % Written by Kenneth Sæterhagen Paulsen    
            folder = getenv('LOGGERFOLDER');  
        end
        
        function inputs = openLoggerFile(inputs,obj)
        % Syntax:
        % 
        % inputs = nb_logger.openLoggerFile(inputs,obj)
        %
        % Description:
        %
        % Open logger file.
        % 
        % Written by Kenneth Sæterhagen Paulsen

            if nargin < 2
                obj = [];
            end

            inputs.closeFile = false;
            if inputs.write && isempty(inputs.fileToWrite)
                if isa(obj,'nb_model_update_vintages')
                    folderName = [getFolder(obj(1)),filesep(),'errors'];
                else
                    if isfield(inputs,'folder')
                        folderName = inputs.folder;
                    else
                        folderName = '';
                    end
                    if isempty(folderName)
                        folderName = getenv('LOGGERFOLDER');
                    end
                    if isempty(folderName)
                        folderName = nb_userpath('gui');
                    end
                end
                inputs.closeFile = true;
                fileNameToWrite  = [folderName, filesep(), 'errorReport_' getenv('username'),'_', nb_clock('vintage'), '.txt'];
                if ~exist(folderName,'dir')
                    mkdir(folderName);
                end
                inputs.fileToWrite = fopen(fileNameToWrite,'a');
                if inputs.fileToWrite == -1
                    error([mfilename ':: Cannot open the error file; ' fileNameToWrite '. Please change the userpath!']);
                end
            end
            if ~isfield(inputs,'inGUI')
                inputs.inGUI = 'off';
            end
            
        end
        
        function closeLoggerFile(inputs) 
        % Syntax:
        % 
        % nb_logger.closeLoggerFile(inputs) 
        %
        % Description:
        %
        % Close logger file.
        % 
        % Written by Kenneth Sæterhagen Paulsen  
            
            if inputs.write && inputs.closeFile
                fclose(inputs.fileToWrite);
            end
        end
        
        function logging(messageLevel,inputs,message,Err) 
        % Syntax:
        % 
        % nb_logger.logging(messageLevel,inputs,message,Err) 
        %
        % Description:
        %
        % Write logger file.
        % 
        % Written by Kenneth Sæterhagen Paulsen

        % Copyright (c) 2021, Kenneth Sæterhagen Paulsen    
            
            level = getenv('LOGGERLEVEL');
            if isempty(level)
                level = nb_logger.DEFAULT;
            else
                level = str2double(level);
                if isnan(level)
                    nb_logger.DEFAULT;
                end
            end
            if messageLevel <= level
                return
            end
        
            if nargin < 4
                if inputs.write
                    if ischar(message)
                        message = cellstr(message);
                    end
                    nb_cellstr2file(message,inputs.fileToWrite,true);
                else
                    if messageLevel == 4
                        if strcmpi(inputs.inGUI,'on')
                            nb_errorWindow(message);
                        else
                            error(message);
                        end
                    elseif messageLevel == 3
                        warning('nb_logger:logWarning',message);
                    end
                end
            else
                if inputs.write
                    nb_writeError(Err,inputs.fileToWrite,message);
                else
                    if messageLevel == 4
                        if strcmpi(inputs.inGUI,'on')
                            nb_errorWindow(message,Err);
                        else
                            nb_error(message,Err);
                        end
                    elseif messageLevel == 3
                        warning('nb_logger:logWarning',message);
                    end
                end
            end
            
        end
        
        function w = getParallellLoggerFile(type)
        % Syntax:
        % 
        % w = nb_logger.getParallellLoggerFile(type) 
        %
        % Description:
        %
        % Write logger file.
        % 
        % Written by Kenneth Sæterhagen Paulsen 
        
            fileNameToWrite = ['errorReport', type, '_' getenv('username'),'_', nb_clock('vintage')];
            w               = nb_funcToWrite(fileNameToWrite,'gui');
            
        end
        
        function loggingDuringParallel(messageLevel,write,w,message,Err) 
        % Syntax:
        % 
        % nb_logger.loggingDuringParallel(write,w,message,Err) 
        %
        % Description:
        %
        % Write logger file.
        % 
        % Written by Kenneth Sæterhagen Paulsen  
            
            level = getenv('LOGGERLEVEL');
            if messageLevel <= level
                return
            end
        
            if nargin < 5
                if write
                    nb_cellstr2file({message},w.Value,true); 
                else
                    if messageLevel == nb_logger.ERROR
                        error(message); 
                    elseif messageLevel == nb_logger.WARN
                        warning('nb_logger:logWarning',message);
                    end
                end
            else
                if write
                    nb_writeError(Err,w.Value,message); 
                else
                    if messageLevel == nb_logger.ERROR
                        nb_error(message,Err);
                    elseif messageLevel == nb_logger.WARN
                        warning('nb_logger:logWarning',message);
                    end
                end 
            end
            
        end
        
    end

end
