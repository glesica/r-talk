# Filename: sentiment.r
# Author: George Lesica <george@lesica.com>
# Description: Very simple sentiment analysis script that demonstrates various
# features of R.

library('rjson')
library('stringr')
library('lattice')

# Perform a naive sentiment analysis on strings of text.
# Args:
#   str: a vector of one more text strings
#   src: csv file containing words and scores, defaults to AFINN-111
# Returns:
#   a vector of sentiment scores the same length as str
sentiment <- function(str, src=NULL) {
  # Helper function to tokenize strings
  tokenize <- function(str) {
    str_split(str, "[^a-zA-Z0-9']")
  }
  # Read in the word scores
  cls <- c('character', 'numeric')
  nms <- c('words', 'values')
  if (is.null(src)) {
    db <- read.csv('data/AFINN-111.txt', sep='\t',
                   col.names=nms, colClasses=cls, head=F)
  } else {
    db <- read.csv(src, col.names=nms, colClasses=cls, head=F)
  }
  # Perform analysis - simple algo, just sum scores for words in each string
  sapply(tokenize(str), function(words) {
    sum(db$values[db$words %in% tolower(words)])
  })
}

# Example that uses the sentiment analysis function above to evaluate some
# movie titles. After that, we plot the results against the critic and user
# ratings for each movie. The goal is to determine whether there is a
# relationship between the sentiment of a movie title and the movie's popular
# and critical reception.
#
# As you can see, plotting can be complicated! Here we use Lattice, which is a
# functional-style plotting system inspired by Trellis, a plotting system
# originally designed by Bell Labs for use in S and S-PLUS.

# Due to this comlexity (and power), it is usually a good idea to write your
# own plotting function(s) that matches your data and wraps one of the plotting
# methods available in R. This way you can just pass in your data and get back
# a nice, consistent plot that is properly configured for your project.

movie.titles <- function() {
    movie_data <- read.csv('data/movies.csv',
                           col.names=c('title', 'critic', 'user'),
                           colClasses=c('character', 'numeric', 'numeric'),
                           head=F)
    movie_data$sentiment <- sentiment(movie_data$title)
    movie_data <- movie_data[movie_data$sentiment != 0,]
    xyplot(sentiment ~ user + critic, data=movie_data, pch=20,
           main=list(label='Movie Title Sentiment', cex=2, fontfamily='Ubuntu'),
           xlab=list(label='Rating', cex=1.5, fontfamily='Ubuntu'),
           ylab=list(label='Sentiment Score', cex=1.5, fontfamily='Ubuntu'),
           cex=3, xlim=c(0, 1), col=c('green', 'magenta'),
           panel=function(x, y, ...) {
               panel.xyplot(x, y, ...)
               mod <- lm(y ~ x)
               panel.abline(mod, col='black', lwd=4)
               panel.text(min(x), mod$coefficients[1] + mod$coefficients[2] * 2,
                          paste('b =', format(mod$coefficients[2], digits=3)))
           },
           key=list(text=list(c('User ratings', 'Critic ratings')),
                    points=list(cex=c(3, 3), col=c('green', 'magenta')),
                    pch=20, padding.text=4, border=T,
                    x=0.05, y=0.95, corner=c(0, 1)))
}

# This takes a search query, optional subreddit and number of search results
# to use and returns a positive-ness score based on an analysis of the link
# titles returned by the Reddit search engine.
#
# This is an example of using JSON from R. We take advantage of the fact that
# Reddit provides a simple way to get any page within the site in JSON format.
# This doesn't really work very well, possibly because link titles are often
# sarcastic and/or non-descriptive.

# Estimate the sentiment of Reddit users toward a given topic.
# Args:
#   str: a search string to evaluate
#   sr: the name of a subreddit to search
#   n: number of results to use, max 100
# Returns:
#   a scalar in [-5, 5] representing sentiment
reddit.thinks <- function(str, sr='all', n=50) {
  url <- str_join('http://reddit.com/',
                  str_join('r/', sr, '/search.json?'),
                  'sort=top&restrict_sr=on',
                  str_join('&limit=', min(n, 100)),
                  str_join('&q=', URLencode(str)))
  # Fetch titles from Reddit in JSON format
  json.data <- suppressWarnings(fromJSON(file=url))
  # Harvest the titles from the parsed JSON
  titles <- sapply(json.data$data$children, function(x) {
    x$data$title
  })
  # Make sure we have at least n results for consistency
  if (length(titles) < n) {
    warning(str_join('too few search results (', length(titles), ')'))
  }
  # Note that we're using an implicit return here
  mean(sentiment(titles))
}

terms <- c('barack obama', 'eric holder', 'julian assange',
           'sarah palin', 'kittens')
#cores <- sapply(terms, reddit.thinks)

# Now we try a variant that uses comment text instead of the link text.

# Estimate the sentiment of Reddit users toward a given topic.
# Args:
#   str: a search string to evaluate
#   sr: the name of a subreddit to search
#   n: number of results to use, max 100
#   depth: number of comments to evaluate for each search result
#   rl: time between requests
# Returns:
#   a scalar in [-5, 5] representing sentiment
reddit.thinks2 <- function(str, sr='all', n=10, depth=10, rl=0.1) {
  # Do the initial search for entries
  search.url <- str_join('http://reddit.com',
                         '/r/', sr, '/search.json?',
                         'sort=top&restrict_sr=on',
                         '&limit=', min(n, 100),
                         '&q=', URLencode(str))
  search.data <- suppressWarnings(fromJSON(file=search.url))
  # Create urls and compute scores for entries
  entry.urls <- sapply(search.data$data$children, function(e) {
    # Warn if there were too few comments
    if (e$data$num_comments < depth) {
      warning(str_join('too few comments (', e$data$num_comments, ')'))
    }
    str_join('http://reddit.com', e$data$permalink, '.json')
  })
  entry.scores <- sapply(entry.urls, function(u) {
    Sys.sleep(rl) # Rate limit
    entry.data <- suppressWarnings(fromJSON(file=u))
    comments <- entry.data[[2]]$data$children[1:depth]
    node.types <- sapply(comments, function(c) {
      c$kind
    })
    comment.scores <- sapply(comments[node.types == 't1'], function(c) {
      sentiment(c$data$body)
    })
    mean(comment.scores)
  })
  # Make sure we have at least n results for consistency
  if (length(entry.scores) < n) {
    warning(str_join('too few search results (', length(entry.scores), ')'))
  }
  return(mean(entry.scores))
}

#scores2 <- sapply(terms, reddit.thinks2)