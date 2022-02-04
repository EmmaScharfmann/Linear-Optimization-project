# DEFINE SETS
	# Auxiliary set
set BOUNDS := {"MIN", "MAX"};

	# Models per series
set Grand_Estates = {'The Trump', 'The Vanderbilt', 'The Hughes', 'The Jackson'} ordered;
set Grand_Estates_PREMIUM = {'The Trump Lake', 'The Vanderbilt Lake', 'The Hughes Lake', 'The Jackson Lake'} ordered;
set Glen_Wood = {'Grand Cypress', 'Grand Cypress Premium', 'Lazy Oak', 'Wind Row', 'Orangewood'};
set Lakeview = {'Bayview', 'Bayview Premium', 'Storeline', 'Docks Edge', 'Golden Pier'};
set Condominiums = {'Country Stream', 'Weeping Willow', 'Picket Fence'};

set all_models = Grand_Estates union Grand_Estates_PREMIUM union Glen_Wood union Lakeview union Condominiums;


	# Models with other characteristics
set two_stories_without_condominiums = {'The Trump', 'The Vanderbilt',
				   'The Trump Lake', 'The Vanderbilt Lake',
				   'Grand Cypress', 'Grand Cypress Premium', 'Lazy Oak', 'Wind Row',
				   'Bayview', 'Bayview Premium', 'Storeline'};
set with_outside_parking = {'The Trump', 'The Vanderbilt', 'The Hughes',
							'The Trump Lake', 'The Vanderbilt Lake', 'The Hughes Lake',
							'Grand Cypress', 'Grand Cypress Premium', 'Lazy Oak', 'Wind Row', 'Orangewood',
							'Bayview', 'Bayview Premium', 'Storeline', 'Docks Edge',
							'Country Stream', 'Weeping Willow', 'Picket Fence'};
							
# Variables
	# General variables
var N{all_models} >= 0;
var N_TOTAL;

	# NEW VARIABLES: For Condominiums tax rate
var more_than_condominiums{{'Grand Estates', 'Glen Wood', 'Lakeview'}} binary;
var i integer; # tax rate
var N_tax{{'Grand Estates', 'Glen Wood', 'Lakeview'}, Condominiums}>=0;

	# NEW VARIABLES: For new Grand Estates Premium quotas
var z{Grand_Estates_PREMIUM} binary;

	# NEW VARIABLES: For sport field
var sport_build binary;
var N_extra_profit{all_models} >= 0;

# Parameters
	# Parameters base problem
param profit{all_models};
param selling_price{all_models};
param size{all_models};

param total_surface;
param N_MAX;

param outside_parking_spots{with_outside_parking};
param outside_parking_size;
param max_parking_space;

param quotas_series{BOUNDS};
param quotas_models{BOUNDS};

param max_quotas_grandcypress_premium;
param max_quotas_bayview_premium;
param max_quotas_two_stories;

	# NEW PARAMETER: For new tax rate
param tax_rate;

	# NEW PARAMETERS: For sport field
param sport_extra_cost;
param sport_space_loss;
param extra_profit{all_models};



# NEW Objective function
maximize total_profit: sum{m in all_models} profit[m]*N[m]
					 - sum{m in all_models diff Condominiums} tax_rate*selling_price[m]*N[m] - sum{m in Condominiums} 0.02*selling_price[m]* N[m] - sum{s in {'Grand Estates', 'Glen Wood', 'Lakeview'}, m in Condominiums} 0.02*selling_price[m]*N_tax[s,m]
					 + sum{m in all_models} extra_profit[m]*N_extra_profit[m] - sport_build*sport_extra_cost;


# Constraints
	# Base problem constraints
		##
subject to total_houses: N_TOTAL = sum{m in all_models} N[m];
subject to Grandestates_premium_spots: sum{m in Grand_Estates_PREMIUM} N[m] >= 50;
subject to limited_surface: sum{m in all_models} size[m]*N[m] <= total_surface - sport_build*sport_space_loss; # Corrected with potential sport field surface reduction

		##
subject to quotas_min_grandestate: sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_grandestate: sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m] <= quotas_series['MAX']*N_TOTAL;

subject to quotas_min_glenwood: sum{m in Glen_Wood} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_glenwood: sum{m in Glen_Wood} N[m] <= quotas_series['MAX']*N_TOTAL;

subject to quotas_min_lakeview: sum{m in Lakeview} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_lakeview: sum{m in Lakeview} N[m] <= quotas_series['MAX']*N_TOTAL;

subject to quotas_min_condominiums: sum{m in Condominiums} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_condominiums: sum{m in Condominiums} N[m] <= quotas_series['MAX']*N_TOTAL;

		##
subject to quotas_min_models_grandestate{k in 1..4}:  N[member(k, Grand_Estates)] + N[member(k, Grand_Estates_PREMIUM)] >= quotas_models['MIN']*sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m];
subject to quotas_max_models_grandestate{k in 1..4}:  N[member(k, Grand_Estates)] + N[member(k, Grand_Estates_PREMIUM)] <= quotas_models['MAX']*sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m];

		##
subject to quotas_min_models_glenwood{m in Glen_Wood diff {'Grand Cypress', 'Grand Cypress Premium'}}:  N[m] >= quotas_models['MIN']*sum{M in Glen_Wood} N[M];
subject to quotas_max_models_glenwood{m in Glen_Wood diff {'Grand Cypress', 'Grand Cypress Premium'}}:  N[m] <= quotas_models['MAX']*sum{M in Glen_Wood} N[M];
subject to quotas_min_models_glenwood_cypress:  N['Grand Cypress'] + N['Grand Cypress Premium'] >= quotas_models['MIN']*sum{M in Glen_Wood} N[M];
subject to quotas_max_models_glenwood_cypress:  N['Grand Cypress'] + N['Grand Cypress Premium'] <= quotas_models['MAX']*sum{M in Glen_Wood} N[M];

		##
subject to quotas_min_models_lakeview{m in Lakeview diff {'Bayview', 'Bayview Premium'}}:  N[m] >= quotas_models['MIN']*sum{M in Lakeview} N[M];
subject to quotas_max_models_lakeview{m in Lakeview diff {'Bayview', 'Bayview Premium'}}:  N[m] <= quotas_models['MAX']*sum{M in Lakeview} N[M];
subject to quotas_min_models_lakeview_bayview:  N['Bayview'] + N['Bayview Premium'] >= quotas_models['MIN']*sum{M in Lakeview} N[M];
subject to quotas_max_models_lakeview_bayview:  N['Bayview'] + N['Bayview Premium'] <= quotas_models['MAX']*sum{M in Lakeview} N[M];

subject to quotas_min_models_condominiums{m in Condominiums}:  N[m] >= quotas_models['MIN']*sum{M in Condominiums} N[M];
subject to quotas_max_models_condominiums{m in Condominiums}:  N[m] <= quotas_models['MAX']*sum{M in Condominiums} N[M];

		##
subject to quotas_grandcypress_premium : N['Grand Cypress Premium'] <= max_quotas_grandcypress_premium*(N['Grand Cypress'] + N['Grand Cypress Premium']);
subject to quotas_bayview_premium : N['Bayview Premium'] <= max_quotas_bayview_premium*(N['Bayview'] + N['Bayview Premium']);
subject to surface_parkings: sum{m in with_outside_parking} outside_parking_size*N[m] <= max_parking_space;
subject to quotas_two_stories: sum{m in two_stories_without_condominiums} N[m] <= max_quotas_two_stories*sum{m in all_models diff Condominiums} N[m];


	# NEW CONSTRAINTS: Compute rank for new tax rate for Condominiums
subject to condominiums_vs_grandestates_1: more_than_condominiums['Grand Estates'] >= (sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m] - sum{m in Condominiums} N[m])/N_MAX; # more GE => binary = 1
subject to condominiums_vs_grandestates_2: more_than_condominiums['Grand Estates'] <= 1 + (sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m] - sum{m in Condominiums} N[m])/N_MAX; # less GE => binary = 0

subject to condominiums_vs_glenwood_1: more_than_condominiums['Glen Wood'] >= (sum{m in Glen_Wood} N[m] - sum{m in Condominiums} N[m])/N_MAX; # more GW => binary = 1
subject to condominiums_vs_glenwood_2: more_than_condominiums['Glen Wood'] <= 1 + (sum{m in Glen_Wood} N[m] - sum{m in Condominiums} N[m])/N_MAX; # less GW => binary = 0

subject to condominiums_vs_lakeview_1: more_than_condominiums['Lakeview'] >= (sum{m in Lakeview} N[m] - sum{m in Condominiums} N[m])/N_MAX; # more LV => binary = 1
subject to condominiums_vs_lakeview_2: more_than_condominiums['Lakeview'] <= 1 + (sum{m in Lakeview} N[m] - sum{m in Condominiums} N[m])/N_MAX; # less LV => binary = 0


subject to set_tax_rate: i = 1 + sum{s in {'Grand Estates', 'Glen Wood', 'Lakeview'}} more_than_condominiums[s]; # easy way to control i, but can't use i directly in objective due to non-linearity. Two next constraints instead
subject to build_tax_1{s in {'Grand Estates', 'Glen Wood', 'Lakeview'}, m in Condominiums}: N_tax[s, m] <= more_than_condominiums[s]*N_MAX; # more_than_condominiums[s] = 0 => N_tax[s, m] = 0
subject to build_tax_2{s in {'Grand Estates', 'Glen Wood', 'Lakeview'}, m in Condominiums}: N_tax[s, m] - N[m] <= more_than_condominiums[s]/N_MAX + (1 - more_than_condominiums[s])*N_MAX; # more_than_condominiums[s] = 1 => N_tax[s, m] = N[m]


	# NEW CONSTRAINTS: New way to define diversity among Grand Estate Premium
subject to at_least_three_diversity: sum{m in Grand_Estates_PREMIUM} z[m] >= 3;
subject to diversity_grandestate_premium{m in Grand_Estates_PREMIUM}: N[m] >= 8*z[m];


	# NEW CONSTAINTS: Decide if we build sports field
subject to build_sport_1{m in all_models}: N_extra_profit[m] <= sport_build*N_MAX; # sport_build = 0 => N_extra_profit = 0
subject to build_sport_2{m in all_models}: N_extra_profit[m] - N[m] <= sport_build/N_MAX + (1 - sport_build)*N_MAX; # sport_build = 1 => N_extra_profit = N

#subject to force_sport_build: sport_build>=0.5;


option solver cplex;
data final_project_modified.dat;
option cplex_options 'sensitivity';
option presolve 0;

solve;

#display i, sport_build, sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m], sum{m in Glen_Wood} N[m], sum{m in Lakeview} N[m], sum{m in Condominiums} N[m];
#display N, i, sport_build;
display _conname, _con.current, _con.down, _con.up;

reset;