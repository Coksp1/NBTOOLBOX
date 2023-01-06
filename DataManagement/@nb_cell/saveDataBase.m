function saveDataBase(obj,varargin)
% Syntax:
%
% saveDataBase(obj,varargin)
%
% Description:
%
% Save data of the nb_cell object
% 
% If no optional input is given the data of the object is save 
% down to xlsx file(s). Each datset of the object is saved down to 
% a excel spreadsheet with the name of the dataset (Taken from the  
% dataNames property of the object)
%
% Input:
% 
% - obj      : An object of class nb_cell
% 
% Optional input (...'propertyName',propertyValue,...):
% 
% - varargin : 
% 
%   > 'saveName' : The data is saved to a excel worksheet with the 
%                  same name as the input after 'saveName'. If  
%                  consisting of more dataset, each page of the 
%                  data property is saved with the same name as the  
%                  input after 'saveName' pluss the page number. 
% 
%   > 'ext'      : 
%
%         > 'xlsx'   : Default. Save data to excel spreadsheet(s)
% 
%         > 'matold' : Save the data down to a mat file. The data is
%                      saved down as a structure, with the variables 
%                      as the fieldnames, and the data as its fields. 
%                      If the data consist of more pages, each field 
%                      will consist of the same number of pages.
% 
%                      The types of the object is also added to the
%                      field 'types' of the saved structure. Which 
%                      makes it possible to load the .mat field up 
%                      again to nb_cs object.
% 
%                      See the toStructure method with input old set to 1.
%
%                      Must be combined with the optional input 
%                      'saveName'.
%
%         > 'mat'    : Save the data down to a mat file. The data is
%                      saved down as a structure, with the variables stored
%                      in the field 'variables', while the data of the  
%                      variables will be saved as its fields with generic 
%                      names ('Var1','Var2' etc). If the data consist
%                      of more pages, each field will consist of the same
%                      number of pages.
% 
%                      The types of the object is also added to the
%                      field 'types' of the saved structure. Which 
%                      makes it possible to load the .mat field up 
%                      again to nb_cs object.
% 
%                      See the toStructure method with input old set to 1.
%
%                      Must be combined with the optional input 
%                      'saveName'.
%
%         > 'mats'   : The object is saved down as a struct using 
%                      the nb_cell.struct function.   
%
%         > 'txt' : Save the data to .txt file.
% 
%   > 'append'  :
%         
%         > 1 : Saves all the datasets (pages of the data) to one
%               excel spreadsheet, but in seperate worksheets. 
%               (With the names of the dataset, given by dataNames 
%               property of the object.)
% 
%               Works only when 'ext' input is set as 'xlsx'. (The 
%               default)
% 
%               Caution : If saved in this way, it is not possible
%                         to load it up again to a nb_cs object
% 
%         > 0 : The default saving method.
%
%   > 'sheets' : A cellstr with the sheet names to save the datasets/pages
%                of the object down to. Must match the dataNames property.
%                This option has precedence over 'append'. 
% 
% Output:
% 
% Saved output in the wanted format.
% 
% See also:
% asCell, toStructure, nb_readMat, nb_readExcel
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    foundSaveName =     '';
    foundExt      = 'xlsx'; % Default format
    foundAppend   =      0; % To not append is default when object consist of more the one page
    foundSheets   =      {};
    for ii = 1:2:length(varargin)

        input = lower(varargin{ii});

        switch input

            case 'savename'

                foundSaveName = varargin{ii+1};

            case 'ext'

                foundExt      = varargin{ii+1};

            case 'append'

                foundAppend   = varargin{ii+1};

            case 'sheets'
                
                foundSheets   = varargin{ii+1};
                if size(foundSheets,2) ~= obj.numberOfDatasets || size(foundSheets,1) ~= 1
                    error([mfilename ':: The ''sheets'' input must be a 1 x ' int2str(obj.numberOfDatasets) ' cellstr.'])
                end
                
            case {'strip','dateformat'}

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
                dataset = obj.cdata(:,:,ii);
                if isempty(foundSaveName)
                    if foundAppend || ~isempty(foundSheets)
                        error([mfilename ':: You must give the ''savename'' when using the ''append'' or ''sheets'' option.'])
                    else
                        % Save each datasets as separate excel
                        % worksheets
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
                        % worksheet
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
                 
        case 'mat'
            
            if isempty(foundSaveName)
                error([mfilename ':: When saving down to mat fil, you must give the property ''saveName'' as input.'])
            else
                s = obj.toStructure; %#ok<NASGU>
                d = fileparts(strrep(foundSaveName,'''',''));
                if ~isempty(d)
                    if exist(d,'dir') == 0
                        mkdir(d);
                    end
                end
                eval(['save ',foundSaveName,' -struct s'])
            end
            
        case 'txt'
            
            % TAB delimited txt file
            cData = obj.cdata;
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
                
                for ii = 1:size(cData,1)
                    
                    for jj = 1:size(cData,2)
                        
                        if isnumeric(cData(ii,jj,kk))
                            fprintf(writer,['\t' cData(ii,jj,kk) '\t']);
                        else
                            if isnan(cData(ii,jj,kk))
                                fprintf(writer,'\tND\t');
                            else
                                fprintf(writer,['\t' num2str(cData(ii,jj,kk)) '\t']);
                            end
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
