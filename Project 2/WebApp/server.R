
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

library(tidyverse)
library(tidytext)
library(stringr)
library(lubridate)
library(magrittr)
library(topicmodels)

library(plotly)
library(ggplot2)

# Replace specified values with new values, in a factor or character vector.
revalue <- plyr::revalue

# get our data objects
load("data/complaints.tidy.RData")

complaints.bing <- complaints.tidy %>% 
  left_join(get_sentiments("bing"), by = c("word" = "word")) %>% # add sentiments (pos or neg)
  select(word, sentiment, everything()) %>%
  mutate(sentiment = ifelse(is.na(sentiment), "neutral", sentiment))


complaints.tdf <- complaints.tidy %>% group_by(id, word) %>% count() %>% ungroup()

sentiment.all.words <- complaints.bing %>%
                        group_by(month) %>% 
                        count(sentiment, product, compensated)

sentiment.all.byMonth <- complaints.bing %>% 
                    mutate(score = as.numeric( revalue(sentiment, c("positive" = 1, "neutral" = 0, "negative" = -1))) ) %>%
                    group_by(month, product, compensated) %>%
                    summarise(score = sum(score))

sentiment.all.byId <- complaints.bing %>% 
                    mutate(score = as.numeric( revalue(sentiment, c("positive" = 1, "neutral" = 0, "negative" = -1))) ) %>%
                    group_by(id, product, compensated) %>%
                    summarise(score = sum(score)) %>%
                    mutate(sentiment = ifelse(score < 0, "negative", ifelse(score == 0, "neutral", "positive")))

sentiment.totals.byMonth <- complaints.no_words %>% group_by(month) %>% summarise(total = sum(n))
sentiment.totals.byId <- complaints.no_words %>% group_by(id) %>% summarise(total = sum(n))

pallete.hist <- c("#C83636", "#85B942", "#3984B6")
replace_reg <- "\\n|\\(|\\)|\\{|\\}|(XXXX)|(XXX)|(XX)|(X)|RE|&|&amp;|&lt;|&gt;|'s|n\\/a|\\$?([0-9])+|(_+)|-|\\%|\\/|\\.\\.\\.|\177|\032|#|\\@|;|'|,|\\.|\"|http(.*)(.html|.htm|.aspx|.php)"
unnest_reg <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"

server <- function(input, output) {
  
  #output$value1 <- renderText({ input$input_isCompensated })
  #output$value2 <- renderText({ input$input_products })
  #output$value3 <- renderText({ input$input_noTopics })
  
  getFiltered <- reactive ({

    result <- sentiment.all.byMonth

    product_list <- revalue(str_split(input$input_products, ',', simplify = TRUE),  warn_missing = FALSE,
                            c("prod_1" = "Bank account or service",
                              "prod_2" = "Credit card",
                              "prod_3" = "Credit reporting",
                              "prod_4" = "Debt collection",
                              "prod_5" = "Mortgage"))


    if (input$input_products == "") {

      # no products
      result <- sentiment.all.byMonth %>% group_by(month, compensated) %>% summarise(score = sum(score))

    } else {

      result %<>% filter(product %in% product_list)
    }

    if (input$input_isCompensated == "yes,no") {

      # nothing - all compensation levels
      if (input$input_products != "") {
        #result <- sentiment.all.id
      }

    } else if (input$input_isCompensated == "yes") {

      result %<>% filter(compensated == TRUE)
    } else if (input$input_isCompensated == "no") {

      result %<>% filter(compensated == FALSE)
    } else {

      # no filtering on compensated or product - only show scores
      if (input$input_products == "") {
        result <- sentiment.all.byMonth %>% group_by(month) %>% summarise(score = sum(score))
      } else {
        result <- sentiment.all.byMonth %>% group_by(month, product) %>% filter(product %in% product_list) %>%
                  summarise(score = sum(score))
      }
    }

    result %<>% left_join(sentiment.totals.byMonth, by = c("month" = "month")) %>%
                  mutate(val = score / total)

    result
  })
  
  getFilteredById <- reactive ({
    
    result <- sentiment.all.byId
    
    product_list <- revalue(str_split(input$input_products, ',', simplify = TRUE),  warn_missing = FALSE,
                            c("prod_1" = "Bank account or service",
                              "prod_2" = "Credit card",
                              "prod_3" = "Credit reporting",
                              "prod_4" = "Debt collection",
                              "prod_5" = "Mortgage"))
    
    
    if (input$input_products == "") {
      
      # no products
      result <- sentiment.all.byId %>% group_by(id, compensated) %>% summarise(score = sum(score))
      
    } else {
      
      result %<>% filter(product %in% product_list)
    }
    
    if (input$input_isCompensated == "yes,no") {
      
      # nothing - all compensation levels
      if (input$input_products != "") {
        #result <- sentiment.all.id
      }
      
    } else if (input$input_isCompensated == "yes") {
      
      result %<>% filter(compensated == TRUE)
    } else if (input$input_isCompensated == "no") {
      
      result %<>% filter(compensated == FALSE)
    } else {
      
      # no filtering on compensated or product - only show scores
      if (input$input_products == "") {
        result <- sentiment.all.byId %>% group_by(id) %>% summarise(score = sum(score))
      } else {
        result <- sentiment.all.byId %>% group_by(id, product) %>% 
                  filter(product %in% product_list) %>%
                  summarise(score = sum(score))
      }
    }
    
    result %<>% mutate(sentiment = ifelse(score < 0, "negative", ifelse(score == 0, "neutral", "positive")))
      #left_join(sentiment.totals.byId, by = c("id" = "id")) %>%
      #mutate(val = 1 - score / total)
    
    result
  })
  
  output$sentimentPlot_perMonth <- renderPlot({ #renderPlotly

    dat <- getFiltered()

    if (("compensated" %in% colnames(dat)) && ("product" %in% colnames(dat)))
    {
      p <- dat %>%
        ggplot(aes(x = month, y = val, group = interaction(product, compensated), fill = interaction(product, compensated))) +
        geom_bar(stat="identity", position = "dodge") +
        xlab("Month") +
        ylab("Score") +
        labs(title = "Sentiment Score per Month for Product and Compensation") +
        scale_fill_discrete(name="Products & Compensated")


    } else if ("compensated" %in% colnames(dat)) {

      p <- dat %>%
        ggplot(aes(x = month, y = val, fill = compensated)) +
        geom_bar(stat="identity", position = "dodge") + 
        xlab("Month") +
        ylab("Score") +
        labs(title = "Sentiment Score per Month for Compensation") +
        scale_fill_discrete(name="Compensated")

    } else if ("product" %in% colnames(dat)) {

      p <- dat %>%
        ggplot(aes(x = month, y = val, fill = product)) +
        geom_bar(stat="identity", position = "dodge") + 
        xlab("Month") +
        ylab("Score") +
        labs(title = "Sentiment Score per Month for Product") +
        scale_fill_discrete(name="Products")
    } else {

      p <- getFiltered() %>%
        ggplot(aes(x = month, y = val)) +
        geom_bar(stat="identity", position = "dodge") +
        xlab("Month") +
        ylab("Score") +
        labs(title = "Sentiment Score per Month") +
        scale_fill_manual(name="Score", values = c("#009688"))
    }

    p

    # ggplotly(p) %>% layout(height = input$plotHeight, autosize=TRUE)
  })
  
  output$sentimentPlot_hist <- renderPlot({ #renderPlotly
    
    dat <- getFilteredById()
    
    ggplot(dat, aes(score, fill = sentiment)) + 
      geom_histogram(binwidth = 1) + 
      xlab("") +
      ylab("Complaints") +
      labs(title = "Distribution of Sentiments for all the Complaints") +
      scale_fill_manual(values = pallete.hist, name = "sentiment", labels=c("Negative", "Neutral", "Positive"))
  })
  
  getComplaintsPerTopic <- reactive({
    
    # Take a dependency on input$btn_update_topic This will run once initially,
    # because the value changes from NULL to 0.
    input$btn_update_topic
    
    complaints.dtm <- complaints.tdf %>%
                      filter(id %in% getFilteredById()$id) %>% # apply filters from selections
                      #anti_join( getFilteredById(), by = c("id" = "id")) %>% 
                      cast_dtm(id, word, n)
    
    k <- isolate( switch(input$input_noTopics, "2" = 2, "3" = 3, "4" = 4, "5" = 5, as.integer(input$input_noTopics)) )
    
    # Use isolate() to avoid dependency on input$input_noTopics
    result <- LDA(complaints.dtm, k = k, control = list(estimate.alpha = FALSE, seed = 2017))
    
    result
  })
  
  output$topicPlot <- renderPlot({
    
    lda <- getComplaintsPerTopic()
    k <- isolate( switch(input$input_noTopics, "2" = 2, "3" = 3, "4" = 4, "5" = 5, as.integer(input$input_noTopics)) )
    
    reviews_topics <- tidy(lda, matrix = "beta")  
    
    top_terms <- reviews_topics %>%
      group_by(topic) %>%
      top_n(15, beta) %>%
      ungroup() %>%
      arrange(topic, -beta) %>%
      mutate(term = reorder(term, beta))

    ggplot(top_terms, aes(term, beta, fill = factor(topic))) +
      geom_col(show.legend = FALSE) +
      facet_wrap(~ topic, scales = "free") +
      labs(title = paste0("For ", k," topics")) +
      xlab("Word") +
      ylab("Beta Score") +
      coord_flip()
  })
  
  getComplaint <- reactive({
    
    # run for any of the buttons being pressed
    input$btn_select_random
    input$btn_select_id
    input$btn_select_text
    
    v <- isolate( input$complaintType )
    
    if (v == "Random") {
      d <- complaints %>% filter(id == sample(1:nrow(complaints), 1)) %>% 
            mutate(complaint = consumer_complaint_narrative) %>% select(id, complaint)
    } else if (v == "New") {
      txt <- isolate( input$input_text )
      d <- data.frame(id = nrow(complaints) + 1, complaint = txt, stringsAsFactors = FALSE) %>% as.tibble()
    } else {
      selectedId <- isolate(input$input_id)
      d <- complaints %>% filter(id == selectedId) %>% 
           mutate(complaint = consumer_complaint_narrative) %>% select(id, complaint)
    }
    
    d
  })
  
  getComplaintWords <- reactive({
    
    ref <- getComplaint()
    
    ref %<>% mutate(text = str_replace_all(complaint, replace_reg, " ")) %>%
      unnest_tokens(word, text, token = "regex", pattern = unnest_reg, to_lower = TRUE) %>% # tokenize
      anti_join( filter(stop_words, lexicon == "snowball"), by = c("word" = "word")) %>% # remove stop words
      filter(word != "x") %>%
      select(id, word) %>%
      left_join(get_sentiments("bing"), by = c("word" = "word")) %>% # add sentiments (pos or neg)
      select(word, sentiment, everything()) %>%
      mutate(sentiment = ifelse(is.na(sentiment), "neutral", sentiment), 
             score = as.numeric( revalue(sentiment, c("positive" = 1, "neutral" = 0, "negative" = -1)), warn_missing = FALSE) )
    
    ref
  })
  
  output$topic_id <- renderText({
    ref <- getComplaint()
    
    print(ref$id)
  })
  
  output$topic_text <- renderText({
    ref <- getComplaint()
    
    print(ref$complaint)
  })
  
  
  output$complaint_result <- renderText({
    
    d <- getComplaintWords() %>% summarise(total = sum(score), mean = mean(score))
    
    percentile <- ecdf(sentiment.all.byId$score)
    target <- percentile(mean(d$mean))
    
    HTML( paste0("Results: <span> Sentiment: ", d$total, " :  Percentile: ", round(target*100)))
  })
  
  output$topic_table <- renderTable(digits = 2, {
    
    lda <- getComplaintsPerTopic()
    k <- isolate( switch(input$input_noTopics, "2" = 2, "3" = 3, "4" = 4, "5" = 5, as.integer(input$input_noTopics)) )
    
    dtm <- getComplaintWords() %>% group_by(id, word) %>% count() %>% ungroup() %>% #tdf
            cast_dtm(id, word, n)
    
    topic.probabilities <- posterior(lda, dtm)
    result <- data.frame(Topic = 1:k, Proportion = topic.probabilities[[2]][1,])
    print(result)
  })
}
