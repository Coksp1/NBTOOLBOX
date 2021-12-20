classdef nb_bgrowth
% Description:
%
% A class for deriving the balanced growth restrictions of a DSGE
% model.
%
% Constructor:
%
%   obj = nb_bgrowth(varName,constant,precision);
% 
%   Input:
%
%   - varName   : Name of the variable(s) to take derivative respect to,
%                 either as a char or cellstr.
%
%   - constant  : Set to true if this object represent a stationary 
%                 variable or parameter.
%
%   - precision : See help on the property precision.
% 
%   Output:
% 
%   - obj       : An object of class nb_bgrowth
%
% See also:
% nb_st
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    
    properties (SetAccess=protected)
        
        % Set to true if this object represent a stationary variable
        % or parameter.
        constant    = false;
        
        % The property storing the expression as a char.
        equation    = '';
        
        % Set to true to make all operators stop working on an equation
        final       = false;
        
        % The precision on the converted numbers. See the nb_num2str 
        % function. Default is [], i.e. use num2str without any input.
        precision   = [];
        
        % Indicator for last method call being uniary minus
        uniaryMinus = false;
        
    end
    
    methods 
        
        function obj = nb_bgrowth(varName,constant,precision)
            
            if nargin == 0
                return
            end
            
            if nargin < 3
                precision = [];
                if nargin < 2
                    constant = false;
                end
            end
            obj.constant  = constant;
            obj.precision = precision;
            if ischar(varName)
                varName = cellstr(varName);
            end
            if ~iscellstr(varName)
                error([mfilename ':: The varName input must be a char or a cellstr.'])
            end
            
            if constant
                if length(varName) > 1
                    nobj = length(varName);
                    obj  = obj(ones(1,nobj),1);
                    for ii = 1:nobj
                        obj(ii).equation = varName{ii};
                    end
                else
                    obj.equation = varName{1};
                end
            else
                if length(varName) > 1
                    nobj = length(varName);
                    obj  = obj(ones(1,nobj),1);
                    for ii = 1:nobj
                        obj(ii).equation = ['D_Z_' varName{ii}];
                    end
                else
                    obj.equation = ['D_Z_' varName{1}];
                end
            end
            
        end
        
    end
    
    methods (Access=protected)
       
        function [objStr,anotherStr,objConst,anotherConst] = getAsString(obj,another,method)
            
            if isa(another,'nb_bgrowth') && isa(obj,'nb_bgrowth')
        
                objStr       = obj.equation;
                objConst     = obj.constant;
                anotherStr   = another.equation;
                anotherConst = another.constant;

            elseif isa(obj,'nb_bgrowth') && (nb_isScalarNumber(another) || nb_isOneLineChar(another))

                objStr   = obj.equation;
                objConst = obj.constant;
                if ischar(another)
                    anotherStr = another;
                else
                    anotherStr = nb_num2str(another,obj.precision);
                end
                anotherConst = true;

            elseif isa(another,'nb_bgrowth') && (nb_isScalarNumber(obj) || nb_isOneLineChar(obj))

                if ischar(obj)
                    objStr = obj;
                else
                    objStr = nb_num2str(obj,another.precision);
                end
                objConst     = true;
                anotherStr   = another.equation;
                anotherConst = another.constant;

            else
                error([mfilename ':: Unsupported method ' method ' for inputs of ' class(obj) ' and ' class(another) ' (May also be unssuported dimension of inputs, e.g. matrices etc).'])
            end
            
        end
        
        function type = loopObjects(obj,another)
        % Figure out if we need to loop stuff
        
            typeObj = false;
            if isa(obj,'nb_bgrowth')
                if numel(obj) > 1
                    typeObj = true;
                end
            end
            typeAnother = false;
            if isa(another,'nb_bgrowth')
                if numel(another) > 1
                    typeAnother = true;
                end
            end
            
            if typeObj && typeAnother
                type = 3;
            elseif typeObj
                type = 2;
            elseif typeAnother
                type = 1;
            else
                type = 0;
            end
            
        end
        
        function out = runLoop(obj,another,type,func)
        % Used by all methods except minus and plus
        
            switch type
                case 1
                    
                    another = another(:);
                    for ii = 1:size(another,1)
                        another(ii) = func(obj,another(ii));
                    end
                    out = another;
                    
                case 2
                    
                    obj = obj(:);
                    for ii = 1:size(obj,1)
                        obj(ii) = func(obj(ii),another);
                    end
                    out = obj;
                    
                case 3
                      
                    obj        = obj(:);
                    another    = another(:);
                    M          = size(obj,1);
                    N          = size(another,1);
                    out(M*N,1) = nb_bgrowth(); 
                    for ii = 1:M
                        for jj = 1:N
                            out((ii-1)*N + jj) = func(obj(ii),another(jj));
                        end
                    end
                    
            end

        end
        
        function out = runLoopExpand(obj,another,type,func)
        % Used by plus and minus
        
            switch type
                case 1
                    
                    another = another(:);
                    out     = cell(size(another,1),1);
                    for ii = 1:size(another,1)
                        out{ii} = func(obj,another(ii));
                    end
                    out = vertcat(out{:});
                    
                case 2
                    
                    obj = obj(:);
                    out = cell(size(obj,1),1);
                    for ii = 1:size(obj,1)
                        out{ii} = func(obj(ii),another);
                    end
                    out = vertcat(out{:});
                    
                case 3
                      
                    obj     = obj(:);
                    another = another(:);
                    M       = size(obj,1);
                    N       = size(another,1);
                    out     = cell(M*N,1); 
                    for ii = 1:M
                        for jj = 1:N
                            out{(ii-1)*N + jj} = func(obj(ii),another(jj));
                        end
                    end
                    out = vertcat(out{:});
                    
            end
            
            % Remove duplicates
            out = removeDuplicates(out);

        end
        
        function obj = removeDuplicates(obj)
        % Remove duplicated equations
            
            eqs     = {obj.equation};
            [~,ind] = unique(eqs);
            obj     = obj(ind);
            
        end
        
        function [objStr,objSum] = splitSum(obj,objStr)
            
            objSplit = regexp(objStr,'(?<!\()[\-]','split'); % Don't match uniary minus!
            if length(objSplit) > 1

                objSum       = obj; % This equations must still hold true!
                objSum.final = true; % This equation is final, and no operators should work on it!

                % In this case we must only pick one of the trends, as they
                % have to be equal. We pick the shortest!
                if size(objSplit{1},2) > size(objSplit{2},2)
                    objStr = objSplit{2};
                else
                    objStr = objSplit{1};
                end
            else
                objSum = [];
            end
            
        end
 
    end
    
    methods (Static=true)
       
        function str = toRegExp(str)
            
            str = regexprep(str,'^\d\.\*','');
            str = strrep(str,'+','\+');
            str = strrep(str,'-','\-');
            str = strrep(str,'^','\^');
            str = strrep(str,'*','\*');
            str = strrep(str,'/','\/');
            str = strrep(str,'(','\(');
            str = strrep(str,')','\)');
            
            
        end
        
    end
    
end
