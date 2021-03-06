/datum/round_event_control/supernova
	name = "Supernova"
	typepath = /datum/round_event/supernova
	weight = 10
	max_occurrences = 2
	min_players = 2

/datum/round_event/supernova
	announceWhen = 40
	startWhen = 1
	endWhen = 300
	var/power = 1
	var/datum/sun/supernova
	var/storm_count = 0

/datum/round_event/supernova/setup()
	announceWhen = rand(4, 60)
	supernova = new
	SSsun.suns += supernova
	if(prob(50))
		power = rand(5,100) / 100
	else
		power = rand(5,5000) / 100
	supernova.azimuth = rand(0, 359)
	supernova.power_mod = 0

/datum/round_event/supernova/announce()
	var/message = "Our tachyon-doppler array has detected a supernova in your vicinity. Peak flux from the supernova estimated to be [round(power,0.1)] times current solar flux. [power > 4 ? "Short burts of radiation may be possible, so please prepare accordingly." : ""]"
	if(prob(power * 25))
		priority_announce(message)
	else
		print_command_report(message)


/datum/round_event/supernova/start()
	supernova.power_mod = 0.00000002 * power
	var/explosion_size = rand(1000000000, 999999999)
	var/turf/epicenter = get_turf_in_angle(supernova.azimuth, SSmapping.get_station_center(), world.maxx / 2)
	for(var/array in GLOB.doppler_arrays)
		var/obj/machinery/doppler_array/A = array
		A.sense_explosion(epicenter, explosion_size/2, explosion_size, 0, 107000000 / power, explosion_size/2, explosion_size, 0)
	if(power > 1 && SSticker.mode.bloodsucker_sunlight?.time_til_cycle > 90)
		var/obj/effect/sunlight/sucker_light = SSticker.mode.bloodsucker_sunlight
		sucker_light.time_til_cycle = 90
		sucker_light.warn_daylight(1,"<span class = 'danger'>A supernova will bombard the station with dangerous UV in [90 / 60] minutes. <b>Prepare to seek cover in a coffin or closet.</b></span>")
		sucker_light.give_home_power()

/datum/round_event/supernova/tick()
	var/midpoint = (endWhen-startWhen)/2
	switch(activeFor)
		if(startWhen to midpoint)
			supernova.power_mod = min(supernova.power_mod*1.2, power)
		if(endWhen-10 to endWhen)
			supernova.power_mod /= 4
	if(prob(round(supernova.power_mod / 2)) && storm_count < 3 && !SSweather.get_weather_by_type(/datum/weather/rad_storm))
		SSweather.run_weather(/datum/weather/rad_storm/supernova)
		storm_count++

/datum/round_event/supernova/end()
	SSsun.suns -= supernova
	qdel(supernova)

/datum/weather/rad_storm/supernova
	weather_duration_lower = 50
	weather_duration_lower = 100
	telegraph_duration = 100
	radiation_intensity = 50
