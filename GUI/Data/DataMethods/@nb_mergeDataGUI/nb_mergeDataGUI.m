classdef nb_mergeDataGUI < nb_methodGUI
% Description:
%
% Open up dialog window for merging datasets. From both the main
% program and within the spreadsheet.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_mergeDataGUI(parent,data1,data2,saveName1,saveName2)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data1      : As an object of class nb_ts or nb_cs. Can be 
%                  empty. If empty the user will be given the 
%                  option to select a dataset from a list.
%
%   - data2      : As an object of class nb_ts or nb_cs. Can be 
%                  empty. If empty the user will be given the 
%                  option to select a dataset from a list.
%
%   - saveName1  : The save name of the dataset, as a string. Must
%                  be provided if the data1 is given.
%
%   - saveName2  : The save name of the dataset, as a string. Must
%                  be provided if the data2 is given.
% 
%   Output:
% 
%   - Triggering an methodFinished event.
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The first dataset to be merged, as a nb_data, nb_ts or nb_cs 
        % object.
        data1       = [];
        
        % The second dataset to be merged, as a nb_data, nb_ts or nb_cs 
        % object.
        data2       = [];
       
        % Save name for the first dataset to merge.
        saveName1   = '';
        
        % Save name for the second dataset to merge.
        saveName2   = '';
        
    end
    
    properties(Access=protected,Hidden=true)
       
        convertListBox = [];
        mergeListBox   = [];
        type           = [];
        
    end
    
    properties (Access=protected)
        
       objectSelectedForConverting = []; 
        
    end
    
    methods
        
        function gui = nb_mergeDataGUI(parent,data1,data2,saveName1,saveName2)
        % Constructor
        
            if nargin < 5
                saveName2 = '';
                if nargin < 4
                    saveName1 = '';
                    if nargin < 3
                        data2 = [];
                        if nargin < 2
                            data1 = [];
                        end
                    end
                end
            end
            
            gui            = gui@nb_methodGUI(parent,[]);
            gui.data1      = data1;
            gui.data2      = data2;
            gui.saveName1  = saveName1;
            gui.saveName2  = saveName2;
             
            if ~isempty(data1) && ~isempty(data2)
            
                % Figure out what types of object we are dealing 
                % with and open up a dialog with the user on how to
                % merge the objects
                mergeDatasetEngine(gui);
                
            else
                
                % Make dialog box for selction datasets to merge 
                makeGUI(gui);
               
            end
            
        end
                         
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = mergeDatasets(varargin)
        
        varargout = mergeDatasetEngine(varargin)
        
        varargout = originalTSMerge(varargin)
        
        varargout = callbackSaveOnResponse(varargin)
        
        varargout = differentFreqMerge(varargin)
        
        varargout = selectedObjectToConvert(varargin)
        
        varargout = convertionFinishedCallack(varargin)
        
        varargout = differentObjectsMerge(varargin)
        
        varargout = callbackMergeOnResponse(varargin)
        
        varargout = originalCSMerge(varargin)
        
        varargout = storeToGUI(varargin)
        
    end
       
end
