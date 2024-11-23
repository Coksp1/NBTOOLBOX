classdef nb_symMatrix
% Description:
%
% An object that represent a matrix of symbolic parameters of a matrix.
%
% The values of the symbols may be provided. Some methods may need
% these values to be used.
%
% Constructor:
%
%   obj = nb_symMatrix(input1,input2)
% 
%   Input:
%
%   > Alternativ 1:
%
%       - input1 : The number of rows of the symbolic matrix.
%
%       - input2 : The number of cols of the symbolic matrix.
% 
%   > Alternativ 2:
%
%       - input1 : A rows x cols cellstr with the symbols, or a rows x 1
%                  char (which will be converted to a rows x 1 cellstr).
%
%   > Alternative 3: 
%
%       - input1 : A rows x cols numeric matrix.
%
%   Output:
% 
%   > Alternativ 1:
%
%       - obj  : A rows x cols nb_symMatrix object with all elements set 2 
%                zero.
% 
%   > Alternativ 2 and 3:
%
%       - obj  : A rows x cols nb_symMatrix object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    properties (Constant=true,Hidden=true)
       
        % The precision on the converted numbers. See the nb_num2str 
        % function. Value is 14.
        precision   = 14;
        
        % Tolerance level used.
        tolerance   = eps^(0.5);
        
    end

    properties (SetAccess=protected)
        
        % A rows x cols nb_term object with the symbolic representation 
        % of the matrix.
        symbols     = [];
         
    end
    
    methods
        
        function obj = nb_symMatrix(input1,input2)
            
            if nargin < 2
                input2 = 1;
                if nargin < 1
                    input1 = 1;
                end
            end
            
            if ischar(input1)
                input1 = cellstr(input1);
            end
            if iscellstr(input1)
                obj.symbols = nb_base(input1);
            elseif isnumeric(input1) && nargin == 1
                obj.symbols = nb_num(input1);
            elseif isa(input1,'nb_term')
                obj.symbols = input1;
            else
                obj.symbols = nb_num(zeros(input1,input2));
            end
            
        end
        
        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.symbols, varargin{:});
        end
        
        function ind = end(obj,k,~)
            ind = size(obj,k);
        end
        
    end
    
    methods (Access=protected)
       
        function [obj,another,err] = checkTypes(obj,another,method)
            
            err = '';
            if isnumeric(obj)
                obj = nb_symMatrix(obj);
            elseif ~isa(obj,'nb_sumMatrix')
                err = ['Unsupported method ' method ' for inputs of ' class(obj) ' and ' class(another) '.'];
            end
            
            if isnumeric(another)
                another = nb_symMatrix(another);
            elseif ~isa(another,'nb_sumMatrix')
                err = ['Unsupported method ' method ' for inputs of ' class(obj) ' and ' class(another) '.'];
            end
            
        end
        
        function [obj,another,err] = checkSizes(obj,another)
        
            err     = '';
            sizeObj = size(obj);
            sizeA   = size(another);
            if sizeA(1) ~= sizeObj(1)
                if sizeA(1) == 1
                    another = expand(another,1,sizeObj);
                elseif sizeObj(1) == 1
                    obj = expand(obj,1,sizeA);
                else
                    err = 'Matrix dimensions must agree.';
                end
            end

            if sizeA(2) ~= sizeObj(2)
                if sizeA(2) == 1
                    another = expand(another,2,sizeObj);
                elseif sizeObj(2) == 1
                    obj = expand(obj,2,sizeA);
                else
                    err = 'Matrix dimensions must agree.';
                end
            end
            
        end
        
        function obj = expand(obj,dim,s)
            
            if dim == 2
                obj.symbols = obj.symbols(:,ones(1,s(dim)));
            else
                obj.symbols = obj.symbols(ones(1,s(dim)),:);
            end
            
        end
        
        function obj = callMethod(obj,another,meth)
        
            siz     = size(obj);
            symsObj = obj.symbols(:);
            symsA   = another.symbols(:);
            for ii = 1:numel(symsObj)
                symsObj(ii) = meth(symsObj(ii),symsA(ii));
            end
            obj.symbols = reshape(symsObj,siz);
            
        end
        
    end
    
    methods (Static=true)
       

    end
    
end

