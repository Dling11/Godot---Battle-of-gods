extends "res://tools/build_iron_reaper_spin_audio.gd"

## Dedicated edits of retained CC0 recordings; no changes to other families.
const CYCLONE_OUTPUT := "res://assets/audio/sfx/abilities/weapons/war_cyclone/"

func _initialize() -> void:
	sample_rate = 44100
	DirAccess.make_dir_recursive_absolute(CYCLONE_OUTPUT)
	DirAccess.make_dir_recursive_absolute("res://tmp/review/cyclone_refine/")
	var spin := PackedFloat32Array()
	spin.resize(roundi(sample_rate*.40))
	_wrapped_grain(spin,_swish("swish-6.wav"),0,.72,.75)
	_wrapped_grain(spin,_swish("swish-9.wav"),spin.size()/2,.82,.65)
	var metal := decode("qubodupImpactMetal.ogg")
	_wrapped_grain(spin,metal.slice(2205,mini(7938,metal.size())),spin.size()/4,.88,.06)
	var low := 0.0
	for pass_index in 2:
		for index in spin.size():
			low = lerpf(low,spin[index],.22)
			if pass_index==1: spin[index] = low
	var mean := 0.0
	for value in spin: mean += value/spin.size()
	for index in spin.size(): spin[index] -= mean
	var peak := 0.0
	for value in spin: peak=maxf(peak,absf(value))
	for index in spin.size(): spin[index]=spin[index]/maxf(peak,.001)*.63
	var start := normalize(_edit(_swish("swish-7.wav"),.92,.24))
	var finish := normalize(_blend([_edit(_swish("swish-8.wav"),.85,.23),_edit(metal,.85,.22)],[.70,.13]))
	var clips := {"spin.wav":spin,"start.wav":start,"finish.wav":finish}
	var manifest := {"sources":["Swishes Sound Pack by artisticdude, CC0","Impact by Iwan qubodup Gabovitch, CC0"],"urls":["https://opengameart.org/content/swishes-sound-pack","https://opengameart.org/content/impact"],"processing":"Retained recorded air/late metal. Offline resample, grains, DC removal, cyclic lowpass, fades and peak normalization. PCM16 mono44100. No runtime DSP.","loop_seam":absf(spin[0]-spin[-1]),"files":[]}
	for file in clips:
		write_wav(CYCLONE_OUTPUT+file,clips[file])
		manifest.files.append({"path":CYCLONE_OUTPUT+file,"sha256":FileAccess.get_sha256(CYCLONE_OUTPUT+file),"seconds":float(clips[file].size())/sample_rate})
	FileAccess.open("res://tmp/review/cyclone_refine/audio-manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"  "))
	print("CYCLONE_AUDIO ",JSON.stringify(manifest))
	quit()
