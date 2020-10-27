# Checking if the files exist in the current directory. If not, they will be 
# downloaded and working directory will be set to a new one.

if(!file.exists("summarySCC_PM25.rds")) {
        tmp <- tempfile()
        download.file(
                "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip",
                tmp)
        dir.create("./pm2.5_project_data")
        old.dir <- getwd()
        setwd("pm2.5_project_data")
        
        # unzipping the downloaded files
        
        unzip(tmp, exdir = ".")
}

# Checking for the existance of 'zip' package. If not, it will be installed

install.packages("zip", "ggplot2")
library(ggplot2)
library(zip)

# loading data

SCC <- readRDS("./Source_Classification_Code.rds")
NEI <- readRDS("./summarySCC_PM25.rds")

# Processing

data <- merge(NEI, SCC)
coalData <- data[grep("[Cc]oal", data$SCC, ignore.case = TRUE),]
yearlyData <- aggregate(coalData$Emissions, by = list(coalData$year, FUN = sum))
names(yearlyData) <- c("Year", "Total_Emissions")

# Plotting

png("plot4.png", height = 461, width = 762, units = "px")
g <- ggplot(yearlyData, aes(Year, Total_Emissions))
g + geom_point() + geom_smooth(method="lm", se=FALSE) + 
        ggtitle("Total Emissions from Coal Combustion Sources (1999-2008)") +
        xlab("Year") + ylab("Emissions (tons)") + theme_bw()

dev.off()

#==================================== END ======================================
