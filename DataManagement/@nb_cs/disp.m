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
% - obj  : An object of class nb_cs
% 
% Output:
% 
% The nb_cs object displayed on the command line if you let out
% the semicolon at the end of the code line
% 
% Examples:
% 
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'})
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 100
        warning('nb_dataSource:dispWarning',[mfilename ':: The object contains too many datasets for the data to be displayed in the command line. ',...
                'Select a subset using the syntax obj(:,:,1:10) or obj(:,:,[2,5])']) 
    else
        displayed = cell(obj.numberOfTypes + 2, obj.numberOfVariables + 1, obj.numberOfDatasets);
        for ii = 1:obj.numberOfDatasets
            displayed(:,:,ii) = [{'Type'} obj.variables; obj.types' num2cell(obj.data(:,:,ii)); {'Type'} obj.variables]; 
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
    
    % nb_cs heading
    disp([nb_createLinkToClass(obj,'nb_cs'), ' with <a href="matlab: nb_dataSource.dispMethods(''nb_cs'')">methods</a>:']);
    disp(' ')
    
end
