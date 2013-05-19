% Introduction to R
% George Lesica
% May, 2013

# What is R?

  * Pedantic
    * Open source implementation of S
    * Largely compatible with commercial S-PLUS
  * Useful
    * Language and framework for data-oriented computing
    * By statisticians, for statisticians (this is important)
    * Includes a number of convenience libraries and tools

# Up and running in one slide

  * Development Environment
    * R Project: <http://www.r-project.org>
    * RStudio: <http://www.rstudio.com/>
  * Sample Data
    * Google Flu Trends: <http://www.google.org/flutrends/us/data.txt>
    * Movie ratings <http://demo.lesica.com/movies.csv>
    * AFINN Corpus
      <http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=6010>

# Let's talk tools - RStudio

  * Great IDE for both coding and interactive work
  * In-window plotting and plot history
  * Built-in documentation browser
  * Code completion
  * Variety of color themes
  * Version control integration
  * Some refactoring support (reflow, extract function, jump to definition)

# The R language

  * C-inspired syntax
  * Anonymous functions
  * Data-centric data structures
    * Vector
    * List
    * Matrix
    * Data Frame
  * Vectorized operations
  * Call-by-value (memory!)

# R in thirty seconds - variables

  * Character
  * Integer
  * Numeric
  * Boolean
  * NA (missing value)
  * NULL (nothing)

# R in thirty seconds - operators

  * Assignment: `<-`
  * Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
  * Logical: `&&`, `&`, `||`, `|`, `!` (short forms are element-wise)
  * Math: `+`, `-`, `*`, `/`, `^`
  * Special:
    * NA: `is.na()`
    * NULL: `is.null()`
    * Be careful comparing to these weird values

# R in thirty seconds - functions

  * Declaration: `f <- function() { ... }`
  * Calling: `f()`
  * Call by value (watch your memory!)
  * Functions are first-class so higher-order functions are fine:

```{.r}
> f <- function() { function() { 2 }}
> g <- f()
> g()
[1] 2

> h <- function(x) { x() + 2 }
> h(g)
[1] 4
```

# R in thirty seconds - flow control

  * Conditional: `if (...) { ... } else { ... }` - else clause optional
    * Be careful, this is a syntax error (newline before `else`):

```{.r}
if (...) {
    ...
}
else {
    ...
}
```

  * Loops:
    * `for (i in ...) { ... }`
    * `while (...) { ... }`
    * `break` and `next` may be used inside loops

# Use the vectors, Luke!

Vectors are everywhere!

```{.r}
> length('hello world')
[1] 1
> length(c('hello world'))
[1] 1
> length(c('hello', 'world'))
[1] 2
> length(5)
[1] 1
> length(c(5))
[1] 1
```

WTF?

# Show me the codez!

A simple demonstration of several aspects of R. Note that there are two types of
return, explicit and implicit.

```{.r}
power.up <- function(x, p=NULL) {
  if (is.null(p)) {
    return(x ^ 2)
  }
  x ^ p
}

a <- 5
b <- 1:5
c <- c(2,4,5)
```


