function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Display object (On the commandline)
% 
% Input:
%
% - obj : An object of class nb_data
%
% Output:
%
% The dataset displayed on the command, as an excel spreadsheet 
%
% Examples:
%
% obj (Note without semicolon)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if  obj.numberOfDatasets > 100
        warning('nb_dataSource:dispWarning',[mfilename ':: The object contains too many datasets for the data to be displayed in the command line. ',...
                'Select a subset using the syntax obj(:,:,1:10) or obj(:,:,[2,5])'])
    else
        displayed = cell(obj.numberOfObservations + 2, obj.numberOfVariables + 1, obj.numberOfDatasets);
        nums      = observations(obj,'cellstr');
        for ii = 1:obj.numberOfDatasets
            displayed(:,:,ii) = [{'Observation'} obj.variables; nums, num2cell(obj.data(:,:,ii)); {'Observation'} obj.variables];
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
    
    % nb_data heading
    disp([nb_createLinkToClass(obj,'nb_data'), ' with <a href="matlab: nb_dataSource.dispMethods(''nb_data'')">methods</a>:']);
    disp(' ')

end
