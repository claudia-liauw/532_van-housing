library(tidyverse)
library(shiny)
library(bslib)

# Data wrangling
data <- read_delim('data/raw/non-market-housing.csv', delim = ';') |>
  rename(`Clientele - Families` = `Clientele- Families`) |> 
  filter(`Project Status` == 'Completed') |> 
  mutate(
    Clientele = case_when(
      (`Clientele - Seniors` == 0) & (`Clientele - Other` == 0) ~ 'Families',
      (`Clientele - Families` == 0) & (`Clientele - Other` == 0) ~ 'Seniors',
      TRUE ~ 'Mixed'
    ),
    `Total Units` = `Clientele - Families` + `Clientele - Seniors` + `Clientele - Other`,
    `Occupancy Year` = as.integer(`Occupancy Year`)
  )

room_types <- c('1BR', '2BR', '3BR', '4BR', 'Studio')
for (br in room_types) {
  data <- data |>
    mutate("{br} Available" := as.integer(rowSums(pick(contains(br))) > 0))
}

access_types = c('Accessible', 'Adaptable', 'Standard')
for (ac in access_types) {
  data <- data |>
    mutate("{ac} Available" := as.integer(rowSums(pick(contains(ac))) > 0))
}

ui <- page_fillable(
  h2(
      "Non-market Housing Dashboard for the City of Vancouver",
      style="text-align:center; font-weight:700; font-size: 40px"
  ),
  p(
      "Below are the buildings that match your selections.",
      style="text-align:center; margin-top:-8px; font-size: 24px; color:#666;"
  ),
  layout_sidebar(
    sidebar = sidebar(
        h4("Filters"),
        checkboxGroupInput(
            "clientele",
            "Clientele",
            c("Families", "Seniors", "Mixed")
        ),
        selectizeInput(
            "br",
            "Bedrooms",
            c("1BR", "2BR", "3BR", "4BR"),
            multiple=TRUE
        ),
        selectizeInput(
            "accessible",
            "Accessibility",
            c("Standard", "Adaptable", "Accessible"),
            multiple=TRUE
        ),
        sliderInput(
            "year",
            "Year",
            min=1971, max=2025,
            value=c(1971, 2025),
            sep=""
        )
    ),

    layout_columns(
      card(
          h4(
            "Total Units Count",
            style="color: #ffffff; text-align: center; font-weight: 500;"
          ),
          div(
            textOutput("total_units_card"),
            style="
                      font-size: 48px;
                      font-weight: bold;
                      text-align: center;
                      color: #ffffff;
                      text-shadow: 1px 1px 3px rgba(0,0,0,0.3);
                  "
          ),
          style="
                    background: linear-gradient(135deg, #6c5ce7, #a29bfe);
                    border-radius: 15px;
                    padding: 25px;
                    height: 200px;
                    box-shadow: 0 6px 15px rgba(0,0,0,0.08);
                "
      ),

      card(
        h4(
          "Buildings Summary",
          style="text-align: center; font-weight: 600; color: #ffffff;"
        ),
        div(
          tableOutput("building_table"),
          style="
                    width: 100%;
                    max-height: 320px;
                    overflow-y: auto;
                    padding: 0;
                    border-radius: 12px;
                    background-color: transparent;
                "
        ),
        style="
                  border-radius: 15px;
                  box-shadow: 0 6px 15px rgba(0,0,0,0.08);
                  background: #777a7f;
                  border: 1px solid #dfe6e9;
                  display: flex;
                  flex-direction: column;
                  align-items: stretch;
                  flex-grow: 1;
                  padding: 12px;
              "
      ),
      style="
                display:flex;
                flex-direction:column;
                gap:15px;
                flex:4;
                height:100%;
            "
    )
  )
)


server <- function(input, output, session){
  df <- reactive({
    filtered_data <- data
    
    if (!is.null(input$clientele)) {
      filtered_data <- filtered_data |> filter(Clientele %in% input$clientele)
    }

    if (!is.null(input$br)) {
      br_list <- paste0(input$br, " Available")
      filtered_data <- filtered_data |> filter(if_any(any_of(br_list), ~ . > 0))
    }

    if (!is.null(input$accessible)){
      access_list <- paste0(input$accessible, " Available")
      filtered_data <- filtered_data |> filter(if_any(all_of(access_list), ~ . > 0))
    }
    
    filtered_data <- filtered_data |>
      filter(`Occupancy Year` >= input$year[1],
             `Occupancy Year` <= input$year[2])
    
    return(filtered_data)
  })
    
    output$total_units_card <- renderText(
      sum(df()$`Total Units`)
    )
    
    output$building_table <- renderTable(
      df() |> 
        select(`Index Number`, Name, `Occupancy Year`) |> 
        arrange(`Occupancy Year`)
    )
}

shinyApp(ui = ui, server = server)