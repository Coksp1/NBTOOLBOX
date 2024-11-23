function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Display object (In the command window)
% 
% Input:
%
% - obj : An object of class nb_bd
%
% Output:
%
% The dataset displayed in the command window.
%
% Examples:
%
% obj (Note without semicolon)
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Display the data
    if  obj.numberOfDatasets > 100
        warning('nb_dataSource:dispWarning',[mfilename ':: The object contains too many datasets for the data to be displayed in the command line. ',...
                'Select a subset using the syntax obj(:,:,1:10) or obj(:,:,[2,5])']) 
    else 
        data  = getFullRep(obj);
        dates = obj.startDate:obj.endDate;
        for ii = 1:obj.numberOfDatasets
            dataT             = data(:,:,ii);
            isNaN             = all(isnan(dataT),2);
            dataT             = dataT(~isNaN,:);
            datesOne          = dates(~isNaN);
            if obj.numberOfDatasets > 1
                disp(['(:,:,' int2str(ii) ') ='])
            end
            disp([{'Time'} obj.variables; datesOne, num2cell(dataT); {'Time'}, obj.variables])
        end
    end
    
    % Page names
    if obj.numberOfDatasets < 101
        if obj.numberOfDatasets > 1
            disp('With data (page) names:')
            disp(obj.dataNames);
        elseif obj.numberOfDatasets == 1
            disp('With data (page) name:')
            disp(' ')
            disp(obj.dataNames{1});
            disp(' ')
        end
    end
    
    % nb_bd heading
    disp([nb_createLinkToClass(obj,'nb_bd'), ' with <a href="matlab: nb_dataSource.dispMethods(''nb_bd'')">methods</a>:']);
    disp(' ')

end
                          
