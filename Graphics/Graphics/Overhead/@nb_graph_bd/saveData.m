function obj = saveData(obj,filename,~)
% Syntax:
% 
% obj = saveData(obj,filename)
% 
% Description:
% 
% Saves the data of the figure
% 
% Input:
% 
% - obj      : An object of class nb_graph_bd
% 
% - filename : A string with the saved output name
% 
% Example:
% 
% obj.saveData('test');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        filename = 'data';
    end

    if ~isempty(obj.DB)

        if strcmpi(obj.graphMethod,'graphinfostruct')
        
            if obj.DB.numberOfDatasets > 1

                dataOfGraph = obj.DB;
                dataOfGraph.saveDataBase('saveName',filename,'append',1,'dateformat','xls')

            else

                dataOfGraph = obj.DB;
                dataOfGraph.saveDataBase('saveName',filename,'dateformat','xls')

            end
            
        else
            
            if obj.DB.numberOfDatasets > 1

                dataOfGraph = obj.getData();
                dataOfGraph.saveDataBase('saveName',filename,'append',1,'dateformat','xls')

            else

                dataOfGraph = obj.getData();
                dataOfGraph.saveDataBase('saveName',filename,'dateformat','xls')

            end
            
        end

    else
        error([mfilename ':: No data is given to the object. So nothing to save.'])
    end

end
