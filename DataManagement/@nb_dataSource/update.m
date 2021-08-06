function obj = update(obj,warningOff,inGUI)
% Syntax:
%
% obj = update(obj,warningOff,inGUI)
%
% Description:
%
% This method will try to update the data of the nb_ts object.
%
% Caution : It is only possible to update an nb_dataSource object 
%           which has updateable links to a FAME database or a full
%           directory (path) to an excel spreadsheet or .mat file.
%
% Caution : If you want to create a link to a specific worksheet
%           of a excel file you must provide the extension!
%
% Caution : All method calls done on the object are preserved. 
%           (There exist some exception; and, or etc.)
%
% Input:
% 
% - obj        : An object of class nb_dataSource which are updatable.
%
% - warningOff : 'on' or 'off'. If 'on' only warnings are given while 
%                the data source is updated, else an error will be given.
%                Default is 'on'.
%
% - inGUI      : 'on' or 'off'. Indicate if the update command is called 
%                in the GUI or not. Default is 'off'.
% 
% Output:
% 
% - obj : An object of class nb_dataSource with the data updated. If it is
%         not possible a warning will be given.
%
% Examples:
%
% obj = nb_ts(['N:\Matlab\Utvikling\MATLAB_LIB\NEMO\'...
%             'Documentation\Examples\example_ts_quarterly']);
% obj = obj.update
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        inGUI = 'off';
        if nargin < 2
            warningOff = 'on';
        end
    end
    
    if ~obj.isUpdateable()
        if strcmpi(warningOff,'on')
            warning('nb_dataSource:CouldNotUpdateObject',[mfilename ':: Non of the data of the object is updateable'])
        end
        return;
    end
        
    % Get properties nedded for doing the update
    locVars = obj.localVariables;
    sorted  = obj.sorted;
    links   = obj.links;
    
    % Do the updating
    new = doUpdate(obj,links,warningOff,inGUI,locVars,sorted);
    
    % Assign output
    new.isBeingUpdated = 0;
    new.userData       = obj.userData;
    obj                = new;
      
end

%==================================================================
% Sub
%==================================================================
function new = doUpdate(obj,links,warningOff,inGUI,locVars,sorted)

    subLinks = links.subLinks;
    link     = subLinks(1);
    source   = link.source;
    if isempty(source)
        new = obj;
    else
        % Update all link of one dataset of the object
        new = recursiveUpdate(class(obj),subLinks,1,warningOff,inGUI,locVars,sorted);
    end

end

%==========================================================================
function [merged,index] = recursiveUpdate(cl,subLinks,index,warningOff,inGUI,locVars,sorted)

    subLink   = subLinks(index);
    source    = subLink.source;
    if ischar(source)
        sourceErr = nb_pathCorrect(source);
    end
    
    classFunc = str2func(cl);
    temp      = classFunc();
    isnb_cell = false;
    switch lower(subLink.sourceType)

        case 'xls'

            sheet     = subLink.sheet;
            range     = subLink.range;
            transpose = subLink.transpose;
            try
                
                % We must use the function readExcel because
                % a time-series object can be read with a specific
                % range of an excel spreadsheet
                if strcmpi(cl,'nb_cell')
                    [temp,isnb_cell] = readCellOrWhat(subLinks,source,sheet,range,transpose,sorted);
                else
                    temp = nb_readExcel(source,sheet,range,transpose,sorted);
                end
                
            catch Err
                
                % Due to differences in path names of INT,FST and PPO we
                % have to check something here
                %----------------------------------------------------------
                if strncmpi('F:\PPO',source,6) && exist(source,'file') ~= 2
                    
                    sourceT = strrep(source,'F:\PPO\','N:\');
                    try
                        if strcmpi(cl,'nb_cell')
                            [temp,isnb_cell] = readCellOrWhat(subLinks,sourceT,sheet,range,transpose,sorted);
                        else
                            temp = nb_readExcel(sourceT,sheet,range,transpose,sorted);
                        end
                    catch %#ok<CTCH>
                        xlError(warningOff,sourceErr,sheet,range,Err)
                    end
                    
                elseif strncmpi('N:\',source,3) && exist(source,'file') ~= 2
                    
                    sourceT = strrep(source,'N:\','F:\PPO\');
                    try
                        if strcmpi(cl,'nb_cell')
                            [temp,isnb_cell] = readCellOrWhat(subLinks,sourceT,sheet,range,transpose,sorted);
                        else
                            temp = nb_readExcel(sourceT,sheet,range,transpose,sorted);
                        end
                    catch %#ok<CTCH>
                        xlError(warningOff,sourceErr,sheet,range,Err)
                    end
                    
                else
                    xlError(warningOff,sourceErr,sheet,range,Err)
                end
                
            end
            
        case 'xlsmp'
            
            try
                temp = nb_readExcelMorePages(source,sorted,subLink.sheet);
            catch Err
                
                % Due to differences in path names of INT,FST and PPO we
                % have to check something here
                %----------------------------------------------------------
                if strncmpi('F:\PPO',source,6) && exist(source,'file') ~= 2
                    
                    sourceT = strrep(source,'F:\PPO\','N:\');
                    try
                        temp = nb_readExcelMorePages(sourceT,sorted,subLink.sheet);
                    catch %#ok<CTCH>
                        xlError(warningOff,sourceErr,subLink.sheet,'',Err)
                    end
                    
                elseif strncmpi('N:\',source,3) && exist(source,'file') ~= 2
                    
                    sourceT = strrep(source,'N:\','F:\PPO\');
                    try
                        temp = nb_readExcelMorePages(sourceT,sorted,subLink.sheet);
                    catch %#ok<CTCH>
                        xlError(warningOff,sourceErr,subLink.sheet,'',Err)
                    end
                    
                else
                    xlError(warningOff,sourceErr,subLink.sheet,'',Err)
                end
                
            end
            
        case 'mat'
            
            temp = nb_readMat(source,sorted);

        case 'db'

            vars      = subLink.variables;
            startDate = subLink.startDate;
            endDate   = subLink.endDate;
            vintage   = subLink.vintage;
            freq      = subLink.freq;
            host      = subLink.host;
            port      = subLink.port;
            options   = subLink.options;
            
            % Check the vintage for local variable notation
            local = 0;
            if ischar(vintage)
                local = nb_contains(vintage,'%#');
                if local
                    locVint = vintage;
                    vintage = nb_localVariables(locVars,vintage);
                end
            elseif iscell(vintage)
                locVint = vintage;
                local   = 0;
                for ii = 1:length(vintage)
                    vin = vintage{ii};
                    if ischar(vin)
                        local = nb_contains(vin,'%#');
                        if local
                            vintage{ii} = nb_localVariables(locVars,vin);
                        end
                    end
                end 
            end
             
            oilprice = false;
            if iscell(options) && ~isempty(options)
                if strcmpi(options{1},'oilprice')
                    oilprice = true;
                end
            end
                
            if oilprice
            
                try
                    temp = oilpricetermin(freq,vars{1},options{2},source,options{3});
                catch Error

                    if strcmpi(warningOff,'on')
                        func_handle = @warning;
                    else
                        func_handle = @error;
                    end                    
                    func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                        '(Do you have access to the FAME database you are fetching from, or is it deleted?) '...
                        'Returns the object with the same data. ' Error.message])

                end
                
            else
                
                try
                    temp = nb_fetchFromFame(source,vars,startDate,endDate,vintage,freq,host,port,options,sorted);
                catch Error

                    if strcmpi(warningOff,'on')
                        func_handle = @warning;
                    else
                        func_handle = @error;
                    end

                    if strcmpi(inGUI,'on')

                        if ~isempty(Error.message)
                            func_handle(['There was an error while checking the variable names: ' Error.message]);
                        else
                            func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                                '(Do you have access to the FAME database you are fetching from, or is it deleted? Or does it need MACM functionalities.) '...
                                'Returns the object with the same data. ' Error.message])

                        end

                    else
                        func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                                '(Do you have access to the FAME database you are fetching from, or is it deleted? Or does it need MACM functionalities.) '...
                                'Returns the object with the same data. ' Error.message])
                    end

                end
                
            end
            
            if local
                link                  = get(temp,'links');
                link.subLinks.vintage = locVint;
                temp                  = temp.setLinks(link);
            end
            
        case {'realdb','releasedb'}

            vars      = subLink.variables;
            startDate = subLink.startDate;
            endDate   = subLink.endDate;
            last      = subLink.vintage;
            host      = subLink.host;
            port      = subLink.port;
            options   = subLink.options;
            
            % Check the vintage for local variable notation
            local = 0;
            if ischar(last)
                local = nb_contains(last,'%#');
                if local
                    locVint = last;
                    last = nb_localVariables(locVars,last);
                end
            elseif iscell(last)
                locVint = last;
                local   = 0;
                for ii = 1:length(last)
                    vin = last{ii};
                    if ischar(vin)
                        local = nb_contains(vin,'%#');
                        if local
                            last{ii} = nb_localVariables(locVars,vin);
                        end
                    end
                end 
            end
            
            try
                temp = nb_fetchRealTimeFromFame(source,vars,startDate,endDate,host,port,sorted,options,last);
            catch Error
                
                if strcmpi(warningOff,'on')
                    func_handle = @warning;
                else
                    func_handle = @error;
                end
                    
                if strcmpi(inGUI,'on')

                    if ~isempty(Error.message)
                        func_handle(['There was an error while checking the variable names: ' Error.message]);
                    else
                        func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                            '(Do you have access to the FAME database you are fetching from, or is it deleted? Or does it need MACM functionalities.) '...
                            'Returns the object with the same data. ' Error.message])

                    end

                else
                    func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                            '(Do you have access to the FAME database you are fetching from, or is it deleted? Or does it need MACM functionalities.) '...
                            'Returns the object with the same data. ' Error.message])
                end
                     
            end
            
            if local
                link                  = get(temp,'links');
                link.subLinks.vintage = locVint;
                temp                  = temp.setLinks(link);
            end    
            
        case {'nbrealdb','nbreleasedb'} 
            
            vars      = subLink.variables;
            startDate = subLink.startDate;
            endDate   = subLink.endDate;
            startVint = subLink.vintage;
            options   = subLink.options;
            
            % Check the vintage for local variable notation
            local = 0;
            if ischar(startVint)
                local = nb_contains(startVint,'%#');
                if local
                    locVint   = startVint;
                    startVint = nb_localVariables(locVars,startVint);
                end
            end
            
            if strcmpi(options,'oilprice')
                try
                    temp = nb_realTimeOilPrice(startVint,vars{1},startDate,endDate,source);
                catch Error

                    if strcmpi(warningOff,'on')
                        func_handle = @warning;
                    else
                        func_handle = @error;
                    end                    
                    func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                        '(Do you have access to the FAME database you are fetching from, or is it deleted?) '...
                        'Returns the object with the same data. ' Error.message])

                end  
            else
                try
                    temp = nb_fetchRealTime(source,vars,startVint,sorted,startDate,endDate);
                catch Error

                    if strcmpi(warningOff,'on')
                        func_handle = @warning;
                    else
                        func_handle = @error;
                    end                    
                    func_handle('nb_dataSource:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                        '(Do you have access to the FAME database you are fetching from, or is it deleted?) '...
                        'Returns the object with the same data. ' Error.message])

                end
            end
            
            if local
                link                  = get(temp,'links');
                link.subLinks.vintage = locVint;
                temp                  = temp.setLinks(link);
            end 
            
        case 'private(nb_cs)'
            
            vars                   = subLink.variables;
            types                  = subLink.types;
            temp                   = nb_cs(source,'',types,vars,sorted);
            tempSubLink            = nb_createDefaultLink;
            tempSubLink.source     = temp.data;
            tempSubLink.sourceType = 'private(nb_cs)';
            tempSubLink.variables  = subLink.variables;
            tempSubLink.types      = subLink.types;
            tempLinks.subLinks     = tempSubLink;
            temp.links             = tempLinks;
            temp.updateable        = 1;
            
        case {'private(nb_ts)','private'}
            
            temp                   = nb_ts(source,'',subLink.startDate,subLink.variables,sorted);
            tempSubLink            = nb_createDefaultLink;
            tempSubLink.source     = temp.data;
            tempSubLink.sourceType = 'private(nb_ts)';
            tempSubLink.variables  = subLink.variables;
            tempSubLink.startDate  = subLink.startDate;
            tempLinks.subLinks     = tempSubLink;
            temp.links             = tempLinks;
            temp.updateable        = 1;
            
        case 'private(nb_data)'
            
            temp                   = nb_data(source,'',subLink.startDate,subLink.variables,sorted);    
            tempSubLink            = nb_createDefaultLink;
            tempSubLink.source     = temp.data;
            tempSubLink.sourceType = 'private(nb_data)';
            tempSubLink.variables  = subLink.variables;
            tempSubLink.startDate  = subLink.startDate;
            tempLinks.subLinks     = tempSubLink;
            temp.links             = tempLinks;
            temp.updateable        = 1;
            
        case 'private(nb_cell)'
            
            temp                   = nb_cell(source,'');    
            tempSubLink            = nb_createDefaultLink;
            tempSubLink.source     = temp.cdata;
            tempSubLink.sourceType = 'private(nb_data)';
            tempLinks.subLinks     = tempSubLink;
            temp.links             = tempLinks;
            temp.updateable        = 1;
            
        otherwise

            try
                temp = classFunc(source,'','',{},sorted);
            catch %#ok<CTCH>
                
                if strcmpi(warningOff,'on')
                    warning('nb_ts:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                            '(Do you have access to the file path ''' sourceErr ''', or is it deleted?). Did not update the '...
                            'variables from this source!'])
                else
                    error('nb_ts:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                            '(Do you have access to the file path ''' sourceErr ''', or is it deleted?). Did not update the '...
                            'variables from this source!'])
                end
                
            end

    end
    
    % Store latest data per source,
    % so we may break the link later if necessary
    if isnb_cell
        temp.links.subLinks.data = temp.cdata;
    else
        temp.links.subLinks.data = temp.data;
    end
    
    % Add local variables
    temp.localVariables = locVars;
    temp.sorted         = sorted;
    
    % Do the operations done to the object after reading 
    % the data source
    operations   = subLink.operations;
    [temp,index] = doOperations(temp,operations,cl,subLinks,index,warningOff,inGUI,locVars,sorted);
    merged       = temp;

end

%==========================================================================
function [temp,index] = doOperations(temp,operations,cl,subLinks,index,warningOff,inGUI,locVars,sorted)

    
    for dd = 1:size(operations,2)

        methodCall = operations{dd};
        if strcmpi(methodCall{1},'merge') || strcmpi(methodCall{1},'mergeappend') 
            
            % We are now at a point of mergeing sublinks
            [tempR,index] = recursiveUpdate(cl,subLinks,index + 1,warningOff,inGUI,locVars,sorted);
            
            % Now we merge the updated link from source jj - 1 and jj
            if ~isempty(tempR)
                temp.isBeingUpdated   = 1;
                tempR.isBeingUpdated  = 1;
                inputs                = methodCall{2};
                temp                  = merge(temp,tempR,inputs{:});
            end
            
        else
            
            funcH  = methodCall{1};
            inputs = methodCall{2};
            if isempty(inputs)
                temp = feval(funcH,temp);
            else

                logi = isa(inputs{1},'nb_dataSource');
                if logi
                    aObj = inputs{1};
                    if aObj.isUpdateable()
                        % Update the object which is an 
                        % input to a method call
                        aObj = update(aObj);
                    end
                    otherInputs = inputs(2:end);
                    temp        = feval(funcH,temp,aObj,otherInputs{:});
                else
                    temp = feval(funcH,temp,inputs{:});
                end

            end
            
        end

    end 

end

%==========================================================================
function [temp,isnb_cell] = readCellOrWhat(subLinks,source,sheet,range,transpose,sorted)

    op        = subLinks.operations;
    readExcel = false;
    for ii = 1:length(op)
        func = op{ii}{1};
        if ~ischar(func)
            func = func2str(func);
        end
        if strcmpi(func,'tonb_cell')
            readExcel = true;
            break
        end
    end
    if readExcel
        temp = nb_readExcel(source,sheet,range,transpose,sorted);
    else
        temp = nb_cell(source,sheet);
    end
    isnb_cell = ~readExcel;

end

%==========================================================================
function xlError(warningOff,sourceErr,sheet,range,Err)

    if isempty(range)

        if strcmpi(warningOff,'on')
            warning('nb_ts:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                    '(Do you have access to the file path ''' sourceErr ''', or is(are) the sheet(s) ' toString(sheet) ' deleted?). Did not update the '...
                    'variables from this source!'])
        else
            nb_error([mfilename ':: The data of the object couldn''t be updated. '...
                    '(Do you have access to the file path ''' sourceErr ''' or ' char(10)...
                    'is(are) the sheet(s) ' toString(sheet) ' deleted?)'],Err)
        end

    else

        if strcmpi(warningOff,'on')
            warning('nb_ts:CouldNotUpdateObject',[mfilename ':: The data of the object couldn''t be updated. '...
                    '(Do you have access to the file path ''' sourceErr ''', is(are) the sheet(s) ''' toString(sheet) ''' deleted, or is the range not valid anymore?). '...
                    'Did not update the variables from this source!'])
        else
            nb_error([mfilename ':: The data of the object couldn''t be updated. '...
                    '(Do you have access to the file path ''' sourceErr ''', ' char(10)...
                    'is(are) the sheet(s) ' toString(sheet) ' deleted,' char(10)...
                    ' or is the range not valid anymore?).'],Err)
        end

    end
    
end
