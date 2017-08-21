Lesson 3 // Web scraping
================

Web scraping is the process of extracting data from websites. It can be done manually, but typically when we talk of web scraping we mean gathering data from websites by automated means. Web scraping involves two distinct processes: fetching or downloading the web page, and extracting data from it. In this lesson we introduce the **rvest** package, which provides various web scraping functions.

In this lesson we'll:

1.  introduce the SelectorGadget tool and show how to use it to identify the parts of a webpage we want.
2.  use **rvest**'s key functions - `read_html()`, `html_nodes()`, and `html_text()` - to scrape data from the web.
3.  see how to scrape data tables from the web.
4.  use `html_attr()` to get HTML nodes of a particular type, like hyperlinks.
5.  use what we've learned to build two larger examples, scraping property data and movie reviews.

Web scraping involves working with HTML files, the language used to construct web pages. The better you know HTML, the easier web scraping will be and the more you can do. That said, this notebook is written as a practical "how to" guide to doing web scraping in R, and tries to get you up and running as quickly as possible. We introduce bits and pieces of HTML as needed, but do not cover these from first principles or in great detail. There is a nice basic introduction to HTML [here](http://www.simplehtmlguide.com/).

Nevertheless, it will be useful to have a rough idea how everything fits together, which is summarised below:

-   Websites are written using **HTML** (Hypertext Markup Language), a markup programming language. A web page is basically an HTML file. An HTML file is a plain-text file in which the text is written using the HTML language i.e. contains HTML commands, content, etc. HTML files can be linked to one another, which is how a web site is put together.

-   An HTML file, and hence a web page, consists of two main parts: HTML **tags** and content. HTML tags are the parts of a web page that define how content is formatted and displayed in a web browser. Its easiest to explain with a small example. Below is a minimal HTML file: the tags are the commands within angle brackets e.g. `<head>`. Try copying the text below to a text editor, save as .html, and open in your browser. Tags can be customised with **tag attributes**.

<!-- -->

-   CSS is **Cascading Style Sheets**, a "style sheet language". A style sheet language is a programming language that controls how certain kinds of documents are structured. CSS is a style sheet language for markup documents like those written using HTML. Style sheets define things like the colour and layout of text and other HTML tags. Separating presentation from content is often useful e.g. multiple HTML pages can share formatting through a shared CSS (.css) file.

-   A CSS file is written as a set of rules. Each rule consists of a **selector** and a declaration. The CSS selector points to the HTML element the declaration refers to. The declaration contains instructions about how the HTML element identified by the CSS selector should be presented. CSS selectors identify HTML elements by matching tags and tag attributes. There's a fun tutorial on CSS selectors [here](http://flukeout.github.io/).

-   **rvest** uses CSS selectors to identify the parts of the web page to scrape.

> Please note! Web scraping invariably involves copying data, and thus copyright issues are often involved. Beyond that, automated web scraping software can process data much more quickly that manual web users, placing a strain on host web servers. Scraping may also be against the terms of service of some websites. The bottom line is that the ethics of web scraping is not straightforward, and is evolving. There is lots of useful information on the web about these issues, for example [here](https://medium.com/towards-data-science/ethics-in-web-scraping-b96b18136f01), [here](http://gijn.org/2015/08/12/on-the-ethics-of-web-scraping-and-data-journalism/), and [here](http://gijn.org/2015/08/12/on-the-ethics-of-web-scraping-and-data-journalism/) (reading up on these is one of the exercises at the end of the notebook).

------------------------------------------------------------------------

First we load the packages we'll need in this workbook.

``` r
library(rvest)
```

    ## Warning: package 'rvest' was built under R version 3.3.3

    ## Loading required package: xml2

    ## Warning: package 'xml2' was built under R version 3.3.3

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 3.3.3

    ## Loading tidyverse: ggplot2
    ## Loading tidyverse: tibble
    ## Loading tidyverse: tidyr
    ## Loading tidyverse: readr
    ## Loading tidyverse: purrr
    ## Loading tidyverse: dplyr

    ## Warning: package 'ggplot2' was built under R version 3.3.3

    ## Warning: package 'tibble' was built under R version 3.3.3

    ## Warning: package 'tidyr' was built under R version 3.3.3

    ## Warning: package 'readr' was built under R version 3.3.3

    ## Warning: package 'purrr' was built under R version 3.3.3

    ## Warning: package 'dplyr' was built under R version 3.3.3

    ## Conflicts with tidy packages ----------------------------------------------

    ## filter(): dplyr, stats
    ## lag():    dplyr, stats

``` r
library(stringr)
```

Example 1: A simple example to illustrate the use of Selector Gadget
--------------------------------------------------------------------

In this example we'll visit the [Eyewitness News](http://ewn.co.za) webpage and use the **SelectorGadget** tool to find the CSS selectors for headlines . Then we'll use the **rvest** package to scrape the headings and save them as strings in R.

First, make sure you've got the SelectorGadget tool available in your web browser's toolbar. Go to <http://selectorgadget.com/> and find the link that says "drag this link to your bookmark bar": do that. You only need to do this once.

Now let's visit the [Eyewitness News](http://ewn.co.za) webpage. Click on the SelectorGadget tool and identify the CSS selectors for headlines (should be `.article-short h4, h1`, although this may change with time). I'll show you how to do this in class, or follow the tutorial on the SelectorGadget website.

Finally, let's switch over to R and scrape the headlines.

We first read in the webpage using `read_html`. This simply reads in an HTML document, which can be from a url, a file on disk or a string. It returns an XML (another markup language) document.

``` r
ewn_page <- read_html("http://ewn.co.za/")
ewn_page
```

    ## {xml_document}
    ## <html lang="en">
    ## [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset= ...
    ## [2] <script type="text/javascript">window.NREUM||(NREUM={});NREUM.info = ...
    ## [3] <script type="text/javascript">window.NREUM||(NREUM={}),__nr_require ...
    ## [4] <body class="campaign">\r\n    <!-- Google Tag Manager (noscript) -- ...

We extract relevant information from the document with `html_nodes`. This returns a set of XML element nodes, each one containing the tag and contents (e.g. text) associated with the specified CSS selectors:

``` r
ewn_elements <- html_nodes(x = ewn_page, css = ".article-short h4 , h1")
ewn_elements
```

    ## {xml_nodeset (44)}
    ##  [1] <h4 class="h4-mega text-center"><a href="http://ewn.co.za/Multimedi ...
    ##  [2] <h4 class="h4-mega text-center"><a href="http://ewn.co.za/Multimedi ...
    ##  [3] <h4 class="h4-mega text-center"><a href="http://ewn.co.za/Multimedi ...
    ##  [4] <h4 class="h4-mega text-center"><a href="http://ewn.co.za/Multimedi ...
    ##  [5] <h1>\r\n                                            Robert Mugabe h ...
    ##  [6] <h4>\r\n                                            Ex-cop's claim  ...
    ##  [7] <h4>\r\n                                            Pretoria CBD cl ...
    ##  [8] <h4>\r\n                                            #VoteOfNoConfid ...
    ##  [9] <h4><a href="http://ewn.co.za/2017/08/16/uwc-highlights-entrepreneu ...
    ## [10] <h4><a href="http://ewn.co.za/2017/08/16/pupils-to-get-counselling- ...
    ## [11] <h4><a href="http://ewn.co.za/2017/08/16/body-burnt-beyond-recognit ...
    ## [12] <h4><a href="http://ewn.co.za/2017/08/16/trump-praises-north-korean ...
    ## [13] <h4><a href="http://ewn.co.za/2017/08/16/blow-for-crystal-palace-as ...
    ## [14] <h4><a href="http://ewn.co.za/2017/08/16/opinion-the-danger-of-supp ...
    ## [15] <h4><a href="http://ewn.co.za/2017/08/16/soes-state-capture-probe-m ...
    ## [16] <h4><a href="http://ewn.co.za/2017/08/16/gundogan-returns-in-man-ci ...
    ## [17] <h4>[OPINION] Top trumps: Zuma intimidation no match for Constituti ...
    ## [18] <h4>[WATCH] Zweli Mkhize: No confidence debate one of the most surp ...
    ## [19] <h4>[CARTOON] When You Strike A Woman...</h4>
    ## [20] <h4>[LISTEN] Top five nutrition lies debunked</h4>
    ## ...

To get just the text inside the element nodes we use `html_text`, with `trim = TRUE` to clean up whitespace characters.

``` r
ewn_text <- html_text(ewn_elements, trim = TRUE)
as.tibble(ewn_text)
```

    ## # A tibble: 44 x 1
    ##                                                                         value
    ##                                                                         <chr>
    ##  1                                                                      Video
    ##  2                                                                      Audio
    ##  3                                                               Infographics
    ##  4                                                                   Cartoons
    ##  5               Robert Mugabe heading to SA over assault claims against wife
    ##  6 Ex-cop's claim that Timol died in the afternoon contradicts prior evidence
    ##  7                        Pretoria CBD cleared following taxi drivers<U+0092> strike
    ##  8         #VoteOfNoConfidence: 'There's no way of identifying how MPs voted'
    ##  9                         UWC highlights entrepreneurship as a career option
    ## 10  Pupils to get counselling after learner killed in gang violence crossfire
    ## # ... with 34 more rows

The table above contains some stuff we don't want (like \[WATCH\]). We'll look at ways to clean up text later.

Example 2: Scraping tables
--------------------------

One especially useful form of scaping is getting tables containing data from websites. This example shows you how to do that.

We'll use the table on [this ESPN cricinfo webpage](http://stats.espncricinfo.com/ci/engine/records/averages/batting.html?class=1;id=2017;type=year), which contains 2017 test cricket batting averages. Before running the code below, visit the webpage and use SelectorGadget to identify the CSS selector you need. Also familiarise yourself with the table, just so you know what to expect.

First, read the webpage as before:

``` r
cric_page <- read_html("http://stats.espncricinfo.com/ci/engine/records/averages/batting.html?class=1;id=2017;type=year")
```

Extract the table element(s) with `html_nodes()`.

``` r
cric_elements <- html_nodes(x = cric_page, css = "table")
```

View the extracted elements, and see we only want the first one.

``` r
cric_elements
```

    ## {xml_nodeset (3)}
    ## [1] <table class="engineTable">\n<caption>Batting averages</caption>\n<t ...
    ## [2] <table class="engineTable" id="shading-desc">\n<tr class="data2" sty ...
    ## [3] <table class="engineTable" style="margin:0px;">\n<tr class="data2">\ ...

Use `html_table()` to extract the tables inside the first element of `cric_elements`.

``` r
cric_table <- html_table(cric_elements[[1]])
head(cric_table)
```

    ##                Player Mat Inns NO Runs  HS   Ave   BF    SR 100 50 0 4s 6s
    ## 1      KJ Abbott (SA)   1    1  0   16  16 16.00   26 61.53   0  0 0  3  0
    ## 2 Ahmed Shehzad (PAK)   2    4  0  121  70 30.25  310 39.03   0  1 0 15  0
    ## 3        MM Ali (ENG)   4    8  1  252  87 36.00  351 71.79   0  2 0 30  3
    ## 4        HM Amla (SA)   9   17  1  645 134 40.31 1327 48.60   1  4 1 92  3
    ## 5   JM Anderson (ENG)   4    7  4   19  12  6.33   48 39.58   0  0 1  2  1
    ## 6   Asad Shafiq (PAK)   4    7  0  101  30 14.42  282 35.81   0  0 1 13  0

We can also use the pipe for this. Note the use of `.[[i]]`, which is the operation "extract the *i*-th element".

``` r
cric_table_piped <- cric_page %>% html_nodes("table") %>% .[[1]] %>% 
    html_table()
head(cric_table_piped)
```

    ##                Player Mat Inns NO Runs  HS   Ave   BF    SR 100 50 0 4s 6s
    ## 1      KJ Abbott (SA)   1    1  0   16  16 16.00   26 61.53   0  0 0  3  0
    ## 2 Ahmed Shehzad (PAK)   2    4  0  121  70 30.25  310 39.03   0  1 0 15  0
    ## 3        MM Ali (ENG)   4    8  1  252  87 36.00  351 71.79   0  2 0 30  3
    ## 4        HM Amla (SA)   9   17  1  645 134 40.31 1327 48.60   1  4 1 92  3
    ## 5   JM Anderson (ENG)   4    7  4   19  12  6.33   48 39.58   0  0 1  2  1
    ## 6   Asad Shafiq (PAK)   4    7  0  101  30 14.42  282 35.81   0  0 1 13  0

Example 3: Scraping house property data
=======================================

This is a more advanced example where we scrape data on houses for sale in a particular area of interest.

The landing page for a suburb shows summaries for the first 20 houses. At the bottom of the page are links to a further pages, each containing 20 house summaries. First we read in the landing page and identify *all* hyperlinks on that page.

``` r
suburb <- read_html("https://www.property24.com/for-sale/fish-hoek/cape-town/western-cape/9074")
suburb_links <- suburb %>% html_nodes("a") %>% html_attr("href")
print(suburb_links)
```

    ##   [1] "http://windows.microsoft.com/en-US/internet-explorer/download-ie"                      
    ##   [2] "/"                                                                                     
    ##   [3] "/"                                                                                     
    ##   [4] "/for-sale/fish-hoek/fish-hoek/western-cape/9074"                                       
    ##   [5] "/new-developments/fish-hoek/fish-hoek/western-cape/9074"                               
    ##   [6] "/commercial-property-for-sale/fish-hoek/fish-hoek/western-cape/9074"                   
    ##   [7] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=r%3dTrue"                           
    ##   [8] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=oa%3dTrue"                          
    ##   [9] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=os%3dTrue"                          
    ##  [10] "/property-values/fish-hoek/fish-hoek/western-cape/9074"                                
    ##  [11] "/to-rent"                                                                              
    ##  [12] "/houses-to-rent/fish-hoek/fish-hoek/western-cape/9074"                                 
    ##  [13] "/apartments-to-rent/fish-hoek/fish-hoek/western-cape/9074"                             
    ##  [14] "/commercial-property-to-rent/fish-hoek/fish-hoek/western-cape/9074"                    
    ##  [15] "/estate-agencies/western-cape/9"                                                       
    ##  [16] "/new-developments"                                                                     
    ##  [17] "/new-developments/fish-hoek/fish-hoek/western-cape/9074"                               
    ##  [18] "/commercial-property"                                                                  
    ##  [19] "/commercial-property-for-sale/fish-hoek/fish-hoek/western-cape/9074"                   
    ##  [20] "/commercial-property-to-rent/fish-hoek/fish-hoek/western-cape/9074"                    
    ##  [21] "/calculators/bond"                                                                     
    ##  [22] "/calculators/bond"                                                                     
    ##  [23] "/calculators/affordability"                                                            
    ##  [24] "/articles/advice"                                                                      
    ##  [25] "/articles/news"                                                                        
    ##  [26] "/articles/advice"                                                                      
    ##  [27] "/property101/sellers-guide/the-best-time-to-sell-a-home"                               
    ##  [28] "/property101/buyers-guide/become-a-first-time-home-owner"                              
    ##  [29] "/property-tools-and-services"                                                          
    ##  [30] "/service-provider-search"                                                              
    ##  [31] "/property-values/fish-hoek/fish-hoek/western-cape/9074"                                
    ##  [32] "/estate-agencies/fish-hoek/fish-hoek/western-cape/9074"                                
    ##  [33] "/attorney-firms/fish-hoek/fish-hoek/western-cape/9074"                                 
    ##  [34] "/private-listing/sell-my-property"                                                     
    ##  [35] "/private-listing/sell-my-property"                                                     
    ##  [36] "/private-listing/rent-my-property"                                                     
    ##  [37] "#loginModal"                                                                           
    ##  [38] "#loginModal"                                                                           
    ##  [39] "/for-sale/fish-hoek/fish-hoek/western-cape/9074"                                       
    ##  [40] "/to-rent/fish-hoek/fish-hoek/western-cape/9074"                                        
    ##  [41] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=r%3dTrue"                           
    ##  [42] "/property-values/fish-hoek/fish-hoek/western-cape/9074"                                
    ##  [43] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=os%3dTrue"                          
    ##  [44] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=oa%3dTrue"                          
    ##  [45] "/estate-agencies/fish-hoek/fish-hoek/western-cape/9074"                                
    ##  [46] "/attorney-firms/fish-hoek/fish-hoek/western-cape/9074"                                 
    ##  [47] "/articles/news"                                                                        
    ##  [48] "/new-developments/fish-hoek/fish-hoek/western-cape/9074"                               
    ##  [49] "javascript:void(0)"                                                                    
    ##  [50] "/"                                                                                     
    ##  [51] "javascript:;"                                                                          
    ##  [52] "/terms-and-conditions"                                                                 
    ##  [53] "/"                                                                                     
    ##  [54] "/for-sale/western-cape/9"                                                              
    ##  [55] "/for-sale/fish-hoek/western-cape/475"                                                  
    ##  [56] "/for-sale/fish-hoek/fish-hoek/western-cape/9074#SortOrder"                             
    ##  [57] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=so%3dPriceLow#SortOrder"            
    ##  [58] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=so%3dPriceHigh#SortOrder"           
    ##  [59] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=so%3dNewest#SortOrder"              
    ##  [60] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=so%3dType#SortOrder"                
    ##  [61] "/for-sale/fish-hoek/fish-hoek/western-cape/9074?sp=so%3dSize#SortOrder"                
    ##  [62] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105489469"                             
    ##  [63] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105483416"                             
    ##  [64] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105419355"                             
    ##  [65] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105438193"                             
    ##  [66] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105403095"                             
    ##  [67] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105467451"                             
    ##  [68] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105459973"                             
    ##  [69] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105444036"                             
    ##  [70] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105392855"                             
    ##  [71] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105436211"                             
    ##  [72] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105403984"                             
    ##  [73] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105436009"                             
    ##  [74] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105418697"                             
    ##  [75] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105349318"                             
    ##  [76] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105440012"                             
    ##  [77] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105380865"                             
    ##  [78] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105443836"                             
    ##  [79] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105357913"                             
    ##  [80] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105380944"                             
    ##  [81] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105432281"                             
    ##  [82] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101746384"                             
    ##  [83] "javascript:;"                                                                          
    ##  [84] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p2"          
    ##  [85] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074"             
    ##  [86] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p2"          
    ##  [87] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p3"          
    ##  [88] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p4"          
    ##  [89] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p5"          
    ##  [90] "/fish-hoek/fish-hoek/property-trends/9074"                                             
    ##  [91] NA                                                                                      
    ##  [92] NA                                                                                      
    ##  [93] NA                                                                                      
    ##  [94] NA                                                                                      
    ##  [95] NA                                                                                      
    ##  [96] NA                                                                                      
    ##  [97] NA                                                                                      
    ##  [98] NA                                                                                      
    ##  [99] NA                                                                                      
    ## [100] NA                                                                                      
    ## [101] NA                                                                                      
    ## [102] NA                                                                                      
    ## [103] NA                                                                                      
    ## [104] NA                                                                                      
    ## [105] NA                                                                                      
    ## [106] NA                                                                                      
    ## [107] NA                                                                                      
    ## [108] NA                                                                                      
    ## [109] NA                                                                                      
    ## [110] NA                                                                                      
    ## [111] "javascript:;"                                                                          
    ## [112] "/for-sale/fish-hoek/fish-hoek/western-cape/9074"                                       
    ## [113] "/houses-for-sale/fish-hoek/fish-hoek/western-cape/9074"                                
    ## [114] "/apartments-for-sale/fish-hoek/fish-hoek/western-cape/9074"                            
    ## [115] "/townhouses-for-sale/fish-hoek/fish-hoek/western-cape/9074"                            
    ## [116] "/vacant-land-for-sale/fish-hoek/fish-hoek/western-cape/9074"                           
    ## [117] "/commercial-property-for-sale/fish-hoek/fish-hoek/western-cape/9074"                   
    ## [118] "/articles/own-a-manor-house-in-capes-milnerton-for-r79m/26271"                         
    ## [119] "/articles/atlantic-seaboard-and-city-bowl-still-sas-hottest-property/26258"            
    ## [120] "/articles/new-estate-homes-in-western-capes-wellington-from-r195m/26257"               
    ## [121] "/articles/buying-property-heres-what-r2m-can-get-you-around-gauteng/26254"             
    ## [122] "/articles/a-step-by-step-guide-to-becoming-a-real-estate-agent/26252"                  
    ## [123] "/articles/safety-conscious-lonehill-in-joburg-offers-home-buyers-excellent-value/26255"
    ## [124] "/articles/south-africans-can-now-invest-in-luxury-property-in-zanzibar/26251"          
    ## [125] "/articles/2-in-1-property-in-cape-towns-pelican-heights-on-auction/26243"              
    ## [126] "/articles/high-end-buyers-still-flocking-to-camps-bay-in-cape-town/26248"              
    ## [127] "/articles/great-value-for-buyers-in-cape-towns-athlone-and-belhar/26233"               
    ## [128] "javascript:;"                                                                          
    ## [129] "/estate-agencies/fish-hoek/fish-hoek/western-cape/9074"                                
    ## [130] "/property-values/fish-hoek/fish-hoek/western-cape/9074"                                
    ## [131] "/for-sale/fish-hoek/western-cape/475"                                                  
    ## [132] "/for-sale/western-cape/9"                                                              
    ## [133] "/for-sale/clovelly/fish-hoek/western-cape/10947"                                       
    ## [134] "/for-sale/faerie-knowe/fish-hoek/western-cape/9082"                                    
    ## [135] "/for-sale/fish-hoek/fish-hoek/western-cape/9074"                                       
    ## [136] "/for-sale/silverglade/fish-hoek/western-cape/9076"                                     
    ## [137] "/for-sale/stonehaven-estate/fish-hoek/western-cape/13916"                              
    ## [138] "/for-sale/sun-valley/fish-hoek/western-cape/9073"                                      
    ## [139] "/for-sale/sunny-cove/fish-hoek/western-cape/16105"                                     
    ## [140] "/for-sale/sunnydale/fish-hoek/western-cape/9090"                                       
    ## [141] "/"                                                                                     
    ## [142] "https://www.facebook.com/property24"                                                   
    ## [143] "https://twitter.com/Property24"                                                        
    ## [144] "https://www.pinterest.com/property24/"                                                 
    ## [145] "https://www.youtube.com/user/Property24"                                               
    ## [146] "https://plus.google.com/u/0/+property24/posts"                                         
    ## [147] "/General/AboutUs"                                                                      
    ## [148] "/contact-us"                                                                           
    ## [149] "/careers"                                                                              
    ## [150] "/terms-and-conditions"                                                                 
    ## [151] "/sitemap"                                                                              
    ## [152] "https://manage.property24.com/"                                                        
    ## [153] "https://itunes.apple.com/us/app/property24.com-property-for/id486012121?mt=8"          
    ## [154] "https://play.google.com/store/apps/details?id=com.korbitec.property24"                 
    ## [155] "https://www.microsoft.com/en-za/store/apps/property24com/9wzdncrcs061"                 
    ## [156] "http://m.property24.com"                                                               
    ## [157] "https://itunes.apple.com/us/app/property24.com-property-for/id486012121?mt=8"          
    ## [158] "https://play.google.com/store/apps/details?id=com.korbitec.property24"                 
    ## [159] "https://www.google.com/intl/en/chrome/browser/"                                        
    ## [160] "http://www.mozilla.org/en-US/firefox/"                                                 
    ## [161] "http://windows.microsoft.com/en-us/internet-explorer/download-ie"                      
    ## [162] "https://www.facebook.com/property24"                                                   
    ## [163] "https://twitter.com/Property24"                                                        
    ## [164] "https://pinterest.com/property24/"                                                     
    ## [165] "https://www.youtube.com/user/Property24"                                               
    ## [166] "https://plus.google.com/u/0/100917904089803312185"                                     
    ## [167] "javascript:;"                                                                          
    ## [168] "#loginTab"                                                                             
    ## [169] "#registerTab"                                                                          
    ## [170] "/reset-password"                                                                       
    ## [171] "/terms-and-conditions"                                                                 
    ## [172] "javascript:$('#googleForm').submit();"                                                 
    ## [173] "javascript:$('#facebookForm').submit();"

Next, we need to identify just those hyperlinks that load pages with house summaries (I'll call these "summary pages"). We do this by matching pattern with regular expressions.

``` r
suburb_pages <- str_subset(suburb_links, "(http).*(for-sale).*(9074)")
suburb_pages
```

    ## [1] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p2"
    ## [2] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074"   
    ## [3] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p2"
    ## [4] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p3"
    ## [5] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p4"
    ## [6] "https://www.property24.com/for-sale/fish-hoek/fish-hoek/western-cape/9074/p5"

For each of the summary pages, we extract the hyperlinks that lead to the full house ads

``` r
house_links <- c()
for (i in suburb_pages) {
    suburb_i <- read_html(i)
    suburb_i_links <- suburb_i %>% html_nodes("a") %>% html_attr("href")
    house_links_i <- str_subset(suburb_i_links, "(for-sale).*(9074/)[0-9]")
    house_links <- c(house_links, house_links_i)
}
# remove any duplicates and reorder
house_links <- sample(unique(house_links))
```

``` r
house_links
```

    ##  [1] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104893221"
    ##  [2] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105337009"
    ##  [3] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104719020"
    ##  [4] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105467451"
    ##  [5] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105489469"
    ##  [6] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105280285"
    ##  [7] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105243214"
    ##  [8] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101758219"
    ##  [9] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104528916"
    ## [10] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105208026"
    ## [11] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105027751"
    ## [12] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105396022"
    ## [13] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105458932"
    ## [14] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105395980"
    ## [15] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104001630"
    ## [16] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104115463"
    ## [17] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104913322"
    ## [18] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105437275"
    ## [19] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104933759"
    ## [20] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104906534"
    ## [21] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105455606"
    ## [22] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104760525"
    ## [23] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105016192"
    ## [24] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105375648"
    ## [25] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105380865"
    ## [26] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105436211"
    ## [27] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105003295"
    ## [28] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104982555"
    ## [29] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104929235"
    ## [30] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/100281435"
    ## [31] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105455173"
    ## [32] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105444036"
    ## [33] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105132810"
    ## [34] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105440012"
    ## [35] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101731628"
    ## [36] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105209718"
    ## [37] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105271793"
    ## [38] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104883083"
    ## [39] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104184529"
    ## [40] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105403984"
    ## [41] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105349318"
    ## [42] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105245326"
    ## [43] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105308441"
    ## [44] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104796703"
    ## [45] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105336746"
    ## [46] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105287763"
    ## [47] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104838272"
    ## [48] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105443836"
    ## [49] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105098020"
    ## [50] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101758705"
    ## [51] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104970483"
    ## [52] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105432281"
    ## [53] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104572110"
    ## [54] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105418697"
    ## [55] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105392855"
    ## [56] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104884390"
    ## [57] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104881283"
    ## [58] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105096848"
    ## [59] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105403095"
    ## [60] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105214504"
    ## [61] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105421138"
    ## [62] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105483416"
    ## [63] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105351674"
    ## [64] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105354575"
    ## [65] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105419355"
    ## [66] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105236513"
    ## [67] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105136981"
    ## [68] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105322012"
    ## [69] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105426736"
    ## [70] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105202157"
    ## [71] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105436009"
    ## [72] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104788125"
    ## [73] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105323680"
    ## [74] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105380944"
    ## [75] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105357913"
    ## [76] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101742923"
    ## [77] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101732762"
    ## [78] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105344291"
    ## [79] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105282092"
    ## [80] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105190873"
    ## [81] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104540282"
    ## [82] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105311888"
    ## [83] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105367720"
    ## [84] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105173664"
    ## [85] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105421369"
    ## [86] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105459973"
    ## [87] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105036713"
    ## [88] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105438193"
    ## [89] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/104748099"
    ## [90] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105323582"
    ## [91] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/101748928"
    ## [92] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105417454"
    ## [93] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105249836"
    ## [94] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105185133"
    ## [95] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105173414"
    ## [96] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105418281"
    ## [97] "/for-sale/fish-hoek/fish-hoek/western-cape/9074/105442251"

We now read each of those pages and extract the data we want.

``` r
house_data <- data.frame()
for (i in house_links[1:3]) {
    # more than 3 and you get blocked
    
    # read house ad html
    house <- read_html(paste("https://www.property24.com", i, 
        sep = ""))
    
    # get the ad text
    ad <- house %>% html_nodes(css = ".js_readMore") %>% html_text(trim = T)
    
    # get house data
    price <- house %>% html_nodes(css = ".p24_price") %>% html_text(trim = TRUE)
    erfsize <- house %>% html_nodes(css = ".dropdown-toggle span")
    nbeds <- house %>% html_nodes(css = ".p24_text:nth-child(2)") %>% 
        html_text(trim = TRUE) %>% as.numeric()
    nbaths <- house %>% html_nodes(css = ".p24_text:nth-child(5)") %>% 
        html_text(trim = TRUE) %>% as.numeric()
    ngar <- house %>% html_nodes(css = ".p24_text:nth-child(8)") %>% 
        html_text(trim = TRUE) %>% as.numeric()
    
    # if couldn't find data on webpage, replace with NA
    price <- ifelse(length(price) > 0, price, NA)
    erfsize <- ifelse(length(erfsize) > 0, html_text(erfsize, 
        trim = TRUE), NA)
    nbeds <- ifelse(length(nbeds) > 0, nbeds, NA)
    nbaths <- ifelse(length(nbaths) > 0, nbaths, NA)
    ngar <- ifelse(length(ngar) > 0, ngar, NA)
    
    # store results
    this_house <- data.frame(price = price, erfsize = erfsize, 
        nbeds = nbeds, nbaths = nbaths, ngar = ngar, ad = ad)
    house_data <- rbind.data.frame(house_data, this_house)
    
    # random wait avoids excessive requesting
    Sys.sleep(sample(seq(10, 30, by = 1), 1))
    
}
```

View the data

``` r
house_data
```

    ##         price erfsize nbeds nbaths ngar
    ## 1 R 2 290 000  498 m²     4    2.5    2
    ## 2   R 800 000    <NA>     2    1.0    1
    ## 3 R 2 295 000  209 m²     3    3.0   NA
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ad
    ## 1 This house is perfectly positioned for a family with school going children.  The house is situated on the corner of First Crescent and 13th Avenue, which is right across from the High School and also within easy walking distance to Fish Hoek Primary School and Valley Shopping Centre. \r\n\r\nThe open plan kitchen and dinning room with built in braai and door leading to the garden, makes this area perfect for entertainment. The spacious lounge on the opposite side of the house, makes it ideal for those wanting a bit of privacy away.  The main bedroom  is conveniently situated at the back of the home diffusing sound from the road.  It has it's own en-suite and a door leading directly into a courtyard which has a door leading into the double garage.  Bedroom 4 is situated close by should you have young children needing attention or need to be close at night.  \r\n\r\nMore away\r\n        <U+0085>\r\n        Read more
    ## 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Wake up to the smell of the ocean and the sound of the waves in this lovely, spacious beach cottage. \r\nFully furnished, open plan 2 bedroom home plus a large single garage.\r\nLease hold property, 12 Years left.\r\nCash buyers only.\r\n\r\n- Open plan living room\r\n- Full bathroom\r\n- 2 bedrooms with built- in cupboards\r\n- Communal garden and braai area\r\n- Large single garage
    ## 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Beautifully renovated seaside apartment offering 3 bedrooms, 3 en-suite bathrooms, spacious farm style kitchen and living areas. 2 minute walk to the beach and amenities. 2nd dwelling ideal for Airbnb.

Example 4: Getting movie reviews
================================

``` r
load("data/movielens-small.RData")
load("output/recommender.RData")
# make into a tibble
links <- as.tibble(links)
head(links)
```

    ## # A tibble: 6 x 3
    ##   movieId imdbId tmdbId
    ##     <int>  <int>  <int>
    ## 1       1 114709    862
    ## 2       2 113497   8844
    ## 3       3 113228  15602
    ## 4       4 114885  31357
    ## 5       5 113041  11862
    ## 6       6 113277    949

The *links* data frame provides identifiers for each movie for three different movie datasets: [MovieLens](https://movielens.org), [IMDb](http://www.imdb.com/), and [The Movie Database](https://www.themoviedb.org). This gives us a way of looking up reviews for a particular *movieId* we are interested in on either IMDb or The Movie Database.

IMDb links are 7 characters long, so we need to add leading zeros in some cases.

``` r
links$imdbId <- sprintf("%07d", links$imdbId)
```

Let's extract just the movies that we used to build our recommender systems in the last lesson, and get the IMDB identifiers for those movies.

``` r
movies_to_use <- unique(ratings_red$movieId)
imdbId_to_use <- links %>% filter(movieId %in% movies_to_use)
```

    ## Warning: package 'bindrcpp' was built under R version 3.3.3

Next we need to know a little more about how reviews are displayed on IMDb. Firstly, a certain number of reviews are shown per page, as in the property example, so we need a way to handle that. Secondly, we need to know the CSS selector for the review text we want to scrape.

``` r
reviews <- data.frame()

# just get the first two movies to save time
for (j in 1:2) {
    
    this_movie <- imdbId_to_use$imdbId[j]
    
    # just get the first 50 reviews
    for (i in c(0, seq(10, 50, 10))) {
        link <- paste0("http://www.imdb.com/title/tt", this_movie, 
            "/reviews?start=", i)
        movie_imdb <- read_html(link)
        
        # Used SelectorGadget as the CSS Selector
        imdb_review <- movie_imdb %>% html_nodes("#pagecontent") %>% 
            html_nodes("div+p") %>% html_text()
        
        this_review <- data.frame(imbdId = this_movie, review = imdb_review)
        reviews <- rbind.data.frame(reviews, this_review)
    }
    
}

reviews <- as.tibble(reviews)
```

We'll now look in a bit more detail on working with text. Let's look at the first review.

``` r
review1 <- as.character(reviews$review[1])
review1
```

    ## [1] "\n\nA towering classic of American cinematic power.  Martin Scorsese teams up\nwith one of the most intense actors of that time to create a masterpiece of\nurban alienation.  Paul Schrader's magnificent script paints a portrait of\nloneliness in the largest city of the world.  Travis never once enters into\na meaningful relationship with any character anywhere in the film.  He is\nthe most hopelessly alone person I've ever encountered on film.He is alone with his thoughts, and his thoughts are dark ones.  The film\nfools you on a first viewing.  Is Travis an endearing eccentric?  Sure, he's\nodd, but he's so polite, and he's got a quirky sense of humor.  His\naffection for Betsy is actually rather endearing.  But on a second view, you\nsee it for what it is.  The audience comes to see Travis's psychosis\ngradually, but there's actually far less development than one might think.\nWhen he talks about cleaning up the city, the repeat viewer knows he doesn't\nmean some sort of Giuliani-facelift.  This is less a film about a character\nin development as it is a kind of snapshot.  To be sure, it takes the\nstimulus to provoke the response, but does that imply some kind of central\nchange in the character?Tremendous supporting roles are brought to life through vivid performances\nby Keitel and Foster especially.  Shepard's character, Betsy, is little more\nthan a foil to highlight Travis's utter alienation from society, but she is\nstill impeccably portrayed.  With only two scenes that don't center on\nTravis, it is unavoidably De Niro's show.  The life with which the\nsupporting cast imbues their characters is a credit to themselves, and to\nthe director's willingness to let the film develop from the intersection of\ndiverse ideas and approaches.  What would the plot lose by eliminating the\nAlbert Brooks character (Tom)?  Nothing at all.  He makes almost no impact\non Travis's life, which is where the plot lives.  But his inclusion makes\nthe film as a whole much richer and fuller.As a piece of American cinema history, this film will live forever.  But far\nmore important than that, this film will survive as a universal,\never-relevant examination of the workings of the alienated mind.  The story\ndoesn't end when the credits roll.  We know Travis will snap again.  But the\nstory doesn't end with Travis either.  It continues today in the cities and\nin the schools.  The film is about the brutal power of the disaffected mind.This film didn't cause the incidents in Colombine, or Hawaii, or Seattle, or\nwherever you care to look, even with all of its disturbing images of\nviolence.  It didn't cause those things.  It predicted them.\n\n"

The first thing we can do is remove references to `\r` and `\n`, which indicate carriage returns and new lines respectively. We do this with a call to `str_replace_all()` and a "regular expression", a way of describing patterns in strings. We'll look at regular expressions in more detail in the next workbook.

``` r
review1_nospace <- str_replace_all(review1, "[\r\n]", " ")
review1_nospace
```

    ## [1] "  A towering classic of American cinematic power.  Martin Scorsese teams up with one of the most intense actors of that time to create a masterpiece of urban alienation.  Paul Schrader's magnificent script paints a portrait of loneliness in the largest city of the world.  Travis never once enters into a meaningful relationship with any character anywhere in the film.  He is the most hopelessly alone person I've ever encountered on film.He is alone with his thoughts, and his thoughts are dark ones.  The film fools you on a first viewing.  Is Travis an endearing eccentric?  Sure, he's odd, but he's so polite, and he's got a quirky sense of humor.  His affection for Betsy is actually rather endearing.  But on a second view, you see it for what it is.  The audience comes to see Travis's psychosis gradually, but there's actually far less development than one might think. When he talks about cleaning up the city, the repeat viewer knows he doesn't mean some sort of Giuliani-facelift.  This is less a film about a character in development as it is a kind of snapshot.  To be sure, it takes the stimulus to provoke the response, but does that imply some kind of central change in the character?Tremendous supporting roles are brought to life through vivid performances by Keitel and Foster especially.  Shepard's character, Betsy, is little more than a foil to highlight Travis's utter alienation from society, but she is still impeccably portrayed.  With only two scenes that don't center on Travis, it is unavoidably De Niro's show.  The life with which the supporting cast imbues their characters is a credit to themselves, and to the director's willingness to let the film develop from the intersection of diverse ideas and approaches.  What would the plot lose by eliminating the Albert Brooks character (Tom)?  Nothing at all.  He makes almost no impact on Travis's life, which is where the plot lives.  But his inclusion makes the film as a whole much richer and fuller.As a piece of American cinema history, this film will live forever.  But far more important than that, this film will survive as a universal, ever-relevant examination of the workings of the alienated mind.  The story doesn't end when the credits roll.  We know Travis will snap again.  But the story doesn't end with Travis either.  It continues today in the cities and in the schools.  The film is about the brutal power of the disaffected mind.This film didn't cause the incidents in Colombine, or Hawaii, or Seattle, or wherever you care to look, even with all of its disturbing images of violence.  It didn't cause those things.  It predicted them.  "

We can remove punctuation in a very similar way. Here `:alnum:` refers to any alphanumeric character, equivalent to `[A-Za-z0-9]`. In this context `^` means negation, so we're removing anything that's not alphanumeric (replacing it with nothing).

``` r
review1_nopunc <- str_replace_all(review1_nospace, "[^[:alnum:] ]", 
    "")
review1_nopunc
```

    ## [1] "  A towering classic of American cinematic power  Martin Scorsese teams up with one of the most intense actors of that time to create a masterpiece of urban alienation  Paul Schraders magnificent script paints a portrait of loneliness in the largest city of the world  Travis never once enters into a meaningful relationship with any character anywhere in the film  He is the most hopelessly alone person Ive ever encountered on filmHe is alone with his thoughts and his thoughts are dark ones  The film fools you on a first viewing  Is Travis an endearing eccentric  Sure hes odd but hes so polite and hes got a quirky sense of humor  His affection for Betsy is actually rather endearing  But on a second view you see it for what it is  The audience comes to see Traviss psychosis gradually but theres actually far less development than one might think When he talks about cleaning up the city the repeat viewer knows he doesnt mean some sort of Giulianifacelift  This is less a film about a character in development as it is a kind of snapshot  To be sure it takes the stimulus to provoke the response but does that imply some kind of central change in the characterTremendous supporting roles are brought to life through vivid performances by Keitel and Foster especially  Shepards character Betsy is little more than a foil to highlight Traviss utter alienation from society but she is still impeccably portrayed  With only two scenes that dont center on Travis it is unavoidably De Niros show  The life with which the supporting cast imbues their characters is a credit to themselves and to the directors willingness to let the film develop from the intersection of diverse ideas and approaches  What would the plot lose by eliminating the Albert Brooks character Tom  Nothing at all  He makes almost no impact on Traviss life which is where the plot lives  But his inclusion makes the film as a whole much richer and fullerAs a piece of American cinema history this film will live forever  But far more important than that this film will survive as a universal everrelevant examination of the workings of the alienated mind  The story doesnt end when the credits roll  We know Travis will snap again  But the story doesnt end with Travis either  It continues today in the cities and in the schools  The film is about the brutal power of the disaffected mindThis film didnt cause the incidents in Colombine or Hawaii or Seattle or wherever you care to look even with all of its disturbing images of violence  It didnt cause those things  It predicted them  "

Finally we can convert everything to lowercase. Note that there are still some problems we'd like to fix up, most often when two words get concatenated (e.g. "charactertremendous" about half-way through the review). Getting text totally clean can be hard work.

``` r
review1_clean <- tolower(review1_nopunc)
review1_clean
```

    ## [1] "  a towering classic of american cinematic power  martin scorsese teams up with one of the most intense actors of that time to create a masterpiece of urban alienation  paul schraders magnificent script paints a portrait of loneliness in the largest city of the world  travis never once enters into a meaningful relationship with any character anywhere in the film  he is the most hopelessly alone person ive ever encountered on filmhe is alone with his thoughts and his thoughts are dark ones  the film fools you on a first viewing  is travis an endearing eccentric  sure hes odd but hes so polite and hes got a quirky sense of humor  his affection for betsy is actually rather endearing  but on a second view you see it for what it is  the audience comes to see traviss psychosis gradually but theres actually far less development than one might think when he talks about cleaning up the city the repeat viewer knows he doesnt mean some sort of giulianifacelift  this is less a film about a character in development as it is a kind of snapshot  to be sure it takes the stimulus to provoke the response but does that imply some kind of central change in the charactertremendous supporting roles are brought to life through vivid performances by keitel and foster especially  shepards character betsy is little more than a foil to highlight traviss utter alienation from society but she is still impeccably portrayed  with only two scenes that dont center on travis it is unavoidably de niros show  the life with which the supporting cast imbues their characters is a credit to themselves and to the directors willingness to let the film develop from the intersection of diverse ideas and approaches  what would the plot lose by eliminating the albert brooks character tom  nothing at all  he makes almost no impact on traviss life which is where the plot lives  but his inclusion makes the film as a whole much richer and fulleras a piece of american cinema history this film will live forever  but far more important than that this film will survive as a universal everrelevant examination of the workings of the alienated mind  the story doesnt end when the credits roll  we know travis will snap again  but the story doesnt end with travis either  it continues today in the cities and in the schools  the film is about the brutal power of the disaffected mindthis film didnt cause the incidents in colombine or hawaii or seattle or wherever you care to look even with all of its disturbing images of violence  it didnt cause those things  it predicted them  "

Exercises
---------

> Please note I haven't tried these myself yet, so I am not certain that the exercises will "work". If you run into problems let me know!

1.  The [Freakonomics Radio Archive](http://freakonomics.com/archive/) contains all previous Freakonomics podcasts. Scrape the titles, dates and descriptions, and download URLs of all the podcasts and store them in a dataframe (see if you can download all the medically-themed podcasts).

2.  [Decanter](http://www.decanter.com/) magazine provides one of the world's best known wine ratings. Scrape the tasting notes, scores, and prices for their South African white wines (or whatever subset you choose).

3.  Think of your own scraping example - a website you think contains useful or interesting information - and put together your own tutorial like one of those above.

4.  Web scraping does bring with it some ethical concerns. Its important to read about these and formulate your own opinion and approach, starting for example [here](https://medium.com/towards-data-science/ethics-in-web-scraping-b96b18136f01), [here](http://gijn.org/2015/08/12/on-the-ethics-of-web-scraping-and-data-journalism/), and [here](http://gijn.org/2015/08/12/on-the-ethics-of-web-scraping-and-data-journalism/).
