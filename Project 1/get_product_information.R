orders <- read.csv("orders.csv") %>% as.tibble()
orders.items <- read.csv("order-items.csv")  %>% as.tibble()


# Getting product Information

page.sitemap <- read_html("http://www.getwine.co.za/sitemap.php")

fileConn <- file("data/source_www.getwine.co.za_sitemap.php.html")
write(as.character(page.sitemap), fileConn)
close(fileConn)


# to make it faster and not hit the server each time use the saved version
page.sitemap <- paste(readLines("data/source_www.getwine.co.za_sitemap.php.html"), collapse="") %>% read_html() 

# Select the links in the table but only those that point to product_info 
page.productLinks <- html_nodes(page.sitemap, css="tr td a[href*='product_info']")
page.indexLinks <- html_nodes(page.sitemap, css="tr td a[href*='main_page=index']")

regexp <- '.*<a.*href="(.*?)"*>(.*)<\\/a>.*';

# example
#page.productLinks[20]
#page.productLinks[20] %>% html_text()
#str_match(page.productLinks[20], pattern = regex(regexp))

length(page.productLinks)

# extract th
page.links <- page.productLinks %>% 
  str_match(pattern = regex(regexp)) %>% .[,c(3,2)] %>% # select href and text from <a href="2">3</a> - swap
  data.frame(matrix(ncol=2, byrow=TRUE)) %>% 
  setNames(c("products_name", "rawlink", "empty1", "empty2")) %>% as.tibble() %>%
  mutate(link = str_replace_all(string = rawlink, pattern = "amp;", replacement = ""), prod_id = str_extract(link, "(\\d*)$"), keep = TRUE) %>% 
  select(products_name, link, prod_id, keep) 

dim(page.links)

page.indexLinks <- page.indexLinks %>%
  str_match(pattern = regex(regexp)) %>% .[,c(3,2)] %>% # select href and text from <a href="2">3</a> - swap
  data.frame(matrix(ncol=2, byrow=TRUE)) %>% 
  setNames(c("name", "rawlink", "empty1", "empty2")) %>% as.tibble() %>%
  mutate(link = str_replace_all(string = rawlink, pattern = "amp;", replacement = "")) %>%
  select(name, link) 

product.lookup <- data.frame()

for(j in 1:as.numeric(count(page.indexLinks))) {
  
  # <a href="http://www.getwine.co.za/index.php?main_page=index&cPath=48_55">Red Wines</a>
  cpath <- str_extract(page.indexLinks[j,]$link, "(\\d+(_\\d+(_\\d+)?)?)$")

  product.lookup <- rbind.data.frame(product.lookup, data.frame(name = str_replace_all(string = page.indexLinks[j,]$name, pattern = "amp;", replacement = ""), path = cpath, stringsAsFactors = FALSE))
}
product.lookup <- unique(product.lookup)

suppressWarnings(dir.create(path = "data/products/"));

# Web scrape the products from the site for each of the products in our list
# then save it to a file for later easy access.
i <- 0
for(j in 1:as.numeric(count(page.links))) {
  
  prod_id <- str_extract(page.links[j,]$link, "(\\d*)$")
  destfile <- paste0("data/products/", prod_id ,".html")
  
  if(!file.exists(destfile)) {  
    
    #message(paste0(j," ", prod_id," ", page.links[j,]$link))
    
    raw <- read_html(as.character(page.links[j,]$link))
    
    fileConn <- file(destfile)
    write(as.character(raw), fileConn)
    close(fileConn)
    i <- i + 1
  }
}

i
as.numeric(count(page.links))


# #as.character(page.links[20,]$products_name)
# #as.character(page.links[20,]$link)
# 
# prod_id <- str_extract(page.links[20,]$link, "(\\d*)$")
# raw <- read_html(paste0("data/products/", prod_id ,".html")) #as.character(page.links[20,]$link))
# 
# breadcrumbs <- html_nodes(raw, css = "#breadcrumbs a") %>% html_text(trim = TRUE)
# # breadcrumbs
# discount <- html_nodes(raw, css = ".product-info .productPriceDiscount")  %>% html_text(trim = TRUE) # %>% str_extract("\\d{2,5}")
# # discount
# description <- html_nodes(raw, css = ".product-info .product-description") %>% html_text(trim = TRUE)
# # description
# recommendation <- html_nodes(raw, css = ".productListing-data p") %>% html_text(trim = TRUE)
# # recommendation
# 
# data.frame(breadcrumbs = paste(breadcrumbs, collapse = "|"), discount = discount, description = description, recommendation = paste(recommendation, collapse = "|"))
#   

# for(j in 1:5) {
#   
#   prod_id <- str_extract(page.links[j,]$link, "(\\d*)$")
#   prod_path <- str_extract(page.links[j,]$link, "\\d+(_\\d+(_\\d+)?)?") %>% str_split("_") %>% unlist()
#   
#   category <- product.lookup[product.lookup$path == prod_path[1],]$name
#   type   <- ifelse(length(prod_path) >= 2, product.lookup[product.lookup$path == paste0(prod_path[1],"_",prod_path[2]), ]$name, "")
#   flavor <- ifelse(length(prod_path) >= 3, product.lookup[product.lookup$path == paste0(prod_path[1],"_",prod_path[2],"_",prod_path[3]), ]$name, "")
#   
#   #message(page.links[j,]$products_name)
#   message(str_c(prod_path,"_"))
#   #message(category)
#   message(type)
#   message(flavor)
# }

is.blank <- function(x, false.triggers=FALSE){
  if(is.function(x)) return(FALSE) # Some of the tests below trigger
  # warnings when used on functions
  return(
    is.null(x) ||                # Actually this line is unnecessary since
      length(x) == 0 ||            # length(NULL) = 0, but I like to be clear
      all(is.na(x)) ||
      all(x=="") ||
      (false.triggers && all(!x))
  )
}

# Extract the details from a page
tmp <- data.frame()

page.links.clean <- mutate(page.links, keep = !(prod_id %in% c(10438, 6589, 6607, 1435, 1436, 1437, 1439, 1440, 10633, 10521, 10635))) %>% filter(keep)

for(j in 1:as.numeric(count(page.links.clean))) {
  
  #j <-13
  #message(j);
  
  prod_id <- str_extract(page.links.clean[j,]$link, "(\\d*)$")
  prod_path <- str_extract(page.links.clean[j,]$link, "\\d+(_\\d+(_\\d+)?)?") %>% str_split("_") %>% unlist()
  
  category <- product.lookup[product.lookup$path == prod_path[1],]$name
  type   <- ifelse(length(prod_path) >= 2, product.lookup[product.lookup$path == paste0(prod_path[1],"_",prod_path[2]), ]$name, "")
  flavor <- ifelse(length(prod_path) >= 3, product.lookup[product.lookup$path == paste0(prod_path[1],"_",prod_path[2],"_",prod_path[3]), ]$name, "")
  
  raw <- read_html(paste0("data/products/", prod_id ,".html"))
  
  name <- html_nodes(raw, css = ".product-info h1") %>% html_text(trim = TRUE)
  breadcrumbs <- html_nodes(raw, css = "#breadcrumbs a") %>% html_text(trim = TRUE)
  discount <- html_nodes(raw, css = ".product-info .productPriceDiscount")  %>% html_text(trim = TRUE) %>% str_extract("\\d{2,5}")
  description <- html_nodes(raw, css = ".product-info .product-description") %>% html_text(trim = TRUE)
  recommendation <- html_nodes(raw, css = ".productListing-data p") %>% html_text(trim = TRUE)
  
  price <- html_nodes(raw, css = ".product-details .productPrice") %>% html_text(trim = TRUE) %>% str_extract("\\d+$")
  priceSpecial <- html_nodes(raw, css = ".product-details .productSpecialPrice") %>% html_text(trim = TRUE) %>% str_extract("\\d+$")
  
  if (length(discount) == 0) discount <- 0;             # might be not defined so discount is 0
  
  r1 <- NA
  r2 <- NA
  r3 <- NA
  
  if (length(recommendation) > 0) {
    r1 <- recommendation[1]
    r2 <- recommendation[2]
    r3 <- recommendation[3]
  }
  
  #message(str_c(c(is.blank(price) ,":", (price !=0), "/", is.blank(priceSpecial)," |",price,"| |",priceSpecial, "| = ", ifelse(is.blank(price), ifelse(is.blank(priceSpecial),NA,priceSpecial), price) )))
  # as.character(page.links[j,]$products_name)
  # as.character(page.links[j,]$link)
  # 
  # description
  # breadcrumbs
  # discount
  # recommendation
  
  this_product <- data.frame(prod_id = prod_id,
                             name = name,
                             category = category,
                             type = ifelse(type == "", NA, type),
                             flavor = ifelse(flavor == "", NA, flavor),
                             price = ifelse(is.blank(price), ifelse(is.blank(priceSpecial), NA, priceSpecial), price),
                             discount = ifelse(is.blank(discount), 0, discount), 
                             description = description, 
                             r1 = r1, r2 = r2, r3 = r3,
                             stringsAsFactors = FALSE)
  
  tmp <- rbind.data.frame(tmp, this_product)
}


# getProduct <- function(x) {
#    p <- filter(tmp, name == x) %>% select(prod_id) %>% as.numeric()
#    message( typeof(p) )
#    return ( ifelse(is.na(p), NA, p) )
# }

product.details <- left_join(tmp, mutate(tmp, prod_rec1 = prod_id, r1_name = name) %>% select(prod_rec1, r1_name), by = c("r1" = "r1_name")) %>% 
  left_join(mutate(tmp, prod_rec2 = prod_id, r2_name = name) %>% select(prod_rec2, r2_name), by = c("r2" = "r2_name")) %>%
  left_join(mutate(tmp, prod_rec3 = prod_id, r3_name = name) %>% select(prod_rec3, r3_name), by = c("r3" = "r3_name")) %>%
  select(-r1, -r2, -r3) %>% as.tibble()

product.details$prod_id <- as.factor(product.details$prod_id)
product.details$category <- as.factor(product.details$category)
product.details$type <- as.factor(product.details$type)
product.details$flavor <- as.factor(product.details$flavor)


# save all the order info
save(orders, orders.items, page.links, product.lookup, product.details, file = "data/starting_data.RData")


save(orders, orders.items, orders.combined, orders.valid, page.links, product.lookup, product.details, product.details.final, page.duplicateLinks, file = "data/starting_data.RData")

