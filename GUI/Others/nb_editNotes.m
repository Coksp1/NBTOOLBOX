function nb_editNotes(obj)
% Syntax:
%
% nb_editNotes(obj)
%
% Description:
%
% Edit the userData property of the the provided input object.
% 
% Input:
% 
% - obj : An object of class nb_graph, nb_graph_adv or 
%         nb_spreadsheetGUI.
% 
% Output:
% 
% - The userData property of the nb_graph or nb_graph_adv object
%   updated or the userData property of the data property of the
%   nb_spreadsheetGUI updated.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the notes from the underlying object storing them
    if isa(obj,'nb_graph_obj') || isa(obj,'nb_graph_adv')
        
        notes = obj.userData;   

    elseif isa(obj,'nb_spreadsheetGUI')
        
        notes = obj.data.userData;
        
    end
    
    % The userData proeprty can be set to anything, so to make
    % things robust
    if ~ischar(notes)
        
        if iscellstr(notes)
            notes = char(notes);
        else
            notes = '';
        end
        
    end
     
    % Create GUI window
    name              = 'Edit Notes';
    currentMonitor    = nb_getCurrentMonitor();
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    f = figure('visible',        'off',...
                  'units',          'characters',...
                  'position',       [40   15  100   40],...
                  'Color',          defaultBackground,...
                  'name',           name,...
                  'numberTitle',    'off',...
                  'dockControls',   'off',...
                  'menuBar',        'None',...
                  'toolBar',        'None',...
                  'tag',            'main');
    nb_moveFigureToMonitor(f,currentMonitor,'center');
    
    space = 0.04;
    
    % Create text above the edit box
    uicontrol('units',              'normalized',...
              'position',           [space, 0.9,1 - space*2,0.05],...
              'parent',             f,...
              'style',              'text',...
              'string',             'Edit Notes',...
              'horizontalAlignment','left');
          
    % Create the edit box
    editBoxBottom = 0.15;
    ed1 = uicontrol('units',              'normalized',...
                    'position',           [space, editBoxBottom,1 - space*2,0.75],...
                    'parent',             f,...
                    'background',         [1 1 1],...
                    'style',              'edit',...
                    'string',             notes,...
                    'max',                100,...
                    'horizontalAlignment','left');
     
    buttonWidth  = 0.2;
    buttonHeight = 0.05;
    buttonXStart = 0.5 - buttonWidth/2;
    buttonYStart = editBoxBottom - space - buttonHeight;
    uicontrol('units',       'normalized',...
              'position',    [buttonXStart, buttonYStart,buttonWidth,buttonHeight],...
              'parent',      f,...
              'style',       'pushbutton',...
              'string',      'Save',...
              'callback',    {@saveNotes,obj,ed1});            
    
    % Make GUI visible           
    set(f,'visible','on');
    
    function saveNotes(~,~,obj,editBox)
    % Save chnages down to the userData property of the underlying
    % object.
    
        newNotes = get(editBox,'string');
        
        if isa(obj,'nb_graph') || isa(obj,'nb_graph_adv')
        
            try
                obj.userData = newNotes; 
            catch
                nb_errorWindow('Graph has been closed. Changes made not saved.')
                delete(get(editBox,'parent'))
                return
            end
            
        elseif isa(obj,'nb_spreadsheetGUI')

            try
                obj.data.userData = newNotes;
            catch
                nb_errorWindow('Spreadsheet has been closed. Changes made not saved.')
                delete(get(editBox,'parent'))
                return
            end
            
        end
        
    end
    
    
end
