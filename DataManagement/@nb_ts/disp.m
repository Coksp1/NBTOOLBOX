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
% - obj : An object of class nb_ts
%
% Output:
%
% The dataset displayed in the command window.
%
% Examples:
%
% obj (Note without semicolon)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Display the data
    if  obj.numberOfDatasets > 100
        warning('nb_dataSource:dispWarning',[mfilename ':: The object contains too many datasets for the data to be displayed in the command line. ',...
                'Select a subset using the syntax obj(:,:,1:10) or obj(:,:,[2,5])']) 
    else 
        displayed = cell(obj.numberOfObservations + 2, obj.numberOfVariables + 1, obj.numberOfDatasets);
        dates     = obj.startDate:obj.endDate;
        for ii = 1:obj.numberOfDatasets
            displayed(:,:,ii) = [{'Time'} obj.variables; dates, num2cell(obj.data(:,:,ii)); {'Time'}, obj.variables];
        end
        disp(displayed);
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
    
    % nb_ts heading
    disp([nb_createLinkToClass(obj,'nb_ts'), ' with <a href="matlab: nb_dataSource.dispMethods(''nb_ts'')">methods</a>:']);
    disp(' ')

end
