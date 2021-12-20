classdef nb_store2DatabaseMAT < nb_store2Database
% Description:
%
% A class that can be used to save results from a nb_calculate_vintages 
% object to MAT files. One MAT file for each variable.
%
% Superclasses:
%
% nb_store2Database, handle
%
% Constructor:
%
%   obj = nb_store2DatabaseMAT(path)
%   obj = nb_store2DatabaseMAT(path,aliases)
%
%   Input:
%
%   - path    : A one line char with the path of the mat files to store 
%               the variables to.
%
%   - aliases : A cellstr with the names of the calculated variables when 
%               stored to the MAT files.
% 
% See also: 
% nb_calculate_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    properties (SetAccess=protected)
       
        % The path for where to store the MAT files.
        path   = {};
        
        % The written runs to the .MAT file.
        runDates = {};
        
    end

    methods 
        
        function obj = nb_store2DatabaseMAT(path,aliases)
           
            if nargin == 0
                return
            end
            
            if ~nb_isOneLineChar(path)
                error([mfilename ':: The path input must be a one line char.'])
            end 
            path = fileparts(path);
            if isempty(path)
                error([mfilename ':: The path input does not contain a proper path.'])
            end
            obj.path = path;
            if nargin > 1
                obj.aliases = aliases;
            end
            
        end
        
        function model = initialize(~,model,~)
            
        end
        
        function s = struct(obj)  
            s = struct('class', class(obj),...
                       'first', obj.first,...
                       'path', obj.path,...
                       'runDates', {obj.runDates}, ...
                       'variables', {obj.variables},...
                       'aliases', {obj.aliases});
        end
        
    end
    
    methods (Static=true)
    
        function obj = unstruct(s)
            
            if isa(s,'nb_store2DatabaseMAT')
                % Add support for old cases.
                obj = s;
                return
            end
            
            obj           = nb_store2DatabaseMAT(s.path);
            obj.first     = s.first;
            obj.runDates  = s.runDates;
            obj.variables = s.variables;
            obj.aliases   = s.aliases;
        end
        
    end
        
end

