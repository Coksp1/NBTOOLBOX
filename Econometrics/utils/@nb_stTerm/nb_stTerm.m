classdef nb_stTerm < nb_st
% Description:
%
% A class representing a trending or non-trending variable/term during 
% stationarization.
%
% Superclasses:
% nb_st, matlab.mixin.Heterogeneous
%
% Constructor:
%
%   obj = nb_stTerm(varName,trend,leadOrLag)
% 
%   Input:
%
%   - varName   : A one line char with the name of the base variable, or
%                 a cellstr with a set of base variables.
%
%   - trend     : A double matching the number of base variables given. It
%                 must store the trend growth of each base variable. Set
%                 to 0 to indicate a non-trending variable.
%
%   - leadOrLag : A double matching the number of base variables given. It
%                 must store the number of periods the base value is
%                 leaded or lagged.
%
%   - unitRoot  : A logical matching the number of base variables given.
%                 Give true for the elements that are unit root variables.
%                 Default is false. If a scalar logical is given it will
%                 be applied to all base variables.
% 
%   Output:
% 
%   - obj : A vector of nb_stTerm objects.   
%
% See also:
% nb_stTerm, nb_stParam
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    methods
       
        function obj = nb_stTerm(varName,trend,leadOrLag,unitRoot)
            
            if nargin == 0
                return;
            end
            if nargin < 4
                unitRoot = [];
                if nargin < 3
                    leadOrLag = [];
                end
            end
            
            if iscellstr(varName)
                if isempty(leadOrLag)
                    leadOrLag = zeros(size(varName));
                end
                if isempty(unitRoot)
                    unitRoot = false(size(varName));
                elseif isscalar(unitRoot)
                    unitRoot = unitRoot(ones(size(varName)),1);
                end
                nobj      = length(varName);
                trend     = trend(:);
                leadOrLag = leadOrLag(:);
                if nobj ~= size(trend,1)
                    error([mfilename ':: The length of varName and trend inputs must be the same.'])
                end
                if nobj ~= size(leadOrLag,1)
                    error([mfilename ':: The length of varName and leadOrLag inputs must be the same.'])
                end
                obj = obj(ones(1,nobj),1);
                for ii = 1:nobj
                    obj(ii).trend  = trend(ii);
                    obj(ii).string = varName{ii};
                    obj(ii)        = update(obj(ii),trend(ii),leadOrLag(ii),unitRoot(ii));
                end
            else
                if isempty(leadOrLag)
                    leadOrLag = 0;
                end
                if isempty(unitRoot)
                    unitRoot = false;
                end
                obj.trend  = trend;
                obj.string = varName;
                obj        = update(obj,trend,leadOrLag,unitRoot);
            end
            
        end
        
    end
    
    methods (Access=private)
        
        function obj = update(obj,trend,leadOrLag,unitRoot)
    
            varName = obj.string;
            if unitRoot
                obj.string = '1';
            end
            
            if leadOrLag == 0
                return
            end
            
            if ~unitRoot
                if leadOrLag > 0
                    sign = '+';
                else
                    sign = '';
                end
                obj.string = [obj.string,'(' sign int2str(leadOrLag) ')'];
            end
            if abs(trend) < eps^0.5
                return
            end
            
            if leadOrLag > 0
                for ii = 1:leadOrLag
                    obj.string = [obj.string,'*D_Z_' varName '(+' int2str(ii) ')'];
                end
            elseif leadOrLag < 0
                obj.string = [obj.string,'*D_Z_' varName '^-1'];
                for ii = -2:-1:leadOrLag
                    obj.string = [obj.string,'*D_Z_' varName '(' int2str(ii+1) ')^-1'];
                end 
            end
            
        end
        
    end
    
end
