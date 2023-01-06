classdef nb_st < matlab.mixin.Heterogeneous
% Description:
%
% An abstract superclass to make it possible to construct a vector of
% nb_stTerm, nb_stBase and nb_stParam.
%
% See also:
% nb_stTerm, nb_stParam
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Constant=true,Hidden=true)
       
        % The precision on the converted numbers. See the nb_num2str 
        % function. Value is 14.
        precision   = 14;
        
        % Tolerance used when deciding if a variable is trending or not.
        tolerance   = eps^(0.5);
        
    end

    properties (SetAccess=protected)
        
        % Error message thrown during stationarization.
        error       = '';
        
        % The trend growth of this term/base/parameter.
        trend       = 0;
        
        % The string representing the new stationarized equation.
        string      = [];
        
    end
    
    methods (Sealed=true)
        
        function disp(obj)
        
            disp(nb_createLinkToClass(obj,'nb_st'));
            disp(' ')
            
            obj   = obj(:);
            nobj  = size(obj,1);
            table = cell(nobj,2);
            for ii = 1:nobj
                if isempty(obj(ii).error)
                    if isa(obj(ii),'nb_stParam')
                        table{ii,1} = [nb_num2str(obj(ii).value,obj(ii).precision) '*'];
                    else
                        table{ii,1} = nb_num2str(obj(ii).trend,obj(ii).precision);
                    end
                    table{ii,2} = obj(ii).string;
                else
                    table{ii,1} = 'Error::';
                    table{ii,2} = obj(ii).error;
                end
            end
            table = [{'Trend/Value','Expression'};table];
            disp(table)
            disp('*) Represent the value. Not the trend.')
            
        end
        
    end
        
end
