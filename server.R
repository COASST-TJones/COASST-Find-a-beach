#####################
# Need
library(shiny)
library(leaflet)
library(shinyjs)
library(plyr)

#######################################

shinyServer(function(input, output, session) {
	
	#######
	# Data for storing map clickable
	data <- reactiveValues(clickedMarker=NULL)
	
	#########################################################
	# load Icons
	#########################################################
	endIcons <- iconList(theta0 = makeIcon("data/png marker lib/turnaround_0.png", iconWidth = 22, iconHeight = 22),
		theta10 = makeIcon("data/png marker lib/turnaround_10.png", iconWidth = 22, iconHeight = 22),
		theta20 = makeIcon("data/png marker lib/turnaround_20.png", iconWidth = 22, iconHeight = 22),
		theta30 = makeIcon("data/png marker lib/turnaround_30.png", iconWidth = 22, iconHeight = 22),
		theta40 = makeIcon("data/png marker lib/turnaround_40.png", iconWidth = 22, iconHeight = 22),
		theta50 = makeIcon("data/png marker lib/turnaround_50.png", iconWidth = 22, iconHeight = 22),
		theta60 = makeIcon("data/png marker lib/turnaround_60.png", iconWidth = 22, iconHeight = 22),
		theta70 = makeIcon("data/png marker lib/turnaround_70.png", iconWidth = 22, iconHeight = 22),
		theta80 = makeIcon("data/png marker lib/turnaround_80.png", iconWidth = 22, iconHeight = 22),
		theta90 = makeIcon("data/png marker lib/turnaround_90.png", iconWidth = 22, iconHeight = 22),
		theta100 = makeIcon("data/png marker lib/turnaround_100.png", iconWidth = 22, iconHeight = 22),
		theta110 = makeIcon("data/png marker lib/turnaround_110.png", iconWidth = 22, iconHeight = 22),
		theta120 = makeIcon("data/png marker lib/turnaround_120.png", iconWidth = 22, iconHeight = 22),
		theta130 = makeIcon("data/png marker lib/turnaround_130.png", iconWidth = 22, iconHeight = 22),
		theta140 = makeIcon("data/png marker lib/turnaround_140.png", iconWidth = 22, iconHeight = 22),
		theta150 = makeIcon("data/png marker lib/turnaround_150.png", iconWidth = 22, iconHeight = 22),
		theta160 = makeIcon("data/png marker lib/turnaround_160.png", iconWidth = 22, iconHeight = 22),
		theta170 = makeIcon("data/png marker lib/turnaround_170.png", iconWidth = 22, iconHeight = 22),
		theta180 = makeIcon("data/png marker lib/turnaround_180.png", iconWidth = 22, iconHeight = 22),
		theta190 = makeIcon("data/png marker lib/turnaround_190.png", iconWidth = 22, iconHeight = 22),
		theta200 = makeIcon("data/png marker lib/turnaround_200.png", iconWidth = 22, iconHeight = 22),
		theta210 = makeIcon("data/png marker lib/turnaround_210.png", iconWidth = 22, iconHeight = 22),
		theta220 = makeIcon("data/png marker lib/turnaround_220.png", iconWidth = 22, iconHeight = 22),
		theta230 = makeIcon("data/png marker lib/turnaround_230.png", iconWidth = 22, iconHeight = 22),
		theta240 = makeIcon("data/png marker lib/turnaround_240.png", iconWidth = 22, iconHeight = 22),
		theta250 = makeIcon("data/png marker lib/turnaround_250.png", iconWidth = 22, iconHeight = 22),
		theta260 = makeIcon("data/png marker lib/turnaround_260.png", iconWidth = 22, iconHeight = 22),
		theta270 = makeIcon("data/png marker lib/turnaround_270.png", iconWidth = 22, iconHeight = 22),
		theta280 = makeIcon("data/png marker lib/turnaround_280.png", iconWidth = 22, iconHeight = 22),
		theta290 = makeIcon("data/png marker lib/turnaround_290.png", iconWidth = 22, iconHeight = 22),
		theta300 = makeIcon("data/png marker lib/turnaround_300.png", iconWidth = 22, iconHeight = 22),
		theta310 = makeIcon("data/png marker lib/turnaround_310.png", iconWidth = 22, iconHeight = 22),
		theta320 = makeIcon("data/png marker lib/turnaround_320.png", iconWidth = 22, iconHeight = 22),
		theta330 = makeIcon("data/png marker lib/turnaround_330.png", iconWidth = 22, iconHeight = 22),
		theta340 = makeIcon("data/png marker lib/turnaround_340.png", iconWidth = 22, iconHeight = 22),
		theta350 = makeIcon("data/png marker lib/turnaround_350.png", iconWidth = 22, iconHeight = 22),
		theta360 = makeIcon("data/png marker lib/turnaround_360.png", iconWidth = 22, iconHeight = 22)
		)

	#########################################################
	# Find a beach
	#########################################################

	#########################################################
	# Info/help button clicked
	observeEvent(input$help, {
		# Show a modal when the button is pressed
		shinyalert(title=NULL, 
		text=HTML("<b>Welcome to COASSTs Find-a-Beach app!</b> <br> <br> Here you can view beaches by current monitoring status. <br>
		<br> If you don't see a dot in a location that you'd like to survey, please visit our <a href='https://coasst.org/'> homepage</a> 
		to look for upcoming trainings, or to contact us to see how you can get involved."), 
		#type = "info", 
		closeOnClickOutside = TRUE, 
		html=TRUE, 
		imageUrl="https://coasst.org/wp-content/uploads/2019/04/COASST_Logo_250.png", imageWidth=160, 
		animation=FALSE)
	})
	
	##############################################################################
	# Map
	# creates and renders map
	output$mymap <- renderLeaflet({
			leaflet(data = beach.pl) %>%
			addProviderTiles("Esri.WorldTopoMap") %>%
			setView(lng = -140, lat = 51.5, zoom = 4) %>%
			setMaxBounds(lng1=-300, lat1=-90, lng2=200, lat2=90)
	})
	
	# Switches map view
	
	observeEvent(input$satview,{
		if(input$satview){
			leafletProxy("mymap") %>% clearTiles() %>%
			addProviderTiles("Esri.WorldImagery")
		} else {
			leafletProxy("mymap") %>% clearTiles() %>%
			addProviderTiles("Esri.WorldTopoMap")
		}
	})
	
	
	# Toggles menu 
	shinyjs::onclick("toggleMenu",						#######
        shinyjs::toggle(id = "Menu", anim = TRUE))    #########
	
	# controls map clusters and objects
	observeEvent(input$SurveyType, {
		
		#*** ADD HERE FOR DIFFERENCES BETWEEN SURVEY TYPES ***#
		collist <- c(rgb(0,0.7,0.1,1), rgb(0,0,1,1))
		pal <- colorFactor(collist, domain=prior.list, alpha = FALSE)
		if(length(input$SurveyType)==0){
			beach.dat <- beach.pl
			colordata <- beach.dat$bb.col
		} else {
			if(input$SurveyType=="Beached Birds"){
				beach.dat <- beach.pl
				colordata <- beach.dat$bb.col
				# Add filter on beaches for regions
			} else {
				if(input$SurveyType=="Large Marine Debris"){
					beach.dat <- beach.pl[beach.pl$region %in% c("North Coast", "South Coast", "Oregon North", "Oregon South", "Strait", "Puget Sound", "San Juan"),]
					colordata <- beach.dat$lmd.col
				} else {
					beach.dat <- beach.pl[beach.pl$region %in% c("North Coast", "South Coast", "Oregon North", "Oregon South", "Strait", "Puget Sound", "San Juan"),]
					colordata <- beach.dat$smd.col
				}
			}
		}
			
		leafletProxy("mymap",data = beach.dat) %>% clearMarkers() %>% clearMarkerClusters() %>% clearControls() %>%
		addCircleMarkers(~longitude, ~latitude, radius=7,stroke=FALSE, fillOpacity=0.7, fillColor=pal(colordata), color=1, layerId =~beach, label=~beach,clusterOptions = NULL,labelOptions = labelOptions(direction = "auto", textOnly = T, style = list("font-family" = "Raleway","font-style" = "italic", "font-size" = "14px","color" = "rgba(0,0,0,0.8)" ))) %>%
		addLegend("bottomright", colors=collist, labels=c("Available", "Monitored"), title="Availability")
		
	})
	
	# Function for controlling what shows in the popup at the given clicked location
	showBeachPopup <- function(beach) {
	
		if(is.null(beach)==FALSE){
			# identifies which beach was clicked
			selectedBeach <- beach.pl[beach.pl$beach == beach,]
			# find coordinates of polygon to plot
			poly.coord <- calc.polygon(lat1=selectedBeach$latitude, lat2=selectedBeach$turn_latitude, long1=selectedBeach$longitude, long2=selectedBeach$turn_longitude)
				
			# controls content of popup
			content <- as.character(tagList(
				tags$h3(HTML(sprintf("Beach: %s",selectedBeach$beach))),				
				tags$h4(HTML(sprintf("%s, %s", selectedBeach$city, selectedBeach$region))), 
				tags$p(HTML(sprintf("BB surveys in last 12 months: %s", selectedBeach$number.of.surveys.BB),"<br>", 
							sprintf("Last BB survey: %s \n", selectedBeach$most.recent.survey.BB),"<br>",
							sprintf("MD surveys in last 12 months: %s \n", selectedBeach$number.of.surveys.MD),"<br>",
							sprintf("Last MD survey: %s \n", selectedBeach$most.recent.survey.MD),"<br>",
							sprintf("Last 3 bird tags: %s \n",selectedBeach$last3tag),"<br>",
							sprintf("Beach length: %s km \n", selectedBeach$blength)
							)
						)
			))
			calcangle <- calc.angle(lat1=selectedBeach$latitude, lat2=selectedBeach$turn_latitude, long1=selectedBeach$longitude, long2=selectedBeach$turn_longitude)
			iconname <- paste("theta", calcangle, sep="")
			if(calcangle < 180){
				popuplat <- selectedBeach$turn_latitude
				popuplon <- selectedBeach$turn_longitude
			} else {
				popuplat <- selectedBeach$latitude
				popuplon <- selectedBeach$longitude
			}
			# adds popup
			leafletProxy("mymap") %>% addPopups(lng=popuplon, lat=popuplat, content, layerId = beach) %>%
			addPolygons(lng=poly.coord$long, lat=poly.coord$lat, layerId = "TempBeach", stroke = FALSE, color = "#E80000", weight = 3, fill=TRUE, opacity=0.5, fillOpacity=0.7) %>%
			addMarkers(lng=selectedBeach$turn_longitude, lat=selectedBeach$turn_latitude, layerId = "BeachEnd", clusterOptions=NULL, icon = endIcons[iconname], options=markerOptions(clickable = FALSE))
		}
	}
	
	# This registers which beach was clicked
	observeEvent(input$mymap_marker_click,{
		data$clickedMarker <- input$mymap_marker_click$id
	})
	
	# This tests whether the click was the same click and if not it will clear shapes and reset to NULL
	observeEvent(input$mymap_click,{
		if(is.null(input$mymap_marker_click)==FALSE){
			if(input$mymap_marker_click$lat != input$mymap_click$lat) { 
				leafletProxy("mymap") %>% clearShapes() %>% removeMarker(layerId="BeachEnd")
				data$clickedMarker <- NULL
			}
		}
	})
	
	# This controls the effect of clicking on the beach
	observeEvent(data$clickedMarker, {
		# Calls the beach popup function
		showBeachPopup(data$clickedMarker)
	})
	
	# This alters view extent when beach selected
	observe({
		BeachO <- input$BeachSearch
		if(BeachO != ""){
			leafletProxy("mymap") %>% 
			setView(lng = beach.df$start_lon[beach.df$name==BeachO], lat = beach.df$start_lat[beach.df$name==BeachO], zoom = 13) 
		}
	})
	
	
			
})





 
