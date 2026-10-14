extends "res://tools/build_weapon_contact_audio.gd"

## Offline CC0 recording edits. Gameplay emits one cue per cut/contact;
## no per-frame audio, new synthesis or per-enemy stacking.
const SCYTHE_SOURCE := "res://art_source/audio/iron_reaper_2026_10_14/"
const SCYTHE_OUTPUT := "res://assets/audio/sfx/player/iron_reaper/"
const SCYTHE_REVIEW := "res://tmp/review/iron_reaper_cadence_2026_10_14/"

func _initialize() -> void:
	sample_rate = 44100
	DirAccess.make_dir_recursive_absolute(SCYTHE_OUTPUT)
	DirAccess.make_dir_recursive_absolute(SCYTHE_REVIEW)
	var air: Array[PackedFloat32Array] = []
	# Different recorded attacks, shorter sharp cuts and a low broad final reap.
	for entry in [["swish-7.wav",1.15,0.20],["swish-9.wav",1.25,0.20],["swish-6.wav",0.95,0.28],["swish-8.wav",0.88,0.28]]:
		air.append(normalize(_edit(_swish(entry[0]),entry[1],entry[2])))
	var meat_one := decode("qubodupImpactMeat01.ogg")
	var meat_two := decode("qubodupImpactMeat02.ogg")
	var wood := decode("qubodupImpactWood.ogg")
	var stone := decode("qubodupImpactStone.ogg")
	var hits: Array[PackedFloat32Array] = [normalize(_blend([meat_one,wood],[0.85,0.15])),normalize(_blend([meat_two,wood],[0.85,0.15]))]
	var reap := normalize(_blend([meat_two,wood,stone],[0.65,0.20,0.30]))
	var names := ["sweep","hook","throw","reap"]
	var manifest := {"rate":sample_rate,"format":"mono PCM16","swing_source":"Swishes Sound Pack by artisticdude, CC0","source_url":"https://opengameart.org/content/swishes-sound-pack","source_archive_sha256":FileAccess.get_sha256(SCYTHE_SOURCE+"swishes.zip"),"contact_source":"Impact by Iwan qubodup Gabovitch, CC0; retained weapon_contact_2026_10_06 pack","processing":"Trim silence; offline pitch/time resample and bounded smooth tails; normal 85% meat/15% wood; final 65% Meat02/20% wood/30% stone; normalized -4dBFS; no runtime DSP","clips":[]}
	for index in air.size(): _publish(names[index]+".wav",air[index],manifest)
	for index in hits.size(): _publish("contact_%d.wav"%(index+1),hits[index],manifest)
	_publish("reap_contact.wav",reap,manifest)
	var audition := PackedFloat32Array()
	audition.resize(sample_rate*4)
	for index in air.size():
		_mix_at(audition,air[index],0.15+index*0.85,db_to_linear(-10))
		_mix_at(audition,reap if index==3 else hits[index%2],0.18+index*0.85,db_to_linear(-5))
	write_wav(SCYTHE_REVIEW+"iron-reaper-audio-audition.wav",audition)
	FileAccess.open(SCYTHE_SOURCE+"manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("IRON_REAPER_AUDIO clips=7 peak=-4dBFS; source recordings CC0; audition isolated from live speaker review")
	quit()

func _swish(name_key: String) -> PackedFloat32Array:
	var stream := AudioStreamWAV.load_from_file(SCYTHE_SOURCE+"swishes/swishes/"+name_key)
	assert(stream!=null)
	var playback := stream.instantiate_playback()
	playback.start()
	var stereo := playback.mix_audio(1.0,ceili(stream.get_length()*sample_rate)+512)
	playback.stop()
	var data := PackedFloat32Array()
	for frame in stereo: data.append((frame.x+frame.y)*0.5)
	var first := 0
	var last := data.size()-1
	while first<last and absf(data[first])<0.004: first+=1
	while last>first and absf(data[last])<0.002: last-=1
	return data.slice(maxi(0,first-44),mini(data.size(),last+441))

func _edit(data: PackedFloat32Array,pitch: float,seconds: float) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	result.resize(mini(ceili(data.size()/pitch),roundi(seconds*sample_rate)))
	for index in result.size():
		var point := index*pitch
		var low := mini(floori(point),data.size()-1)
		var fade := minf(1.0,float(index)/88.0)*minf(1.0,float(result.size()-index)/882.0)
		result[index] = lerpf(data[low],data[mini(low+1,data.size()-1)],point-low)*fade
	return result

func _blend(clips: Array,weights: Array) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	for clip in clips: result.resize(maxi(result.size(),clip.size()))
	for index in result.size():
		for part in clips.size():
			if index<clips[part].size(): result[index] += clips[part][index]*weights[part]
	return result

func _mix_at(destination: PackedFloat32Array,clip: PackedFloat32Array,seconds: float,gain: float) -> void:
	var start := roundi(seconds*sample_rate)
	for index in mini(clip.size(),destination.size()-start): destination[start+index]+=clip[index]*gain

func _publish(name_key: String,data: PackedFloat32Array,manifest: Dictionary) -> void:
	write_wav(SCYTHE_OUTPUT+name_key,data)
	var peak := 0.0
	var energy := 0.0
	for value in data:
		peak = maxf(peak,absf(value))
		energy += value*value
	manifest.clips.append({"file":name_key,"duration":float(data.size())/sample_rate,"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/data.size())),"sha256":FileAccess.get_sha256(SCYTHE_OUTPUT+name_key)})
