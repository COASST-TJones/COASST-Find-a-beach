# Need
library(shiny)
library(leaflet)
library(shinyjs)
library(shinyalert)
library(plyr)

##################################################

shinyUI(
	fluidPage(title="COASST: Find a Beach",  useShinyalert(),
		################################################
		div(class="outer",
			# Include our custom CSS
			tags$head(
				tags$style(HTML("@import url('https://fonts.googleapis.com/css?family=Raleway&display=swap');
				input[type=\"number\"] {
					max-width: 80%;
				}
				div.outer {
					position: fixed;
					top: 0px;
					left: 0;
					right: 0;
					bottom: 0;
					overflow: hidden;
					padding: 0;
				}
				/* Customize fonts */
				p { 
					font-family: 'Raleway', sans-serif;
					font-weight: 250;
					font-size: 14px;
				} 
				label { 
					font-family: 'Raleway', sans-serif;
					font-weight: 200;
					font-size: 14px;
				} 
				input { 
					font-family: 'Raleway', sans-serif;
					font-weight: 200;
					font-size: 16px;
				}
				navbar-header {
					font-family: 'Raleway', sans-serif;
					font-weight: 250;
					font-size: 36px;
				}
				button { 
					font-family: 'Raleway', sans-serif;
					font-weight: 250;
					font-size: 22px;
				} 
				select { 
					font-family: 'Raleway', sans-serif;
					font-weight: 200;
					font-size: 16px;
				}
				h1 { 
					font-family: 'Raleway', sans-serif;
					font-weight: 400; 
					font-size: 32px;
					} 
				h2 { 
					font-family: 'Raleway', sans-serif;
					font-weight: bold;
					font-size: 20px;
					line-height: 0.7;
					margin: 0px 0px 0px 0px;
					padding: 15px 8px 0px 8px;
					} 
				h3 { 
					font-family: 'Raleway', sans-serif;
					font-weight: bold;
					font-size: 18px;						
					} 
				h4 { 
					font-family: 'Raleway', sans-serif;
					font-weight: 250; 
					font-size: 16px;
					}
				.selectize-dropdown { 
					font-family: 'Raleway', sans-serif;
					font-size: 14px; 
					font-style: italic;
					}
				.selectize-input { 
					font-family: 'Raleway', sans-serif;
					font-size: 14px; 
					font-style: italic;
					}
				.sweet-alert p {
					font-family: 'Raleway', sans-serif;
					font-size: 16px;
					font-weight: 300;
					text-align: center;
				}
				.leaflet .legend i{
					border-radius: 50%;
					width: 12px;
					height: 12px;
					margin-top: 4px;
				}
				.legend {
					padding: 6px 10px 6px 6px;
				}
				#togglemenu {
					/* Controls look of expanding button */
					text-align: center;
					margin: 0px 0px 0px 0px;
					padding: 2px 2px 2px 2px;
				}
				#controls {
					/* Appearance */
					background-color: white;
					padding: 10px 20px 20px 20px;
					cursor: move;
					/* Fade out while not hovering */
					opacity: 0.95;
					zoom: 0.9;
					transition: opacity 500ms 0.2s;
				}
				#controls:hover {
					/* Fade in while hovering */
					opacity: 0.95;
					transition-delay: 0;
				}
				/* Position and style citation */
				#cite {
					position: absolute;
					bottom: 1px;
					left: 1px;
					font-size: 0.5px;
				}
				/* If not using map tiles, show a white background */
				.leaflet-container {
					background-color: white !important;
				}
				.navbar {
					background-color: white;
				}
				"))
			),
			# Draw map and other elements
			shinyjs::useShinyjs(),
			leafletOutput('mymap',width="100%", height='100%'),
			absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
				draggable = FALSE, top = "12px", left = "auto", right = "12px", bottom = "auto",
				width = 340, height = "auto",
				div(img(src="https://coasst.org/wp-content/uploads/2019/04/COASST_Logo_250.png", width="44%"), style="text-align: center;"),
				h2(strong("Find a Beach"), align = "center"),
				div(actionLink("toggleMenu", label=NULL, icon=icon("sort-down"), href = "#", style="color: #1faad7; font-size: 30px"), style="text-align: center;"),
				shinyjs::hidden(
					div(id = "Menu",
						p("Here you can view COASST beaches color-coded by availability."), 
						p("Beach availability can be viewed for any of the COASST modules by selecting from the drop-down menu below."),
						selectInput("SurveyType", "Choose a COASST module:", c("Beached Birds", "Large Marine Debris", "Small/Medium Marine Debris"), width="95%", selected="Beached Birds", selectize=FALSE),
						p(strong("OR")),
						selectInput("BeachSearch","Pick a beach:", c("", unique(beach.df$name)[order(unique(beach.df$name))]), selected="", width="95%", selectize=TRUE),
						p("Beach icons can be clicked for more information."), 
						checkboxInput("satview", label="Turn on sattelite view", value=FALSE, width="95%"),
						actionLink("help", label="More Info",icon=icon("info-circle"), style="color: #1faad7; font-size: 14px")
					)
				),
				style = "opacity: 1; z-index: 600000;"
			)		
		)
		#############################################################################################
	)
)



