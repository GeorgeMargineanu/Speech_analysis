				########################
				#Silent period detector#
				########################

form Sound Analysis
	comment What is the python directory?
	text directory_python C:\Users\georg\Desktop\try\.idea
	comment What is the folder with audio files?
	text directory C:\Users\georg\Desktop\audioFiles\SEPHR_200206_115505\
endform



#directory_python$ = "C:\Users\georg\Desktop\try\.idea"
runSystem: "py ", directory_python$, "\praat.py"

#directory$ = "C:\Users\georg\Desktop\audioFiles\SEPHR_200206_115505\"
strings = Create Strings as file list: "list_sound", directory$ + "*.flac"
strings_text = Create Strings as file list: "list_text", directory$ + "*.txt"
numberOfFiles = Get number of strings

for ifile to numberOfFiles
    selectObject: strings
    fileName$ = Get string: ifile
	appendInfoLine: fileName$
fileName_without_extention$ = fileName$ - ".flac"

#path_text$ = "C:\Users\georg\Desktop\audioFiles\SEPHR_200206_115505\'fileName_without_extention$'.txt"
path_text$ = directory$ + fileName_without_extention$ + ".txt"

Read Strings from raw text file: path_text$
numberOfStrings = Get number of strings
for stringNumber from 1 to numberOfStrings
	string$ = Get string: stringNumber
	time[stringNumber] = number(string$)
endfor

hour = time[1]
minute = time[2]
second = time[3]
frequency = time[4]

@isDigit: hour, "hh$"
@isDigit: minute, "mm$"
@isDigit: second, "ss$"


path$ = directory$ + fileName$
#sound = Read from file: path$
sound = Read from file: path$
sound$ = selected$("Sound")

frequency$ = string$(frequency)

outputFileName$ = fixed$(frequency,3)  + ".csv"

#deletes previous csv
deleteFile: outputFileName$

#appendFileLine: outputFileName$,"starting time of the simulation" , ";" ,hh$, ":", mm$, ":",ss$
initial_time = hour * 3600 + minute * 60 + second

numOfChannels = 2
Extract all channels
soundsList = Create Strings as file list: "audioList", "*.flac" 

writeInfoLine:"number of channels = 2 "

for i from 1 to numOfChannels
	addString$ [i] = "_ch" + "'i'"  
endfor
period_of_sounding = 0

channel_index$ = ""
for i from 1 to numOfChannels

	if (i == 1 ) 
	channel_index$ = "LEFT"
	else
	 channel_index$ = "RIGHT"
	endif

	channel$ = fileName_without_extention$ + addString$[i]
	#CHANNEL SELECTION
	selectObject: "Sound 'channel$'" 

	silences = To TextGrid (silences): 100, 0, -50, 0.4, 0.4, "silence", "sounding"
	selectObject: silences
	number_of_intervals = Get number of intervals... 1
	#appendInfoLine: "Number_of_intervals",";", number_of_intervals, newline$

	#write to file
	#appendFileLine: outputFileName$ ,"Number_of_intervals for channel 'i' ",";", number_of_intervals
	#appendFileLine: outputFileName$ , "frequency" ,";", "channel" , ";", "starting time", ";", "ending time", ";", "duration"

	period_of_silence = 0
	
	index_silence = 0
	index_sounding = 0

	for k from 1 to number_of_intervals
		selectObject = silences
		seg_label$ = Get label of interval... 1 k
		seg_start = Get starting point... 1 k
		seg_end = Get end point... 1 k
	
		#Cut a bit b4 and after??????
		start = seg_start 
		end = seg_end 
		
		if (seg_label$ <> "silence")
			#appendFileLine:directory$+ outputFileName$, seg_label$, ";" ,fixed$ (seg_start, 2), ";" , fixed$ (seg_end, 2)
		endif

		if (seg_label$ <> "silence")

			period_of_sounding = period_of_sounding + (end - start)
			index_sounding = index_sounding + 1

			start_time = initial_time + seg_start
			start_hours = start_time div 3600			
			start_minutes = (start_time - start_hours * 3600) div 60
			start_seconds = (start_time - start_hours * 3600) mod 60
			
			end_time = initial_time + seg_end
			end_hours = end_time div 3600
			end_minutes = (end_time - end_hours * 3600) div 60
			end_seconds = (end_time - end_hours * 3600) mod 60

			round_s_h =  round(start_hours)
			round_s_m = round(start_minutes)
			round_s_s = round(start_seconds)

			round_e_h =  round(end_hours)
			round_e_m = round(end_minutes)
			round_e_s = round(end_seconds)

			if round_s_s == 60 
				round_s_s = 0
				round_s_m = round_s_m + 1
			endif

			if round_s_m == 60 
				round_s_m = 0
				round_s_h = round_s_h + 1
			endif

			if round_e_s == 60 
				round_e_s = 0
				round_e_m = round_e_m + 1
			endif

			if round_e_m == 60 
				round_e_m = 0
				round_e_h = round_e_h + 1
			endif

			@midnight: round_s_h, "mid_s_hour"
			@midnight: round_e_h, "mid_e_hour"

			@isDigit: mid_s_hour, "sh$"
			@isDigit: round_s_m, "sm$"
			@isDigit: round_s_s, "ss$"

			@isDigit: mid_e_hour, "eh$"
			@isDigit: round_e_m, "em$"
			@isDigit: round_e_s, "es$"

			appendInfoLine:  sh$ ,":", sm$,":", ss$ ," --> ",eh$, ":", em$ ,":", es$,tab$, fixed$(end - start,2)
			appendFileLine:directory$ + outputFileName$, fixed$(frequency,3) ,";",channel_index$, ";" ,sh$ ,":", sm$,":", ss$ , ";" ,eh$, ":", em$ ,":", es$,tab$, ";", fixed$(end - start,2)
	
		endif	
		
		else 
				period_of_silence = period_of_silence + (end - start)
				index_silence = index_silence + 1
				
		endif
	endfor
	
	#aici poate am gresit
	selectObject: silences, "Sound 'fileName_without_extention$'"
	#View & Edit
	removeObject: silences
	removeObject: "Sound 'channel$'"
	
	#selectObject: "Sound 'channel$'" 
	total_duration = Get total duration
	#occupancy = index_sounding / total_duration *100

	#appendInfoLine:newline$, "no. of silent intervals: " , index_silence
	appendInfoLine: "no. of sounding intervals: ", index_sounding

	#appendInfoLine:newline$, "period of silence", tab$, period_of_silence
	appendInfoLine: "period of sounding", tab$, fixed$(period_of_sounding,3), newline$


endfor

procedure isDigit: .number, .result$
	if .number <= 9 
	.numbers$ = string$(.number)	
    	'.result$' = "0" + .numbers$
	else
	'.result$' = string$(.number)
	endif
endproc

procedure midnight: .number, .result$
	if .number >= 24 
	'.result$' = .number - 24
	else
	'.result$' = .number 
	endif
endproc

	#R/T occupancy
	occupancy = period_of_sounding / total_duration * 100
	appendFileLine:path_text$, newline$, "R/T occupancy ", fixed$(occupancy,3), " %"
endfor

#Extract sounding periods as sound files
# for k from 1 to number_of_intervals
# 	    selectObject: silences

#                 seg_label$ = Get label of interval... 1 'k'
#               seg_start = Get starting point... 1 'k'
#                 seg_end = Get end point... 1 'k'
#                 # Cut a bit before and after - 0.025
#                 start = seg_start + 0.025
#                 end = seg_end 
                             
# 		  if seg_label$ <> "silence"
                         
#                                 # Now we select the sound
#                                 select Sound 'sound$'
#                                 # We extract
#                                 #Extract part: seg_start, seg_end, "rectangular", 1, "no" 
# 		endif
# endfor








