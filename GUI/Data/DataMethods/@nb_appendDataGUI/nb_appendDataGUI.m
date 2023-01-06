classdef nb_appendDataGUI < nb_methodGUI
% Description:
%
% Open up dialog window for append a dataset to another. From both 
% the main program and within the spreadsheet.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_appendDataGUI(parent,data,saveName)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
%
%   - saveName   : As a string
% 
%   Output:
% 
%   - gui        : An object of class nb_appendDataGUI.
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The dataset to append the other, as an nb_ts object.
        data1       = [];
        
        % The dataset to be append, as an nb_ts object.
        data2       = [];
       
        % Save name for the first dataset to append the other.
        saveName1   = '';
        
        % Save name for the second dataset to append.
        saveName2   = '';
        
    end
    
    properties(Access=protected,Hidden=true)
       
        convertListBox = [];
        mergeListBox   = [];
        appendType     = [];
        
    end
    
    properties (Access=protected)
        
       objectSelectedForConverting = []; 
        
    end
    
    methods
        
        function gui = nb_appendDataGUI(parent,data,saveName)
        % Constructor
       
            gui            = gui@nb_methodGUI(parent,[]);
            gui.data1      = data;
            gui.saveName1  = saveName; 
            
            % Make dialog box for selction datasets to merge 
            makeGUI(gui);
            
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
        
        varargout = differentFreqMerge(varargin)
        
        varargout = selectedObjectToConvert(varargin)
        
        varargout = convertionFinishedCallack(varargin)
        
        varargout = storeToGUI(varargin)
        
    end
       
end
