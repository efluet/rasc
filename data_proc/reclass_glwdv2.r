
library(terra)
library(tidyverse)
library(stringr)
library(here)
here()


# /----------------------------------------------------------------------------#
#/  Read inputs

# Read in GLWDv2 data
glwdv2 <- rast('../data/GLWDv2/grids/GLWD_v2_delta_area_by_class_ha_tif/GLWD_v2_delta_area_by_class_ha/GLWD_v2_delta_class_01_ha_x10.tif')

# Read class xwalk
xwalk <- 
  read.csv('../data/GLWDv2/glwdv2_gwo_xwalk.csv') %>% 
  arrange(gwo) %>% 
  # Add leading 0
  mutate(gwo   = str_pad(gwo, width=2, pad = 0),
         glwdv2= str_pad(glwdv2, width=2, pad = 0)) %>% 
  filter(!is.na(gwo))


gwo_class_area_df <- data.frame()


# /----------------------------------------------------------------------------#
#/ Loop through GWO classes in the list
for (gwo_class in unique(xwalk$gwo)){

  print(gwo_class)

  # Create/reinitialize empty temp output
  gwo_out <- rast()
  
  # Loop through GLWDv2 classes matching the GWO class  
  for (glwd2_class in unique(xwalk[xwalk$gwo==gwo_class,'glwdv2'])){
  
    print(paste0('  |-> ', glwd2_class))
    
    # file name 
    fname <- paste0('../data/GLWDv2/grids/GLWD_v2_delta_area_by_class_ha_tif/GLWD_v2_delta_area_by_class_ha/GLWD_v2_delta_class_', glwd2_class, '_ha_x10.tif')
    
    # Append to stack
    gwo_out <- c(gwo_out, rast(fname))
    
  }
  
  # sum all glwdv2 classes together
  gwo_out <- app(gwo_out, sum, na.rm=T, cores=8)
  
  writeRaster(gwo_out,
              paste0('../output/results/grids/GLWD_v2_delta_GWO_class_', gwo_class, '_ha_x10.tif'))
  
  
  # Add global area to output df
  gwo_class_area_df <- bind_rows(gwo_class_area_df,
                                 data.frame(gwo_class = gwo_class,
                                            area_Mha = global(gwo_out, sum, na.rm=T)/10/10^6))
  
}

# /----------------------------------------------------------------------------#
#/   Save area to file

gwo_class_area_df <- 
  gwo_class_area_df %>% 
  mutate(sum = sum*0.01)

names(gwo_class_area_df) <- c('gwo_class','area_Mkm2')


write.csv(gwo_class_area_df, '../output/results/gwo_class_area.csv')

sum(gwo_class_area_df$area_Mkm2)


# PLOT AREA
gwo_class_area_df <- read.csv('../output/results/gwo_class_area_wnames.csv')


library(forcats)

ggplot(gwo_class_area_df) +
  geom_bar(aes(x=fct_reorder(gwo_name, area_Mkm2), y=area_Mkm2), stat='identity', fill='blue3', width=0.6) +
  coord_flip() +
  scale_y_continuous(expand=c(0,0)) +
  ylab('Area (million km^2)') +
  xlab('') +
  theme_classic()

ggsave('../output/figures/gwo_class_area.png',
       # barplot_resev_perc,
       width=90, height=60, dpi=400, units='mm' )



