# Load libraries
library(uuid)
library(dplyr)
library(readr)
library(zip)
library(stringr)

setwd("~/Documents/kummel")
#do this only once!
# Generate one UUID for datasetID
# dataset_uuid <- paste0("urn:uuid:", UUIDgenerate())

# Read your input file
input_file <- "test.txt"
data <- read_tsv(input_file, col_types = cols())

# Clean all character fields
clean_data <- data %>%
  mutate(across(
    where(is.character),
    ~ str_squish(gsub("[\r\n]", " ", .))  # remove line breaks, collapse multiple spaces
  ))

# Create occurrence data
dwc_data <- clean_data %>%
  mutate(
    occurrenceID = UUIDgenerate(n = n()),
    basisOfRecord = "HumanObservation",
    datasetID = "urn:uuid:e495db61-2817-4938-b78a-6dd38803a3bb",
    datasetName = "Mark Kummel Photographs",
    references = "https://www.flickr.com/people/treebeard/",
    institutionCode = "UCSB",
    collectionCode = "IZC",
    accessRights = "Use permitted under Creative Commons Attribution 4.0 International License (CC BY 4.0)",
    license = "https://creativecommons.org/licenses/by/4.0/",
    recordedBy = "Mark Kummel",
    eventDate = Date_YYYYMMDD,
    decimalLatitude = Latitude,
    decimalLongitude = Longitude,
    coordinateUncertaintyInMeters = Accuracy,
    country = Country,
    stateProvince = State,
    county = "",
    locality = Locality,
    scientificName = ScientificName,
    family = Families,
    vernacularName = CommonNames,
    associatedTaxa = associatedTaxa,
    occurrenceRemarks = Notes,
    associatedMedia = paste0("https://symbiota.ccber.ucsb.edu/kummel/2025/", File.Name)
  ) %>%
  select(
    occurrenceID,
    basisOfRecord,
    datasetID,
    datasetName,
    references,
    institutionCode,
    collectionCode,
    accessRights,
    license,
    scientificName,
    vernacularName,
    associatedTaxa,
    eventDate,
    country,
    stateProvince,
    county,
    locality,
    decimalLatitude,
    decimalLongitude,
    coordinateUncertaintyInMeters,
    occurrenceRemarks,
    associatedMedia
  )
# Save occurrence file matching meta.xml core location
write_tsv(dwc_data, "occurrence.tsv", na = "", eol = "\r\n")

# Create multimedia extension data
media_data <- dwc_data %>%
  select(occurrenceID, associatedMedia) %>%
  mutate(
    identifier = associatedMedia,
    Credit = "Mark Kummel",
    creator = "Mark Kummel",
    licenseLogoURL = "https://creativecommons.org/licenses/by/4.0/",
    UsageTerms = "CC BY 4.0"
  ) %>%
  select(
    occurrenceID,
    identifier,
    Credit,
    creator,
    licenseLogoURL,
    UsageTerms
  )

# Save media extension as tab-separated
write_tsv(media_data, "associatedMedia.tsv", na = "", eol = "\r\n")

# Zip DwC-A
zip::zip(
  zipfile = "dwca_kummel_2025.zip",
  files = c("occurrence.tsv", "eml.xml", "meta.xml", "associatedMedia.tsv")
)

cat("DwC-A archive created: dwca_kummel_2025.zip\n")
