#functions to create data lists

#first define average ages for traps and shells cause we're gonna use it elsewhere
mean_age_shells <- mean(real_data$shell_ppl$age)
mean_age_traps <- mean(real_data$trap_ppl$age)

##########################################################################
#PREPARE DATA - AGE ONLY
##########################################################################
#SHELLS
make_list_data_age <- function(data = real_data, foraging_type ){
      d_shellppl <- data$shell_ppl
      d_shells <- data$shells
      
      #keep only foraging data
      d_shellppl <- d_shellppl %>% filter(data == "shells")
      
      #add index variables
      #index and sort all individuals so we can loop across them
      d_shellppl$index_id <- as.integer(as.factor(d_shellppl$anonymeID))
      d_shellppl <- d_shellppl[order(d_shellppl$index_id),]
      #add index for individuals in the foraging data
      for ( i in 1:nrow(d_shells)){
        d_shells$index_id[i] <- d_shellppl$index_id[which ( d_shellppl$anonymeID == d_shells$anonymeID[i])]
      }
      #TRAPS
      d_trapppl <- data$trap_ppl
      d_traps <- data$traps
      
      #keep only foraging data
      d_trapppl <- d_trapppl %>% filter(data == "traps")
      d_traps <- d_traps[which(d_traps$lenght_hour >= 1), ]
      
      #add index variables
      #index and sort all individuals so we can loop across them
      d_trapppl$index_id <- as.integer(as.factor(d_trapppl$anonymeID))
      d_trapppl <- d_trapppl[order(d_trapppl$index_id),]
      for ( i in 1:nrow(d_traps)){
        d_traps$index_id[i] <- d_trapppl$index_id[which ( d_trapppl$anonymeID == d_traps$anonymeID[i])]
      }
      
      #index id of best actor
      best_guy <- d_trapppl$index_id[which(d_trapppl$anonymeID == 13212)]
      
      
      dat_shells_age <- list(
        N = nrow(d_shellppl),
        M = nrow(d_shells),
        age = d_shellppl$age / mean(real_data$shell_ppl$age),
        returns = as.numeric(d_shells$returns)/1000,
        duration = d_shells$lenght_min/mean(d_shells$lenght_min),
        tide = d_shells$tide_avg_depth,
        ID_i= d_shells$index_id
      )
      
      
      dat_traps_age <- list(
        N = nrow(d_trapppl),                       #n individuals in total sample
        M = nrow(d_traps),                         #n trip/person
        ID_i= d_traps$index_id,                    #index of person of trip 
        success = d_traps$success,                 #whether trap captured something
        age = d_trapppl$age / mean(real_data$trap_ppl$age),
        duration = d_traps$lenght_hour/mean(d_traps$lenght_hour),
        best_guy = best_guy
      )
    #return either type of data  
  if(foraging_type == "shells"){
    return(dat_shells_age)
  }else{
    if(foraging_type == "traps"){
      return(dat_traps_age)
    }
  }
}



##########################################################################
#PREPARE DATA - ALL PREDICTORS
##########################################################################
make_list_data_all <- function(data = real_data, foraging_type ){

      #SHELLS
      d_shellppl <- data$shell_ppl
      d_shells <- data$shells
      d_shell_k <- data$shell_k
      
      #add index variables
      #index and sort all individuals so we can loop across them
      d_shellppl$index_id <- as.integer(as.factor(d_shellppl$anonymeID))
      d_shellppl <- d_shellppl[order(d_shellppl$index_id),]
      #add index for individuals in the foraging data
      for ( i in 1:nrow(d_shells)){
        d_shells$index_id[i] <- d_shellppl$index_id[which ( d_shellppl$anonymeID == d_shells$anonymeID[i])]
      }
      #sort knowledge data
      d_shell_k <- d_shell_k[ order(row.names(d_shell_k)), ]
      
      #TRAPS
      d_trapppl <- data$trap_ppl
      d_traps <- data$traps
      d_trap_k <- data$trap_k
      
      #add index variables
      #index and sort all individuals so we can loop across them
      d_trapppl$index_id <- as.integer(as.factor(d_trapppl$anonymeID))
      d_trapppl <- d_trapppl[order(d_trapppl$index_id),]
      for ( i in 1:nrow(d_traps)){
        d_traps$index_id[i] <- d_trapppl$index_id[which ( d_trapppl$anonymeID == d_traps$anonymeID[i])]
      }
      
      #remove traps shorter than one hour
      d_traps <- d_traps[which(d_traps$lenght_hour >= 1), ]
      
      #sort knowledge data
      d_trap_k <- d_trap_k[ order(row.names(d_trap_k)), ]
      
      #SHELLS
      dat_shells_all <- list(
        #foraging data
        N = nrow(d_shellppl),                       #n individuals in total sample
        M = nrow(d_shells),                         #n trip/person
        ID_i= d_shells$index_id,                    #index of person of trip 
        returns = as.numeric(d_shells$returns)/1000,#amount of shells in kg
        age = d_shellppl$age / mean(real_data$shell_ppl$age),
        sex = ifelse(d_shellppl$sex == "m", 1, 2), #make vector of sexes 1 = male 2 = female
        duration = d_shells$lenght_min/mean(d_shells$lenght_min),
        tide = d_shells$tide_avg_depth,
        #height data
        has_height = ifelse(is.na(d_shellppl$height), 0, 1),# #vector of 0/1 for whether height has to be imputed
        height = d_shellppl$height/mean(d_shellppl$height, na.rm = TRUE),
        min_height = 50/mean(d_shellppl$height, na.rm = TRUE),#average height of newborn as intercept in height model
        #grip data
        has_grip = ifelse(is.na(d_shellppl$grip), 0, 1),# #vector of 0/1 for whether grip has to be imputed
        grip = d_shellppl$grip/mean(d_shellppl$grip, na.rm = TRUE),
        #knowledge data
        has_knowledge = ifelse(is.na(d_shellppl$knowledge), 0, 1),# #vector of 0/1 for whether knowledge has to be imputed
        knowledge_nit = d_shellppl$knowledge/mean(d_shellppl$knowledge, na.rm = TRUE),
        Q = ncol(d_shell_k),                        #n items in freelist
        answers = d_shell_k                         #all answers from freelist
      )
      
      #TRAPS
      dat_traps_all <- list(
        #foraging data
        N = nrow(d_trapppl),                       #n individuals in total sample
        M = nrow(d_traps),                         #n trip/person
        ID_i= d_traps$index_id,                    #index of person of trip 
        has_foraging = ifelse(d_trapppl$data == "traps", 1, 0),
        success = d_traps$success,                 #whether trap captured something
        age = d_trapppl$age / mean(real_data$trap_ppl$age),
        sex = ifelse(d_trapppl$sex == "m", 1, 2), #make vector of sexes 1 = male 2 = female
        duration = d_traps$lenght_hour/mean(d_traps$lenght_hour),
        #height data
        has_height = ifelse(is.na(d_trapppl$height), 0, 1),# #vector of 0/1 for whether height has to be imputed
        height = d_trapppl$height/mean(d_trapppl$height, na.rm = TRUE),
        min_height = 50/mean(d_trapppl$height, na.rm = TRUE),#average height of newborn as intercept in height model
        #grip data
        has_grip = ifelse(is.na(d_trapppl$grip), 0, 1),# #vector of 0/1 for whether grip has to be imputed
        grip = d_trapppl$grip/mean(d_trapppl$grip, na.rm = TRUE),
        #knowledge data
        has_knowledge = ifelse(is.na(d_trapppl$knowledge), 0, 1),# #vector of 0/1 for whether knowledge has to be imputed
        knowledge_nit = d_trapppl$knowledge/mean(d_trapppl$knowledge, na.rm = TRUE),
        Q = ncol(d_trap_k),                        #n items in freelist
        answers = d_trap_k                       #all answers from freelist
      )
      #return either type of data  
  if(foraging_type == "shells"){
    return(dat_shells_all)
  }else{
    if(foraging_type == "traps"){
      return(dat_traps_all)
    }
  }
}

