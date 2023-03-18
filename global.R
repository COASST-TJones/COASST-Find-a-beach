# libraries
library(shinyjs)
library(leaflet)
library(plyr)
library(lubridate)
library(here)

##############################################################################################################
##############################################################################################################
##############################################################################################################
# read in data files

beach.df <- read.csv(here::here("data","Beaches_edited.csv"))
beach.pl <- read.csv(here::here("data","Beach_Processed_Map.csv")) 

beach.pl$region <- factor(beach.pl$region, levels=c("Mendocino","Humboldt", "Oregon South", "Oregon North", "South Coast", "North Coast", "Strait", "Puget Sound", "San Juan", "Southeast Alaska","Gulf of Alaska","Aleutian Islands", "Bering Sea", "Chukchi"))

beach.pl$number.of.surveys.MD <- as.character(beach.pl$number.of.surveys.MD)
beach.pl$number.of.surveys.BB <- as.character(beach.pl$number.of.surveys.BB)
beach.pl$most.recent.survey.MD[is.na(beach.pl$most.recent.survey.MD)] <- " "
beach.pl$most.recent.survey.BB[is.na(beach.pl$most.recent.survey.BB)] <- " "
beach.pl$last3tag[is.na(beach.pl$last3tag)] <- " "
beach.pl$last3tag[beach.pl$last3tag==""] <- " "

# Revalue levels in Beach.pl

beach.pl$bb.col <- revalue(beach.pl$bb.col, c("Currently monitored"="Monitored", "Available"="Available"))
beach.pl$smd.col <- revalue(beach.pl$smd.col, c("Currently monitored"="Monitored", "Available"="Available"))
beach.pl$lmd.col <- revalue(beach.pl$lmd.col, c("Currently monitored"="Monitored", "Available"="Available"))

beach.pl$bbtrue <- as.logical(ceiling(beach.pl$bbn12/1000000))
beach.pl$lmdtrue <- as.logical(ceiling(beach.pl$lmdn12/1000000))
beach.pl$s_mmdn12 <- beach.pl$smdn12 + beach.pl$mmdn12
beach.pl$smmdtrue <- as.logical(ceiling(beach.pl$s_mmdn12/1000000))

prior.list <- c("Available","Monitored")
Full.Year.list <- c("All", rev(seq(from=1999, to=year(Sys.Date()), by=1)))
##############################################################################################################

##############################################################################################################
##############################################################################################################
##############################################################################################################

calc.polygon <- function(lat1, lat2, long1, long2){

	if(lat1 > lat2){			# order so that point 1 is south of point 2
		tmplat1 <- lat1
		tmplat2 <- lat2
		lat2 <- tmplat1
		lat1 <- tmplat2
		tmplon1 <- long1
		tmplon2 <- long2
		long2 <- tmplon1
		long1 <- tmplon2
	}
	dely <- lat2-lat1
	delx <- long2-long1
	theta <- atan(dely/delx)
	
	deltax <- 0.0004*sin(theta)/cos(((lat1+lat2)/2)*pi/180)
	deltay <- 0.0004*cos(theta)
	
	x1p <- long1 - deltax/2
	x2p <- long1 + deltax/2
	
	y1p <- lat1 + deltay/2
	y2p <- lat1 - deltay/2
	
	x3p <- long2 + deltax/2
	x4p <- long2 - deltax/2
	
	y3p <- lat2 - deltay/2
	y4p <- lat2 + deltay/2
	
	xl <- c(x1p,x2p,x3p,x4p)
	yl <- c(y1p,y2p,y3p,y4p)
	coor.df <- data.frame(lat=yl, long=xl)
	return(coor.df)

}

calc.angle <- function(lat1, lat2, long1, long2){
	dely <- lat2-lat1
	delx <- long2-long1
	theta <- 180*atan(dely/delx)/pi
	if(delx >= 0){
		if(dely > 0){
			theta <- theta
		} else {
			theta <- 360 + theta
		}
	} else {
		theta <- 180 + theta
	}
	theta <- round(theta/10)*10
	if(theta > 360){
		theta <- theta - 360
	}
	return(theta)
}

##############################################################################################################
##############################################################################################################
##############################################################################################################

ORDREG <- c("Chukchi","Bering Sea","Aleutian Islands","Gulf of Alaska","Southeast Alaska","San Juan","Puget Sound","Strait", "North Coast", "South Coast", "Oregon North", "Oregon South", "Humboldt", "Mendocino")

