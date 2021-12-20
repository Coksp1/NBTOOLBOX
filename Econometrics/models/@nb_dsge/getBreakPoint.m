function [options,isBreakP,isTimeOfBreakP,states,filterType] = getBreakPoint(options)
% Syntax:
%
% [options,isBreakP,isTimeOfBreakP,states,filterType] = ...
%                               nb_dsge.getBreakPoint(options)
%
% Description:
%
% Get information on break points.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    parser         = options.parser;
    if isempty(options.prior)
        estimated = {};
    else
        estimated = options.prior(:,1);
    end
    filterType     = 1;
    isBreakP       = false(length(estimated),1);
    isTimeOfBreakP = isBreakP;
    states         = [];
    if isfield(parser,'breakPoints')
        if ~nb_isempty(parser.breakPoints)
            
            % Is the estimated parameter a break-point parameter?
            breakP       = nb_dsge.getBreakPointParameters(parser,false);
            isBreakP     = ismember(estimated,breakP);   
            dataS        = nb_date.date2freq(options.dataStartDate);
            sDate        = dataS + (options.estim_start_ind - 1);
            eDate        = dataS + (options.estim_end_ind - 1);
            states       = nb_dsge.getStatesOfBreakPoint(parser,sDate,eDate);
            filterType   = 2;
            
            % Is the estimated parameter a break-point date?
            breakD         = nb_dsge.getBreakTimingParameters(parser,false);
            isTimeOfBreakP = ismember(estimated,breakD); 
            
            % Store initial value of break-points
            nBreaks     = parser.nBreaks;
            breakPoints = parser.breakPoints;
            for ii = 1:nBreaks
                breakPoints(ii).initDate = breakPoints(ii).date;
            end
            options.parser.breakPoints = breakPoints;
            
        end
    end
    
end
