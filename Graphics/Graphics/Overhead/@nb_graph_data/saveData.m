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
% - obj      : An object of class nb_graph_data
% 
% - filename : A string with the saved output name
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        strip = 'on';
        if nargin < 2
            filename = 'data';
        end
    end

    if ~isempty(obj.DB)

        if strcmpi(obj.graphMethod,'graphinfostruct')
        
            if obj.DB.numberOfDatasets > 1

                dataOfGraph = obj.DB;
                dataOfGraph.saveDataBase('saveName',filename,'append',1,'strip',strip)

            else

                dataOfGraph = obj.DB;
                dataOfGraph.saveDataBase('saveName',filename,'strip',strip)

            end
            
        else
            
            if obj.DB.numberOfDatasets > 1

                dataOfGraph = obj.getData();
                dataOfGraph.saveDataBase('saveName',filename,'append',1,'strip',strip)

            else

                dataOfGraph = obj.getData();
                dataOfGraph.saveDataBase('saveName',filename,'strip',strip)

            end
            
        end

    else
        error([mfilename ':: No data is given to the object. So nothing to save.'])
    end

end
