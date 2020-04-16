# School Shootings Introduction - data, purpose
Utilizing R, [data](https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv) maintained by the Washington Post was employed to model school shooting casualties with a negative binomial model (which models a Poisson distribution with overdipersion). K-means clustering was then used to classify school shootings into three distinct groups.

## Publication
The findings have been [published](https://spiremagazine.com/2018/10/15/a-statistical-exploration-of-school-shootings/) in a Florida State student magazine, Spire.  

## Caveats
The dataset utilized does not contain enough observations to offer any reliable predictive power. This project attempted to be fully descriptive in nature. Although some of the findings can be disputed, through solid statistical techniques, there were interesting insights gleaned, especially about resource officers' roles in reducing and/or increasing casualties in a given school shooting and which types of weapons cause the most casualties.  

## Research Question
Can the number of casualties per school shooting be described statistically with the factors in this dataset?

## Process
The data was cleaned and missing data was given its own category of unknown. All data was converted to numeric. Independent research was perfomed to fill in all missing data, especially the age of the shooter(s), where possible. Ages of shooters were grouped into buckets to reduce error rate of filling data.  

|casualties|resource_officer|two_shooters|wt.known|wt.handgun|wt.shotgun|wt.rifle|ws.known|ws.illegal|ws.friend|ws.relative_ext|ws.relative_imm|ws.police|minority.proportion|public|reas.known|reas.accidental|reas.targeted|reas.indiscriminate|gender.known|gender.male|gender.female|age.adult|age.teen|age.child|lunch.known|lunch2550|lunch5075|lunch75.plus|shooter.deceased|shooter.race.known|shooter.white|shooter.minority|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|34|1|1|1|1|1|0|1|0|1|0|0|0|0.092620865|1|1|0|0|1|1|1|0|1|0|0|1|0|0|0|1|1|1|0|
|1|0|0|1|1|0|0|0|0|0|0|0|0|0.991496599|1|1|0|1|0|1|1|0|0|1|0|1|0|0|1|0|0|0|0|
|6|1|0|1|1|0|1|0|0|0|0|0|0|0.131482834|1|1|0|0|1|1|1|0|0|1|0|1|0|0|0|0|1|1|0|
|1|1|0|1|1|0|0|1|0|1|0|0|0|0.933587544|1|1|0|1|0|1|1|0|0|1|0|1|0|1|0|0|0|0|0|
|1|0|0|0|0|0|0|0|0|0|0|0|0|0.964157706|1|1|0|1|0|1|1|0|0|0|0|1|1|0|0|0|0|0|0|

The naming of the columns follow a logical convention. Most of the meanings of the columns can be deduced intutively. The following abbreviations were used:
- ws: weapon source. Example: ws.relative_ext = the weapon came from an extended relative
- wt: weapons type: Example: wt.shotgun = the shooter used a shotgun
- reas: reason. Example: reas.accidental = the shooting was accidental, reas.targeted = the shooter was going after a specific individual(s)
- lunch: the percentage of students eligibile for a reduced-priced lunch program. Proxy variable for poverty. Example: lunch5075 = between 50% and 75% of the student population is eligible for this program

The final dataset included 238 rows of data (each row represents a shooting), with 32 independent variables to predict 1 target (casualties). 

A linear model, poisson model, and negative binomial model were each specified with the cleaned model inputs. The negative binomial returned the best information criteria.  

|Model|LL|AIC|BIC|
|---|---|---|---|
|Linear|-629.1234|1326.2468|1444.3040|
|Poisson|-390.5976|847.1951|961.7801|
|NB|-358.5415|785.0829|903.1401|

A summary of the model outputs:

```
Call:
glm.nb(formula = casualties ~ ., data = D.main, init.theta = 2.843998801, 
    link = log)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-2.3518  -0.9645  -0.1604   0.4071   2.7071  

Coefficients:
                    Estimate Std. Error z value Pr(>|z|)    
(Intercept)         -0.57227    0.53524  -1.069  0.28499    
resource_officer     0.56893    0.15737   3.615  0.00030 ***
two_shooters         0.38337    0.43444   0.882  0.37753    
wt.known            -0.36334    0.37096  -0.979  0.32736    
wt.handgun           0.50435    0.27736   1.818  0.06900 .  
wt.shotgun           0.48950    0.28514   1.717  0.08603 .  
wt.rifle             0.90682    0.28543   3.177  0.00149 ** 
ws.known             0.34667    0.27370   1.267  0.20529    
ws.illegal          -0.45373    0.54674  -0.830  0.40660    
ws.friend            0.21905    0.41421   0.529  0.59692    
ws.relative_ext      0.34126    0.53964   0.632  0.52714    
ws.relative_imm      0.58613    0.29489   1.988  0.04685 *  
ws.police           -0.22585    0.41142  -0.549  0.58303    
minority.proportion  0.55106    0.31299   1.761  0.07830 .  
public              -0.54770    0.49757  -1.101  0.27101    
reas.known           0.02566    0.52809   0.049  0.96125    
reas.accidental      0.68259    0.35277   1.935  0.05300 .  
reas.targeted        0.10908    0.29894   0.365  0.71520    
reas.indiscriminate  0.77559    0.31505   2.462  0.01382 *  
gender.known         1.26671    1.76662   0.717  0.47336    
gender.male         -1.48035    1.71844  -0.861  0.38899    
gender.female       -1.34100    1.75282  -0.765  0.44424    
age.adult            0.06551    0.28200   0.232  0.81631    
age.teen            -0.18750    0.29357  -0.639  0.52302    
age.child           -0.70879    0.58645  -1.209  0.22681    
lunch.known          0.77684    0.38564   2.014  0.04397 *  
lunch2550           -0.70990    0.22885  -3.102  0.00192 ** 
lunch5075           -0.67489    0.25244  -2.673  0.00751 ** 
lunch75.plus        -0.65428    0.28031  -2.334  0.01959 *  
shooter.deceased     0.14610    0.20016   0.730  0.46544    
shooter.race.known  -1.40270    1.25942  -1.114  0.26538    
shooter.white        1.68253    1.25697   1.339  0.18071    
shooter.minority     1.38222    1.26253   1.095  0.27360    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for Negative Binomial(2.844) family taken to be 1)

    Null deviance: 453.86  on 237  degrees of freedom
Residual deviance: 210.78  on 205  degrees of freedom
AIC: 785.08

Number of Fisher Scoring iterations: 1


              Theta:  2.844 
          Std. Err.:  0.627 

 2 x log-likelihood:  -717.083 
 ```
 
 Distribution of the dependent variable follows a Poisson shape with overdispersion:
 
 ![](https://github.com/mikekeith52/School-Shootings-Supervised_Usupervised-Learning/blob/master/casualties_distribution.png)

The statistically significant inpupts at the 90% confidence level, which are the ones with a p-value less than 0.10, from the best model were then examined and interpreted. These included:
- resouce_officer (positive effect on casualties -- this can have several reasons, and I'm not sure there is one definitive answer)
- wt.handgun (positive effect on casualties compared to an unknown weapon type)
- wt.shotgun (positive effect on casualties compared to an unknown weapon type)
- wt.rifle (highest positive effect on casualties compared to an unknown weapon type)
- reas.indiscriminate (positive effect on casualties to an unknown reason)
- school lunch variables (as the proportion of students eligible for these reduced-priced lunch programs go up, casualties actually go down--probably due to the decreased notoriety one would get from targeting a low-income area vs. an affluent one)

This is not an all-inclusive list of the statistically significant variables, but these were the most interesting to interpret.  

After the Negative Binomial model was interpreted, a K-Means Cluster analysis was performed to further understand how the datapoints relate to one another. Using this method, school shootings were divided into three types and the findings from the statistical model were generally confirmed.  

## Key Findings
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

## Cluster analysis
A cluster analysis reinforces the implications of the negative binomial model. After trying several different cluster analysis options, I decided to reduce the dimensionality of the dataset using two principal components, capturing 20.6% of the variance in the dataset. Then, a k-means cluster analysis with three centers seemed to return an intuitive breakdown of the data.  

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

**High poverty clusters to the middle / left of the graph**

![](https://github.com/mikekeith52/School-Shootings-Usupervised-Learning/blob/master/cluster_poverty.jpeg)
