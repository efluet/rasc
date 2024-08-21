
# /----------------------------------------------------------------------------#
#/   Get inputs and join them         --------

# Read in extracted dfs
soc_df  <- read.csv('../output/results/soilgrids2/soc_0-30cm_mean_perclass.csv')
bdod_df <- read.csv('../output/results/soilgrids2/bdod_0-30cm_mean_perclass.csv')



# Get GWO class lookup names
gwo_area <- read.csv('../output/results/gwo/gwo_class_area_wnames.csv')


# Join together
df <- full_join(soc_df, bdod_df, by=c('lon','lat','gwo_class_num')) %>% 
  # left_join(., gwo_area, by='gwo_class_num') %>% 
  # Convert SOC from dg/kg to OC%
  # Convert BDOD to g/cm^3
  mutate(cstock_gcm3 = soc_0_30cm_mean*0.0001 * bdod_0_30cm_mean*0.01)

glimpse(df)


# /----------------------------------------------------------------------------#
#/  GLOBAL SUMMARY VALUES

# Summarize SOC values per class
df_cstock_perclass <- 
  df %>%  # [1:10000,] %>%
  select(cstock_gcm3, gwo_class_num) %>% 
  group_by(gwo_class_num) %>%  
  summarise(cstock_gcm3_p25 = quantile(cstock_gcm3, 0.25, na.rm=T),
            cstock_gcm3_mean= mean(cstock_gcm3, na.rm=T),
            cstock_gcm3_p75 = quantile(cstock_gcm3, 0.75, na.rm=T)) %>% 
  # Join to the GWO area
  left_join(., gwo_area, by='gwo_class_num') %>% 
  # Convert cm-3 to m-2 
  # convert area from Mkm2 to m2
  # Convert g to Tg
  mutate(cstock_PgC_p25 =  cstock_gcm3_p25*30*100*100 * area_Mkm2*10^12 / 10^15,
         cstock_PgC_mean = cstock_gcm3_mean*30*100*100 * area_Mkm2*10^12 / 10^15,
         cstock_PgC_p75 =  cstock_gcm3_p75*30*100*100 * area_Mkm2*10^12 / 10^15)

  
glimpse(df_cstock_perclass)



# /----------------------------------------------------------------------------#
#/  GLOBAL SUMMARY FIGURES


# Barplot of area per GWO class
barplot_area <- 
  ggplot(df_cstock_perclass) +
  geom_bar(aes(x=gwo_class_name, y= area_Mkm2, fill=gwo_class_name), stat='identity', width=0.7) +
  coord_flip() +
  ylab('Wetland area (Mkm^2)') +
  scale_y_continuous(expand=c(0,0)) + 
  xlab('') +
  line_plot_theme +
  theme(legend.position = 'none') 




# Barplot of area per GWO class
boxplot_cstock <- 
  ggplot(df_cstock_perclass) +
  geom_boxplot(aes(x=gwo_class_name,  
                   lower = cstock_gcm3_p25,
                   upper = cstock_gcm3_p75,
                   middle = cstock_gcm3_mean,
                   ymin = cstock_gcm3_p25,
                   ymax = cstock_gcm3_p75,
                   y = cstock_gcm3_mean,
                   fill = gwo_class_name,
                   color = gwo_class_name), stat = "identity", width = .7) +
  geom_point(aes(x=gwo_class_name,  y= cstock_gcm3_mean), shape=124, size=5) +
  coord_flip() +
  ylab('Belowground carbon density (g/cm^3)') +
  scale_y_continuous(expand=c(0,0)) + 
  xlab('') +
  line_plot_theme +
  # ggtitle('Belowground carbon stock (g/cm^3) from SoilGrids2 per GWO wetland type') +
  theme(legend.position = 'none',
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())




# Barplot of area per GWO class
barplot_cstock_tot <- 
  ggplot(df_cstock_perclass) +
  geom_bar(aes(x=gwo_class_name, y= cstock_PgC_mean, fill=gwo_class_name), stat='identity', width=0.7) +
  geom_errorbar(aes(x=gwo_class_name, ymin = cstock_PgC_p25, ymax = cstock_PgC_p75), width = 0.2, size=0.4) +
  coord_flip() +
  ylab('Global belowground carbon stock (PgC)') +
  xlab('') +
  scale_y_continuous(expand=c(0,0)) + 
  line_plot_theme +
  theme(legend.position = 'none',
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())





# /----------------------------------------------------------------------------#
#/    Make multipanel plot: arrange in grid                          --------

library(cowplot)

# Dimensions of each margin: t, r, b, l     (To remember order, think trouble).
# barplot_area <- barplot_area + theme(plot.margin=unit(c(0, 0, 0, -30), 'mm'))


# arrange plots grob into layout 
fig <- plot_grid(barplot_area,
                 boxplot_cstock,
                 barplot_cstock_tot,
                  
                  ncol=3, nrow=1, 
                  rel_heights = c(1, 1, 1),
                  rel_widths = c(1, .75, .75),
                  
                  # labels = c('A','B','C'),
                  align='h')


ggsave('../output/figures/soilgrids2/multipanel_global_total_cstock.png', fig,
       width=247, height=70, dpi=400, units='mm')





