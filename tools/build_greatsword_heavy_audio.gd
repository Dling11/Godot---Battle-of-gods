extends "res://tools/build_weapon_contact_audio.gd"

## Offline processing of retained CC0 recordings. No runtime DSP or new voices.
const DEST := "res://assets/audio/sfx/player/greatsword_heavy/"
const AUDIT := "res://art_source/audio/greatsword_heavy_2026_10_15/"
const AUDITION := "res://tmp/review/greatsword_polish_2026_10_15/"

func _initialize() -> void:
	sample_rate=44100
	for folder in [DEST,AUDIT,AUDITION]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	FileAccess.open(AUDIT+".gdignore",FileAccess.WRITE).store_string("")
	var metal:=decode("qubodupImpactMetal.ogg")
	var stone:=decode("qubodupImpactStone.ogg")
	var wood:=decode("qubodupImpactWood.ogg")
	var body:=decode("qubodupImpactMeat01.ogg")
	var clips: Array[PackedFloat32Array]=[]
	for pitch in [.70,.74,.67]:
		clips.append(mix_recordings([metal,body,wood],[.76,.46,.22],[pitch,.82,.78],.30))
	clips.append(mix_recordings([metal,stone,wood,body],[.90,.70,.40,.50],[.58,.70,.65,.72],.40))
	clips.append(mix_recordings([metal,stone,wood],[.34,.70,.25],[.64,.76,.76],.27))
	var audition:=PackedFloat32Array()
	audition.resize(sample_rate*5)
	var stats: Array[Dictionary]=[]
	for index in clips.size():
		var name_key: String=["contact_1","contact_2","contact_3","smash","ground"][index]
		var data:=clips[index]
		write_wav(DEST+name_key+".wav",data)
		var energy:=0.0
		var peak:=0.0
		for value in data:
			energy+=value*value
			peak=maxf(peak,absf(value))
		for sample_index in data.size():
			audition[roundi(sample_rate*(.15+index*.90))+sample_index]=data[sample_index]*db_to_linear(-9.0 if index==4 else -5.0)
		stats.append({"file":name_key+".wav","duration":float(data.size())/sample_rate,"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/data.size())),"sha256":FileAccess.get_sha256(DEST+name_key+".wav")})
	write_wav(AUDITION+"heavy-metal-audition.wav",audition)
	var manifest: Dictionary={"source":"Impact by Iwan qubodup Gabovitch","source_url":"https://opengameart.org/content/impact","license":"CC0 1.0","source_archive_sha256":FileAccess.get_sha256("res://art_source/audio/weapon_contact_2026_10_06/qubodupImpact.7z"),"processing":"Recorded metal mixed with body/wood; stronger metal/stone smash; offline resample, damp ring, fade and normalize peak -4dBFS; mono PCM16 44100Hz. Normal -6dB, finisher -4dB, ground -12dB at runtime. No procedural tone or runtime DSP.","clips":stats,"audition":"Three normal cuts, jump smash, then quieter floor debris. Speaker approval pending."}
	FileAccess.open(AUDIT+"manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	print("GREATSWORD_HEAVY_AUDIO ",JSON.stringify(stats))
	quit()

func mix_recordings(sources: Array[PackedFloat32Array],gains: Array,pitches: Array,seconds: float) -> PackedFloat32Array:
	var result:=PackedFloat32Array()
	result.resize(roundi(seconds*sample_rate))
	for source_index in sources.size():
		var recording:=sources[source_index]
		for index in result.size():
			var position: float=index*float(pitches[source_index])
			var start:=floori(position)
			if start>=recording.size(): break
			var value:=lerpf(recording[start],recording[mini(start+1,recording.size()-1)],position-start)
			# Retain a short metallic decay without a long high ringing tail.
			var damp:=exp(-float(index)/sample_rate*(9.0 if source_index==0 else 4.0))
			result[index]+=value*float(gains[source_index])*damp
	return normalize(result)
