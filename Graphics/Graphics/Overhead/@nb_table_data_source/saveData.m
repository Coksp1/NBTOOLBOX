function obj = saveData(obj,filename,strip)
% Syntax:
% 
% obj = saveData(obj,filename,strip)
% 
% Description:
% 
% Saves the data of the figure
% 
% Input:
% 
% - obj      : An object of class nb_table_data_source
% 
% - filename : A string with the saved output name, without extension.
% 
% - strip    : - 'on'  : Strip all observation dates where all the 
%                        variables has no value. Default. 
% 
%              - 'off' : Does not strip all observation dates where 
%                        all the variables has no value 
% 
% Example:
% 
% obj.saveData('test');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        strip = 'on';
        if nargin < 2
            filename = 'data';
        end
    end

    dataAsCell = getDataAsCell(obj,strip);
    xlswrite([filename '.xlsx'], dataAsCell);
    
end
