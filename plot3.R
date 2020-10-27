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

NEI <- readRDS("summarySCC_PM25.rds")

# Processing

baltimore_data <- subset(NEI, fips == "24510")
baltimore_data <- baltimore_data[c(1,4,5,6)]
baltimore_data$type <- factor(baltimore_data$type)
baltimore_data$Cat <- interaction(baltimore_data$year, baltimore_data$type)
sums <- with(baltimore_data, tapply(Emissions, Cat, sum))
summed_data <- data.frame(Cat = names(sums), Emissions = sums)
summed_data$year <- sapply(summed_data$Cat, 
                           function(x) {
                                   y <- strsplit(x, "\\.");
                                   return(y[[1]][1])
                           }
)
summed_data$type <- sapply(summed_data$Cat, 
                           function(x) {
                                   y <- strsplit(x, "\\.");
                                   return(y[[1]][2])
                           }
)
summed_data <- summed_data[-1]

# Plotting data

png("plot3.png", height = 461, width = 762, units = "px")
g2 <- ggplot(summed_data, aes(as.integer(year), Emissions))
g2 + geom_point() + 
        geom_smooth(method="lm", se=FALSE) +
        facet_wrap(type ~ .) +
        xlab("Year") +
        ylab("Total Emissions (tons)") +
        ggtitle("Emissions from 1999 to 2008 according to the type of Source") +
        theme_bw() 
dev.off()

#=================================== END =======================================
