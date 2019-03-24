# School Shootings Introduction - data, purpose
Utilizing the coding language R, Data maintained by the Washington Post was employed to model school shooting casualties with a negative binomial model. K-means clustering was then used to classify school shootings into three distinct groups.

Data maintained by Washington Post GitHub page: https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv

jpeg files attached show general conclusions visually.

# Negative binomial model
The distribution of casualties seemed to follow a Poisson distribution generally with overdispersion, and the negative binomial estimation returned more favaroable information criteria than a Poisson regression or normal linear regression. The code for writing and visualizing this model is given in the Rscript.

A negative binomial model is normally used when the data to be predicted follows a Poisson distribution but there is a large amount overdispersion--the variance is much greater than the mean. That was the case for the phenomenon of interest in this case, casualties per school shooting, where the mean is 1.9 and variance is 19.2.

Insights gleaned from the negative binomial model are recorded in the following blog post:

http://econmikekeith.blogspot.com/2018/08/taking-statistical-approach-to-analyze.html

Summarizing the results of the study, and visualizing with `ggplot2`, the following conclusions are made:
- Resource officers on campus lead to higher casualties, except in high-poverty schools, all esle constant.


- More impoverished schools see fewer casualties generally.
- Rifles are the weapons which cause the highest amounts of casualties.
- The legaility/illegality of a weapon is inconclusive as to how it affects casualties.

**Casualties decrease as poverty increases, and the fitted line representing schools with resource officers present is higher on the casualties axis**

![Casualties decrease as poverty increases, and the fitted line representing schools with resource officers present is higher on the casualties axis](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/RO_model_fitted_line.jpeg)

**Rifles are indicative of higher casualties**

![](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/rifle_model_fitted_line.jpeg)

**Illegality of the weapon in causing casualties is inconclusive**

![Illegality of the weapon in causing casualties is inconclusive](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/illegal_weapon_fitted_line.jpeg)

Answering questions involving the above points was not my aim in doing this analysis, but these were the things I found most interesting at the conclusion.

# Cluster analysis
A cluster analysis seems to reinforce the implications of the negative binomial model.
Findings given in the following blog post:

http://econmikekeith.blogspot.com/2018/08/unsupervised-learning-to-classify-and.html

## Cluster analysis approach
After trying several different cluster analysis options, I decided to reduce the dimensionality of the dataset using two principal components, capturing 20.6% of the variance in the dataset. Then, a k-means cluster analysis with three centers seemed to return an intuitive breakdown of the data.

*With three centers, the clusters can be viewed in the following visualization:*

![](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/cluster_outcomes.jpeg)

The interpretation can be thought of in the following manner:

- **Cluster 1:** High-casualty, low-poverty
-- These are the points in the bottom-right
-- highlighted by several notorious shootings, such as Marjory Stoneman Douglas and Columbine
- **Cluster 2:** Low-casualty, high-poverty
-- These are the points in the top-middle
- **Cluster 3:** Low-casualty, low-povery
-- These are the points in the bottom-left

Using these interpretations, we can think of the first principal component as the high-casualty, low-poverty component, and the second principal component as the high-poverty, low-casualty component. Indeed, looking at the rotation, that is what is suggested:

|Variable|PC1 Rotation|PC2 Rotation|
|------|------|-----|
|casualties|0.204|-0.209|
|lunch2550|0.123|-0.010|
|lunch5075|-0.028|0.265|
|lunch75.plus|-0.137|0.106|

*The lunch variables are binary - first one, lunch2550, is 1 if the school has between 25-50% of the student body eligible for a reduced-price lunch program, and 0 otherwise, and so forth through the three lunch-related variables - these were the proxies used to represent poverty levels in the analysis*

Other breakdowns of the data seem to confirm these findings:

**High casulaties cluster to the bottom-right of the graph**

![](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/cluster_casualties.jpeg)

**High poverty clusters to the middle / left of the graph

![](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/cluster_poverty.jpeg)

# Tableau

The link below is to an interactive map that highlights every school shooting listed on wikipedia in an interactive manner, breaking down by number of casualties and the era in which the shooting occored. The data is prepped for this analysis in the School_Shooting_Poisson_RScript.R file, where an api is used to call and manipulate the data directly from Wikipedia.

https://public.tableau.com/profile/michael.keith6845#!/vizhome/SchoolShootingsMap/Map

![](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/Tableau%20map%20-%20SS.PNG)

# Publication

The results of all the above are published in Spire Magazine in a format understandable to non-technical readers:

https://spiremagazine.com/2018/10/15/a-statistical-exploration-of-school-shootings/

# R Code
R code is attached to the repository and will not be expounded here, other than to highlight where each component is located:

- Code for supervised learning in the attached School_Shooting_Poisson_RScript.R
- Code for unsupervised learning in the attached School_Shooting_unsupervised_RScript.R
