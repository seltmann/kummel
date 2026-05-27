#split into 1000 records, combine records together

setwd("~/Documents/kummel")
library(dplyr)
library(stringr)
library(readr)

# ---- Load your data ----
data <- read_tsv("Kummel_Data_20250509.tsv", col_types = cols(.default = col_character()))
problems(data)


# ---- Sread.table()# ---- Split into chunks of 100,000 rows ----
chunk_size <- 1000
n <- ceiling(nrow(data) / chunk_size)

for (i in 1:n) {
  start_row <- (i - 1) * chunk_size + 1
  end_row <- min(i * chunk_size, nrow(data))
  chunk <- data[start_row:end_row, ]
  filename <- paste0("output/cleaned_data_chunk_", i, ".csv")
  write.csv(chunk, filename, row.names = FALSE)
}


##############cleaning functions#############
data <- read.csv("output/cleaned_data_chunk_1.csv", stringsAsFactors = FALSE)

#To switch the values between ScientificName and associatedTaxa only when associatedTaxa contains "Quercus agrifolia"

data <- data %>%
  mutate(
    # Create temporary copies of both columns
    original_ScientificName = ScientificName,
    original_associatedTaxa = associatedTaxa,
    
    # Perform the conditional swap
    ScientificName = if_else(str_detect(original_associatedTaxa, "Quercus agrifolia"), 
                             original_associatedTaxa, 
                             original_ScientificName),
    
    associatedTaxa = if_else(str_detect(original_associatedTaxa, "Quercus agrifolia"), 
                             original_ScientificName, 
                             original_associatedTaxa)
  ) %>%
  select(-original_ScientificName, -original_associatedTaxa)  # clean up

write.csv(data,"output/cleaned_data_chunk_1_new.csv",row.names = FALSE)
