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

NEI.req <- subset(NEI, fips == "24510" | fips == "06037")
data <- merge(NEI.req, SCC)
motorSources <- data[grep("motor|vehicle", data$Short.Name, ignore.case = TRUE),]
motorSources$cat <- interaction(motorSources$year, motorSources$fips)
aggrData <- aggregate(motorSources$Emissions, list(motorSources$cat), sum)
aggrData$year <- sapply(as.character(aggrData$Group.1), function(x) {
        y <- strsplit(x, "\\.");
        return(y[[1]][1])
})
aggrData$fips <- sapply(as.character(aggrData$Group.1), function(x) {
        y <- strsplit(x, "\\.");
        return(y[[1]][2])
})
aggrData <- aggrData[-1]
names(aggrData)[1] <- "Emissions"
aggrData$year <- as.integer(aggrData$year)
aggrData$city <- sapply(aggrData$fips, function(x) {
        if (x == "24510") {return("Baltimore")}
        else {return("Los Angeles County")}
})

# Plotting

png("plot.png", height = 550, width = 910, units = "px")
g <- ggplot(aggrData, aes(year, Emissions))
g + geom_point() + geom_smooth(method = "lm", se = FALSE) + 
        facet_wrap(city ~ .) + 
        ggtitle("Comparison of Reduction in Particulate Matter in 
          Baltimore city and Los Angeles County from 1999 to 2008") +
        xlab("Year") + ylab("Emissions (tons)")
dev.off()

#==================================== END ======================================
