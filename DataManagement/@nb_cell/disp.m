function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Display the object on the command line (Without semicolon)
% 
% Input:
% 
% - obj  : An object of class nb_cell
% 
% Output:
% 
% The nb_cell object displayed on the command line if you let out
% the semicolon at the end of the code line
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if  obj.numberOfDatasets > 100
        warning('nb_dataSource:dispWarning',[mfilename ':: The object contains too many datasets for the data to be displayed in the command line. ',...
                'Select a subset using the syntax obj(:,:,1:10) or obj(:,:,[2,5])']) 
    else
        disp(obj.cdata);
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
    
    % nb_cell heading
    disp([nb_createLinkToClass(obj,'nb_cell'), ' with <a href="matlab: nb_dataSource.dispMethods(''nb_cell'')">methods</a>:']);
    disp(' ')

end
