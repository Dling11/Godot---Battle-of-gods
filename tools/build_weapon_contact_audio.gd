extends SceneTree

## Offline decode/registration of CC0 body-impact recordings by qubodup.
## No runtime DSP, remote download or audio dependency. Retains original pack.
const SOURCE := "res://art_source/audio/weapon_contact_2026_10_06/qubodupImpact/qubodupImpact/"
const OUTPUT := "res://assets/audio/sfx/player/weapon_contact/"
const REVIEW := "res://tmp/review/combat/weapon_finalize_2026_10_06/"
var sample_rate := 44100

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/review/combat/weapon_finalize_2026_10_06/"))
	sample_rate = roundi(AudioServer.get_mix_rate())
	var first := decode("qubodupImpactMeat01.ogg")
	var second := decode("qubodupImpactMeat02.ogg")
	var blended := PackedFloat32Array()
	blended.resize(maxi(first.size(),second.size()))
	for i in blended.size():
		blended[i] = (first[i] if i<first.size() else 0.0)*0.4 + (second[i] if i<second.size() else 0.0)*0.6
	var clips: Array[PackedFloat32Array] = [normalize(first),normalize(second),normalize(blended)]
	var stats: Array[Dictionary] = []
	for i in clips.size():
		var data := clips[i]
		write_wav(OUTPUT+"contact_%d.wav"%(i+1),data)
		var energy := 0.0
		var peak := 0.0
		for value in data:
			peak=maxf(peak,absf(value))
			energy+=value*value
		stats.append({"file":"contact_%d.wav"%(i+1),"duration":float(data.size())/sample_rate,"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/maxi(1,data.size())))})
	for row in [["sword",1.0,-6.0],["axe",0.82,-4.0],["dual",1.14,-8.0]]:
		var preview := PackedFloat32Array()
		preview.resize(sample_rate*3)
		for index in clips.size():
			var pitch: float = row[1] * [1.0,0.97,1.03][index]
			var clip := clips[index]
			for i in ceili(clip.size()/pitch):
				var sample := i*pitch
				var a := floori(sample)
				var b := mini(a+1,clip.size()-1)
				preview[roundi(sample_rate*(0.15+index*0.85))+i] = lerpf(clip[mini(a,clip.size()-1)],clip[b],sample-a)*db_to_linear(row[2])
		write_wav(REVIEW+row[0]+"_impacts.wav",preview)
	FileAccess.open(REVIEW+"audio_manifest.json",FileAccess.WRITE).store_string(JSON.stringify({"source":"Impact by Iwan qubodup Gabovitch","url":"https://opengameart.org/content/impact","license":"CC0 1.0","rate":sample_rate,"format":"mono PCM16","processing":"trim near silence; mono; third variation 40/60 blend; peak normalize -4dBFS; short fade; family pitch/gain at playback","source_archive_sha256":FileAccess.get_sha256("res://art_source/audio/weapon_contact_2026_10_06/qubodupImpact.7z"),"clips":stats},"\t"))
	print("RECORDED_WEAPON_CONTACT: "+JSON.stringify(stats))
	quit()

func decode(name_key: String) -> PackedFloat32Array:
	var stream := AudioStreamOggVorbis.load_from_file(SOURCE+name_key)
	assert(stream!=null)
	var playback := stream.instantiate_playback()
	playback.start()
	var stereo := playback.mix_audio(1.0,ceili(stream.get_length()*sample_rate)+512)
	playback.stop()
	var values := PackedFloat32Array()
	for frame in stereo: values.append((frame.x+frame.y)*0.5)
	var start := 0
	var end := values.size()-1
	while start<end and absf(values[start])<0.002: start+=1
	while end>start and absf(values[end])<0.001: end-=1
	start=maxi(0,start-roundi(sample_rate*0.001))
	end=mini(values.size(),end+roundi(sample_rate*0.012))
	assert(end>start and float(end-start)/sample_rate<0.65,"Unexpected long or silent impact")
	return values.slice(start,end)

func normalize(values: PackedFloat32Array) -> PackedFloat32Array:
	var peak := 0.0
	for i in values.size():
		var fade := minf(1.0,float(values.size()-i)/maxi(1,roundi(sample_rate*0.012)))
		values[i]*=fade
		peak=maxf(peak,absf(values[i]))
	assert(peak>0.001)
	for i in values.size(): values[i]=values[i]/peak*0.63
	return values

func write_wav(path: String, data: PackedFloat32Array) -> void:
	var pcm := PackedByteArray()
	pcm.resize(data.size()*2)
	for i in data.size(): pcm.encode_s16(i*2,roundi(clampf(data[i],-1.0,1.0)*32767))
	var stream := AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=sample_rate
	stream.stereo=false
	stream.data=pcm
	assert(stream.save_to_wav(path)==OK)
