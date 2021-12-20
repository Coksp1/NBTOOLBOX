classdef nb_writeFcst2DatabaseMAT < nb_writeFcst2Database
% Description:
%
% A class that can be used to write forecast from a 
% nb_model_forecast_vintages object to MAT files. One MAT file for each 
% variable.
%
% Superclasses:
%
% nb_writeFcst2Database, handle
%
% Constructor:
%
%   obj = nb_writeFcst2DatabaseMAT(path)
%
%   Input:
%
%   - path    : A one line char with the path of the mat files to store 
%               the variables to.
%
% See also: 
% nb_model_forecast_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties (SetAccess=protected)
       
        % The path for where to store the MAT files.
        path     = {};
        
        % The written runs to the .MAT file.
        runDates = {};
        
    end

    methods 
        
        function obj = nb_writeFcst2DatabaseMAT(path)
           
            if ~nb_isOneLineChar(path)
                error([mfilename ':: The path input must be a one line char.'])
            end 
            path = fileparts(path);
            if isempty(path)
                error([mfilename ':: The path input does not contain a proper path.'])
            end
            obj.path = path;
            
        end
        
        function model = initialize(~,model,~)
            
        end
        
        function s = struct(obj)  
            s = struct('class', class(obj),...
                       'first', obj.first,...
                       'path', obj.path,...
                       'runDates', {obj.runDates}, ...
                       'variables2Write', {obj.variables2Write});
        end
        
    end
    
    methods (Static=true)
    
        function obj = unstruct(s)
            obj                 = nb_writeFcst2DatabaseMAT(s.path);
            obj.first           = s.first;
            obj.runDates        = s.runDates;
            obj.variables2Write = s.variables2Write;
        end
        
    end
        
end

