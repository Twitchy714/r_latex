setwd("/home/lluc/Documents/R/marianne")

source("../functions.R")

data.new<-read.csv("Daten.relativ.neu.csv", sep=",", dec=".", header=T)

colnames(data.new)<-c("","","Substrate","treatment","rep","NH4+ (µmol g-1 DW)","sqNH4+ (µmol g-1 DW)","NO3- (µmol g-1 DW)","sqNO3- (µmol g-1 DW)","NPOC (µmol g-1 DW)","sqNPOC (µmol g-1 DW)","TN (µmol g-1 DW)","sqTN (µmol g-1 DW)","C mic (µmol g-1 DW)","sqC mic (µmol g-1 DW)","N mic (µmol g-1 DW)","sqN mic (µmol g-1 DW)","","C/N mic","sqC/N mic","Exoglucan (pmol g-1 min-1)","sqExoglucan (pmol g-1 min-1)","Endochit (pmol g-1 min-1)","","sqEndochit (pmol g-1 min-1)","","Phosph (pmol g-1 min-1)","sqPhosph (pmol g-1 min-1)","Protease (nmol g-1 min-1)","sqProtease (nmol g-1 min-1)","phenoloxidase (µmol h-1 g-1 DW)","sqphenoloxidase (µmol h-1 g-1 DW)","peroxidase","sqperoxidase","Cellulase-act (µg gluc g-1 DW h-1)","sqCellulase-act (µg gluc g-1 DW h-1)","Protease-act (µg AS-N g-1 DW h-1)","sqProtease-act (µg AS-N g-1 DW h-1)","Bruttomineralisierung (µg NH4-N g-1 h-1)","sqBruttomineralisierung (µg NH4-N g-1 h-1)","Immobilisierung","sqImmobilisierung","Respiration","sqRespiration","Total bacteria(nmol %contr)","sqTotal bacteria(nmol %contr)","Gram+ bac","sqGram+ bac","Gram- bac","sqGram- bac","Fungi","sqFungi","0.751388889","sq0.751388888888889","Total bacteria(mol% in %kontr.)","sqTotal bacteria(mol% in %kontr.)","Gram+ bac","sqGram+ bac","Gram- bac","sqGram- bac","Fungi","sqFungi","0.751388889","sq0.751388888888889","APE13Cplfa","sqAPE13Cplfa","APE 13C total respiration","sqAPE 13C total respiration","Respired excess 13C (% of Microbial Biomass excess 13C)","sqRespired excess 13C (% of Microbial Biomass excess 13C)","Priming effect (% of control)")
data.new[,6]

data.new.means<-data.frame(matrix(nrow=length(levels(data.new[,1])), ncol=ncol(data.new)))
colnames(data.new.means)<-colnames(data.new)
rownames(data.new.means)<-levels(data.new[,1])
data.new.ci<-data.new.means
data.new.sig<-data.new.means
data.new.siglev<-data.new.means


?t.test
ttestp <- function(x) {
if (length(x)>1){
tmp<-t.test(x, null.value=100)
return(tmp$p.value/2)
} else {return(NA)}
}
i<-6

for(i in 6:ncol(data.new))
{
data.new.means[,i]<-tapply(data.new[is.na(data.new[,i])==F,i],data.new[is.na(data.new[,i])==F,1], mean)
data.new.sig[,i]<-tapply(data.new[is.na(data.new[,i])==F,i],data.new[is.na(data.new[,i])==F,1], function(x) ttestp(x))
data.new.siglev[,i]<-tapply(data.new[is.na(data.new[,i])==F,i],data.new[is.na(data.new[,i])==F,1], function(x) siglev(ttestp(x)))
}

data.new.sig<0.01


warnings()


write.csv(data.new.sig, "data.new.sig.csv")
write.csv(data.new.siglev, "data.new.siglev.csv")

data.new<-read.csv("Daten.relativ.neu.N.csv", sep=",", dec=".", header=T)

colnames(data.new)<-c("","","Substrate","treatment","rep","NH4+ (µmol g-1 DW)","sqNH4+ (µmol g-1 DW)","NO3- (µmol g-1 DW)","sqNO3- (µmol g-1 DW)","NPOC (µmol g-1 DW)","sqNPOC (µmol g-1 DW)","TN (µmol g-1 DW)","sqTN (µmol g-1 DW)","C mic (µmol g-1 DW)","sqC mic (µmol g-1 DW)","N mic (µmol g-1 DW)","sqN mic (µmol g-1 DW)","","C/N mic","sqC/N mic","Exoglucan (pmol g-1 min-1)","sqExoglucan (pmol g-1 min-1)","Endochit (pmol g-1 min-1)","","sqEndochit (pmol g-1 min-1)","","Phosph (pmol g-1 min-1)","sqPhosph (pmol g-1 min-1)","Protease (nmol g-1 min-1)","sqProtease (nmol g-1 min-1)","phenoloxidase (µmol h-1 g-1 DW)","sqphenoloxidase (µmol h-1 g-1 DW)","peroxidase","sqperoxidase","Cellulase-act (µg gluc g-1 DW h-1)","sqCellulase-act (µg gluc g-1 DW h-1)","Protease-act (µg AS-N g-1 DW h-1)","sqProtease-act (µg AS-N g-1 DW h-1)","Bruttomineralisierung (µg NH4-N g-1 h-1)","sqBruttomineralisierung (µg NH4-N g-1 h-1)","Immobilisierung","sqImmobilisierung","Respiration","sqRespiration","Total bacteria(nmol %contr)","sqTotal bacteria(nmol %contr)","Gram+ bac","sqGram+ bac","Gram- bac","sqGram- bac","Fungi","sqFungi","0.751388889","sq0.751388888888889","Total bacteria(mol% in %kontr.)","sqTotal bacteria(mol% in %kontr.)","Gram+ bac","sqGram+ bac","Gram- bac","sqGram- bac","Fungi","sqFungi","0.751388889","sq0.751388888888889","APE13Cplfa","sqAPE13Cplfa","APE 13C total respiration","sqAPE 13C total respiration","Respired excess 13C (% of Microbial Biomass excess 13C)","sqRespired excess 13C (% of Microbial Biomass excess 13C)","Priming effect (% of control)")
data.new[,6]

data.new.means<-data.frame(matrix(nrow=length(levels(data.new[,1])), ncol=ncol(data.new)))
colnames(data.new.means)<-colnames(data.new)
rownames(data.new.means)<-levels(data.new[,1])
data.new.ci<-data.new.means
data.new.sig<-data.new.means
data.new.siglev<-data.new.means


?t.test
ttestp <- function(x) {
if (length(x)>1){
tmp<-t.test(x, null.value=100)
return(tmp$p.value/2)
} else {return(NA)}
}
i<-6

for(i in 6:ncol(data.new))
{
data.new.means[,i]<-tapply(data.new[is.na(data.new[,i])==F,i],data.new[is.na(data.new[,i])==F,1], mean)
data.new.sig[,i]<-tapply(data.new[is.na(data.new[,i])==F,i],data.new[is.na(data.new[,i])==F,1], function(x) ttestp(x))
data.new.siglev[,i]<-tapply(data.new[is.na(data.new[,i])==F,i],data.new[is.na(data.new[,i])==F,1], function(x) siglev(ttestp(x)))
}

data.new.sig<0.01


warnings()


write.csv(data.new.sig, "data.new.sig.N.csv")
write.csv(data.new.siglev, "data.new.siglev..Ncsv")