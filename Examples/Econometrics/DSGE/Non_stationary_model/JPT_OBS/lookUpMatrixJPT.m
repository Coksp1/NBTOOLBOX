%--------------------------------------------------------------------------
% This is a input file to the nb_graph_ts class
%--------------------------------------------------------------------------
% Must be a cell on the format:
%   - first column  : The expression (variable) to look up
%   - second column : The english text to match the given expression
%   - third column  : The norwegian text to match the given expression
%--------------------------------------------------------------------------
obj.lookUpMatrix = {
'C_NW',             'Consumption',                      'Konsum';
'DPQ_P_NW',         'Inflation',                        'Inflasjon';
'DPQ_W_NW',         'Wage inflation',                   'Lønnsinflasjon';
'I_NW',             'Investment',                       'Investeringer';   
'K_NW',             'Capital',                          'Kapital';
'L_NW',             'Hours worked',                     'Timeverk';
'NAT_Y_NW',         'Output',                           'Produksjons';
'RN3M_NW',          'Money market rate',                'Pengemarkedsrenten';
};
