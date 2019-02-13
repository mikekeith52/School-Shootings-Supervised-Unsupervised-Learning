# School Shootings Introduction - data, purpose
Utilizing the coding language R, Data maintained by the Washington Post was employed to model school shooting casualties with a negative binomial model. K-means clustering was then used to classify school shootings into three distinct groups.

Data maintained by Washington Post GitHub page: https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv

jpeg files attached show general conclusions visually.

# Negative binomial model
The distribution in casualties seemed to follow a Poisson distribution generally with overdispersion, and the negative binomial estimation returned favaroable information criteria. The code for writing an visualizing this model are given in the Rscript.

Insights gleaned from the negative binomial model recorded in the following blog post:

http://econmikekeith.blogspot.com/2018/08/taking-statistical-approach-to-analyze.html

Summarizing the results of the study, and visualizing with `ggplot2`, the following conclusions are made:
- Resource officers on campus lead to higher casualties, except in high-poverty schools, all esle constant.


- More impoverished schools see fewer casualties generally.
- Rifles are weapons which cause the highest amounts of casualties.
- The legaility/illegality of a weapon is inconclusive as to how it affects casualties.
![Casualties decrease as poverty increases, and the fitted line representing schools with resource officers present is higher on the casualties axis](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/rifle_model_fitted_line.jpeg)

![Illegality of the weapon in causing casualties is inconclusive](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/illegal_weapon_fitted_line.jpeg)

Answering questions involving the above points was not my aim in doing this analysis, but these were the things I found most interesting at the conclusion.

# Cluster analysis
A cluster analysis seems to reinforce the implications of the negative binomial model.
Findings given in the following blog post:

http://econmikekeith.blogspot.com/2018/08/unsupervised-learning-to-classify-and.html

# Tableau

Interactive map underscoring the issue (from data taken from wikipedia--code to scrape the data given in Rscript):

https://public.tableau.com/profile/michael.keith6845#!/vizhome/SchoolShootingsMap/Map

# Publication

The results of all the above are published in Spire Magazine:

https://spiremagazine.com/2018/10/15/a-statistical-exploration-of-school-shootings/

