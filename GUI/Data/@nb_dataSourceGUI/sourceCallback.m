function sourceCallback(gui,~,~)
% Syntax:
%
% sourceCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Callback for the source listbox. Checks the sourcetype of the selection 
% and updates the data/panel accordingly.
%
% Written by Eyo I. Herstad and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(gui.data,'nb_modelDataSource')
        
        variableList      = gui.data.variables;
        dataObj           = fetch(gui.data);
        vintageList       = dataObj.dataNames;
        gui.currentSource = 'smart';
        
    else

        % Check source, and pick correct panel based on selection
        sourceLinks       = get(gui.data,'links');
        index             = get(gui.sourceSelect,'value');
        sourceIndex       = gui.linkInfo(index);
        gui.currentSource = sourceLinks.subLinks(sourceIndex).sourceType;
        indexOfSource     = sum(gui.linkInfo(1:index)==sourceIndex);

        % Get new values
        variableList    = sourceLinks.subLinks(sourceIndex).variables;
        if ~iscellstr(variableList)
            variableList = variableList{indexOfSource};
        end
        typeList  = sourceLinks.subLinks(sourceIndex).types;
        startDate = sourceLinks.subLinks(sourceIndex).startDate;
        if isa(startDate,'nb_date')
            startDate = toString(startDate);
        elseif isnumeric(startDate)
            startDate = int2str(startDate);
        end
        endDate = sourceLinks.subLinks(sourceIndex).endDate;
        if isa(endDate,'nb_date')
            endDate = toString(endDate);
        elseif isnumeric(endDate)
            endDate = int2str(endDate);    
        end
        frequency = sourceLinks.subLinks(sourceIndex).freq;
        vintage   = sourceLinks.subLinks(sourceIndex).vintage;
        if isempty(vintage)
            vintage = '';
        else
            if iscellstr(vintage) || iscell(vintage)
                try
                    vintage = vintage{indexOfSource};
                catch %#ok<CTCH>
                    vintage = vintage{1};
                end
                if ~ischar(vintage)
                    vintage = num2str(vintage);
                end
            end
        end
        host      = sourceLinks.subLinks(sourceIndex).host;
        port      = sourceLinks.subLinks(sourceIndex).port;
        sheet     = sourceLinks.subLinks(sourceIndex).sheet;
        transpose = sourceLinks.subLinks(sourceIndex).transpose;
        if ~isempty(sourceLinks.subLinks(sourceIndex).range)
           range       = {sourceLinks.subLinks(sourceIndex).range};
        else
           range       = '';
        end
        source = gui.sourceLinks.subLinks(sourceIndex).source;
        if iscell(source)
            source = source{indexOfSource};
        end
        
    end
    
    % Change the GUI
    switch lower(gui.currentSource) 
        case 'smart'
             
            % Update info
            set(gui.smartVar,'string',variableList);
            set(gui.smartVint,'string',vintage);
            set(gui.smartFreq,'string',frequency);
            
            % Change Panel
            set(gui.nb_tsPanel,'visible','off');
            set(gui.famePanel,'visible','off');
            set(gui.nb_csPanel,'visible','off');
            set(gui.nb_dataPanel,'visible','off');
            set(gui.smartPanel,'visible','on');
            
        case 'xls'
            
            if isa(gui.data,'nb_ts')
                
                % Change values to the new ones
                set(gui.tsSource,'string',source);
                set(gui.tsVar,'string',variableList);
                set(gui.tsStDate,'string',startDate);
                set(gui.tsEndDate,'string',endDate);
                set(gui.tsSheet,'string',sheet);
                set(gui.tsRange,'string',range);
                set(gui.tsTranspose,'value',transpose);
                
                % Turn on relevant buttons
                set(gui.tsSource,'visible','on');
                set(gui.tsTranspose,'visible','on');
                set(gui.tsTransposeText,'visible','on');
                set(gui.tsRange,'visible','on');
                set(gui.tsRangeText,'visible','on');
                set(gui.tsSheet,'visible','on');
                set(gui.tsSheetText,'visible','on');
                
                % Change panel
                set(gui.nb_tsPanel,'visible','on');
                set(gui.famePanel,'visible','off');
                set(gui.nb_csPanel,'visible','off');
                set(gui.nb_dataPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            elseif isa(gui.data,'nb_data')
                
                % Change values to the new ones
                set(gui.dataSource,'string',source);
                set(gui.dataVar,'string',variableList);
                set(gui.dataStDate,'string',startDate);
                set(gui.dataEndDate,'string',endDate);
                set(gui.dataSheet,'string',sheet);
                set(gui.dataRange,'string',range);
                set(gui.dataTranspose,'value',transpose);
                
                % Turn on relevant buttons
                set(gui.dataSource,'visible','on');
                set(gui.dataTranspose,'visible','on');
                set(gui.dataTransposeText,'visible','on');
                set(gui.dataRange,'visible','on');
                set(gui.dataRangeText,'visible','on');
                set(gui.dataSheet,'visible','on');
                set(gui.dataSheetText,'visible','on');
                
                % Change panel
                set(gui.nb_dataPanel,'visible','on');
                set(gui.famePanel,'visible','off');
                set(gui.nb_csPanel,'visible','off');
                set(gui.nb_tsPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            elseif isa(gui.data,'nb_cs')
               
                % Change values to the new ones
                set(gui.csSource,'string',source);
                set(gui.csVar,'string',variableList);
                set(gui.csType,'string',typeList);
                set(gui.csSheet,'string',sheet);
                set(gui.csRange,'string',range);
                set(gui.csTranspose,'value',transpose);
                
                % Turn on relevant buttons
                set(gui.csSource,'visible','on');
                set(gui.csTranspose,'visible','on');
                set(gui.csTransposeText,'visible','on');
                set(gui.csRange,'visible','on');
                set(gui.csRangeText,'visible','on');
                set(gui.csSheet,'visible','on');
                set(gui.csSheetText,'visible','on');
                
                % Change Panel
                set(gui.nb_csPanel,'visible','on');
                set(gui.famePanel,'visible','off');
                set(gui.nb_tsPanel,'visible','off');
                set(gui.nb_dataPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            else
                
                % Change values to the new ones
                set(gui.csSource,'string',source);
                
                % Turn on relevant buttons
                set(gui.csSource,'visible','on');
                set(gui.csTranspose,'visible','on');
                set(gui.csTransposeText,'visible','on');
                set(gui.csRange,'visible','on');
                set(gui.csRangeText,'visible','on');
                set(gui.csSheet,'visible','on');
                set(gui.csSheetText,'visible','on');
                
                set(gui.nb_csPanel,'visible','on');
                set(gui.famePanel,'visible','off');
                set(gui.nb_tsPanel,'visible','off');
                set(gui.nb_dataPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            end
            
        case {'mat','private(nb_ts)','private','private(nb_cs)','private(nb_data)','private(nb_cell)'}
            
            if isa(gui.data,'nb_ts')
                
                % Change values to the new ones
                set(gui.tsSource,'string','');
                set(gui.tsVar,'string',variableList);
                set(gui.tsStDate,'string',startDate);
                set(gui.tsEndDate,'string',endDate);
                
                % Turn off irrelevant buttons
                set(gui.tsSource,'visible','off');
                set(gui.tsTranspose,'visible','off');
                set(gui.tsTransposeText,'visible','off');
                set(gui.tsRange,'visible','off');
                set(gui.tsRangeText,'visible','off');
                set(gui.tsSheet,'visible','off');
                set(gui.tsSheetText,'visible','off');
                
                % Change Panel
                set(gui.nb_tsPanel,'visible','on'); 
                set(gui.famePanel,'visible','off');
                set(gui.nb_csPanel,'visible','off');
                set(gui.nb_dataPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            elseif isa(gui.data,'nb_data')
                
                % Change values to the new ones
                set(gui.dataVar,'string',variableList);
                set(gui.dataStDate,'string',startDate);
                set(gui.dataEndDate,'string',endDate);
                
                % Turn off irrelevant buttons
                set(gui.dataSource,'visible','off');
                set(gui.dataTranspose,'visible','off');
                set(gui.dataTransposeText,'visible','off');
                set(gui.dataRange,'visible','off');
                set(gui.dataRangeText,'visible','off');
                set(gui.dataSheet,'visible','off');
                set(gui.dataSheetText,'visible','off');
                
                % Change Panel
                set(gui.nb_dataPanel,'visible','on');
                set(gui.nb_tsPanel,'visible','off'); 
                set(gui.famePanel,'visible','off');
                set(gui.nb_csPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            elseif isa(gui.data,'nb_cs')
                
                % Change Values to the new ones
                set(gui.csVar,'string',variableList);
                set(gui.csType,'string',typeList);
                
                % Turn off irrelevant buttons
                set(gui.csSource,'visible','off');
                set(gui.csTranspose,'visible','off');
                set(gui.csTransposeText,'visible','off');
                set(gui.csRange,'visible','off');
                set(gui.csRangeText,'visible','off');
                set(gui.csSheet,'visible','off');
                set(gui.csSheetText,'visible','off');
                
                % Change Panel
                set(gui.nb_csPanel,'visible','on');
                set(gui.famePanel,'visible','off');
                set(gui.nb_tsPanel,'visible','off');
                set(gui.nb_dataPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            else
                
                set(gui.nb_csPanel,'visible','off');
                set(gui.famePanel,'visible','off');
                set(gui.nb_tsPanel,'visible','off');
                set(gui.nb_dataPanel,'visible','off');
                set(gui.smartPanel,'visible','off');
                
            end
            
        case 'db'
            
            % Change values to the new ones
            set(gui.fameSource,'string',source);
            set(gui.fameVar,'string',variableList);
            set(gui.fameStDate,'string',startDate);
            set(gui.fameEndDate,'string',endDate);
            set(gui.fameFreq,'string',frequency);
            set(gui.fameVintage,'string',vintage);
            set(gui.fameHost,'string',host);
            set(gui.famePort,'string',port);
            
            
            % Change Panel
            set(gui.famePanel,'visible','on');
            set(gui.nb_tsPanel,'visible','off');
            set(gui.nb_csPanel,'visible','off');
            set(gui.nb_dataPanel,'visible','off');
            set(gui.smartPanel,'visible','off');
            
    end

end

