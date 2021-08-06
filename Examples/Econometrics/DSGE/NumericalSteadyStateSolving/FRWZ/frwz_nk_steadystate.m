function [ys,checque]=frwz_nk_steadystate(junk,exe) %#ok<INUSD>

% We need to declare some dynare variables as global
%------------------------------------------------------------------
global M_ options_ %oo_

% We need to get the parameters of the model to be able to solve 
% the steady state
%_-----------------------------------------------------------------
way2getparams = 2;
for j = 1:M_.param_nbr
	pname = deblank(M_.param_names(j,:));
    switch way2getparams
        case 1% this is good but takes time
            eval([pname,'=get_param_by_name(pname);'])
        case 2% this is fast: but dangerous if list of parameters reordered like perhaps in dynare version 3
            eval([pname,'=M_.params(j);'])
        case 3 
            % this approach gets the ids once and for all so as to avoid
            % the use of strmach, which seems costly. if the mod file
            % changes and the function not refreshed, we have a problem.
            if isnan(params_id(j))
                params_id(j) = strmatch(pname,M_.param_names,'exact');
            end
            eval([pname,'=M_.params(params_id(j));'])
    end
end

%==================================================================
% Solution
%==================================================================
PAI = 1;
Y   = (eta-1)/eta;
R   = exp(mu)/betta*PAI;
RR  = R/PAI;

%==================================================================
% Assign the steady state variables to the output variable ys
%==================================================================

%##

if isfield(M_,'orig_model')
    my_endo_nbr = M_.orig_model.orig_endo_nbr;
    mylist      = M_.orig_model.endo_names;
else
    my_endo_nbr = M_.orig_endo_nbr;
    mylist      = M_.endo_names;
end

checque = 0;
if isfield(options_,'ReestimateTheSteadyState') && options_.ReestimateTheSteadyState == 0
	ys = options_.ys;
	return
end

ys   = nan(my_endo_nbr,1);
list = [];
for j=1:my_endo_nbr
    try
        ys(j) = eval(mylist(j,:)); % <--- ys(j)=eval(M_.endo_names(j,:));
    catch
        list = [list,j];
    end
end

if ~isempty(list)
    disp(mylist(list,:))
    error('The list above are not assign a steady-state')
end
