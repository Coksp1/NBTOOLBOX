function addContextMenu(gui) 
% Syntax:
%
% addContextMenu(gui)
%
% Description:
%
% Part of DAG. Add context menu to table
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')

        % Add context menu so the user is able to create random 
        % data or paste from clipboard
        cMenu = uicontextmenu('parent',gui.figureHandle);
            uimenu(cMenu,'Label','Paste','Callback',{@gui.paste,'locally'});
            uimenu(cMenu,'Label','Paste from Clipboard (.)','Callback',{@gui.paste,'.'});
            uimenu(cMenu,'Label','Paste from Clipboard (,)','Callback',{@gui.paste,','});
            uimenu(cMenu,'Label','Paste from Sarepta','Callback',{@gui.paste,'sarepta'});
            %uimenu(cMenu,'Label','Show information bar','Callback',{@gui.hidePageBox,'show'},'visible','off');
            rMenu = uimenu(cMenu,'Label','Generate','Callback','');
                uimenu(rMenu,'Label','Time-Series','Callback',{@gui.rand,'nb_ts'});
                uimenu(rMenu,'Label','Cross-Section','Callback',{@gui.rand,'nb_cs'});
                uimenu(rMenu,'Label','Data','Callback',{@gui.rand,'nb_data'});
                uimenu(rMenu,'Label','Cell Object','Callback',{@gui.rand,'nb_cell'});
        set(gui.table,'UIContextMenu',cMenu);
        return
        
    end

    if gui.editMode == 1

        % In edit mode there is not possible to select multiple
        % cells, so the copy options are removed
        set(gui.table,'UIContextMenu','');

    else

        if isa(gui.data,'nb_modelDataSource') || isempty(gui.data)
            isDist = false;
        else
            isDist = isDistribution(gui.data);
        end
        
        if isDist
        
            if and(strcmp(gui.tableType,'Freeze') || strcmp(gui.tableType,'Unfreeze'),isa(gui,'nb_spreadsheetAdvGUI'))
                cMenu = uicontextmenu('parent',gui.figureHandle);
            else
                cMenu = '';
            end
            
        else
            
            if strcmp(gui.tableType,'Freeze') 

                cMenu = uicontextmenu('parent',gui.figureHandle);
                    uimenu(cMenu,'Label','Copy','Callback',@gui.copySelectedLocally);
                    uimenu(cMenu,'Label','Copy to Clipboard','Callback',@gui.copySelected);
                    uimenu(cMenu,'Label','Copy to Clipboard (with)','Callback',@gui.copySelectedWith);
                    uimenu(cMenu,'Label','Copy to Clipboard (table)','Callback',@gui.copyTable);
                    uimenu(cMenu,'Label','Average','separator','on','Callback',{@gui.momentCallback,'mean'});
                    uimenu(cMenu,'Label','Sum','Callback',{@gui.momentCallback,'sum'});
                    uimenu(cMenu,'Label','Standard deviation','Callback',{@gui.momentCallback,'std'});
                    uimenu(cMenu,'Label','Variance','Callback',{@gui.momentCallback,'var'});
                    uimenu(cMenu,'Label','Minimum','Callback',{@gui.momentCallback,'min'});
                    uimenu(cMenu,'Label','Maximum','Callback',{@gui.momentCallback,'max'});
                    %uimenu(cMenu,'Label','Show information bar','Callback',{@gui.hidePageBox,'show'},'visible','off');

            elseif strcmp(gui.tableType,'Unfreeze')

                cMenu = uicontextmenu('parent',gui.figureHandle);
                    %uimenu(cMenu,'Label','Copy','Callback',@gui.copySelectedLocally);
                    uimenu(cMenu,'Label','Copy to Clipboard','Callback',@gui.copySelected);
                    uimenu(cMenu,'Label','Copy to Clipboard (table)','Callback',@gui.copyTable);
                    %uimenu(cMenu,'Label','Show information bar','Callback',{@gui.hidePageBox,'show'},'visible','off');

            else
                cMenu = '';
            end
            
        end
        set(gui.table,'UIContextMenu',cMenu);

        if isa(gui,'nb_spreadsheetAdvGUI')

            if strcmp(gui.tableType,'Freeze') 
                uimenu(cMenu,'Label','Graph','separator','on','Callback',@gui.graph); 
                uimenu(cMenu,'Label','Graph Selected','Callback',@gui.graphSelected);  
                %uimenu(cMenu,'Label','Show information bar','Callback',{@gui.hidePageBox,'show'},'visible','off');
            else
                if ~isa(gui.data,'nb_cell')
                    uimenu(cMenu,'Label','Graph','separator','on','Callback',@gui.graph); 
                    %uimenu(cMenu,'Label','Show information bar','Callback',{@gui.hidePageBox,'show'},'visible','off');
                end
            end

        end

    end

end
