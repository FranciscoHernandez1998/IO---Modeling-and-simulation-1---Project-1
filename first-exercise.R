library(xts)

get_random_arrival_time <- function(week_day) {
  time_between_arrivals <- c(0, 1, 2, 3, 4, 5, 6)
  week_days_probabilities <- list(
    c(0.1, 0.15, 0.1, 0.35, 0.25, 0.05, 0),
    c(0.1, 0.1, 0.15, 0.2, 0.35, 0.1, 0),
    c(0, 0.1, 0.1, 0.2, 0.1, 0.25, 0.25),
    c(0, 0.15, 0.2, 0.2, 0.15, 0.15, 0.15),
    c(0.15, 0.15, 0.2, 0.2, 0.1, 0.1, 0.1),
    c(0.2, 0.15, 0.1, 0.5, 0.05, 0, 0),
    c(0.35, 0.25, 0.2, 0.1, 0.1, 0, 0)
  )
  arrival_time <- sample(time_between_arrivals, 1, replace = TRUE, prob = week_days_probabilities[[week_day]])
  return(arrival_time)
}

get_time_sequence_list <- function() {
  day_data <- list()
  total_time_sequence <- format(seq(from=as.POSIXct(paste(Sys.Date(), " 10:00")),to=as.POSIXct(paste(Sys.Date(), " 18:00")),by="min"), '%H:%M')
  for(i in 1:length(total_time_sequence)) {
    minute_data <- c(
      i,
      total_time_sequence[i],
      0
    )
    day_data[[length(day_data)+1]] <- minute_data
  }
  return(day_data)
}

get_customer_arrivals <- function() {
  day_data <- get_time_sequence_list()
  current_date_time <- 1
  while(current_date_time < length(day_data)) {
    random_arrival_time <- get_random_arrival_time()
    current_date_time <- current_date_time + random_arrival_time
    if(current_date_time <= length(day_data)) {
      if(strtoi(day_data[[current_date_time]][3]) == 0) {
        day_data[[current_date_time]][3] <- 1
      }else {
        existing_number <- day_data[[current_date_time]][3]
        day_data[[current_date_time]][3] <- strtoi(existing_number) + 1
      }
    }
  }
  return(day_data)
}



run_day_simulation <- function(week_day) {
  day_data <- get_customer_arrivals()
  data_frame_header = c("correlative",
                        "time",
                        "customer_arrivals"
                        )
  data_frame= as.data.frame(t(as.data.frame(day_data)))
  rownames(data_frame)<- NULL
  colnames(data_frame)<-data_frame_header
  return(data_frame)
}

run_week_simulation <- function() {
  
}

