# Marvel_Package

__Name of project__: Marvel Information Search Package.   

__Owner of project__: Mengran Xia, mx2205@columbia.edu

__Brief description of the purpose__: Marvel is an American media franchise and shared universe centered on a series of superhero films, independently produced by Marvel Studios and based on characters that appear in American comic books published by Marvel Comics. The rich history of Marvel marks countless number of comic series released and films produced, leaving abundunt information for audience to discover. On the character segment alone, Marvel website has 2575 results/characters, making it very hard to navigate through the website and to browse on the stories and comic series of one particular super-hero. The overwhelming amount of information can be organized and sorted by creating this Marvel R Package. Users will easily browse through web-scraped content by specifying which character/creator/comics series they are interested in. 

__Type of project__: This project would primarily be an API Client (B-type) project. A side integration of a Data Project (type A1/A2) will be added.   

__Online Duplication Check__: https://www.npmjs.com/package/marvel-api There is one avialable but not in the format of R pacakge. This is deisgned for Node.js. 

__Links to data sources / API etc__: https://developer.marvel.com/documentation/getting_started

__Outline the technical steps__:
1. Use Marvel API to retreive Character, Comic, Series, Stories, Creators and Events information for all characters. package `httr` and `rvest`will be used. 
2. Design parameters that allows users to search through all the variables. 
3. Transform all data from json to DataFrame.
4. Organize Dataset and apply text cleaning and analysis on DataFrames. 
5. Process Strings using Regular Expression
6. Apply Step 3-5 multiple times on all varaibels and make them into different functions.
7. Combine functions into one R package 

__Available Functions__:
## API_access Function

This function marks the very first step of using the Marvel package. Users need to provide their own private and public key for Marvel API in order to gain access to the information of the rest of the functions in Marvel library. 

## get_all_nameid Function

This function allows users who does not have any set character name or id set in mind and wish to explore all the available characters on Marvel.com.

The function loops through all the characters using limit and offset (meaning starting from which index of the character) and returns a dataframe that provides id, name and url (if the character has its own website link, if not, the function will return "Not Found") of all characters. 

## basic_info_by_ID Function

This function retrieves the most basic information of the inputed character. It provides the number of comics/series/stories/events available of that particular character. 

## marvel_char_compare Function

This function is a more advanced function of basic_info_by_ID() Function. It allows user to retrieve the basic information of number of comics/series/stories/events available to up to 3 characters and easily compare. 

Note, the third character is optional. To succesfully run this function, user needs to input at least 2 and at most 3 character names. 

## get_character_bio Function

This function allows user to gain access to biogrophy related information that's listed on the Character url within Marvel.com. It can only retrieve biography if the character already has its own website on Marvel.com. This can be assessed through get_all_nameid(), whereas the column "url" Information includes height, weight, eye color and hair color etc. 

Unlike other functions that use `httr` package to content(GET(url)), this function `rvest` and `xml2` packages to inspect css selectors on a given webpage and retrieve information. 

## get_event Function

This function allows user to retrive up to 100 most recent events held by Marvel. The parameter input ranges from 0 to 100. The returned dataframe provides the name, description, start date and end date etc for that specific event. 

## search_character_comic Function

This function takes basic_info_by_ID() Function to the next level by digging deeper of the comics information of a particular character. Rather than only listing the number of comics avaialble of the character, it returns all information of each comics. 

## search_character_events Function

This function takes basic_info_by_ID() Function to the next level by digging deeper of the events information of a particular character. Rather than only listing the number of events avaialble of the character, it returns all information of each event. 

## search_character_stories Function

This function takes basic_info_by_ID() Function to the next level by digging deeper of the stories information of a particular character. Rather than only listing the number of stories avaialble of the character, it returns all information of each story. 
