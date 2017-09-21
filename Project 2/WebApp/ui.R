
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)
library(shinyjs)
library(plotly)
library(markdown)


jscode <- "
shinyjs.init = function() {

var timerId = 0;

function clickWrap(id, el, input) {
  if (el.attr('rel') == 'all') {
    $('#'+ id +' a[rel!=all][rel!=none]').addClass('label-primary');
  } else if (el.attr('rel') == 'none') {
    $('#'+ id +' a').removeClass('label-primary');
  } else {
    el.toggleClass('label-primary');
  }
  
  $('#'+ input).val( $('#'+ id +' a.label-primary').map(function(){return $(this).attr('rel');}).get().join(',') );

  if (timerId != 0) clearTimeout(timerId);

  timerId = setTimeout(function(){ $('#'+ input).change(); }, 500);
}

$(document).on('click', '#isCompensated a', function(event) {
    event.preventDefault();
    clickWrap('isCompensated', $(this), 'input_isCompensated' );
});

$(document).on('click', '#products a', function(event) {
    event.preventDefault();
    clickWrap('products', $(this), 'input_products' );
});

$(document).on('click', 'a.help', function(event) {
    event.preventDefault();
    $('#helpPanel').toggle();
});

$(document).on('click', '.nav-tabs a', function(event) {
 
  if ($('.nav-tabs a[data-value*=Sentiment]').parent().hasClass('active')) { 
    $('#topicSelector').hide();
  } else {
    $('#topicSelector').show();
  }
});

}"

#$(".nav-tabs a[data-value*=Topic]")

# should be able to generate the products from code :p

ui <- fluidPage(theme = shinytheme("spacelab"),

  tags$head(
    tags$title('Sentiment and Topic Modelling'),
    includeCSS(path = "www/app.css")
  ),
  
  fluidRow(
    column(8, h2("Sentiment and Topic Modelling", span(": US Consumer Financial Protection Bureau "))),
    column(4, class="text-right", a(href = "#", class="help", img(src = "help-icon-26.png")))
  ),
  
  useShinyjs(),
  extendShinyjs(text = jscode),
  
  # Sidebar with a slider input for number of bins
  #sidebarLayout(
  fluidRow( 
    #sidebarPanel(
    column(4, style="width: 360px",
      div(class="well",
        hidden(
          textInput(inputId = "input_isCompensated", label = "", value = "yes,no"),
          textInput(inputId = "input_products", label = "", value = "prod_1,prod_2,prod_3,prod_4,prod_5")
        ),
        
        div( id = "isCompensated", class = "block",
          span( class="control-label", "Was the consumer compensated ?"),
          a(class="label label-primary", "Yes", rel="yes"),
          a(class="label label-primary", "No", rel="no"),
          div( class="inline-block",
            a(class="label", "Both", rel="all"),
            a(class="label", "None", rel="none")
          )
        ),
        
        div( id = "products", class="block",
          span(class="control-label", "Filter by product:"),
          a(class="label label-primary", rel="prod_1", "Bank account or service"),
          a(class="label label-primary", rel="prod_2", "Credit card"),
          a(class="label label-primary", rel="prod_3", "Credit reporting"),
          a(class="label label-primary", rel="prod_4", "Debt collection"),
          a(class="label label-primary", rel="prod_5", "Mortgage"),
          div( class="inline-block",
            a(class="label", "All", rel="all"),
            a(class="label", "None", rel="none")
          )
        ),
        
        div( id = "topicSelector", style="display: none;", 
            radioButtons(inputId = "input_noTopics", label = "Number of Topics:", choices = c(2,3,4,5), selected = 2, inline = TRUE),
            actionButton("btn_update_topic", "Update", icon = icon("refresh"))
        )
        
        #verbatimTextOutput("value1"),
        #verbatimTextOutput("value2"),
        #verbatimTextOutput("value3")
      )
    ),

    # Show a plot of the generated distribution
    #mainPanel(
    column(8, style = "width: calc(100% - 360px);",
      tabsetPanel(
        tabPanel("Sentiment Analysis", icon = icon("area-chart"), id = "sentiment",
          
          plotOutput('sentimentPlot_hist'),
          plotOutput('sentimentPlot_perMonth')
        ), 
        tabPanel("Topic Modeling", icon = icon("bar-chart-o"), id = "topic",
          plotOutput("topicPlot")
        ), 
        tabPanel("New Complaint", icon = icon("keyboard-o"), id = "data",
          
          radioButtons(inputId = "complaintType", label = "Sampling Method", choices = c("Random", "Select Existing", "New"), inline = TRUE),
          
          conditionalPanel(
            condition = "input.complaintType == 'Random'",
            actionButton("btn_select_random", "Select a random existing complaint", icon = icon("random"))
          ),
          conditionalPanel(
            condition = "input.complaintType == 'Select Existing'",
            numericInput(inputId = "input_id", label = "Complaint ID (1 - 20 000)", min = 1, max = 20000, value = 3),
            actionButton("btn_select_id", "Use complaint", icon = icon("folder-open-o"))
          ),
          conditionalPanel(
            condition = "input.complaintType == 'New'",
            textAreaInput(inputId = "input_text", label="Complaint:", width = "600px", height = "200px"),
            actionButton("btn_select_text", "Submit", icon = icon("paper-plane-o"))
          ),
          hr(),
          
          h4(htmlOutput("complaint_result")),
          
          fluidRow( 
            column(4, tableOutput("topic_table")),
            column(8, h5("ID:"), textOutput("topic_id"), h5("Complaint:"), div(class="txt", textOutput("topic_text")) )
          )
        )
      ),
      absolutePanel(id = "helpPanel", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                    height = "auto",
                    class = "help",
                    style = "display:none;",
                    HTML(c("<h4>Help</h4>
                           <hr>
                           <p>This web application displays the sentiment and topic analysis of complaints received by the <strong>US Consumer Financial Protection Bureau</strong>.</p>
                           <p>The panel on the left lets you filter the details on whether the customer was <em>compensated</em> before/after the complaint was lodged and the type of <em>product</em> the complaint was about.</p>
                           <p><strong>NOTE:</strong> The filter apply to all the tabs.</p>
                           <p>The tabs display the various views pertaining to the complaints.</p>
                           <ol>
                           <li><strong>Sentiment Analysis</strong>
                           <ul>
                           <li>Histogram of the sentiment for all complaints for that period of time.</li>
                           <li>Sentiment score for each of the products and/or if they were compensated.</li>
                           </ul>
                           </li>
                           <li><strong>Topic Modeling</strong><br>
                           This plot displays the <em>top 15</em> words filtered on the selected number of topics.
                           </li>
                           <li><strong>New Complaint</strong><br>
                           Select or enter a new complaint to be used for analysis.
                           </li>
                           </ol>"))
      )
    )
    
    
  )
)
