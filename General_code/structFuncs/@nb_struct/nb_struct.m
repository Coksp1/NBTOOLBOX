classdef nb_struct < matlab.mixin.Copyable
% Description:
%
% A handle representation of a MATLAB structure (struct).
%
% All the function that works on a struct will also work on a nb_struct.
%
% Differences are:
% - Initializing with two inputs, see below.
% - Assign a multivalued struct (e.g. with size 1 x 4) with a cell;
%
%   s = nb_struct(4,{'t'})
%   s.t = {'t','d','e','f'};
%   s.t
% 
%   ans = {'t','d','e','f'}
%
%   s(4).t = {{'g'}};
%
% - Caution: Don't set the fields of this type of struct to other structs,
%            as it is not supported to assign thoose struct. Use instead a
%            normal MATLAB struct!
% 
% Superclasses:
% matlab.mixin.Copyable, handle
%
% Constructor:
%
%   nb_struct(varargin)
% 
%   Input:
%
%   - Same input as for a MATLAB struct with one exception:
%
%     If the first input is a integer and the second is a cellstr, it
%     will create a nb_struct with size varargin{1} and with fields
%     given by the cellstr varargin{2}.
% 
%   Output:
% 
%   - obj : A nb_struct object.
% 
%   Examples:
%
%   st1 = nb_struct();
%   st2 = nb_struct('test',{},'test2',{});
%   st3 = nb_struct([]) % Empty 
%
% See also: 
% struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % A normal MATLAB struct.
        s = struct();
        
    end
    
    
    methods
        
        function obj = nb_struct(varargin)
        % Constructor
            
            if size(varargin,2) == 2
                
                num    = varargin{1};
                fields = varargin{2};
                
                if isnumeric(num) && iscellstr(fields)
                    for ii = 1:length(fields)
                        st(num).(fields{ii}) = [];  %#ok<AGROW>
                    end
                    obj.s = st;
                else
                    obj.s = struct(varargin{:});
                end
            else
                obj.s = struct(varargin{:});
            end
        
        end
        
        function propertyValue = get(obj,propertyName)
        
            if nargin == 1
                propertyValue = obj.s;
                return
            end
            
            propertyValue = obj.(propertyName);
            
        end

        function out = subsref(obj,sub)
            
            obj = copy(obj);
            switch sub(1).type
                
                case '()'
                    
                    switch size(sub(1).subs,2)
                        case 1
                            value = sub(1).subs{1};
                            obj.s = obj.s(value);
                            out   = obj;
                            if size(sub,2) > 1
                                out = subsref(out,sub(2:end));
                            end
                        case 2
                            value1 = sub(1).subs{1};
                            value2 = sub(1).subs{2};
                            obj.s  = obj.s(value1,value2);
                            out    = obj;
                            if size(sub,2) > 1
                                out = subsref(out,sub(2:end));
                            end
                        case 3
                            value1 = sub(1).subs{1};
                            value2 = sub(1).subs{2};
                            value3 = sub(1).subs{3};
                            obj.s  = obj.s(value1,value2,value3);
                            out    = obj;
                            if size(sub,2) > 1
                                out = subsref(out,sub(2:end));
                            end
                        otherwise
                            error([mfilename ':: Invalid subsref.'])
                    end
                    
                case '.'
                    
                    sStruct = size(obj.s);
                    if sum(sStruct) == 2
                        out = obj.s.(sub(1).subs);
                    else
                        out = cell(sStruct);
                        for ii = 1:sStruct(1)
                            for jj = 1:sStruct(2)
                                out{ii,jj} = obj.s(ii,jj).(sub(1).subs);
                            end
                        end
                    end
                    if size(sub,2) > 1
                        out = subsref(out,sub(2:end));
                    end
                        
                case '{}'
                    
                    error([mfilename ':: Undefined subscript type {} for an object of class nb_struct.'])
                     
            end
                        
        end
        
        function obj = subsasgn(obj,sub,b)
            
%             sSub = size(sub,2);
%             if sSub > 1
%                 switch sub(1).type
%                     case '.'
%                         for ii = 1:size(obj.s,1)
%                             for jj = 1:size(obj.s,2)
%                                 obj.s(ii,jj).(sub(1).subs) = subsasgn(obj.s(ii,jj).(sub(1).subs),sub(2:end),b);
%                             end
%                         end
%                     case '()'
%                         obj.s(sub(1).subs) = subsasgn(obj.s(sub(1).subs),sub(2:end),b);
%                     otherwise
%                         error([mfilename ':: Unsupported indexing ' sub(1).type])
%                 end
%                 
%             end
            
            if iscell(b) && ~isempty(b)
            
                switch sub(1).type

                    case '()'

                        if strcmpi(sub(2).type,'.')
                        
                            value = sub(1).subs;
                            if numel(value) == 1
                                siz = size(obj);
                                if siz(1) == 1
                                    value = [{1},value];
                                elseif siz(2) == 1
                                    value = [value,{1}];
                                else
                                    error([mfilename ':: The struct is consisting of 2 dimensions, but only one index value is used for assignment.'])
                                end
                            end
                            if ~all([size(value{1},2), size(value{2},2)] == size(b))
                                error([mfilename ':: The value assign to the struct must match. Size of assign struct is ' int2str(size(value,1)) 'x' ...
                                    int2str(size(value,2)) ' while the cell you try to assign to the struct is of size ' int2str(size(b,1)) 'x' ...
                                    int2str(size(b,2)) '.'])
                            end

                            field  = sub(2).subs;
                            index1 = value{1};
                            index2 = value{2};
                            for ii = 1:size(index1,2)
                                for jj = 1:size(index2,2)
                                    obj.s(index1(ii),index2(jj)).(field) = b{ii,jj};
                                end
                            end
                            
                        else
                            obj.s = subsasgn(obj.s,sub,b);
                        end
                        
                    case '.'

                        if numel(b) == 1 && iscell(b{1}) 
                            field = sub(1).subs;
                            for ii = 1:size(obj.s,1)
                                for jj = 1:size(obj.s,2)
                                    obj.s(ii,jj).(field) = b{1};
                                end
                            end
                        elseif ~all(size(obj.s) == size(b))
                            field = sub(1).subs;
                            for ii = 1:size(obj.s,1)
                                for jj = 1:size(obj.s,2)
                                    obj.s(ii,jj).(field) = b;
                                end
                            end
                        else
                            field = sub(1).subs;
                            for ii = 1:size(obj.s,1)
                                for jj = 1:size(obj.s,2)
                                    obj.s(ii,jj).(field) = b{ii,jj};
                                end
                            end
                        end
                        
                    case '{}'

                        error([mfilename ':: Undefined subscript type {} for an object of class nb_struct.'])

                end
                
            elseif sum(size(obj.s)) > 2
                
                field = sub(1).subs;
                for ii = 1:size(obj.s,1)
                    for jj = 1:size(obj.s,2)
                        obj.s(ii,jj).(field) = b;
                    end
                end
                
            else
                obj.s = subsasgn(obj.s,sub,b);
            end
            
        end
        
        function disp(obj)
           
            disp(obj.s)
            
        end
        
    end
      
end
