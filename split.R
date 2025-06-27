#split into 1000 records, combine records together

setwd("~/Documents/kummel")

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
