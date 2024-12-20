function string = toMFile(obj,filename,varName)
% Syntax:
%
% string = toMFile(obj)
% toMFile(obj,filename)
% string = toMFile(obj,filename,varName)
%
% Description:
%
% Write a .m file to generate the current object.
% 
% Input:
%
% - obj      : An nb_cs object.
% 
% - filename : The filename to write the code to. If empty no file
%              will be written.
%
% - varName  : Name of decleard variable by this code. Default is
%              data.
% 
% Output:
% 
% - string   : A cellstr with the .m code to generate the current
%              object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        varName = '';
        if nargin < 2
            filename = '';
        end
    end
    
    if isempty(varName)
        varName = 'data';
    end

    [pathname,filename,ext] = fileparts(filename);

    if isempty(ext)
        ext = '.m';
    end
    
    if ~strcmpi(ext,'.m')
        error([mfilename ':: Extension must be .m'])
    end
    
    if isempty(filename)
        tempName = 'dataset';
    else
        if isempty(pathname)
            tempName = filename;
        else
            tempName = [pathname,'\',filename];
        end
    end
    
    if isempty(obj)
        string = {[varName ' = nb_cs();']};
    else
    
        % Get the code to initialize the nb_cs object
        %--------------------------------------------
        string = {};
        if isUpdateable(obj)

            % Write code to construct nb_cs objects of all sources
            string = [string;{[varName ' = nb_cs();']}];
            for ii = 1:obj.numberOfDatasets

                subLinks = obj.links(ii).subLinks;
                sources  = {subLinks.source};
                if isempty(sources)

                    % The object has some updateable pages, but this 
                    % page is not.
                    temp  = window(obj,'','',ii);
                    sName = [tempName '_' int2str(ii)];
                    saveDataBase(temp,'ext','mat','saveName',sName);
                    string = [string;{[varName '_' int2str(ii) ' = nb_cs(''' sName '.mat'');']}];

                else

                    for jj = 1:size(subLinks,2)

                        string = writeSubLinkCode(subLinks(jj),string,jj,ii,tempName,varName);
                        string = [string;{''}]; %#ok<*AGROW>

                    end

                end

                % Call all methods called on each source object and merge
                % the source if more
                string = recursiveMethodCalls(string,subLinks,1,ii,varName);
                dName  = [varName '_' int2str(ii)];
                string = [string;{[dName ' = ' dName '_1;']}];

                % Add pages
                string = [string;{''}];
                string = [string;{[varName ' = addPages(' varName ', ' varName '_'  int2str(ii) ');']}];
                string = [string;{''}];

            end

        else

            obj.saveDataBase('ext','mat','saveName',tempName);
            string = [string;{[varName ' = nb_cs(''' tempName '.mat'');']}];

        end
        
    end
    
    % Write the code to a .m file
    %----------------------------
    if ~isempty(filename)
        if isempty(pathname)
            saveName = [filename,ext];
        else
            saveName = [pathname,'\',filename,ext];
        end
        nb_cellstr2file(string,saveName);
    end
        
end

%==================================================================
% SUB
%==================================================================
function string = writeSubLinkCode(subLinks,string,sourceNum,page,tempName,varName)
% Get the code for initializing the sources as objects

    switch lower(subLinks.sourceType)

        case 'xls'
        
            source    = nb_pathCorrect(subLinks.source);
            sheet     = subLinks.sheet;
            range     = subLinks.range;
            if isempty(range)
                range = '{}';
            else
                range = ['{''' range{1} ''',''' range{2} ''',''' range{3} '''}'];
            end
            transpose = int2str(subLinks.transpose);
            string    = [string;{[varName '_' int2str(page) '_' int2str(sourceNum) ' = nb_readExcel(''' source ''',''' sheet ''',' range ',' transpose ');']}];
            
        case 'mat'
            
            source    = nb_pathCorrect(subLinks.source);
            string    = [string;{[varName '_' int2str(page) '_' int2str(sourceNum) ' = nb_cs(''' source ''');']}];
            
        case 'db'
            
            source = subLinks.source;
            if iscell(source)
                
                str = ['dbNames   = {''' nb_pathCorrect(source{1})];
                for ii = 2:length(source)
                    str = [str,''', ''' nb_pathCorrect(source{ii})];
                end
                str = [str,'''};'];
                
            elseif ischar(source)
                
                str = ['dbNames   = ''' nb_pathCorrect(source) ''';'];
                    
            end
            string = [string;{str}];
            
            variables = subLinks.variables;
            if iscell(source)
                
                str = 'objNames  = {';
                for ii = 1:length(variables)
                    
                    tempVar = variables{ii};
                    if ii == 1
                        str = [str,'{''' tempVar{1}];
                    else
                        str = [str,',{''' tempVar{1}];
                    end
                    
                    for ll = 2:length(tempVar)
                        str = [str,''', ''' tempVar{ll}];
                    end
                    str = [str,'''}'];
                    
                end
                str = [str,'};'];
                
            elseif ischar(source)
                
                str = ['objNames  = {''' variables{1}];
                for ii = 2:length(variables)
                    str = [str,''', ''' variables{ii}];
                end
                str = [str,'''};'];
                    
            end
            string = [string;{str}];
            
            startDate = subLinks.startDate;
            if isa(startDate,'nb_date')
                startDate = toString(startDate);
            end
            string = [string;{['startDate = ''' startDate ''';']}];
            
            endDate = subLinks.endDate;
            if isa(endDate,'nb_date')
                endDate = toString(endDate);
            end
            string = [string;{['endDate   = ''' endDate ''';']}];
            
            vintage = subLinks.vintage;
            if isempty(vintage)
                str = 'vintages  = {};';
            else
                
                if iscell(vintage)

                    if ischar(vintage{1})
                        str = ['vintages  = {''' vintage{1}];
                        num = false;
                    elseif isnumeric(vintage{1})
                        str = ['vintages  = {' int2str(vintage{1})];
                        num = true;
                    end
                    
                    for ii = 2:length(vintage)
                        
                        if num && ischar(vintage{ii})
                            str = [str,', ''' vintage{ii}];
                            num = false;
                        elseif ~num && ischar(vintage{ii}) 
                            str = [str,''', ''' vintage{ii}];
                            num = false;
                        elseif num && isnumeric(vintage{ii})
                            str = [str,', ' int2str(vintage{ii})];
                            num = true;
                        else
                            str = [str,''', ' int2str(vintage{ii})];
                            num = true;
                        end
                            
                    end
                    
                    if num
                        str = [str,'};'];
                    else
                        str = [str,'''};'];
                    end

                elseif ischar(vintage)

                    str = ['vintages  = ''' vintage ''';'];
                    
                elseif isnumeric(vintage)
                    
                    str = ['vintages  = ' int2str(vintage) ';'];

                end
                
            end
            string = [string;{str}];
            
            freq   = subLinks.freq;
            string = [string;{['reqFreq   = ''' freq ''';']}];
            
            host   = subLinks.host;
            string = [string;{['host      = ''' host ''';']}];
            
            port   = subLinks.port;
            string = [string;{['port      = ''' port ''';']}];
            
            options = subLinks.options;
            string  = [string;{['options   = ''' options ''';']}];
            
            string  = [string;{[varName '_' int2str(page) '_' int2str(sourceNum) ' = nb_fetchFromFame(dbNames,objNames,startDate,endDate,vintages,reqFreq,host,port,options);']}];
            
        case 'private' % Data without source
            
            source    = subLinks.source;
            variables = subLinks.variables;
            startDate = subLinks.startDate;
            temp      = nb_cs(source,'',startDate,variables);
            sName     = [tempName '_' int2str(page) '_'  int2str(sourceNum)];
            saveDataBase(temp,'ext','mat','saveName',sName);
            string    = [string;{[varName '_' int2str(page) '_' int2str(sourceNum) ' = nb_cs(''' sName '.mat'');']}];
            
        otherwise
            
            error([mfilename ':: Unsupported source type ' subLinks.sourceType])
            
    end
    
end

function [string,sourceNum] = recursiveMethodCalls(string,subLinks,sourceNum,page,varName)
% Write the method call acting on the object (this has to be done
% recursively given that merging of different source can happend
% at any time.)

    subLink     = subLinks(sourceNum);
    operations  = subLink.operations;
    dataObjName = [varName '_' int2str(page) '_' int2str(sourceNum)];
    for dd = 1:size(operations,2)

        methodCall = operations{dd};
        if ischar(methodCall)
            
            % We are now at a point of merging sublinks
            [string,sourceNum] = recursiveMethodCalls(string,subLinks,sourceNum + 1,page,varName);
            
            % Now we merge the sources
            mObjName = [varName '_' int2str(page) '_' int2str(sourceNum)];
            string   = [string;{[dataObjName ' = merge(' dataObjName ',' mObjName ');']}];
            
        else
            
            funcStr = func2str(methodCall{1});
            inputs  = methodCall{2};
            if isempty(inputs)
                string = [string;{[dataObjName ' = ' funcStr '(' dataObjName ');']}];
            else
                    
                % Write the code for the inputs
                inputCode = {}; 
                for ii = 1:length(inputs)

                    inputCodeTemp = nb_any2code(inputs{ii},['input' int2str(ii)]);
                    inputCode     = [inputCode;inputCodeTemp];

                end
                string = [string;inputCode];

                % Write the code for the function call
                str = [dataObjName ' = ' funcStr '(' dataObjName];
                for ii = 1:length(inputs)
                    str = [str,', input' int2str(ii)];
                end
                str = [str,');'];

                string = [string;{str}];

            end
            
        end

    end

end
