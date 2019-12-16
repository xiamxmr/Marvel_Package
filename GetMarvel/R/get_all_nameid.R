#' Gain API Access
#'
#' This function asks users to input the API Key for Marvel.com
#' This function is the foundation of the entire package, without an API, the functions will not be able to gain access to Marvel information. Users need to use this function to input API key in order to call out other functions in the package.
#' @param x private key
#' @param y public key
#' @return list of encoded API
#' @import rlist
#' @export
#' @examples
#' API_access("b2026849c62827d3c5313156d93d22cef8062791","3084b91d33dcdbdc3f566b2f214af5a6")
#'
API_access <- function(x = "b2026849c62827d3c5313156d93d22cef8062791",y = "3084b91d33dcdbdc3f566b2f214af5a6" ){
  private_key <- x
  public_key <- y
  ts <- round(as.numeric(Sys.time())*1000)
  to_hash <- sprintf("%s%s%s",
                     ts,
                     private_key,
                     public_key)

  params <- list(
    ts=ts,
    hash=digest::digest(to_hash, "md5", FALSE),
    apikey=public_key)
  assign("params",params,envir = .GlobalEnv)
  return(params)
}

#' Get All Marvel Character Name/ID
#'
#' This function is used to fetch all the current Marvel Characters including: Name, Character ID, and website URL
#'
#' This function does not require any parameters as it loops through Marvel website to GET all the characters and the corresponding ID. Moreover, it will check if this character has a wiki website that features the specific information of the character.
#' If it does, it will return the website link, and if it doesn't, it will return string "Not Found"
#'
#' @return a dataframe consisting 3 columns : Name, ID and URL
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @export
#' @examples
#' params <- API_access()
#' get_all_nameid()
#'

get_all_nameid <- function(){
  offset <- 0
  name_df <- data.frame(matrix(ncol=1),nrow = 0)
  name <- vector("list",0)
  id <- vector("list",0)
  char_url <- vector("list",0)
  link_url <- vector("list",0)

  for (i in 1:15){
    url <- "https://gateway.marvel.com:443/v1/public/characters?limit=100&offset="
    url <- paste(url,offset,collapse="")
    content <- content(GET(url,query=params))
    for (i in 1:length(content$data$results)){
      name <- append(name,(content$data$results[[i]]$name))
      id <- append(id,(content$data$results[[i]]$id))
    }
    for (x in 1:length(content$data$results)){
      link_url <- vector("list",0)
      for (i in 1:length(content$data$results[[x]]$urls)){
        if(content$data$results[[x]]$urls[[i]]$type=='wiki'){
          link_url <- append(link_url,content$data$results[[x]]$urls[[i]]$url)
        }
      }
      if (length(link_url)>0){
        char_url <- append(char_url,link_url[1])
      } else {
        char_url <- append(char_url,"Not Found")
      }
    }
    offset <- offset + 100
  }
  name_url <- data.frame(name = unlist(name), id = unlist(id), url = unlist(char_url), stringsAsFactors = F)

  return(name_url)
}

#' Search Character's comics
#'
#' This function allows user to access the detailed comics information of a particular character
#'
#' @param x the saved dataframe of the output get_all_nameid()
#' @param y the index of the character within the get_all_nameid() dataframe
#' @return dataframe of the character's comics
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @import jsonlite
#' @export
#' @examples
#' params <- API_access()
#' allnames <- get_all_nameid()
#' search_character_comic(allnames,123)
#'
search_character_comic <- function(x,y){
  id = x$id[y]
  name = x$name[y]

  newcontent <- content(GET(paste(c("https://gateway.marvel.com:443/v1/public/characters/",id,"/comics?limit=100&format=",format),collapse=""),query = params))
  comic_info <- jsonlite::fromJSON(toJSON(newcontent$data$results),simplifyDataFrame = T)
  if (length(comic_info)>0){
  comic_info <- comic_info[,c("title","issueNumber","variantDescription","description","modified","upc","format","pageCount","resourceURI")]
  input <- data.frame(matrix(ncol=0,nrow = length(newcontent$data$results)))
  input$character_id <- id
  input$character_name <-name
  info <- data.frame(matrix(ncol=length(colnames(comic_info)),nrow=length(newcontent$data$results)))
  colnames(info) <- colnames(comic_info)
  for (i in 1:length(comic_info)){
    g <- unlist(lapply(comic_info[[i]],function(x) if(identical(class(x), "list"))'Not Available' else x))
    info[i] <- g
  }
  return(cbind(input,info))
  }else{
    return("There is no available information ")
}
}

#' Search Character's events
#'
#' This function allows user to access the detailed events information of a particular character
#' @param x the saved dataframe of the output get_all_nameid()
#' @param y the index of the character within the get_all_nameid() dataframe
#' @return dataframe of the character's events
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @import jsonlite
#' @export
#' @examples
#' params <- API_access()
#' allnames <- get_all_nameid()
#' search_character_events(allnames,123)

search_character_events <- function(x,y){
  id = x$id[y]
  name = x$name[y]
  newcontent <- content(GET(paste(c("https://gateway.marvel.com:443/v1/public/characters/",id,"/events?limit=100"),collapse=""),query = params))
  series_info <- jsonlite::fromJSON(toJSON(newcontent$data$results),simplifyDataFrame = T)
  if (length(series_info)>0){
    series_info <- series_info[,c("id","title","description","resourceURI","modified","start","end")]

    input <- data.frame(matrix(ncol=0,nrow = length(newcontent$data$results)))
    input$character_id <- id
    input$character_name <-name

    info <- data.frame(matrix(ncol=length(colnames(series_info)),nrow=length(newcontent$data$results)))
    colnames(info) <- colnames(series_info)

    for (i in 1:length(series_info)){
      g <- unlist(lapply(series_info[[i]],function(x) if(identical(class(x), "list"))'Not Available' else x))
      info[i] <- g
    }
    return(cbind(input,info))
  }else{
    return("There is no available information ")
  }
}


#' Search Character's stories
#'
#' This function allows user to access the detailed stories information of a particular character
#' @param x the saved dataframe of the output get_all_nameid()
#' @param y the index of the character within the get_all_nameid() dataframe
#' @return dataframe of the character's stories
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @import jsonlite
#' @export
#' @examples
#' params <- API_access()
#' allnames <- get_all_nameid()
#' search_character_stories(allnames,123)

search_character_stories <- function(x,y){
  id = x$id[y]
  name = x$name[y]

  newcontent <- content(GET(paste(c("https://gateway.marvel.com:443/v1/public/characters/",id,"/stories?limit=100"),collapse=""),query = params))
  series_info <- jsonlite::fromJSON(toJSON(newcontent$data$results),simplifyDataFrame = T)
  series_info
  if (length(series_info)>0){
    series_info <- series_info[,c("id","title","description","resourceURI","type","modified")]

    input <- data.frame(matrix(ncol=0,nrow = length(newcontent$data$results)))
    input$character_id <- id
    input$character_name <-name

    info <- data.frame(matrix(ncol=length(colnames(series_info)),nrow=length(newcontent$data$results)))
    colnames(info) <- colnames(series_info)

    for (i in 1:length(series_info)){
      g <- unlist(lapply(series_info[[i]],function(x) if(identical(class(x), "list"))'Not Available' else x))
      info[i] <- g
    }
    return(cbind(input,info))
  }
  else{
    return("There is no available information ")
  }
}


#' Get Marvel recent events
#'
#' This function provides information of the recent Marvel events.
#'
#' @param x number of events you wish to retrieve, range from 0 to 100
#' @return a data frame of rencent (x) number of events
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @import jsonlite
#' @export
#' @examples
#' params <- API_access()
#' get_event(30)
#'
get_event <- function(x){
  events <- content(GET(paste(c("https://gateway.marvel.com:443/v1/public/events?limit=",x),collapse=""),query=params))
  events_info <- jsonlite::fromJSON(toJSON(events$data$results),simplifyDataFrame = T)
  events_info <- events_info[,c("id","title","description","resourceURI","modified","start","end")]

  info <- data.frame(matrix(ncol=length(colnames(events_info)),nrow=length(events$data$results)))
  colnames(info) <- colnames(events_info)
  for (i in 1:length(events_info)){
    g <- unlist(lapply(events_info[[i]],function(x) if(identical(class(x), "list"))'Not Available' else x))
    info[i] <- g
  }
  return(info)
}



#' Get Character Biography information
#'
#' This function retrieves the basic information such as height, family etc of a character.
#'
#' This function can only be used after get_all_nameid()
#'
#' @param i the saved dataframe of the output get_all_nameid()
#' @param o the index of the character within the get_all_nameid() dataframe
#' @return a dataframe of the character information
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @export
#' @examples
#' params <- API_access()
#' allnames <- get_all_nameid()
#' get_character_bio(allnames,123)
#'
#'
get_character_bio <- function(i,o){
  x = i$url[o]
  y = i$name[o]
  z = i$id[o]
  if(x == "Not Found"){
    return("This Character currently does not have any information available.")
  }else{
    if(http_status(GET(x))$category == "Success"){
      url <- read_html(x)
      div_class1 <- "#featured-2 > div > div.grid-wrapper > div > div > div.featured__container >   div.featured__copy"
      div_class2 <- "#masthead-1 > div > div.masthead__wrapper > div.masthead__hero > div > div > div"
      bio <- "#two_column-4 > div > div.flex-col-auto.two-column__content > div > div.content-block__body > div"

      desc1 <- html_nodes(url,div_class1) %>% html_text()
      desc2 <- html_nodes(url,div_class2) %>% html_text()
      bio <- html_nodes(url,bio) %>% html_text()

      label <- html_nodes(url, css = "p.bioheader__label") %>% html_text()
      stat <- html_nodes(url,css="p.bioheader__stat") %>% html_text()
      label1 <- html_nodes(url, css = "p.railBioInfoItem__label") %>% html_text()
      stat1 <- html_nodes(url,css = "ul.railBioLinks") %>% html_text()
      idname <- data.frame(label = c("name","id"), stat = c(y,z), stringsAsFactors = F)
      df1 <- data.frame(label = label, stat = stat,stringsAsFactors = F)
      df2 <- data.frame(label = label1,stat = stat1,stringsAsFactors = F)
      all_info <- rbind(idname,df1,df2)
      return(all_info)
    }
    else{
      return(http_status(GET(x))$message)
    }
  }
}


#' Character Basic Marvel number of release information
#'
#' This function allows user to access the most basic information of a character. Ex: number of comics/series/stories/events avaialbale on Marvel.
#' @param x Character ID if you already know the ID number. If not, select from the saved out put of get_all_nameid()
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @return dataframe of the basic Marvel number of release information of the character
#' @export
#' @examples
#' params <- API_access()
#' allnames <- get_all_nameid()
#' basic_info_by_ID(allnames$id[1])
#'
#'
basic_info_by_ID <- function(x){
  specificid <- content(GET(paste(c("https://gateway.marvel.com:443/v1/public/characters/",x),collapse=""),query = params))
  idname <- specificid$data$results[[1]]$name
  comicsavailable <- specificid$data$results[[1]]$comics$available
  seriesavailable <- specificid$data$results[[1]]$series$available
  storiesavailable <- specificid$data$results[[1]]$stories$available
  eventsavailable <- specificid$data$results[[1]]$events$available

  basic_info <- data.frame("Labels" = c("Name","ID", "Comics Available", "Series Available", "Stories Available", "Events Available"), "Stats" = c(idname,x, comicsavailable,seriesavailable,storiesavailable,eventsavailable))
  return(basic_info)
}



#' Compare Marvel Character
#'
#' This function allows user to compare the previous output of basic_info_by_ID() with different characters on Marvel. It will take at most three arguments, with the third being optional.
#' @param x first character name
#' @param y second character name
#' @param z third character name (optional)
#' @return dataframe
#' @import httr
#' @import rvest
#' @import dplyr
#' @import xml2
#' @import tidyr
#' @import purrr
#' @import stringr
#' @export
#' @examples
#' params <- API_access()
#' allnames <- get_all_nameid()
#' marvel_char_compare(allnames$name[1],allnames$name[2],allnames$name[3])
#'
marvel_char_compare <- function(x,y,z){
  final_result <- data.frame(matrix(ncol=6))

  if (missing(z)){
    name_list <- c(x,y)
  }
  else{
    name_list <- c(x,y,z)
  }
  for (i in c(name_list)){
    params$name <- i
    character <- i
    content <- content(GET("https://gateway.marvel.com:443/v1/public/characters",query=params))
    description <- content$data$results[[1]]$description
    id <- content$data$results[[1]]$id
    num_com_avialable <- content$data$results[[1]]$comics$available
    num_series_avialable <- content$data$results[[1]]$series$available
    num_stories_available <- content$data$results[[1]]$stories$available

    link_url <- vector("list",0)
    for (i in 1:length(content$data$results[[1]]$urls)){
      if (content$data$results[[1]]$urls[[i]]$type == "wiki"){
        link_url <- append(link_url,content$data$results[[1]]$urls[[i]]$url)
      }
    }
    if (length(link_url)>0){
      char_url <- link_url[1]
    }
    else{
      char_url <- "Not Found"
    }

    result <- data.frame(character,id,num_com_avialable,num_series_avialable,num_stories_available,char_url,stringsAsFactors = F)
    colnames(result) <- c("Character","ID","Num_Com_Available","Num_Series_Available","Num_Stories_Available","Charcter_URL")
    colnames(final_result) <- colnames(result)
    final_result <- rbind(final_result,result)
  }
  final_result <- final_result[-1,]
  rownames(final_result) <- 1:nrow(final_result)
  return(final_result)
}




