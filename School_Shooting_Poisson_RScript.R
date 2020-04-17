# Install needed packages
install.packages(c("rvest","stringi"))
install.packages("plyr")
install.packages("MASS")
install.packages("lubridate")
install.packages("corrplot")

# CHANGE TO YOUR WORKING DIRECTORY
setwd("C:\\Users\\uger7\\Desktop\\Data Incubator\\School Shooting")


# Create function to find a keyword in a column
# This function will output a column of 0/1 if
# The column row you reference contains the keyword
# you choose
pdum<-function(kw,col,type=c(1,0)){ # can also be c(T,F)
  t<-as.data.frame(grep(as.character(kw),col,ignore.case=T))
  t$one<-type[1]
  colnames(t)<-c("col1","dummy") 
  t2<-as.data.frame(grep(as.character(kw),col,ignore.case=T,
    invert=T))
  t2$zero<-type[2]
  colnames(t2)<-c("col1","dummy")
  t3<-rbind(t,t2)
  t3<-t3[order(t3$col1),]
  return(t3$dummy)
}

# Create a function to show Information Criteria
ic<-function(name="model",model){
  return(data.frame(Model=name,
         LL=logLik(model),
         AIC=AIC(model),
         BIC=BIC(model)))
}

# Read in files
# Scrape data from WAPO website - don't have to change this path
D<-read.csv("https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv")
write.csv(D,"wapo_ss_raw_data.csv")

# Clone data in case we want to reference it later
D2<-D

# Create the number of shooters variable (either one or two)
D$two_shooters<-ifelse(is.na(D$age_shooter2)!=T,1,0)

# Create weapon type (wt) dummy variables
# Technically, data will be biased by doing this,
# bc unknown could be a handgun or rigle, etc.
# But I don't know a way around this
D$weapon<-as.character(D$weapon)
D$wt.unkown<-ifelse(D$weapon=="",1,0)
D$wt.known<-ifelse(D$weapon!="",1,0)
D$wt.handgun<-pdum("handgun",D$weapon)+pdum("revolver",D$weapon)
D$wt.handgun<-ifelse(D$wt.handgun==0,0,1)
D$wt.shotgun<-pdum("shotgun",D$weapon)
D$wt.rifle<-pdum("rifle",D$weapon)
D$wt.assault<-pdum("AK",D$weapon)+pdum("assault",D$weapon)
D$wt.assault<-ifelse(D$wt.assault==0,0,1)

# Create weapon source (ws) dummy variables - make known/unknown
D$weapon_source<-as.character(D$weapon_source)
D$ws.unknown<-ifelse(D$weapon_source=="",1,0)
D$ws.known<-ifelse(D$weapon_source!="",1,0)
D$ws.illegal<-pdum("stolen",D$weapon_source)+pdum("illegally",D$weapon_source)
D$ws.friend<-pdum("friend",D$weapon_source)
D$ws.relative_ext<-pdum("relative",D$weapon_source)+pdum("uncle",D$weapon_source)
D$ws.relative_imm<-pdum("father",D$weapon_source)+pdum("mother",D$weapon_source)+
  pdum("parent",D$weapon_source)+pdum("brother",D$weapon_source)+
  pdum("home",D$weapon_source)
D$ws.relative_imm<-ifelse(D$ws.relative_imm>=1,1,0)
D$ws.police<-pdum("police",D$weapon_source)+pdum("department",D$weapon_source)


# Create a one-off cloned dataset for creating columns
# used for reference only
D3<-D

# Count minorities
# Again, replace unkown values with zeros, not a great strategy!
D3$hawaiian_native_pacific_islander<-ifelse(is.na(D3$hawaiian_native_pacific_islander)==T,
  0,D3$hawaiian_native_pacific_islander)
D3$american_indian_alaska_native<-ifelse(is.na(D3$american_indian_alaska_native)==T,
  0,D3$american_indian_alaska_native)
D3$asian<-ifelse(is.na(D3$asian)==T,
  0,D3$asian)
D3$hispanic<-ifelse(is.na(D3$hispanic)==T,
  0,D3$hispanic)
D3$black<-ifelse(D3$black=="",
  0,D3$black)
D3$white<-ifelse(D3$white=="",
  0,D3$white)

# Add the minority columns together in the main dataset
D$minority=as.numeric(D3$hawaiian_native_pacific_islander)+
  as.numeric(D3$american_indian_alaska_native)+
  as.numeric(D3$asian)+as.numeric(D3$hispanic)+as.numeric(D3$black)
D$minority<-ifelse(is.na(D$minority)==T,0,D$minority)

### minority: keep as is -- interpretation: students who "identify" as minority

# Make the enrollment variable numeric
D3$enrollment<-enrollment<-gsub(",","",D$enrollment)
D$enrollment<-as.numeric(D3$enrollment)

# Create white and minority proportional variables
D$minority.proportion<-D$minority/D$enrollment

# This is not correct
D$white.proportion<-1-D$minority.proportion

# Create date variables
D$date_date<-as.Date(as.character(D$date),format="%m/%d/%Y")
D$year.n<-as.numeric(D$year)
D$month.n<-as.numeric(substr(D$date_date,6,7))

# Create time of day variable
D$time<-as.character(D$time)
D$time.unknown<-ifelse(D$time=="",1,0)
D$time.known<-ifelse(D$time!="",1,0)
D$morning<-pdum("AM",D$time)*D$time.known
D$afternoon<-pdum("PM",D$time)*D$time.known

# Create shooter type (st) dummy variables
D$shooter_relationship1<-as.character(D$shooter_relationship1)
D$st.unknown<-ifelse(D$shooter_relationship1=="",1,0)
D$st.known<-ifelse(D$shooter_relationship1!="",1,0)
D$st.student<-pdum("student",D$shooter_relationship1)
D$st.lover<-pdum("boyfriend",D$shooter_relationship1)+
  pdum("dating",D$shooter_relationship1)

# Create day of week column
D$dow<-ifelse(D$day_of_week=="Monday","Mon",
  ifelse(D$day_of_week=="Tuesday","Tues",
  ifelse(D$day_of_week=="Wednesday","Wed",
  ifelse(D$day_of_week=="Thursday","Thu",
  ifelse(D$day_of_week=="Friday","Fri",
  ifelse(D$day_of_week=="Saturday","Sat",
  ifelse(D$day_of_week=="Sunday","Sun","Unk"
)))))))

# Create school type dummy variables 
D$public<-pdum("public",D$school_type)
D$private<-pdum("private",D$school_type)

# Create reason for shooting (reas) dummy variables
D$shooting_type<-as.character(D$shooting_type)
D$reas.unclear<-pdum("unclear",D$shooting_type)+ifelse(D$shooting_type=="",1,0)
D$reas.known<-ifelse(D$reas.unclear==1,0,1)
D$reas.accidental<-pdum("accidental",D$shooting_type)-D$reas.unclear
D$reas.accidental<-ifelse(D$reas.accidental<=0,0,1)
D$reas.targeted<-pdum("targeted",D$shooting_type)-D$reas.unclear
D$reas.targeted<-ifelse(D$reas.targeted<=0,0,1)
D$reas.indiscriminate<-pdum("indiscriminate",D$shooting_type)-D$reas.unclear
D$reas.indiscriminate<-ifelse(D$reas.indiscriminate<=0,0,1)

# Greate gender dummy
D$gender_shooter1<-as.character(D$gender_shooter1)
D$gender.known<-ifelse(D$gender_shooter1=="",1,0)
D$gender.known<-ifelse(D$gender_shooter1!="",1,0)
D$gender.female<-pdum("f",D$gender_shooter1)
D$gender.male<-pdum("m",D$gender_shooter1)

# Create age dummy variables (replacing NAs with zeros)
D3$age<-as.numeric(D$age_shooter1)
D3$age<-ifelse(is.na(D3$age)==T,0,D3$age)
D$age.adult<-ifelse(D3$age>=18,1,0)
D$age.teen<-ifelse(D3$age<18 & D3$age>=12,1,0)
D$age.child<-ifelse(D3$age<12 & D3$age>0,1,0)
D$age.known<-ifelse(D3$age>0,1,0)
D$age.unk<-ifelse(D3$age==0,1,0)
D$age.child<-D$age.child*D$age.known

# Manually change ages - based on independent research
D$age.adult[35]<-1
D$age.teen[54]<-1
D$age.adult[66]<-1
D$age.adult[113]<-1
D$age.adult[119]<-1
D$age.adult[131]<-1
D$age.adult[160]<-1
D$age.teen[164]<-1
D$age.adult[167]<-1
D$age.child[173]<-1
D$age.teen[187]<-1
D$age.teen[195]<-1
D$age.teen[196]<-1
D$age.teen[201]<-1
D$age.teen[206]<-1
D$age.adult[213]<-1
D$age.adult[214]<-1
D$age.teen[221]<-1

D$age.known<-ifelse(D3$age!=0 | D$age.adult!=0 | D$age.teen!=0 | 
                  D$age.child!=0,1,D$age.known)
D$age.unk<-ifelse(D3$age==0 & D$age.adult==0 & D$age.teen==0 & 
                  D$age.child==0,1,D$age.unk)

# Check correlation with private schools and missing lunch programs
# Create lunch proportion dummy variables
D3$lunch<-as.numeric(D$lunch)
D3$lunch.unknown<-ifelse(is.na(D3$lunch)==T,1,0)
D$lunch.unknown<-ifelse(is.na(D3$lunch)==T,1,0)
D$lunch.known<-ifelse(is.na(D3$lunch)==F,1,0)
D3$lunch<-ifelse(is.na(D3$lunch)==T,0,D3$lunch)
D$lunch.proportion<-D3$lunch/D$enrollment
D$lunch2550<-ifelse(D$lunch.proportion>=.25 & D$lunch.proportion<.5,1,0)*D$lunch.known
D$lunch25.plus<-ifelse(D$lunch.proportion>=.25,1,0)*D$lunch.known
D$lunch5075<-ifelse(D$lunch.proportion>=.5 & D$lunch.proportion<.75,1,0)*D$lunch.known
D$lunch50.plus<-ifelse(D$lunch.proportion>=.5,1,0)*D$lunch.known
D$lunch75.plus<-ifelse(D$lunch.proportion>=.75,1,0)*D$lunch.known

# Create dummy variable indicating whether the shooter was deceased
D$shooter.deceased<-ifelse(is.na(D$shooter_deceased1)==T,0,
  D$shooter_deceased1)
D$shooter.race.unknown<-ifelse(D[[21]]=="",1,0)
D$shooter.race.known<-ifelse(D[[21]]!="",1,0)
D$shooter.white<-pdum("w",D[[21]])
D$shooter.minority<-pdum("b",D[[21]])+pdum("h",D[[21]])+pdum("ai",D[[21]])

# Write out full dataset
write.csv(D,"wapo_df_all_variables.csv")

############################
### Modeling ###
############################
### Select variables we want to model
# This part, I took anything I thought could possibly be signficant,
# but which models we want to run and which variables to use
# Is a work in progress
D.main<-subset(D,select=c(
             casualties,
             #enrollment,
             resource_officer,
             two_shooters,
             wt.known,wt.handgun,wt.shotgun,wt.rifle,#wt.assault,
             ws.known,ws.illegal,ws.friend,ws.relative_ext,
               ws.relative_imm,ws.police,
             minority.proportion,
             #time.known,morning,afternoon,
             #st.known,st.student,st.lover,
             #dow,
             public,
             reas.known,reas.accidental,reas.targeted,reas.indiscriminate,
             gender.known,gender.male,gender.female,
             #region,
             #age.known,
             age.adult,age.teen,age.child,
             lunch.known,lunch2550,lunch5075,lunch75.plus,
             shooter.deceased,
             shooter.race.known,shooter.white,shooter.minority
))

summary(D.main)
apply(D.main,2,sd)

write.csv(D.main,"shooting_modeling_data.csv")

# Linear model
lm.out<-lm(casualties~.,D.main)

# Show Poisson distribution
mean<-mean(D$casualties)
var<-sd(D$casualties)^2
range<-c(min(D$casualties):max(D$casualties))
p<-(exp(-mean)*(mean^range))/factorial(range)

par(mfrow=c(1,1))
barplot(table(D$casualties)/nrow(D),axis.lty = 1,
  main="Casualties in the Dataset Resemble a Poisson Distribution",
  ylab="Percent Frequency in Dataset",xlab="Number of Casualties")
lines(p,col="Dark Blue")
legend(x=7,y=.45,legend="Overlayed Poisson Distribution", #text.width=5,cex=.7,
  fill="Dark Blue",col="Dark Blue")
png(file = "casualties_distribution.png")

# Poisson model
pois.out<-glm(casualties~.,data=D.main,family="poisson")

# Negative binomial model
library("MASS")
nb.out<-glm.nb(casualties~.,data=D.main)

# Display model ICs in order
rbind(ic(name="OLS",lm.out),
       ic(name="Poisson",pois.out),
       ic(name="NB",nb.out))

summary(nb.out)

nb.write<-data.frame(nb.out$coef)
nb.write$effects<-nb.out$effects[1:nrow(nb.write)]

write.csv(nb.write,"summary_best_model.csv")

library(corrplot)
# View correlations
D.main %>%
  cor() %>%
 corrplot()

### Graphics
# What percent of shootings committed by males/females?
# School lunch program vs. casualties
library(ggplot2)
library(RColorBrewer)
D$resource_officer<-ifelse(D$resource_officer==1,T,F)
D$lunch.proportion<-D$lunch.proportion*100
D$wt.rifle<-ifelse(D$wt.rifle==1,T,F)
D$ws.illegal<-ifelse(D$ws.illegal==1,T,F)

# Resource officer
ggplot(D[D$lunch.known==1,], aes(x=lunch.proportion, y=casualties, 
    col=as.factor(resource_officer))) +
  geom_point() +
  geom_smooth(alpha=0,method=glm.nb) +
  labs(x = "Percentage of Students in School Eligible for Reduced-Cost Lunch",
    y = "Casualties",
    col = "Resource Officer on\nCampus During Shooting -\nFitted Line") +
  ggtitle("Resource Officer Suggests a Siginifcant Positive Effect on Casualties") +
  theme(plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size=10, face = "bold")) +  
  scale_color_brewer(palette="Set1")

jpg(file = "RO_model_fitted_line.jpeg")


# Rifle vs. no rifle
ggplot(D[D$wt.known==1,], aes(x=lunch.proportion, y=casualties, 
    col=wt.rifle)) +
  geom_point() +
  geom_smooth(alpha=0,method=glm.nb) +
  labs(x = "Percentage of Students in School Eligible for Reduced-Cost Lunch",
    y = "Casualties",
    col = "Shooter\nUsed Rifle -\nFitted Line") +
  ggtitle("Significantly More Casualties Caused When Rifle is Used in School Shooting") +
  theme(plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size=10, face = "bold")) +
  scale_color_brewer(palette="Set1")

jpg(file = "rifle_model_fitted_line.jpeg")

# Illegal vs. Legal
ggplot(D[D$ws.known==1,], aes(x=lunch.proportion, y=casualties, 
    col=as.factor(ws.illegal))) +
  geom_point() +
  geom_smooth(alpha=0,method=glm.nb) +
  labs(x = "Percentage of Students in School Eligible for Reduced-Cost Lunch",
    y = "Casualties",
    col = "Weapon Obtained\nIllegally -\nFitted Line") +
  ggtitle("The Effect of Illegally Obtained Weapons on Casualties is Inconclusive") +
  theme(plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size=10, face = "bold")) +
  scale_color_brewer(palette="Set1")

jpg(file = "illegal_weapon_fitted_line.jpeg")
