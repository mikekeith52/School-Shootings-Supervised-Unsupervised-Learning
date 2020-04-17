# set wd
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

# Create function to summarize data by clusters
clust.sum<-function(df,col,k){
  summ<-list()
  colnum<-which(names(df)==as.character(col))
  for (i in 1:k){
    summ[[i]]<-summary(df[df[[colnum]]==k,])
  }
return(summ)
}

# Read in files
# Scrape data from WAPO website
D<-read.csv("https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv")
#############################
# Wash Post Data - D
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

# Manually change age groups of indv. obs. based on independent research
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

############################
### Modeling ###
############################
### Select variables we want to model
# This part, I took anything I thought could possibly be signficant,
# but which models we want to run and which variables to use
# Is a work in progress
D.main<-subset(D,select=c(
             casualties,
             enrollment,
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
             shooter.deceased
             #shooter.race.known,shooter.white,shooter.minority
))

summary(D.main)
apply(D.main,2,sd)

# Display how difficult it will be
library(corrplot)
library(tidyverse)
# View correlations
D.main %>%
 cor() %>%
 corrplot()

# PCA model to reduce dimensionality
pca.out<-prcomp(D.main,center=T,scale=T)
# Cumulative variance
pcs.var<-pca.out$sd^2
pve<-pcs.var/sum(pcs.var)
# Two PCs ~ 21% of the variance (1/5)
cumsum(pve)

# See weighting pattern
df.pca<-data.frame(pc1=pca.out$rotation[,1],pc2=pca.out$rotation[,2])
df.pca

# rotation suggests higher casualties in the bottom right
# resource officer in the middle (left) - shifted by casualties
# rifle towards the bottom (right)
# poverty arch on the top


# Take first two PCs
pcs<-predict(pca.out,D.main)
pc1<-pcs[,1]
pc2<-pcs[,2]
PCS<-pcs[,c(1,2)]

# Run model
set.seed(123)
# Initialize total within sum of squares error: wss

wss <- 0
# For 1 to 15 cluster centers
for (i in 1:10) {
  km.out <- kmeans(scale(PCS), centers = i, nstart=100, iter.max=1000)
  # Save total within sum of squares to wss variable
  wss[i] <- km.out$tot.withinss
}

# Plot total within sum of squares vs. number of clusters
par(cex.sub=.7)
plot(1:10, wss, type = "b",
     xlab = "Number of Clusters", 
     ylab = "Within groups sum of squares",
     main = "Choose k (Number of Clusters) Where Elbow Bends",
     sub = "K-means Clustering")

# Choose k where the elbow bends
k<-3

########### Run this together always ##############3
# Reset seed to make the numbering consistent across trials
set.seed(123)
km.out<-kmeans(scale(PCS),centers=3,iter.max=1000,nstart=100)
D.main$cluster.km.pc2<-km.out$cluster
table(D.main$cluster.km.pc2)

# Summarize the clustered df
clust.sum(D.main,"cluster.km.pc2",3)

D.main$lunch.proportion<-D$lunch.proportion
D.main$PC1<-pc1
D.main$PC2<-pc2

# View the precursory results
plot(x=D.main$PC1,y=D.main$PC2,col=as.factor(D.main$cluster.km.pc2))

# Change the cluster names
D.main$cluster.km.pc2<-as.character(ifelse(D.main$cluster.km.pc2==3,
  " Lower Poverty, Higher Casualties ",
  ifelse(D.main$cluster.km.pc2==2," Higher Poverty, Lower Casualties ",
  " Lower Poverty, Lower Casualties ")))
#######################################

library(tidyverse)
library(RColorBrewer)
library(ggrepel)
# Show the 3 clusters & high casualties line
ggplot(D.main,aes(y=PC2,x=PC1,col=as.factor(cluster.km.pc2)))+
  geom_point()+
  geom_label_repel(aes(label=ifelse(D$casualties>=17,
    paste0(D$date,", ",D$school_name,", ",D$casualties),'')),
    box.padding   = 0.35, 
    point.padding = 0.5,
    segment.color = 'grey50')+
  labs(y="Principal Component 2", x="Principal Component 1",
       col="Cluster Type")+
  ggtitle("Unsupervised Categorization of School Shooting Type")+
  scale_color_brewer(palette="Set1")+
  theme(plot.title = element_text(size = 14, face = "bold",hjust=.5),
    axis.title = element_text(size=10, face = "bold"),
    legend.position="bottom",legend.title=element_blank(),
    legend.text = element_text(colour="black", size=9, 
                                     face="bold"),
   legend.background = element_rect(fill="grey75",
                                  size=1, linetype="solid", 
                                  colour ="black"))

jpg(file='cluster_outcomes.jpeg')


# Show the poverty line
ggplot(D.main,aes(y=PC2,x=PC1,col=lunch.proportion*100))+
  geom_point()+
  geom_label_repel(aes(label=ifelse(D$lunch.proportion>=.99,
    paste0(D$date," - ",D$city,", ",D$state," - ",D$casualties),'')),
    box.padding   = 0.35, 
    point.padding = 0.5,
    segment.color = 'grey50')+
  scale_colour_gradient2(D$lunch.proportion, low = 'grey50', 
    mid = 'indianred1',
    high = 'indianred4', midpoint = 50, space = "Lab",
    na.value = "grey50", guide = "colourbar", aesthetics = "colour")+
  labs(y="Principal Component 2", x="Principal Component 1",
       col="Proportion Eligible for Reduce-Priced Lunch")+
  ggtitle("Percentage of Students in School Elgible for Reduce-Priced Lunch")+
  theme(plot.title = element_text(size = 14, face = "bold",hjust=.5),
    axis.title = element_text(size=10, face = "bold"),
    legend.position="bottom",legend.title=element_blank(),
    legend.text = element_text(colour="black", size=9, 
                                     face="bold"))

# Most impoverished schools show at most 2 casualties
# Most impoverished school to have more than 2 casualties
max(D$lunch.proportion[D$casualties>2])
# Name of that school
D$school_name[D$lunch.proportion==max(D$lunch.proportion[D$casualties>2])]
# Date
D$date[D$lunch.proportion==max(D$lunch.proportion[D$casualties>2])]
# That's the outlier in group 2
D$casualties[D$lunch.proportion==max(D$lunch.proportion[D$casualties>2])]

# Show the casualties line
man_colors<-colorRampPalette(brewer.pal(9,"YlOrRd"))(length(unique(D$casualties)))
ggplot(D.main,aes(y=PC2,x=PC1,col=as.factor(casualties)))+
  geom_point()+
  geom_label_repel(aes(label=ifelse(as.character(D$date)=="2/1/2018",
    paste0(D$date," - ",D$school_name," - ",D$casualties),'')),
    box.padding   = 0.35, 
    point.padding = 0.5,
    segment.color = 'grey50')+
  labs(y="Principal Component 2", x="Principal Component 1",
     col="Casualties",hjust=.5)+
  ggtitle("Higher Casualties Cluster around the Bottom-Right")+
  scale_color_manual(values=man_colors)+
  theme(plot.title = element_text(size = 14, face = "bold",hjust=.5),
    axis.title = element_text(size=10, face = "bold"),
    legend.text = element_text(colour="black", size=11, 
                               hjust=.5,face="bold"),
    panel.background=element_rect(fill="grey60"),
    panel.grid=element_line(color="grey80"))

jpg(file='cluster_casualties.jpeg')

# Show resource officer in unimpoverished schools with no casualties
D.main$resource_officer<-ifelse(D$resource_officer==1,T,F)
ggplot(D.main,aes(y=PC2,x=PC1,col=resource_officer))+
  geom_point()+
  geom_label_repel(aes(label=ifelse(D$resource_officer==1 & D$lunch.proportion<.25,
    paste0(D$date," - ",D$casualties),'')),
    box.padding   = 0.35, 
    point.padding = 0.5,
    segment.color = 'grey50')+
  labs(y="Principal Component 2", x="Principal Component 1",
       col="Resource Officer on Campus")+
  ggtitle("Resource Officer Makes Most Difference When Poverty is Higher")+
  theme(plot.title = element_text(size = 14, face = "bold",hjust=.5),
    axis.title = element_text(size=10, face = "bold"),
    legend.position="bottom",
    legend.text = element_text(colour="black", size=9, 
                                     face="bold"),
   legend.background = element_rect(fill="grey75",
                                  size=1, linetype="solid", 
                                  colour ="black"))+
  scale_color_brewer(palette="Set1")

jpg(file='cluster_poverty.jpeg')
