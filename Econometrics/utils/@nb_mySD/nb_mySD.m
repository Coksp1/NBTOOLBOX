classdef nb_mySD < nb_varOrPar
% Description:
%
% A class for doing symbolic derivative of a function.
%
% Superclasses:
%
% nb_varOrPar, matlab.mixin.Heterogeneous
%
% Constructor:
%
%   obj = nb_mySD(varName,precision);
% 
%   Input:
%
%   - varName   : Name of the variable to take derivative respect to, as 
%                 a one line char or a cellstr.
% 
%   - precision : See help on the property precision.
%
%   Output:
% 
%   - obj       : An object of class nb_mySD
%
%   Examples:
%
%   d      = nb_mySD('x');
%   d      = d.^2;
%   strDer = d.derivatives;  
%
% See also:
% myAD
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % The base variable.
        bases       = {''};
        
        % The property storing the derivatives as a cellstr.
        derivatives = {'1'};
        
        % The precision on the converted numbers. See the nb_num2str 
        % function. Default is 14, i.e. use nb_num2str with the second 
        % input set to 14.
        precision   = 14;
        
        % The property storing the original equation as a string.
        values      = '';
        
    end
    
    methods 
        
        function obj = nb_mySD(varName,precision)
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
                    obj(ii).bases  = {varName{ii}};
                    obj(ii).values = varName{ii};
                end
            else
                if ~ischar(varName) || size(varName,1) > 1
                   error([mfilename ':: The varName input must be a 1xN char or a Mx1 cellstr.']) 
                end
                obj.bases  = {varName};
                obj.values = varName;
            end
            
        end
        
        function disp(obj)
           
            disp(nb_createLinkToClass(obj));
            if numel(obj) > 1
                obj = obj(:);
                for ii = 1:numel(obj)
                    disp(' ');
                    disp(['Equation nr. ' int2str(ii) ':']);
                    disp(obj(ii).values);
                    disp(' ');
                    disp('Derivatives:');
                    for jj = 1:length(obj(ii).derivatives)
                        disp(['Wrt. ' obj(ii).bases{jj} ': ' obj(ii).derivatives{jj}]);
                    end
                end
            else
                disp(' ')
                disp('Equation:');
                disp(obj.values);
                disp(' ');
                disp('Derivatives:');
                for ii = 1:length(obj.derivatives)
                    disp(['Wrt. ' obj.bases{ii} ': ' obj.derivatives{ii}]);
                end
            end
            
        end
        
    end
    
    methods (Static=true)
       
        function str = addPar(str,type)
        % Syntax:
        %
        % str = nb_mySD.addPar(str,type)
        %
        % Description:
        %
        % Add parentheses if needed to a term during parsing.
        % 
        % Input:
        % 
        % - str  : A one line char.
        %
        % - type : Give false to allways add parentheses, even if no +,-,
        %          ^ or * is found.
        %
        % Output:
        % 
        % - str  : A one line char.
        %
        % Written by Kenneth Sæterhagen Paulsen    
            
            if iscellstr(str) %#ok<ISCLSTR>
                siz = size(str);
                str = str(:);
                for ii = 1:length(str)
                    str{ii} = nb_mySD.addPar(str{ii},type);
                end
                str = reshape(str,siz);
                return
            end
        
            s1 = regexp(str,'[\^*+-/]','start'); % For some reason this return matches with '.' as well??
            s2 = regexp(str,'\.','start');
            s3 = regexp(str,'\(','start') + 1;
            s1 = setdiff(s1,[s2,s3]);
            if isempty(s1)
                if type
                    return
                else
                    if ~strcmp(str(1),'(')
                        % No parentheses so we add them
                        str = ['(' str ')'];
                    end
                    return
                end   
            end
            
            parO = zeros(1,size(str,2));
            s2   = regexp(str,'\(','start');
            if isempty(s2)
                str = ['(' str ')'];
                return
            elseif s2(1) ~= 1
                str = ['(' str ')'];
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
            s3   = regexp(str,'\)','start');
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
                str = ['(' str ')'];
            end
  
        end
           
    end
    
end
