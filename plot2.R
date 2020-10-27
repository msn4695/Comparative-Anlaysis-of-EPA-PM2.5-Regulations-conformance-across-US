# Checking if the files exist in the current directory. If not, they will be 
# downloaded and working directory will be set to a new one.

if(!file.exists("Source_Classification_Code.rds") & 
   !file.exists("summarySCC_PM25.rds")) {
        tmp <- tempfile()
        download.file(
                "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip",
                tmp)
        dir.create("./pm2.5_project_data")
        old.dir <- getwd()
        setwd("pm2.5_project_data")
}

# Checking for the existance of 'zip' package. If not, it will be installed

if (!require("zip", quietly = TRUE)) {
        install.packages("zip")
        library(zip)
} else {
        library(zip)
}

# unzipping the downloaded files

unzip(tmp, exdir = ".")

# loading data

SCC <- readRDS("Source_Classification_Code.rds")
NEI <- readRDS("summarySCC_PM25.rds")

# Processing

nei_baltimore <- subset(NEI, fips == "24510")
yeardata <- with(nei_baltimore, tapply(Emissions, year, sum))
yeardata1 <- data.frame(Year = names(yeardata), Total_Emissions = yeardata)

# Plotting data

png("plot2.png", height=461, width=762, units="px")
with(yeardata1, plot(Year, Total_Emissions, pch = 19, 
                     main = "Total Emissions in Maryland, Baltimore from 1999 to 2008",
                     xlim = c(1998, 2008),
                     xlab="Year", ylab="Total Emissions (tons)"
))
lmm <- lm(Total_Emissions ~ as.integer(Year), yeardata1)
abline(lmm, lwd = 2)
title()

dev.off()

# Closing

setwd(old.dir)

#=================================== END =======================================
