classdef nb_SMARTHarmonizeLossFunc
% Description:
%
% An object of this class represent one restiction to be used by a
% harmonizer.
%
% Constructor:
%
%   obj = nb_SMARTHarmonizeLossFunc(name,description,...
%       lossFunc,weights,frequency,mapping)
%
%   Input:
%
%   See the help on the properties of this class with the same names.
%
%   Output:
%
%   - obj : An object of class nb_SMARTHarmonizeLossFunc.
%
% See also:
% nb_SMARTJudgmenter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    properties (SetAccess=protected)
        
        % The name of the applied restriction
        name = '';
        
        % The description of the applied restriction
        description = '';
        
        % The frequency that each term of the loss function should be 
        % evaluated at.
        frequency = [];
        
        % The frequency that each restrictions should be evaluated at.
        frequencyRestrictions = [];

        % The loss function being minimized. Each term is calculated, and
        % a weighted sum of the residuals are calculated, i.e.
        %
        % min sum(term{1}^weights(1) + ... + term{N}^weights(N))
        %
        % As a cellstr.
        lossFunc = {};
        
        % Set the mapping of the restricted variable. Default is
        % 'diffAverage'. Only used if the frequency property is not empty.
        % For the supported mappings see help on the method
        % nb_math_ts.convert.
        % See also:
        % nb_math_ts.convert
        mapping   = 'diffAverage';

        % The restrictions to minimize the loss function under. As a 
        % cellstr.
        restrictions = {};
        
        % The weights of the criteria to minimize. Must have the same
        % number of elements as the lossFunc property. As a double vector.
        weights = [];
        
    end
    
    methods
        
        function obj = nb_SMARTHarmonizeLossFunc(name,description,...
                lossFunc,weights,restrictions,frequency,...
                frequencyRestrictions,mapping)
            
            if nargin < 8
                mapping = '';
                if nargin < 7
                    frequencyRestrictions = [];
                    if nargin < 6
                        frequency = [];
                    end
                end
            end

            if ~nb_isOneLineChar(name)
                error('The name input must be a one line char.')
            end
            if ~nb_isOneLineChar(description)
                error('The description input must be a one line char.')
            end
            if ~iscellstr(lossFunc)
                error('The lossFunc input must be a cellstr.')
            end
            if ~iscellstr(restrictions)
                error('The restrictions input must be a cellstr.')
            end
            if ~(isvector(weights) && isnumeric(weights))
                error('The weights input must be a double vector.')
            end
            if length(lossFunc) ~= length(weights)
                error('The lossFunc and weights inputs must have same length')
            end
            if ~isempty(frequency)
                if ~(isvector(frequency) && isnumeric(frequency))
                    error('The frequency input must be a double vector.')
                end
                if length(lossFunc) ~= length(frequency)
                    error('The lossFunc and frequency inputs must have same length')
                end
            end
            if ~isempty(frequencyRestrictions)
                if ~(isvector(frequencyRestrictions) && isnumeric(frequencyRestrictions))
                    error('The frequencyRestrictions input must be a double vector.')
                end
                if length(restrictions) ~= length(frequencyRestrictions)
                    error('The restrictions and frequencyRestrictions inputs must have same length')
                end
            end
            if ~nb_isOneLineChar(mapping)
                error('The mapping input must be a one line char.')
            end
            obj.name                  = name;
            obj.description           = description;
            obj.lossFunc              = lossFunc;
            obj.restrictions          = restrictions;
            obj.weights               = weights;
            obj.frequency             = frequency;
            obj.frequencyRestrictions = frequencyRestrictions;
            if ~isempty(mapping)
                obj.mapping = mapping;
            end
            
        end

        function disp(obj)
            
            obj = obj(:);
            if size(obj,1) > 1
               for ii = 1:size(obj,1)
                   disp(obj(ii))
               end
               return
            end
            
            disp(' ')
            weightsStr = '';
            for ii = 1:length(obj.weights)
                weightsStr = [weightsStr, num2str(obj.weights(ii)) ', ']; %#ok<AGROW>
            end
            weightsStr = weightsStr(1:end-2);

            freqStr = '';
            if ~isempty(obj.frequency)
                for ii = 1:length(obj.frequency)
                    freqStr = [freqStr, num2str(obj.frequency(ii)) ', ']; %#ok<AGROW>
                end
                freqStr = freqStr(1:end-2);
            end
            
            freqRestStr = '';
            if ~isempty(obj.frequencyRestrictions)
                for ii = 1:length(obj.frequencyRestrictions)
                    freqRestStr = [freqRestStr, num2str(obj.frequencyRestrictions(ii)) ', ']; %#ok<AGROW>
                end
                freqRestStr = freqRestStr(1:end-2);
            end
            
            table = cell(6 + length(obj.lossFunc) + length(obj.restrictions), 2);

            table(1:7,:) = {
                'Name: ',obj.name
                'Description: ',obj.description
                'Weights: ', weightsStr
                'Frequency: ', freqStr
                'Frequency (restrictions): ', freqRestStr
                'Mapping: ',obj.mapping
                'Loss function: ',obj.lossFunc{1}
            };
            for ii = 2:length(obj.lossFunc)
                table(6 + ii,:) = {'',obj.lossFunc{ii}};
            end
            numLoss = length(obj.lossFunc);
            for ii = 1:length(obj.restrictions)
                table(6 + numLoss + ii,:) = {'',obj.restrictions{ii}};
            end
            table{6 + numLoss + 1,1} = 'Restrictions: ';
            
            disp([char(table(:,1)),char(table(:,2))]);
            
        end
        
        function namesOfRest = names(obj)
            obj         = obj(:);
            namesOfRest = {obj.name};
        end
        
        function obj = setWeight(obj,index,value)
            obj.weights(index) = value;
        end

        function s = get(obj)
            
            obj = obj(:);
            s = struct(...
                'restricted','',...
                'parameters',cell(1,size(obj,1)),...
                'variables',[],...
                'frequency',[],...
                'mapping','',...
                'R_scale',[] ... 
            );
            for ii = 1:size(obj,1)
                s(ii).restricted = obj(ii).restricted;
                s(ii).parameters = obj(ii).parameters;
                s(ii).variables  = obj(ii).variables;
                s(ii).frequency  = obj(ii).frequency;
                s(ii).mapping    = obj(ii).mapping;
                s(ii).R_scale    = obj(ii).R_scale;
            end
            
        end
        
    end
    
end
