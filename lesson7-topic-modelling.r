
library(tidyverse)
library(tidytext)
library(topicmodels)

load("data/my_imdb_reviews.RData")

reviews <- as.tibble(reviews)
reviews$review <- as.character(reviews$review) 
reviews$reviewId <- 1:nrow(reviews) 
reviews <- reviews %>% rename(imdbId = imbdId)

tidy_reviews <- reviews %>% 
  unnest_tokens(word, review, token = "words", to_lower = T) %>%
  filter(!word %in% stop_words$word)

reviews_tdf <- tidy_reviews %>%
  group_by(reviewId,word) %>%
  count() %>%  
  ungroup() 

dtm_reviews <- reviews_tdf %>% 
  cast_dtm(reviewId, word, n)

set.seed(1234)
reviews_lda <- LDA(dtm_reviews, k = 2)
reviews_lda
str(reviews_lda)

term <- as.character(reviews_lda@terms)
topic1 <- reviews_lda@beta[1,]
topic2 <- reviews_lda@beta[2,]
reviews_topics <- tibble(term = term, topic1 = topic1, topic2 = topic2)

reviews_topics <- reviews_topics %>% 
  gather(topic1, topic2, key = "topic", value = "beta") %>%
  mutate(beta = exp(beta)) # pr(topic k generates word i) = exp(beta_ik)
head(reviews_topics)

reviews_topics <- tidy(reviews_lda, matrix = "beta")
head(reviews_topics)

top_terms <- reviews_topics %>%
  group_by(topic) %>%
  top_n(20, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

beta_spread <- reviews_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic1 > .001 | topic2 > .001) %>%
  mutate(log_ratio = log2(topic2 / topic1))

beta_spread %>%
  group_by(direction = log_ratio > 0) %>%
  top_n(10, abs(log_ratio)) %>%
  ungroup() %>%
  mutate(term = reorder(term, log_ratio)) %>%
  ggplot(aes(term, log_ratio)) +
  geom_col() +
  labs(y = "Log2 ratio of beta in topic 2 / topic 1") +
  coord_flip()

reviews_gamma <- reviews %>% 
    left_join(tidy(reviews_lda, matrix = "gamma") %>% 
    mutate(reviewId = as.numeric(document)) %>% # some cleaning to make key variable (reviewId) usable
    select(-document) %>%
    spread(key = topic, value = gamma, sep = "_"))

reviews_gamma %>% group_by(imdbId) %>% summarize(ntopic1 = sum(topic_1 > 0.5))

reviews_gamma %>% filter(imdbId == "0075314") %>% arrange(desc(topic_1)) %>% select(imdbId, topic_1, topic_2) %>% head(3)

reviews_gamma %>% filter(imdbId == "0075314") %>% arrange(topic_1) %>% select(imdbId, topic_1, topic_2) %>% head(3)

reviews_gamma %>% filter(imdbId != "0075314") %>% arrange(topic_1) %>% select(imdbId, topic_1, topic_2) %>% head(3)

reviews_gamma %>% filter(imdbId != "0075314") %>% arrange(topic_2) %>% select(imdbId, topic_1, topic_2) %>% head(3)
