# School-Shootings-Usupervised-Learning
Utilizing the coding language R, WAPO data was used to model school shooting casualties with a negative binomial model. K-means clustering then used to classify school shootings into three distinct groups.

Data maintained by Washington Post GitHub page: https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv

# Negative binomial model
The distribution in casualties seemed to follow a poisson generally with overdispersion, and negative binomial returned favaroable information criteria

Insights gleaned from the negative binomial model recorded in the following blog post:

http://econmikekeith.blogspot.com/2018/08/taking-statistical-approach-to-analyze.html

The model suggests that resource officers lead to higher casualties, except in high-poverty schools
More impoverished schools see fewer casualties generally
Rifles are the weapons which cause the highest amounts of casualties
The legaility/illegality is inconclusive as to how it affects casualties

# Cluster analysis
A cluster analysis seems to reinforce the implications of the negative binomial model
Findings given in the following blog post:

http://econmikekeith.blogspot.com/2018/08/unsupervised-learning-to-classify-and.html
