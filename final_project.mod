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

# Models per number of rooms
set two_bedrooms = {'Golden Pier',
					'Weeping Willow', 'Picket Fence'};
set three_bedrooms = {'The Jackson',
					  'The Jackson Lake',
					  'Wind Row', 'Orangewood',
					  'Storeline', 'Docks Edge',
					  'Country Stream'};
set four_bedrooms = {'The Vanderbilt', 'The Hughes',
					 'The Vanderbilt Lake', 'The Hughes Lake',
					 'Grand Cypress', 'Grand Cypress Premium', 'Lazy Oak',
					 'Bayview', 'Bayview Premium'};
set five_bedrooms = {'The Trump',
					 'The Trump Lake'};

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
							
set affordable_houses = {'Golden Pier', 'Weeping Willow', 'Picket Fence'};

# Variables
var N{all_models} >= 0;
var N_TOTAL;

# Parameters
param profit{all_models};
param size{all_models};

param total_surface;

param outside_parking_spots{with_outside_parking};
param outside_parking_size;
param max_parking_space;

param quotas_bedrooms{nb_bedrooms in 2..5, BOUNDS};
param quotas_series{BOUNDS};
param quotas_models{BOUNDS};


param max_quotas_grandcypress_premium;
param max_quotas_bayview_premium;
param max_quotas_two_stories;
param min_quotas_affordability;


# Objective function
maximize total_profit: sum{m in all_models} profit[m]* N[m];


# Constraints
subject to total_houses: N_TOTAL = sum{m in all_models} N[m];
# QUESTION: Grand Estate Premium take 50 half-acre. Do we retrieve this to the 300 acre available? How do we count their roads and outside parking?
# OLD subject to Grandestates_premium_spots: sum{m in Grand_Estates_PREMIUM} N[m] <= 50; # Badly formulated, please rethink it
# OLD subject to limited_surface: sum{m in all_models diff Grand_Estates_PREMIUM} size[m]*N[m] <= total_surface; # total_surface defined as 275 acre: 300 - 50 half-acre for Grand Estate PREMIUM. To be discussed. Put total_surface back to 275 if keep OLD formulation
subject to Grandestates_premium_spots: sum{m in Grand_Estates_PREMIUM} N[m] >= 50;
subject to limited_surface: sum{m in all_models} size[m]*N[m] <= total_surface;

subject to diversity_grandestate_premium{m in Grand_Estates_PREMIUM}: N[m] >= 8;

# Quotas number of bedrooms
subject to quotas_min_two_bedrooms: sum{m in two_bedrooms} N[m] >= quotas_bedrooms[2, 'MIN']*N_TOTAL;
subject to quotas_max_two_bedrooms: sum{m in two_bedrooms} N[m] <= quotas_bedrooms[2, 'MAX']*N_TOTAL;

subject to quotas_min_three_bedrooms: sum{m in three_bedrooms} N[m] >= quotas_bedrooms[3, 'MIN']*N_TOTAL;
subject to quotas_max_three_bedrooms: sum{m in three_bedrooms} N[m] <= quotas_bedrooms[3, 'MAX']*N_TOTAL;

subject to quotas_min_four_bedrooms: sum{m in four_bedrooms} N[m] >= quotas_bedrooms[4, 'MIN']*N_TOTAL;
subject to quotas_max_four_bedrooms: sum{m in four_bedrooms} N[m] <= quotas_bedrooms[4, 'MAX']*N_TOTAL;

subject to quotas_min_five_bedrooms: sum{m in five_bedrooms} N[m] >= quotas_bedrooms[5, 'MIN']*N_TOTAL;
subject to quotas_max_five_bedrooms: sum{m in five_bedrooms} N[m] <= quotas_bedrooms[5, 'MAX']*N_TOTAL;


# Quotas series repartition
subject to quotas_min_grandestate: sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_grandestate: sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m] <= quotas_series['MAX']*N_TOTAL;

subject to quotas_min_glenwood: sum{m in Glen_Wood} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_glenwood: sum{m in Glen_Wood} N[m] <= quotas_series['MAX']*N_TOTAL;

subject to quotas_min_lakeview: sum{m in Lakeview} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_lakeview: sum{m in Lakeview} N[m] <= quotas_series['MAX']*N_TOTAL;

subject to quotas_min_condominiums: sum{m in Condominiums} N[m] >= quotas_series['MIN']*N_TOTAL;
subject to quotas_max_condominiums: sum{m in Condominiums} N[m] <= quotas_series['MAX']*N_TOTAL;


# Quotas models within each series
subject to quotas_min_models_grandestate{i in 1..4}:  N[member(i, Grand_Estates)] + N[member(i, Grand_Estates_PREMIUM)] >= quotas_models['MIN']*sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m];
subject to quotas_max_models_grandestate{i in 1..4}:  N[member(i, Grand_Estates)] + N[member(i, Grand_Estates_PREMIUM)] <= quotas_models['MAX']*sum{m in Grand_Estates union Grand_Estates_PREMIUM} N[m];


		# Treat Grand Cypress and Grand Cypress Premium together
subject to quotas_min_models_glenwood{m in Glen_Wood diff {'Grand Cypress', 'Grand Cypress Premium'}}:  N[m] >= quotas_models['MIN']*sum{M in Glen_Wood} N[M];
subject to quotas_max_models_glenwood{m in Glen_Wood diff {'Grand Cypress', 'Grand Cypress Premium'}}:  N[m] <= quotas_models['MAX']*sum{M in Glen_Wood} N[M];
subject to quotas_min_models_glenwood_cypress:  N['Grand Cypress'] + N['Grand Cypress Premium'] >= quotas_models['MIN']*sum{M in Glen_Wood} N[M];
subject to quotas_max_models_glenwood_cypress:  N['Grand Cypress'] + N['Grand Cypress Premium'] <= quotas_models['MAX']*sum{M in Glen_Wood} N[M];

		# Treat Bayview and Bayview Premium together
subject to quotas_min_models_lakeview{m in Lakeview diff {'Bayview', 'Bayview Premium'}}:  N[m] >= quotas_models['MIN']*sum{M in Lakeview} N[M];
subject to quotas_max_models_lakeview{m in Lakeview diff {'Bayview', 'Bayview Premium'}}:  N[m] <= quotas_models['MAX']*sum{M in Lakeview} N[M];
subject to quotas_min_models_lakeview_bayview:  N['Bayview'] + N['Bayview Premium'] >= quotas_models['MIN']*sum{M in Lakeview} N[M];
subject to quotas_max_models_lakeview_bayview:  N['Bayview'] + N['Bayview Premium'] <= quotas_models['MAX']*sum{M in Lakeview} N[M];

subject to quotas_min_models_condominiums{m in Condominiums}:  N[m] >= quotas_models['MIN']*sum{M in Condominiums} N[M];
subject to quotas_max_models_condominiums{m in Condominiums}:  N[m] <= quotas_models['MAX']*sum{M in Condominiums} N[M];


# Other quotas
subject to quotas_grandcypress_premium : N['Grand Cypress Premium'] <= max_quotas_grandcypress_premium*(N['Grand Cypress'] + N['Grand Cypress Premium']);
subject to quotas_bayview_premium : N['Bayview Premium'] <= max_quotas_bayview_premium*(N['Bayview'] + N['Bayview Premium']);
subject to surface_parkings: sum{m in with_outside_parking} outside_parking_size*N[m] <= max_parking_space;
subject to quotas_two_stories: sum{m in two_stories_without_condominiums} N[m] <= max_quotas_two_stories*sum{m in all_models diff Condominiums} N[m];
subject to quotas_affordability: sum{m in affordable_houses} N[m] >= min_quotas_affordability*N_TOTAL;


option solver cplex;
data final_project.dat;
option cplex_options 'sensitivity';
option presolve 0;

solve;

display N;
display _conname, _con.current, _con.down, _con.up;

reset;