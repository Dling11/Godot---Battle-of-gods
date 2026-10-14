extends "res://tools/build_iron_reaper_audio.gd"

## Add one quiet looping layer; never rewrite the seven approved recordings.
func _initialize() -> void:
	sample_rate = 44100
	DirAccess.make_dir_recursive_absolute("res://tmp/review/iron_reaper_spin_2026_10_14/")
	var loop := PackedFloat32Array()
	loop.resize(roundi(sample_rate*0.30))
	_wrapped_grain(loop,_swish("swish-6.wav"),0,0.82,0.9)
	_wrapped_grain(loop,_swish("swish-9.wav"),loop.size()/2,0.90,0.72)
	var metal := decode("qubodupImpactMetal.ogg")
	# Only a low-level late rustle; omit the recorded metal strike transient.
	metal = metal.slice(mini(2205,metal.size()/3),mini(7938,metal.size()))
	_wrapped_grain(loop,metal,loop.size()/4,1.05,0.045)
	_wrapped_grain(loop,metal,loop.size()*3/4,1.13,0.035)
	var low := 0.0
	var mean := 0.0
	# Warm the offline filter over a full cycle so the loop boundary matches.
	for pass_index in 2:
		for index in loop.size():
			low = lerpf(low,loop[index],0.24)
			if pass_index==1: loop[index] = low
	for value in loop: mean+=value/loop.size()
	for index in loop.size(): loop[index]-=mean
	var peak := 0.0
	for value in loop: peak=maxf(peak,absf(value))
	assert(peak>0.001)
	for index in loop.size(): loop[index]=loop[index]/peak*0.63
	write_wav(SCYTHE_OUTPUT+"spin.wav",loop)
	var audition := PackedFloat32Array()
	audition.resize(sample_rate*3)
	# The actual attack mix: launch, quiet moving spin, then catch silence.
	var launch := normalize(_edit(_swish("swish-6.wav"),0.95,0.28))
	_mix_at(audition,launch,0.25,db_to_linear(-10))
	for index in roundi(sample_rate*0.90):
		var progress := float(index)/(sample_rate*0.90)
		var gain_db := lerpf(-42,-24,minf(progress/0.12,1)) if progress<0.70 else lerpf(-24,-52,(progress-0.70)/0.30)
		audition[roundi(sample_rate*0.25)+index] += loop[index%loop.size()]*db_to_linear(gain_db)
	write_wav("res://tmp/review/iron_reaper_spin_2026_10_14/spin-audition.wav",audition)
	var manifest := {"source":"Retained artisticdude CC0 swish-6/9 plus very quiet late qubodup CC0 metal rustle; approved audio unchanged","source_urls":["https://opengameart.org/content/swishes-sound-pack","https://opengameart.org/content/impact"],"processing":"Offline two alternating windowed air grains, very quiet late metal tail, cyclic low-pass, DC removal; PCM16 mono44100; no runtime DSP","duration":0.30,"peak_dbfs":linear_to_db(0.63),"seam_step":absf(loop[0]-loop[-1]),"runtime_peak_volume_db":-24,"runtime_sha256":FileAccess.get_sha256(SCYTHE_OUTPUT+"spin.wav")}
	FileAccess.open(SCYTHE_SOURCE+"spin-manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("IRON_REAPER_SPIN_AUDIO: ",JSON.stringify(manifest))
	quit()

func _wrapped_grain(destination: PackedFloat32Array,data: PackedFloat32Array,start: int,pitch: float,gain: float) -> void:
	var count := ceili(data.size()/pitch)
	for index in count:
		var point := index*pitch
		var first := mini(floori(point),data.size()-1)
		var window := pow(sin(PI*float(index)/maxi(1,count-1)),2)
		destination[(start+index)%destination.size()] += lerpf(data[first],data[mini(first+1,data.size()-1)],point-first)*window*gain
