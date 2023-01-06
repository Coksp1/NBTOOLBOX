classdef nb_macro
% Description:
%
% A class representing a macro variable that can be defined in a NB 
% toolbox macro syntax.
%
% Constructor:
%
%   obj = nb_macroVar(input)
% 
%   Input:
%
%   - input : One of:
%             > Scalar double.
%             > Vector of numerical.
%             > Matrix of numerical, will be converted to a vector.
%             > One line char. Special cases;
%               * '"C"' will be converted to 'C'.
%               * '["C","B"]' will be converted to cellstr.
%               * '{"C","B"}' will be converted to cellstr.
%               * '{'C','B'}' will be converted to cellstr.
%               * '2' will be converted to scalar numerical.
%               * 'true' or 'false' will be converted to scalar logical.
%               * '[1,0.2,3]' will be converted to a numerical vector.
%               * '[true,false]' will be converted to a logical vector.
%               * '[true,false,1]' will be converted to a numerical vector.
%               * Else it will be stored as a normal char.
%             > Multi-line char, converted to cellstr. No interpretation!
%             > Scalar logical.
%             > Vector of logicals.
%             > Matrix of logicals, will be converted to a vector.
% 
%   Output:
% 
%   - obj : A object of class nb_macroVar.
% 
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Name of the the macro variable
        name    = 'zero';
        
    end

    properties (SetAccess=protected)
        
        % Value that the macro variable represents
        value   = 0;     
        
    end
    
    methods
        
        function obj = nb_macro(name,input)
            
            if nargin == 0
                return
            end
            
            obj.name = name;
            
            if isnumeric(input)
                obj.value = nb_rowVector(input);
                return
            elseif islogical(input)
                obj.value = nb_rowVector(input);
                return
            elseif iscellstr(input)
                obj.value = nb_rowVector(input);
                return
            elseif ischar(input) && size(input,1) > 1
                obj.value = nb_rowVector(cellstr(input));
                return
            elseif isa(input,'string')
                obj.value = char(input);
                return
            end
            
            % If it is a one line char we try to convert it to a 
            % interpret it using the NB toolbox macro language.
            if strcmp(input(1),'[') || strcmp(input(1),'{')
                
                if nb_contains(input,'"') || nb_contains(input,'''')
                        
                    input = strrep(input,'"','''');
                    input = strrep(input,'[','{');
                    input = strrep(input,']','}');
                    try
                        obj.value = eval(input);
                    catch Err
                        error([Err.message ' ' getMessage(obj)])
                    end
                    if ~iscellstr(obj.value)
                        error(getMessage(obj))
                    end
                    obj.value = nb_rowVector(obj.value);
                    
                else
                    try
                        obj.value = eval(input);
                    catch Err
                        error([Err.message ' ' getMessage(obj)])
                    end
                    if not(isnumeric(obj.value) || islogical(obj.value))
                        error(getMessage(obj))
                    end
                    obj.value = nb_rowVector(obj.value);
                end
                
            else
                
                if nb_contains(input,'"')
                    
                    input = strtrim(input);
                    ind = strfind(input,'"');
                    if ind(1) ~= 1 || ind(2) ~= size(input,2)
                        error(['If "" syntax is used the input must start end end with ". ' getMessage(obj)])
                    end
                    input     = input(2:end-1);
                    obj.value = input;
                    
                else
                    try
                        obj.value = eval(input);
                    catch 
                        if nb_isOneLineChar(input)
                            obj.value = input;
                        else
                            error(getMessage(obj))
                        end
                    end
                    if ischar(obj.value) 
                        if size(obj.value,1) > 1
                            obj.value = cellstr(obj.value);
                        end
                    elseif not(isnumeric(obj.value) || islogical(obj.value) || iscellstr(obj.value))
                        error(getMessage(obj))
                    end
                    obj.value = nb_rowVector(obj.value);
                end
                
            end
                
        end
        
        function err = getMessage(obj)
            err = ['Could not convert input (name = ''' obj.name ''') to any of the supported types.'];
        end
        
        function obj = set.name(obj,name)
    
            if ~nb_isOneLineChar(name)
                error([mfilename ':: The name input must be given as a one line char.'])
            end
            obj.name = name;

        end
        
    end

    methods(Access=protected)
       
        function [obj,name1,name2,value1,value2] = getInfo(obj1,obj2)
           
            if isa(obj1,'nb_macro') 
                value1 = obj1.value;
                name1  = obj1.name;
                obj    = obj1;
            else
                value1 = obj1;
                try
                    name1 = nb_any2String(obj1);
                catch
                    if isa(obj2,'nb_macro') 
                        value2 = obj2.value;
                    else
                        value2 = obj2;
                    end
                    error(nb_macro.getError(value1,value2,'+'));
                end
            end

            if isa(obj2,'nb_macro') 
                value2 = obj2.value;
                name2  = obj2.name;
                obj    = obj2;
            else
                value2 = obj2;
                try
                    name2 = nb_any2String(obj2);
                catch
                    error(nb_macro.getError(value1,value2,'+'));
                end
            end
            
        end
        
        function [looped,obj] = loopOperator(obj1,obj2,meth)
            
            [s1,s2] = size(obj1);
            [r1,r2] = size(obj2);
            if s1*s2 > 1 || r1*r2 > 1

                if s1 == 1 && s2 == 1

                    try
                        obj = obj2;
                        for ii = 1:r1
                            for jj = 1:r2
                                obj(ii,jj) = meth(obj1,obj2(ii,jj));
                            end
                        end
                    catch Err
                        error([Err.message ' At element ' int2str(ii) 'x' int2str(jj) ' of the second input.'])
                    end

                elseif r1 == 1 && r2 == 1

                    try
                        obj = obj1;
                        for ii = 1:s1
                            for jj = 1:s2
                                obj(ii,jj) = meth(obj1(ii,jj),obj2);
                            end
                        end
                    catch Err
                        error([Err.message ' At element ' int2str(ii) 'x' int2str(jj) ' of the first input.'])
                    end

                elseif r1 == s1 && r2 == s2

                    try
                        obj = obj1;
                        for ii = 1:r1
                            for jj = 1:r2
                                obj(ii,jj) = meth(obj1(ii,jj),obj2(ii,jj));
                            end
                        end
                    catch Err
                        error([Err.message ' At element ' int2str(ii) 'x' int2str(jj) '.'])
                    end
                else
                    error('Matrix dimension not consistent.')
                end
                looped = true;
            else
                looped = false;
                obj    = [];
            end

        end
        
        function [looped,obj] = loopOperator1(obj,meth)
            
            [s1,s2] = size(obj);
            if s1*s2 > 1

                try
                    for ii = 1:s1
                        for jj = 1:s2
                            obj(ii,jj) = meth(obj(ii,jj));
                        end
                    end
                catch Err
                    error([Err.message ' At element ' int2str(ii) 'x' int2str(jj) '.'])
                end
                looped = true;
                
            else
                looped = false;
            end

        end
        
    end
    
    methods(Static=true)
       
        function obj = empty()
            obj = nb_macro();
            obj = obj(1:0);
        end
        varargout = interpret(varargin);
        
    end
    
    methods (Static=true,Access=protected)
        
        function err = getError(value1,value2,op)
            err = ['Undefined operator ' op ' for input arguments of type ' class(value1) ' and ' class(value2) '.'];
        end
        
        function err = getError1(value1,op)
            err = ['Undefined operator ' op ' for input arguments of type ' class(value1) '.'];
        end
        
    end
        
end
