setwd("/home/lluc/Documents/R/dip/vanja2")

source("/home/lluc/Documents/R/functions.R")

#peaks<-read.csv("heads.csv", sep=";", header=TRUE)
#sim.vanja<-read.csv("sim_vanja.csv", sep=",", header=TRUE)
#tic.vanja<-read.csv("tic_vanja.csv", sep=",", header=TRUE)
rsim.vanja<-read.csv("rsim.csv", sep=",", header=TRUE)
peaks.vanja<-read.csv("peaks.csv", sep=",", header=TRUE)
samples.vanja<-read.csv("samples_vanja.csv", sep=",", header=TRUE)
#tic<-read.csv("tic.csv", sep=";", header=TRUE)

peaknr<-length(colnames(rsim.vanja))

type<-samples.vanja$type
harvest<-samples.vanja$harvest
typlev<-levels(type)
harlev<-levels(as.factor(harvest))

head(peaks.vanja)

pdf("timeseries_vanja.pdf")
for (i in 1:peaknr)
timeseries(rsim.vanja[,i], harvest, type, paste(peaks.vanja[i,2], "( RT =", peaks.vanja[i,1], ") [", peaks.vanja[i,5], "]") , "litter incubation (month)", "SIM relative peak area  (permille, SE)", allpoints=TRUE, col=TRUE)
dev.off()

notartifact<-peaks.vanja$type!="x"
isfa<-peaks.vanja$type=="fa"
islig<-peaks.vanja$type=="g"|peaks.vanja$type=="sy"


# exclude artifact peaks
peaks.vanja<-peaks.vanja[notartifact, 1:ncol(peaks.vanja)]
sim.vanja<-sim.vanja[1:nrow(sim.vanja), notartifact]
tic.vanja<-tic.vanja[1:nrow(tic.vanja), notartifact]

peaknr<-length(colnames(sim.vanja))

ncol(sim.vanja)
ncol(tic.vanja)
nrow(peaks.vanja)

#carbos<-peaks[,2]=="c"|peaks[,2]=="ch"|peaks[,2]=="f"
#ligs<-peaks[,2]=="sy"|peaks[,2]=="g"
#nitr<-peaks[,2]=="ind"|peaks[,2]=="p"
#phen<-peaks[,2]=="ph"
#al<-peaks[,2]=="al"
#ka<-peaks[,2]=="ka"

#sim vs. tic graphs

      pdf("simvstic_vanja.pdf")
      for (i in 1:peaknr)
      {
      ti<-subset(tic.vanja[,i], is.na(tic.vanja[,i])==FALSE & is.na(sim.vanja[,i])==FALSE)
      si<-subset(sim.vanja[,i], is.na(tic.vanja[,i])==FALSE & is.na(sim.vanja[,i])==FALSE)

      if(max(ti) > 0)
      {

      plot(ti ~ si, pch="+", 
	  xlab="peak area(sim)", ylab="peak area(tic)", xlim=c(0,max(si)), ylim=c(0, max(ti))
	)

      title(peaks.vanja[i,1]) #paste(peaks[i,2], "(", peaks[i,5], "; RT = ", peaks[i,1],")"))
      mtext(paste("R² =", formatC(cor(ti, si), digits=5)))
      abline(lm(tic.vanja[,i] ~ sim.vanja[,i]))
      }
      }
      dev.off()


# calculate cTIC

      cTIC.vanja<-sim.vanja

      for (i in 1:peaknr)
      {
      cTIC.vanja[,i]<-c(rep(0,74))

      ti<-subset(tic.vanja[,i], is.na(tic.vanja[,i])==FALSE & is.na(sim.vanja[,i])==FALSE)
      si<-subset(sim.vanja[,i], is.na(tic.vanja[,i])==FALSE & is.na(sim.vanja[,i])==FALSE)
      orig<-data.frame(si,ti)
      mod<-lm(ti ~ si, data=orig)

      ti<-tic.vanja[,i]
      si<-sim.vanja[,i]
      new<-data.frame(si,ti)
#      if(peaks[i,6]>0) cTIC[,i]<-sim[,i]/peaks[i,6]
#      if(peaks[i,6]==0) 
cTIC.vanja[,i]<-predict.lm(mod, newdata=new, type="response")
      }

      rcTIC.vanja<-cTIC.vanja/rowSums(cTIC.vanja)*1000
      rsim.vanja<-sim.vanja/rowSums(sim.vanja)*1000

# sums by category

      catrsim.vanja<-sumif(rsim.vanja,peaks.vanja$type)
      catrcTIC.vanja<-sumif(rcTIC.vanja, peaks.vanja$type)

#timeseries
      pdf("timeseries_vanja.pdf")
      for (i in 1:peaknr)
      timeseries(rsim.vanja[,i], harvest, type, paste(peaks.vanja$name[i], peaks.vanja$RT[i], peaks.vanja$origin[i]), "litter incubation (month)", "sum of cTIC peak area (permille of all peaks)", points=FALSE, col=TRUE, allpoints=TRUE)
      timeseries(catrsim.vanja$fa, harvest, type, paste(peaks.vanja$name[i], peaks.vanja$RT[i], peaks.vanja$origin[i]), "litter incubation (month)", "sum of cTIC peak area (permille of all peaks)", points=FALSE, col=TRUE, allpoints=TRUE)

      catnames<-colnames(catrcTIC.vanja)
      for (i in 1:ncol(catrcTIC.vanja))
      timeseries(catrcTIC.vanja[,i], harvest, type, catnames[i], "litter incubation (month)", "sum of cTIC peak area (permille of all peaks)", points=FALSE)

      dev.off()
    
# pca with all peaks.vanja
      pdf("pca.vanja.allpeaks")
      vanja.allpeaks.pca<-(rda(rsim.vanja))
      plot(vanja.allpeaks.pca, type="n")
      for (i in 1:length(typlev))
      for (j in 1:length(harlev))
      points(vanja.allpeaks.pca, display="sites", select=samples.vanja$harvest==harlev[j] & samples.vanja$type==typlev[i], col=i, pch=20+j, cex=0.5)
      text(vanja.allpeaks.pca, display="species", labels=peaks.vanja[,1], cex=.5)
      dev.off()

#mds of peaks from t(sim)
      pdf("tsim_mds_vanja.pca")
      tsim.vanja<-t(sim.vanja)
      rtsim.vanja<-tsim.vanja/rowSums(tsim.vanja)
      rtsim.mds.vanja<-metaMDS(rtsim.vanja, zerodist="add")
      plot(rtsim.mds.vanja, type="n")
      abline(h=0, col = "gray")
      abline(v=0, col = "gray")
      for (i in 1:length(typlev))
      for (j in 1:length(harlev))
      points(rtsim.mds.vanja, display="species", select=harvest==harlev[j] & type==typlev[i], col=i, pch=20+j, cex=0.5)
      points(rtsim.mds.vanja, display="sites", col=1, pch="+", cex=.3)
      legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))

      plot(rtsim.mds.vanja, type="n")
      abline(h=0, col = "gray")
      abline(v=0, col = "gray")
      for (i in 1:length(typlev))
      for (j in 1:length(harlev))
      points(rtsim.mds.vanja, display="species", select=harvest==harlev[j] & type==typlev[i], col=1, pch=20+j, cex=0.3)

      text(rtsim.mds.vanja, display="sites",  select=peaks.vanja$type=="g", col="green", labels=peaks.vanja$type, font=2,cex=0.6)
      text(rtsim.mds.vanja, display="sites",  select=peaks.vanja$type=="sy", col="green", labels=peaks.vanja$type, font=2,cex=0.6)
      text(rtsim.mds.vanja, display="sites",  select=peaks.vanja$type=="f", col="red", labels=peaks.vanja$type, font=2,cex=0.6)
      text(rtsim.mds.vanja, display="sites",  select=peaks.vanja$type=="fa", col="blue", labels=peaks.vanja$type, font=2,cex=0.6)
      text(rtsim.mds.vanja, display="sites",  select=peaks.vanja$type=="g", col="green", labels=peaks.vanja$type, font=2,cex=0.6)

      dev.off()

#pca fa only
 
      peaks.vanja.faonly<-peaks.vanja[isfa,1:ncol(peaks.vanja)]
      peaks.vanja.faonly
      rsim.vanja.faonly<-sim.vanja[,isfa]*1000/rowSums(sim.vanja[,isfa])


      pdf("fa_only.pdf")
      for (i in 1:ncol(rsim.vanja.faonly))
      timeseries(rsim.vanja.faonly[,i], harvest, type, paste(peaks.vanja.faonly$name[i], "( RT = ", peaks.vanja.faonly$RT[i], ")"), "litter incubation(month)", "relative SIM area (permille, FA only, SE)")

      faonly.pca<-rda(rsim.vanja.faonly, scaled=TRUE)
      plot(faonly.pca, type="n")
      for (i in 1:length(typlev))
      for (j in 1:length(harlev))
      points(faonly.pca, select=type==typlev[i]&harvest==harlev[j], display="sites", col=i, pch=20+j, cex=0.6)
      text(faonly.pca, display="species", labels=paste(peaks.vanja.faonly$RT, peaks.vanja.faonly$code), font=2,cex=0.6)
      legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
      title("PCA (scaled) - fatty acids only")
      fit.harvest<-envfit(faonly.pca~harvest)
      #fit.log.harvest<-envfit(faonly.pca~log(sim.vanja$harvest+1))
      #fit.type<-envfit(faonly.pca~sim.vanja$type)
      plot(fit.harvest, labels="harvest", cex=.5)
      #plot(fit.log.harvest, labels="harvest", cex=.2)
      #plot(fit.type)
      dev.off()

#pca lig only
 
      peaks.vanja.ligonly<-peaks.vanja[islig,1:ncol(peaks.vanja)]
      rsim.vanja.ligonly<-sim.vanja[,islig]*1000/rowSums(sim.vanja[,islig])


      pdf("lig_only.pdf")
      for (i in 1:ncol(rsim.vanja.ligonly))
      timeseries(rsim.vanja.ligonly[,i], harvest, type, paste(peaks.vanja.ligonly$name[i], "( RT = ", peaks.vanja.ligonly$RT[i], ")"), "litter incubation(month)", "relative SIM area (permille, FA only, SE)")

      ligonly.pca<-rda(rsim.vanja.ligonly, scaled=TRUE)
      plot(ligonly.pca, type="n")
      for (i in 1:length(typlev))
      for (j in 1:length(harlev))
      points(ligonly.pca, select=type==typlev[i]&harvest==harlev[j], display="sites", col=i, pch=20+j, cex=0.6)
      text(ligonly.pca, display="species", labels=paste(peaks.vanja.ligonly$RT, peaks.vanja.ligonly$code), font=2,cex=0.6)
      legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
      title("PCA (scaled) - lignin markers only")
      fit.harvest<-envfit(ligonly.pca~harvest)
      #fit.log.harvest<-envfit(faonly.pca~log(sim.vanja$harvest+1))
      #fit.type<-envfit(faonly.pca~sim.vanja$type)
      plot(fit.harvest, labels="harvest", cex=.5)
      #plot(fit.log.harvest, labels="harvest", cex=.2)
      #plot(fit.type)
      dev.off()

?envfit

plot(lig_wo.mds, type="n", tck=.01)
points(lig_wo.mds, display="sites", pch="+", col=1, font=2, cex=0.6)
text(lig_wo.mds, display="species",  select=names_wo[,3]=="S", col="blue", labels=names_wo[,1], font=2,cex=0.6)
text(lig_wo.mds, display="species",  select=names_wo[,3]=="G", col="red",labels=names_wo[,1], font=2,cex=0.6)
legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only - w/o G3:1-OH)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

plot(lig_wo.mds, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(lig_wo.mds, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
points(lig_wo.mds, display="species", pch="+", col=1, font=2, cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
title("MDS (Lignin Markers only - w/o G3:1-OH)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

plot(lig_wo.mds, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(lig_wo.mds, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
text(lig_wo.mds, display="species", col="black", labels=names_wo[,1], font=2,cex=0.6)
#text(lig.mds, display="species",  select=names[,3]=="G", col="red",labels=names[,1], font=2,cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only - w/o G3:1-OH)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

timeseries_nolimit(scores_wo[,1], pyr[,2], pyr[,1], "MDS - Lignin Peaks only (w/o G3:1-OH)", "litter incubation (month)", "MDS1")
abline(h=0, col = "gray", lty = "dotted")
timeseries_nolimit(scores_wo[,2], pyr[,2], pyr[,1], "MDS - Lignin Peaks only (w/o G3:1-OH)", "litter incubation (month)", "MDS2")
abline(h=0, col = "gray", lty = "dotted")




summary(peaks)
head(peaks)
peaknr<-length(rownames(peaks))
peaknr

head(peaks)

#sim vs. tic graphs

pdf("simvstic.pdf")
for (i in 1:peaknr)
{
ti<-subset(tic[,i], is.na(tic[,i])==FALSE & is.na(sim[,i])==FALSE)
si<-subset(sim[,i], is.na(tic[,i])==FALSE & is.na(sim[,i])==FALSE)

if(max(ti) > 0)
{

plot(ti ~ si, pch="+", xlab="peak area(sim)", ylab=paste("peak area(tic)", peaks[i,7])) 
title(paste(peaks[i,4], "(", peaks[i,5], "; RT = ", peaks[i,1],")"))
mtext(paste("R² =", formatC(cor(ti, si), digits=5)))
abline(lm(tic[,i] ~ sim[,i]))
}
}
dev.off()

cTIC<-sim

for (i in 1:peaknr)
{
cTIC[,i]<-c(rep(0,74))

ti<-subset(tic[,i], is.na(tic[,i])==FALSE & is.na(sim[,i])==FALSE)
si<-subset(sim[,i], is.na(tic[,i])==FALSE & is.na(sim[,i])==FALSE)
orig<-data.frame(si,ti)
mod<-lm(ti ~ si, data=orig)

ti<-tic[,i]
si<-sim[,i]
new<-data.frame(si,ti)
if(peaks[i,6]>0) cTIC[,i]<-sim[,i]/peaks[i,6]
if(peaks[i,6]==0) cTIC[,i]<-predict.lm(mod, newdata=new, type="response")
}


predict.lm(mod, si=sim[1], type=predict)
?predict.lm

pyr<-read.csv("../calculated_tic_sums.csv", sep=";")
#names<-read.csv("peaknames.csv", header=FALSE)
names<-colnames(cTIC)
kmax<-length(colnames(cTIC))
imax<-4

jmax<-4

pdf("cTIC_time_series_CI.pdf")
for (k in 1:kmax)
timeseries_CI(cTIC[,k], pyr[,2], pyr[,1], names[k], "litter incubation (month)", "relative calculated TIC area (permille)")
  dev.off()


pdf("cTIC_time_series.pdf")
for (k in 1:kmax)
timeseries(cTIC[,k], pyr[,2], pyr[,1], names[k], "litter incubation (month)", "relative calculated TIC area (permille, 95% CI)")
dev.off()
warnings()

#sink("mds.anovas")
#mds1
#mod<-lm(scores[,1] ~ factor(pyr[,1])*factor(pyr[,2]))
#ano<-aov(mod)
#mod
#summary(mod)
#summary(ano)
#TukeyHSD (ano)
#mds2
#mod<-lm(scores[,2] ~ factor(pyr[,1])*factor(pyr[,2]))
#ano<-aov(mod)
#mod
#summary(mod)
#summary(ano)
#TukeyHSD (ano)

#sink()

harvest<-pyr[,2]
type<-pyr[,1]
harlev<-levels(as.factor(harvest))
typelev<-levels(as.factor(type))
harlev
typelev


pca.lignin<-princomp(cTIC[,95:121])
ligscores<-scores(princomp(cTIC[,95:121]))

pdf("lig_primcomp.pdf")
timeseries_nolimit(ligscores[,1], pyr[,2], pyr[,1], "PC 1 (lignin)", "time (month)", "primcomp1 (lignin peaks)" )
timeseries_nolimit(ligscores[,2], pyr[,2], pyr[,1], "PC 2 (lignin)", "time (month)", "primcomp2 (lignin peaks)" )
biplot(princomp(cTIC[,95:121]))
plot(princomp(cTIC[,95:121]))
dev.off()

pca.n<-princomp(cTIC[,122:130])
nscores<-scores(princomp(cTIC[,122:130]))

pdf("n_primcomp.pdf")
timeseries_nolimit(nscores[,1], pyr[,2], pyr[,1], "PC 1 (N compounds)", "time (month)", "primcomp1 (nitrogen peaks)" )
timeseries_nolimit(nscores[,2], pyr[,2], pyr[,1], "PC 2 (N compounds)", "time (month)", "primcomp2 (nitrogen peaks)" )
biplot(princomp(cTIC[,122:130]))
plot(princomp(cTIC[,122:130]))
dev.off()


biplot(pca.lignin, type="n", tck=.01)
points(pca.lignin, display="sites", pch="+", col=1, font=2, cex=0.6)
text(pca.lignin, display="species", col="blue", labels=colnames(cTIC[95:121]), font=2,cex=0.6)
#text(pca.lignin, display="species",  select=names[,3]=="G", col="red",labels=names[,1], font=2,cex=0.6)
#legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("PCA (Lignin Markers)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")


plot(pca.lignin, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(pca.lignin, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
points(pca.lignin, display="species", pch="+", col=1, font=2, cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
title("PCA (Lignin Markers)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

plot(pca.lignin, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(pca.lignin, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
text(pca.lignin, display="species", col="black", labels=colnames(cTIC[95:121]), font=2,cex=0.6)
#text(lig.mds, display="species",  select=names[,3]=="G", col="red",labels=names[,1], font=2,cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
#legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

timeseries_nolimit(scores[,1], pyr[,2], pyr[,1], "MDS - Lignin Peaks only", "litter incubation (month)", "MDS1")
abline(h=0, col = "gray", lty = "dotted")

timeseries_nolimit(scores[,2], pyr[,2], pyr[,1], "MDS - Lignin Peaks only	", "litter incubation (month)", "MDS2")
abline(h=0, col = "gray", lty = "dotted")

dev.off()

  
metaMDS(cTIC)

pdf("ligonly_mds.pdf")
plot(lig.mds, type="n", tck=.01)
points(lig.mds, display="sites", pch="+", col=1, font=2, cex=0.6)
text(lig.mds, display="species",  select=names[,3]=="S", col="blue", labels=names[,1], font=2,cex=0.6)
text(lig.mds, display="species",  select=names[,3]=="G", col="red",labels=names[,1], font=2,cex=0.6)
legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")


plot(lig.mds, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(lig.mds, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
points(lig.mds, display="species", pch="+", col=1, font=2, cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
title("MDS (Lignin Markers only)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

plot(lig.mds, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(lig.mds, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
text(lig.mds, display="species", col="black", labels=names[,1], font=2,cex=0.6)
#text(lig.mds, display="species",  select=names[,3]=="G", col="red",labels=names[,1], font=2,cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

timeseries_nolimit(scores[,1], pyr[,2], pyr[,1], "MDS - Lignin Peaks only", "litter incubation (month)", "MDS1")
abline(h=0, col = "gray", lty = "dotted")

timeseries_nolimit(scores[,2], pyr[,2], pyr[,1], "MDS - Lignin Peaks only	", "litter incubation (month)", "MDS2")
abline(h=0, col = "gray", lty = "dotted")

dev.off()

lig_wo<-lig
lig_wo$G3.1.OH<- NULL
lig_wo

lig_wo.mds<-metaMDS(lig_wo)
scores_wo <- scores(lig_wo.mds)
names_wo<-read.csv("peaknames_wo.csv", header=FALSE)



pdf("ligonly_mds_wo.pdf")
plot(lig_wo.mds, type="n", tck=.01)
points(lig_wo.mds, display="sites", pch="+", col=1, font=2, cex=0.6)
text(lig_wo.mds, display="species",  select=names_wo[,3]=="S", col="blue", labels=names_wo[,1], font=2,cex=0.6)
text(lig_wo.mds, display="species",  select=names_wo[,3]=="G", col="red",labels=names_wo[,1], font=2,cex=0.6)
legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only - w/o G3:1-OH)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

plot(lig_wo.mds, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(lig_wo.mds, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
points(lig_wo.mds, display="species", pch="+", col=1, font=2, cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
title("MDS (Lignin Markers only - w/o G3:1-OH)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

plot(lig_wo.mds, type="n", tck=.01)
for (i in 1:imax)
for (j in 1:jmax)
points(lig_wo.mds, display="sites", select=harvest==harlev[j] & type==typelev[i], col=i, pch=20+j, cex=0.6)
text(lig_wo.mds, display="species", col="black", labels=names_wo[,1], font=2,cex=0.6)
#text(lig.mds, display="species",  select=names[,3]=="G", col="red",labels=names[,1], font=2,cex=0.6)
legend("topright", pch=c(rep(c( 21, 22, 23, 24),4)), col=c(rep(1,4), rep(2,4), rep(3,4), rep(4,4)), legend=c("AK0","AK2","AK3","AK4","KL0","KL2", "KL3", "KL4", "OS0","OS2","OS3","OS4","SW0","SW2","SW3","SW4"))
legend("topleft", pch=21, col=c("blue", "red"), legend=c("coniferyl markers", "sinapyl markers"))
title("MDS (Lignin Markers only - w/o G3:1-OH)")
abline(h=0, col = "gray", lty = "dotted")
abline(v=0, col = "gray", lty = "dotted")

timeseries_nolimit(scores_wo[,1], pyr[,2], pyr[,1], "MDS - Lignin Peaks only (w/o G3:1-OH)", "litter incubation (month)", "MDS1")
abline(h=0, col = "gray", lty = "dotted")
timeseries_nolimit(scores_wo[,2], pyr[,2], pyr[,1], "MDS - Lignin Peaks only (w/o G3:1-OH)", "litter incubation (month)", "MDS2")
abline(h=0, col = "gray", lty = "dotted")
dev.off()
