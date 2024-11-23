function vintageCallback(gui,~,~)
% Syntax:
%
% vintageCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Edit vintage tag of (FAME) source.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(get(gui.smartPanel,'visible'),'on')
        string = get(gui.smartVint,'string');
    else
        string = get(gui.fameVintage,'string');
    end
    local  = nb_contains(string,'%#');
    if local
        locVar = string;
        vint   = string;
        string = nb_localVariables(gui.data.localVariables,vint);
    end
    
    if isempty(string)
        vint = '';
    else
        if size(string,2) < 8
            vint = round(str2double(string));
            if isnan(vint)
                nb_errorWindow('The vintage provided (or returned by the local variable) must be an integer when it has less then 8 numbers')
                return
            end
        elseif size(string,2) == 8 || size(string,2) == 12
            vint   = string;
            tested = round(str2double(string));
            if isnan(tested)
                nb_errorWindow('The vintage provided (or returned by the local variable) must be an integer')
                return
            end
        else
            nb_errorWindow('The vintage provided (or returned by the local variable) is not correct. It must either be an integer with size <=8 or 12.')
            return
        end
    end  
    
    if local 
        vint = locVar;
    end
    
    % Get the source index (I.e. each page can consist of more sources)
    index         = get(gui.sourceSelect,'value');
    sourceIndex   = gui.linkInfo(index);
    indexOfSource = sum(gui.linkInfo(1:index)==sourceIndex);
       
    % Update the link of the object
    new     = gui.data;
    link    = get(new,'links');
    sources = link.subLinks(sourceIndex).source;
    if iscell(sources)
        oldVint = link.subLinks(sourceIndex).vintage;
        if ~iscell(oldVint)
            oldVint = repmat({oldVint},1,length(sources));
        end
        newVint                = oldVint;
        newVint{indexOfSource} = vint;
        link.subLinks(sourceIndex).vintage = newVint;
    else
        link.subLinks(sourceIndex).vintage = vint;
    end
    new = new.setLinks(link);
    
    try
        new = update(new,'off','on');
    catch Err
        set(gui.fameVintage,'string',oldVint)
        nb_errorWindow('Error while updating the data with the new vintage.', Err)
        return
    end
    
    % Update the data and notify the listeners (i.e. spreadsheetGUI)
    gui.data = new;
    notify(gui,'methodFinished');
    
    % Inform the user
    nb_infoWindow('The change of vintage was successful!')
     
end
