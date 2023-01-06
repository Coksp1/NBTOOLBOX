function saveDataBase(obj,varargin) 
% Syntax:
%
% saveDataBase(obj,varargin)
%
% Description:
%
% Save data of the object to (a) file(s)
%
% If no optional input is given, i.e. obj.saveDataBase(). The data 
% of the object is save down to xlsx file(s). Each datset of the 
% object is saved down to a excel spreadsheet with the name of the 
% dataset (Taken from the 'dataNames' property)
%
% Input:
% 
% - obj      : An object of class nb_data
% 
% Optional input (...,'propertyName',propertyValue,...):
% 
% - 'saveName' : A string with the wanted name of the saved file.
% 
% - 'ext'      : > 'xlsx'   : Saves the object down to a excel 
%                             spreadsheet. Default
% 
%                > 'matold' : Saves the data down to a mat file. The 
%                             data is transformed into a structure, 
%                             with the variables as the fieldnames, 
%                             and the data as its fields. If the data 
%                             consist of more pages, each field
%                             will consist of the same number of 
%                             pages. See the toStructure method with input
%                             old set to 1.
% 
%                             Must be combined with the optional 
%                             input 'saveName'.
%
%                > 'mat'    : Saves the data down to a mat file. The 
%                             data is transformed into a structure, 
%                             with the variables stored in the field 
%                             'variables', while the data of the variables 
%                             will be saved as its fields with generic 
%                             names ('Var1','Var2' etc). If the data 
%                             consist of more pages, each field will  
%                             consist of the same number of pages. See the  
%                             toStructure method.
% 
%                             Must be combined with the optional 
%                             input 'saveName'.
% 
%                > 'mats'   : The object is saved down as a struct
%                             using the nb_data.struct function.   
%
%                > 'txt'    : Saves the data down to a txt file.
% 
% - 'append'   : > 1 : Saves all the datasets (pages of the data) 
%                      to one excel spreadsheet, but in seperate 
%                      worksheets. (Where the names of the 
%                      worksheets are given by the dataNames 
%                      property of the object.)
% 
%                      Works only when 'ext' input is set to 
%                      'xlsx'. (The default)
%               
%                 > 0 : The default saving method.
% 
% - 'strip'     : > 'on'  : Strip all observation dates where all 
%                           the variables has no value. (is nan)
% 
%                 > 'off' : Default
% 
%                 Caution : Only an option when saved to excel.
%
% Output:
% 
% The nb_data object saved to the wanted file format.
% 
% Examples:
%                   
% Save the data to excel with the name 'test':
% saveDataBase(obj,'saveName','test');
%
% Save the data to excel with another date format:
% saveDataBase(obj,'saveName','test','dateformat','xls');
%
% Save the data to excel spreadsheet with the datasets as different
% worksheets:
% saveDataBase(obj,'saveName','test','append',1);
%
% Save the data to a .mat with the name 'test':
% obj.savDataBase('ext','mat','saveName','test')
% 
% See also:
% asCell, toStructure, nb_readMat, nb_readExcel
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(obj)
        return
    end

    foundSaveName   =        '';
    foundExt        =    'xlsx'; % Default format
    foundAppend     =         0; % To not append is default when object consist of more the one page
    foundStrip      =     'off'; 
    foundSheets     =        {};
    for ii = 1:2:length(varargin)

        input = lower(varargin{ii});

        switch input

            case 'savename'

                foundSaveName   = varargin{ii+1};
                
            case 'strip'
                
                foundStrip      = varargin{ii+1};

            case 'ext'

                foundExt        = varargin{ii+1};

            case 'append'

                foundAppend     = varargin{ii+1};

            case 'sheets'
                
                foundSheets   = varargin{ii+1};
                if size(foundSheets,2) ~= obj.numberOfDatasets || size(foundSheets,1) ~= 1
                    error([mfilename ':: The ''sheets'' input must be a 1 x ' int2str(obj.numberOfDatasets) ' cellstr.'])
                end
                     
            otherwise

                error([mfilename ':: No optional input ' varargin{ii}])

        end


    end

    if isa(obj.data,'nb_distribution')
        if ~strcmpi(foundExt,'mats')
            error([mfilename ':: It is not possible to save down a object storing distributions to the format ''' foundExt '''.'])
        end
    end
    
    % Suppress warning for adding xls-sheets 
    warning off MATLAB:xlswrite:AddSheet

    switch foundExt

        case 'xlsx'
            
             for ii = 1:obj.numberOfDatasets

                % Make a cell of the objects data, variables and
                % dates
                if strcmpi(foundStrip,'on')
                   
                    d         = obj.data(:,:,ii);
                    ind       = all(isnan(d),2);
                    d         = d(~ind,:);
                    obsOfData = observations(obj,'cell');
                    obsOfData = obsOfData(~ind,1);
                    dataset   = [{'Obs'}, obj.variables; obsOfData, num2cell(d)];
                    
                else
                    
                    obsOfData = observations(obj,'cell');
                    dataset   = [{'Obs'}, obj.variables; obsOfData, num2cell(obj.data(:,:,ii))];
                    
                end
                
                if isempty(foundSaveName)
                    if foundAppend || ~isempty(foundSheets)
                        error([mfilename ':: You must give the ''savename'' when using the ''append'' or ''sheets'' option.'])
                    else
                        % Save each datasets as separate excel 
                        % spreadsheet
                        saveN = obj.dataNames{ii};
                        xlswrite([saveN '.xlsx'], dataset);
                    end
                else
                    if ~isempty(foundSheets)
                        % Save each datasets as separate worksheet of
                        % a excel spreadsheet
                        saveN = foundSaveName;
                        xlswrite([saveN '.xlsx'], dataset, foundSheets{ii});
                    elseif foundAppend
                        % Save each datasets as separate worksheet of
                        % a excel spreadsheet
                        saveN = foundSaveName;
                        xlswrite([saveN '.xlsx'], dataset, obj.dataNames{ii});
                        
                    else
                        % Save each datasets as separate excel 
                        % spreadsheet
                        if obj.numberOfDatasets == 1
                            xlswrite([foundSaveName '.xlsx'], dataset);
                        else
                            saveN = [foundSaveName int2str(ii)];
                            xlswrite([saveN '.xlsx'], dataset);
                        end
                    end
                end

             end
             
             if or(foundAppend,~isempty(foundSheets)) && ~isempty(foundSaveName)
                nb_deleteDefaultWorksheets(foundSaveName)
             end
            
        case 'matold'

            if isempty(foundSaveName)
                error([mfilename ':: When saving down to a .mat file, you must give the property ''saveName'' as input.'])
            else
                s = obj.toStructure(1); %#ok<NASGU>
                d = fileparts(strrep(foundSaveName,'''',''));
                if ~isempty(d)
                    if exist(d,'dir') == 0
                        mkdir(d);
                    end
                end
                save(foundSaveName,'-struct','s')
            end     
             
        case 'mat'

            if isempty(foundSaveName)
                error([mfilename ':: When saving down to a .mat file, you must give the property ''saveName'' as input.'])
            else
                s = obj.toStructure; %#ok<NASGU>
                d = fileparts(strrep(foundSaveName,'''',''));
                if ~isempty(d)
                    if exist(d,'dir') == 0
                        mkdir(d);
                    end
                end
                save(foundSaveName,'-struct','s')
            end

        case 'mats'
            
            if isempty(foundSaveName)
                error([mfilename ':: When saving down to a .mat file, you must give the property ''saveName'' as input.'])
            else
                s = obj.struct(); %#ok<NASGU>
                d = fileparts(strrep(foundSaveName,'''',''));
                if ~isempty(d)
                    if exist(d,'dir') == 0
                        mkdir(d);
                    end
                end
                save(foundSaveName,'-struct','s')
            end    
            
        case 'txt'

            % TAB delimited txt file
            obsOfData = observations(obj,'cellstr');

            for kk = 1:obj.numberOfDatasets 
                if isempty(foundSaveName)

                    dos(['del ' obj.dataNames{kk} '.txt']);
                    writer = fopen([obj.dataNames{kk} '.txt'],'w+');

                else

                    if obj.numberOfDatasets == 1

                        dos(['del ' foundSaveName '.txt']);
                        writer = fopen([foundSaveName '.txt'],'w+');

                    else

                        saveN = [foundSaveName int2str(kk)];
                        dos(['del ' saveN '.txt']);
                        writer = fopen([saveN '.txt'],'w+');
                    end
                end

                % Write the first line ('DATE',variable names)
                fprintf(writer,'OBS\t');

                for ii = 1:obj.numberOfVariables

                    fprintf(writer,['\t' obj.variables{ii} '\t']);

                end

                fprintf(writer,'\r\n');

                for ii = 1:obj.numberOfObservations

                    % write the date
                    fprintf(writer,[obsOfData{ii} '\t']);

                    % write the data of all variables
                    for jj = 1:obj.numberOfVariables

                        if isnan(obj.data(ii,jj,kk))
                            fprintf(writer,'\tND\t');
                        else
                            fprintf(writer,['\t' num2str(obj.data(ii,jj,kk)) '\t']);
                        end

                    end

                    fprintf(writer,'\r\n');

                end

            end

            fclose(writer);
            fclose('all');
            
        otherwise

            error([mfilename ':: format ' foundExt ' unknown'])
    end

end
