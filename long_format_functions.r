

get_envelope <- function(y){
	token_polygon <- list(x=c(1:length(y),length(y):1), y=c(y, rep(min(y),length(y))))
	token_chull <- chull(token_polygon$x, token_polygon$y)
	token_env_x <- token_chull[token_chull<=length(y)]
	token_env_x <- token_env_x[order(token_env_x)]
	# approx(intensity$x[token_env_x], y[token_env_x], n=length(y))$y
	approx(token_env_x, y[token_env_x], n=length(y))$y
}

find_datacolumns <- function(data, labels){
	datacolumns <- list()
	for (label in labels){
		#datacolumns[[label]] <- names(data)[grepl(label, names(data))]
		datacolumns[[label]] <- setdiff(names(data)[grepl(paste0(label,'_'), names(data))], 
			c(names(data)[grepl('step', names(data))], names(data)[grepl('measure', names(data))], names(data)[grepl('r2', names(data))]))
	}
	datacolumns
}

times_from_formantcolumns <- function(datacolumns, label){
	as.numeric(gsub('\\.','-',gsub(paste0(label,'_'),'',datacolumns[[label]])))/100
}

long_format_data <- function(token_row, column_prefix='I', datacolumns=NULL){
	if (is.null(datacolumns)){
		datacolumns <- find_datacolumns(token_row, column_prefix)
	}
	longdata <- data.frame(x=1:length(datacolumns[[column_prefix]]))

	if (paste(column_prefix,'step',sep='_')%in%names(token_row)){
		longdata$t <- token_row[,paste(column_prefix,'first_measure',sep='_')] + (longdata$x-1)*token_row[,paste(column_prefix,'step',sep='_')]
	}else{
		longdata$t <- token_row[,'first_measure'] + (longdata$x-1)*token_row[,'step']
	}

	longdata$y <- as.numeric(token_row[,datacolumns[[column_prefix]]])
	longdata
}

long_format_intensity <- function(token_row, datacolumns=NULL){
	if (is.null(datacolumns)){
		datacolumns <- find_datacolumns(token_row, 'I')
	}
	intensity <- data.frame(x=1:length(datacolumns$I))
	intensity$t <- token_row$first_measure + (intensity$x-1)*token_row$step
	intensity$y <- as.numeric(token_row[,datacolumns$I])
	intensity
}

long_format_formants <- function(token_row, parameters=c('F'), formants=1:3, datacolumns=NULL){
	if (is.null(datacolumns)){
		pf <- expand.grid(formants=formants, parameters=parameters)
		datacolumns <- find_datacolumns(token_row, paste0(pf[,2],pf[,1]))
	}
	
	basic_fp <- paste0(parameters[1],formants[1])
	F_times_pct <- times_from_formantcolumns(datacolumns, basic_fp)
	formants_long <- data.frame(x=1:length(datacolumns[[basic_fp]]))
	formants_long$t <- token_row$phonestart + F_times_pct * with(token_row, phoneend-phonestart)

	for (parameter in parameters){
		for (formant in formants){
			label <- paste0(parameter,formant)
			formants_long[,label] <- as.numeric(token_row[,datacolumns[[label]]])
		}
	}
	formants_long
}

delta <- function(y) c(0,diff(y))

max_delta <- function(y, direction=1){
	token_delta <- delta(y)
	if (direction<0){
		which(token_delta==min(token_delta))
	}else{
		which(token_delta==max(token_delta))
	}
}

find_extrema <- function(y){
	extrema <- c(diff(delta(y) / abs(delta(y))), 0)
	extrema[is.na(extrema)] <- 0
	-extrema/2
}

contiguousequal <- function(data, value, position) {
    if(data[position] != value)
    	return(rep(FALSE, length(data)))
    id <- cumsum(c(1, as.numeric(diff(data) != 0)))
    id == id[position]
}

find_max <- function(y){
	as.numeric(y==max(y, na.rm=T))
}

find_many_extrema <- function(data, local=FALSE){
	require(reshape2)
	if (local){
		extrema <- t(apply(data, 1, find_extrema))
	}else{
		extrema <- t(apply(data, 1, find_max))
		colnames(extrema) <- colnames(data)
	}
	the_extrema <- melt(extrema)
	the_extrema <- the_extrema[the_extrema[,3]==1,1:2]
	data.frame(time=as.numeric(the_extrema[,1]), frequency=as.numeric(the_extrema[,2]))
}

find_extrema_plus <- function(data){
	require(reshape2)
	extrema <- t(apply(data, 1, find_extrema))
	the_extrema <- melt(extrema)
	names(the_extrema) <- c('time','frequency','extreme')
	the_extrema$energy <- melt(data)$value
	the_extrema <- the_extrema[the_extrema[,3]!=0,]
	the_extrema <- the_extrema[order(the_extrema$time),]

	the_extrema$prominence <- NA
	the_extrema$prominence_slice_relative <- NA
	the_extrema$prominence_clip_relative <- NA
	the_extrema$prominence_rank <- NA
	clip_energy <- mean(aggregate(energy ~ time, FUN=max, the_extrema)[,2])

	for (tt in unique(the_extrema$time)){
		test_vector <- the_extrema[the_extrema$time==tt,]
		test_vector$prominence <- 0
		for(i in which(test_vector$extreme>0)){
			peak_domain <- which(contiguousequal(test_vector$energy<=test_vector$energy[i]|test_vector$extreme<0, 1, i))
			#print(i)
			#print(peak_domain)
			south_peak_domain <- peak_domain[peak_domain<=i]
			north_peak_domain <- peak_domain[peak_domain>=i]
			#print(test_vector$energy[north_peak_domain])
			south_prominence <- diff(range(test_vector$energy[south_peak_domain]))
			north_prominence <- diff(range(test_vector$energy[north_peak_domain]))
			test_vector[i,]$prominence <- min(south_prominence, north_prominence)
		}
		the_extrema[the_extrema$time==tt,]$prominence <- test_vector$prominence
		the_extrema[the_extrema$time==tt,]$prominence_slice_relative <- test_vector$prominence / diff(range(test_vector$energy, na.rm=T))
		the_extrema[the_extrema$time==tt,]$prominence_clip_relative <- test_vector$prominence / clip_energy
		the_extrema[the_extrema$time==tt,]$prominence_rank <- rank(-test_vector$prominence)
		#the_extrema[the_extrema$time==tt&the_extrema$extreme<0,]$prominence_rank <- NA
	}
	the_extrema
}


smooth_multitaper <- function(data, span="cv", bass=0){
	datasmoothed <- c()
	for (i in 1:nrow(data)){
		datasmoothed <- rbind(datasmoothed, supsmu(1:ncol(data),data[i,], span=span, bass=bass)$y)
	}
	rownames(datasmoothed) <- rownames(data)
	colnames(datasmoothed) <- colnames(data)
	datasmoothed
}

plot_formant_trajectories <- function(data, formants=c('F1','F2','F3'), xlim=c(3,19), ylim=c(0,2000)){
  data$word=factor(data$word)
  word_colors = rainbow(length(levels(data$word)),v=0.6)
  plot(0,0,type='n',xlim=xlim,ylim=ylim)
  for (r in 1:nrow(data)){
    formants_long = long_format_formants(data[r,])
    formants_long = subset(formants_long, x%in%c(3:19))
    for (f in formants){
    	print(f)
    	print(formants_long[,f])
      points(formants_long$x, formants_long[,f], type='l', col=word_colors[as.numeric(data[r,'word'])])
    }
  }
  legend('topright', levels(data$word), lty=1, col=word_colors)
}