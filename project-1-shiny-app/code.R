library(xts)

# param -> week_day: number from 1 to 7 representing day of the week
# return -> random arrival time based on day's probabilities
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

# return -> random serving time based on average serving time and std deviation
get_random_serving_time <- function() {
  serving_time <- floor(rnorm(1, 8, 5))
  while(serving_time < 0) {
    serving_time <- floor(rnorm(1, 8, 5))
  }
  return(serving_time)
}

# return -> list of vectors with values for first four columns of data frame data
#           correlative | time | customer_arrivals | next_arrival
get_time_sequence_list <- function() {
  day_data <- list()
  total_time_sequence <- format(seq(from=as.POSIXct(paste(Sys.Date(), " 10:00")),to=as.POSIXct(paste(Sys.Date(), " 18:00")),by="min"), '%H:%M')
  for(i in 1:length(total_time_sequence)) {
    minute_data <- c(
      i,
      total_time_sequence[i],
      0,
      -1
    )
    day_data[[length(day_data) + 1]] <- minute_data
  }
  return(day_data)
}

# param -> week_day: number from 1 to 7 representing day of the week
# return -> list of vectors with correct values of simulation for two columns of data frame data
#            customer_arrivals | next_arrival
get_customer_arrivals <- function(week_day) {
  day_data <- get_time_sequence_list()
  current_date_time <- 1
  while(current_date_time < length(day_data)) {
    random_arrival_time <- get_random_arrival_time(week_day)
    current_date_time <- current_date_time + random_arrival_time
    if(current_date_time <= length(day_data)) {
      if(strtoi(day_data[[current_date_time]][3]) == 0) {
        day_data[[current_date_time]][3] <- 1
        day_data[[current_date_time - random_arrival_time]][4] <- random_arrival_time
      }else {
        existing_number <- day_data[[current_date_time]][3]
        day_data[[current_date_time]][3] <- strtoi(existing_number) + 1
        day_data[[current_date_time]][4] <- random_arrival_time
      }
    }
  }
  return(day_data)
}

# param -> week_day: number from 1 to 7 representing day of the week
# param -> servers_number: number from 1 to 7 representing amount of servers available
# return -> entire simulation of a single day with n servers available
#           correlative | time | customer_arrivals | next_arrival | agent_1_serving_time |... | agent_n_serving_time | customers_queue | unattended_customers | attended_customers | queue_time
run_day_simulation <- function(week_day, servers_number, max_queue_size) {
  day_data <- list()
  customer_arrivals <- get_customer_arrivals(week_day)
  customers_queue <- 0
  previous_customers_queue <- 0
  agents_serving_time <- c()
  queue_time <- 0
  for(i in 1:servers_number) agents_serving_time <- c(agents_serving_time, 0)
  for (i in 1:length(customer_arrivals)) {
    row <- customer_arrivals[[i]]
    customers <- strtoi(row[3])
    pending_customers <- customers + customers_queue
    served_customers <- 0
    if(pending_customers != 0) {
      for (j in 1:pending_customers) {
        for (k in 1:length(agents_serving_time)) {
          if(agents_serving_time[k] == 0){
            agents_serving_time[k] <- get_random_serving_time()
            served_customers <- served_customers + 1
            break;
          }
        }
      }
    }
    previous_customers_queue <- customers_queue
    customers_queue <- pending_customers - served_customers
    finished_served_customers <- 0
    for (j in 1:length(agents_serving_time)) {
      if(agents_serving_time[j] == 1){
        finished_served_customers <- finished_served_customers + 1
      }
    }
    if(customers_queue > max_queue_size & max_queue_size != -1) {
      day_data[[length(day_data) + 1]] <- c(customer_arrivals[[i]], 
                                            agents_serving_time, 
                                            c(max_queue_size, customers_queue - max_queue_size, finished_served_customers),
                                            if(previous_customers_queue > customers_queue & (customers_queue != 0)) queue_time else 0 )
      customers_queue <- max_queue_size
    } else {
      day_data[[length(day_data) + 1]] <- c(customer_arrivals[[i]], 
                                            agents_serving_time, 
                                            c(customers_queue, 
                                              0, 
                                              finished_served_customers),
                                            if(previous_customers_queue > customers_queue & (customers_queue != 0)) queue_time else 0)
    }
    if((previous_customers_queue > customers_queue & customers_queue != 0) | (customers_queue == 0)) {
      queue_time <- 0
    } else if(customers_queue != 0) {
      queue_time <- queue_time + 1
    }
    for (j in 1:length(agents_serving_time)) {
      if(agents_serving_time[j] > 0){
        agents_serving_time[j] <- agents_serving_time[j] -1
      }
    }
  }
  return(day_data)
}

# param -> day_data: all columns to construct data frame of simulation
# param -> servers_number: number from 1 to 7 representing amount of servers available
# return -> data frame with all simulation columns
#           correlative | time | customer_arrivals | next_arrival | agent_1_serving_time | ... | agent_n_serving_time | customers_queue | unattended_customers | attended_customers | queue_time
get_day_data_frame <- function(day_data, servers_number) {
  agents_headers <- c()
  for(i in 1:servers_number) agents_headers <- c(agents_headers, paste("agent_", toString(i), "_serving_time", sep=''))
  data_frame_header = c("correlative",
                        "time",
                        "customer_arrivals",
                        "next_arrival",
                        agents_headers,
                        "customers_queue",
                        "unattended_customers",
                        "attended_customers",
                        "queue_time"
  )
  data_frame= as.data.frame(t(as.data.frame(day_data)))
  rownames(data_frame)<- NULL
  colnames(data_frame)<-data_frame_header
  return(data_frame)
}

# return -> list of data frames with simulations from 1 to 7 servers for a day of the week in particular
run_all_servers_day_simulations <- function(week_day, max_queue_size) {
  all_servers_simulations <- list()
  for (i in 1:7) {
    all_servers_simulations[[length(all_servers_simulations) + 1]] <- get_day_data_frame(run_day_simulation(week_day, i, max_queue_size), i)
  }
  return(all_servers_simulations)
}

# return -> data frame with averages of queues based on number of servers and day of the week
get_week_average_queues <- function(days_to_get=7, num_of_servers=7) {
  list_of_day_averages <- list(seq(from = 1, to = num_of_servers, by = 1))
  for (i in 1:days_to_get) {
    day_simulations <- run_all_servers_day_simulations(i, -1)
    day_averages <- c()
    for (j in 1:num_of_servers) {
      day_averages <- c(day_averages, ceiling(mean(as.numeric(day_simulations[[j]]$customers_queue))))
    }
    list_of_day_averages[[length(list_of_day_averages) + 1]] <- day_averages
  }
  data_frame= as.data.frame(list_of_day_averages[0:days_to_get + 1])
  data_frame_header = c("num_of_servers",
                        "monday",
                        "tuesday",
                        "wednesday",
                        "thursday",
                        "friday",
                        "saturday",
                        "sunday"
                      )[0:days_to_get + 1]
  rownames(data_frame)<- NULL
  colnames(data_frame)<-data_frame_header
  return(data_frame)
}

# return -> data frame with averages of unattended customers based on a customers queue max size
get_week_average_unattended_customers <- function(days_to_get=7, num_of_servers=7, max_queue_size=10) {
  list_of_day_averages <- list(seq(from = 1, to = num_of_servers, by = 1))
  for (i in 1:days_to_get) {
    day_simulations <- run_all_servers_day_simulations(i, max_queue_size)
    day_averages <- c()
    for (j in 1:num_of_servers) {
      total_unattended_customers <- sum(as.numeric(day_simulations[[j]]$unattended_customers))
      day_averages <- c(day_averages, total_unattended_customers)
    }
    list_of_day_averages[[length(list_of_day_averages) + 1]] <- day_averages
  }
  data_frame= as.data.frame(list_of_day_averages[0:days_to_get + 1])
  data_frame_header = c("num_of_servers",
                        "monday",
                        "tuesday",
                        "wednesday",
                        "thursday",
                        "friday",
                        "saturday",
                        "sunday"
                        )[0:days_to_get + 1]
  rownames(data_frame)<- NULL
  colnames(data_frame)<-data_frame_header
  return(data_frame)
}


# return -> data frame with averages of waiting time on queue
get_week_average_queue_waiting_time <- function(days_to_get=7, num_of_servers=7, max_queue_size=10) {
  list_of_day_averages <- list(seq(from = 1, to = num_of_servers, by = 1))
  for (i in 1:days_to_get) {
    day_simulations <- run_all_servers_day_simulations(i, max_queue_size)
    day_averages <- c()
    for (j in 1:num_of_servers) {
      queue_times <- as.numeric(day_simulations[[j]]$queue_time)
      non_zero_queue_times <- queue_times[queue_times != 0]
      avg_waiting_time <- ceiling(mean(non_zero_queue_times))
      day_averages <- c(day_averages, if(is.nan(avg_waiting_time)) 0 else avg_waiting_time )
    }
    list_of_day_averages[[length(list_of_day_averages) + 1]] <- day_averages
  }
  data_frame= as.data.frame(list_of_day_averages[0:days_to_get + 1])
  data_frame_header = c("num_of_servers",
                        "monday",
                        "tuesday",
                        "wednesday",
                        "thursday",
                        "friday",
                        "saturday",
                        "sunday"
  )[0:days_to_get + 1]
  rownames(data_frame)<- NULL
  colnames(data_frame)<-data_frame_header
  return(data_frame)
}
