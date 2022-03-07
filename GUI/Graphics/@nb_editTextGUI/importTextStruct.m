function out = importTextStruct(gui)
% Syntax:
%
% saveToSession(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    % Opening a "blank" GUI
    if nargin < 1
        gui = 'newSession';
    end

    [file,path] = uigetfile('*.mat');
    
    % Cancelled by user, file will be set to 0
    if file == false
        return
    end
    
    loadedStruct = load([path,file]);
    
    % Trying to check if user downloaded correct file
    % This can be improved!
    if ~isstruct(loadedStruct) || length(fieldnames(loadedStruct)) > 1
        nb_errorWindow('It looks like you imported the wrong file. Please try again.')
        return
    end
    
    if strcmpi(gui,'newSession')
        % Called in constructor, returning the struct
        out = loadedStruct.graphInfo;
    else
        % Called in menu, returning gui with the new struct

        % Checking if imported file contains the same graphs as the existing
        % GUI and handle inconsitencies
        existingGraphs = gui.graphNames;
        newGraphs      = fieldnames(loadedStruct.graphInfo);
        
        graphsNotInTextGUI = existingGraphs(~ismember(existingGraphs,newGraphs));
        graphsNotInMainGUI = newGraphs(~ismember(newGraphs,existingGraphs));
            
        S = loadedStruct.graphInfo;
        if ~isempty(graphsNotInMainGUI)
            S = rmfield(S,graphsNotInMainGUI);
        end
            
        if ~isempty(graphsNotInTextGUI)
            for ii = 1:length(graphsNotInTextGUI)
                S.(graphsNotInTextGUI{ii}) = gui.infoStruct.(graphsNotInTextGUI{ii});
            end
        end
        gui.infoStruct = S;
        out = gui;
    end
end
