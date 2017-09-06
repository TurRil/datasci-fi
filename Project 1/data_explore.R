# Explore the data

orders.items %>% 
  group_by(products_name) %>% 
  summarise(sum_products_quantity = sum(products_quantity)) %>% 
  arrange(sum_products_quantity)


for(j in 1:5) {
  
  prod_id <- str_extract(page.links[j,]$link, "(\\d*)$")
  
  
  message(page.links[j,]$products_name)
  message(str_c(prod_path,"_"))
  message(category)
  message(type)
  message(flavor)
}