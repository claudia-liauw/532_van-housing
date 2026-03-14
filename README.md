# 532_van-housing

## Vancouver Non-Market Housing Dashboard

This dashboard visualizes non-market housing projects in **Vancouver** using publicly available data. It is designed to help:

- **Residents & Renters**: Understand building options, types, and occupancy years of non-market housing.  
- **City Planners & Policymakers**: Track housing development and analyze trends over time.  

Users can filter projects by **clientele**, **bedrooms**, **accessibility**, and **occupancy year**. The dashboard displays:  

- **Total Units**: Aggregated housing units based on selected filters  
- **Buildings Table**: List of projects matching filter criteria  
- **Map**: Intended for geospatial visualization (inactive)

## Getting Started

### Installation

1. Clone this repository:
```bash
git clone https://github.com/claudia-liauw/532_van-housing
```

2. Install the rsconnect package if required:
```R
install.packages("rsconnect")
library(rsconnect)
```

3. Install packages
```R
setwd("path/to/532_van-housing")
installPackages(manifest = "manifest.json")
```

### Running the Dashboard Locally

```R
setwd("path/to/532_van-housing")
runApp()
```

### View the Dashboard Live

The dashboard can be viewed [online](https://019ce9ef-d6e9-e124-f5c1-e2ff1bb1bfe5.share.connect.posit.cloud/).