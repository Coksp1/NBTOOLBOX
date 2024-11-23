classdef nb_eq2Latex
% Description:
%
% A class for converting equations to latex format.
%
% Constructor:
%
%   obj = nb_eq2Latex(varName,precision);
% 
%   Input:
%
%   - varName   : Name of the variable(s) of the expression(s) that is 
%                 converted to latex code, as a one line char or a cellstr.
% 
%   - precision : See help on the property precision.
%
%   Output:
% 
%   - obj       : An object of class nb_eq2Latex.
%
%   Examples:
%
%   d = nb_eq2Latex('x');
%   d = d.^2 
%
% See also:
% nb_eq2Latex.parse, nb_dsge.writeTex
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % The property storing the latex code of the equation, as a one
        % line char.
        latex       = '';
        
        % The precision on the converted numbers. See the nb_num2str 
        % function. Default is 14, i.e. use nb_num2str with the second 
        % input set to 14.
        precision   = 14;
        
        % The property storing the original equation as a string.
        values      = '';
        
    end
    
    methods 
        
        function obj = nb_eq2Latex(varName,precision)
            if nargin > 1
                obj.precision = precision;
            end
            if nargin < 1
                varName = 'x';
            end
            if iscellstr(varName)
                nobj = length(varName);
                obj  = obj(ones(1,nobj),1);
                for ii = 1:nobj
                    obj(ii).values = varName{ii};
                    obj(ii).latex  = varName{ii};
                end
            else
                if ~ischar(varName) || size(varName,1) > 1
                   error([mfilename ':: The varName input must be a 1xN char or a Mx1 cellstr.']) 
                end
                obj.values = varName;
                obj.latex  = varName;
            end
            
        end
        
        function disp(obj)
           
            disp(nb_createLinkToClass(obj));
            disp(' ')
            
            if numel(obj) > 1
                obj = obj(:);
                for ii = 1:numel(obj)
                    disp(' ');
                    disp(['Equation nr. ' int2str(ii) ':']);
                    disp(obj(ii).values);
                    disp(' ');
                    disp('Latex equation:');
                    disp(obj(ii).latex);
                end
            else
                disp('Equation:');
                disp(obj.values);
                disp(' ');
                disp('Latex equation:');
                disp(obj.latex);
            end
            
        end
        
    end
    
    methods (Static=true)
        
        varagout = parse(varargin);
           
        function str = addLatexPar(str,type)
        % Syntax:
        %
        % str = nb_eq2Latex.addLatexPar(str,type)
        %
        % Description:
        %
        % Add latex matched parentheses if needed to a term during parsing.
        % 
        % Input:
        % 
        % - str  : A one line char.
        %
        % - type : Give true to allways add parentheses, even if no +,-,
        %          or \frac is found.
        %
        % Output:
        % 
        % - str  : A one line char.
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if iscellstr(str) %#ok<ISCLSTR>
                for ii = 1:length(str)
                    str{ii} = nb_mySD.addLatexPar(str{ii},type);
                end
                return
            end
        
            % Ensure that the term breaks are not inside {}
            sbo     = strfind(str,'{');
            numOpen = zeros(1,length(str));
            if length(sbo) == 1 
                numOpen(sbo:end) = 1;
            else
                for ii = 1:size(sbo,2)-1
                    numOpen(sbo(ii):sbo(ii+1)) = ii;
                end
                numOpen(sbo(ii+1)+1:end) = ii + 1;
            end

            sbc      = strfind(str,'}');
            numClose = zeros(1,size(str,2));
            if length(sbc) == 1 
                numClose(sbc:end) = 1;
            else
                for ii = 1:size(sbc,2)-1
                    numClose(sbc(ii):sbc(ii+1)) = ii;
                end
                numClose(sbc(ii+1)+1:end) = ii + 1;
            end
            num = numOpen - numClose;
            s1  = regexp(str,'[+-]|\frac','start');
            s1  = s1(~num(s1));
            
            if isempty(s1)
                if type
                    return
                else
                    if ~strncmp(str,'\left(',5)
                        % No parentheses so we add them
                        str = ['\left(' str '\right)'];
                    end
                    return
                end   
            end
            
            % Ensure that the term breaks are not inside \left( \right)
            parO = zeros(1,size(str,2));
            s2   = regexp(str,'\left(','start');
            if isempty(s2)
                str = ['\left(' str '\right)'];
                return
            elseif s2(1) ~= 1
                str = ['\left(' str '\right)'];
                return
            end
            
            if length(s2) == 1 
                parO(s2:end) = 1;
            else
                for ii = 1:size(s2,2)-1
                    parO(s2(ii):s2(ii+1)) = ii;
                end
                parO(s2(ii+1)+1:end) = ii + 1;
            end

            parC = zeros(1,size(str,2));
            s3   = regexp(str,'\right)','start');
            if length(s3) == 1 
                parC(s3:end) = 1;
            else
                for ii = 1:size(s3,2)-1
                    parC(s3(ii):s3(ii+1)) = ii;
                end
                parC(s3(ii+1)+1:end) = ii + 1;
            end
            par = parO - parC;
            if any(par(s1) == 0)
                str = ['\left(' str '\right)'];
            end
  
        end
        
    end
    
end
