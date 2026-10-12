extends "res://tools/build_weapon_contact_audio.gd"

## Reuse the retained CC0 pack. Only the new finisher and review audition are
## written; approved sword/axe/dual recordings and all animation remain intact.
const PROOF := "res://tmp/review/combat/weapon_impact_closure_2026_10_07/"

func _initialize() -> void:
	sample_rate = 44100
	var meat := decode("qubodupImpactMeat01.ogg")
	var wood := decode("qubodupImpactWood.ogg")
	var stone := decode("qubodupImpactStone.ogg")
	var smash := PackedFloat32Array()
	smash.resize(maxi(meat.size(),maxi(wood.size(),stone.size())))
	for index in smash.size():
		smash[index] = (meat[index] if index<meat.size() else 0.0)*0.65
		smash[index] += (wood[index] if index<wood.size() else 0.0)*0.20
		smash[index] += (stone[index] if index<stone.size() else 0.0)*0.30
	smash = normalize(smash)
	write_wav(OUTPUT+"greatsword_finisher.wav",smash)
	var audition := PackedFloat32Array()
	audition.resize(sample_rate*4)
	var clips: Array[PackedFloat32Array] = [normalize(decode("qubodupImpactMeat01.ogg")),normalize(decode("qubodupImpactMeat02.ogg"))]
	var blended := PackedFloat32Array()
	blended.resize(maxi(clips[0].size(),clips[1].size()))
	# The existing third contact is normalized after blending the raw originals.
	var raw_first := decode("qubodupImpactMeat01.ogg")
	var raw_second := decode("qubodupImpactMeat02.ogg")
	for index in blended.size():
		blended[index] = (raw_first[index] if index<raw_first.size() else 0.0)*0.4 + (raw_second[index] if index<raw_second.size() else 0.0)*0.6
	clips.append(normalize(blended))
	clips.append(smash)
	for index in clips.size():
		var pitch: float = 0.9 if index==3 else 0.74*[1.0,0.97,1.03][index]
		var clip := clips[index]
		for sample_index in ceili(clip.size()/pitch):
			var sample: float = sample_index*pitch
			var start := mini(floori(sample),clip.size()-1)
			var end := mini(start+1,clip.size()-1)
			audition[roundi(sample_rate*(0.15+index*0.85))+sample_index] = lerpf(clip[start],clip[end],sample-start)*db_to_linear(-4.0)
	DirAccess.make_dir_recursive_absolute(PROOF)
	write_wav(PROOF+"greatsword_impact_audition.wav",audition)
	var energy := 0.0
	var peak := 0.0
	for value in smash:
		peak = maxf(peak,absf(value))
		energy += value*value
	var manifest := {"source":"Impact by Iwan qubodup Gabovitch","license":"CC0 1.0","source_url":"https://opengameart.org/content/impact","source_archive_sha256":FileAccess.get_sha256("res://art_source/audio/weapon_contact_2026_10_06/qubodupImpact.7z"),"processing":"mono PCM16 at 44100Hz; trim/fade; aligned 65% meat + 20% wood + 30% stone mix; normalize peak -4dBFS; no metal sample or runtime DSP","normal":"existing three meat variations, pitch .74, -4dB; one cue per accepted swing","finisher":"new mixed recording, pitch .9, -4dB; fourth cut only; existing floor-contact sound remains separate","duration_seconds":float(smash.size())/sample_rate,"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/smash.size())),"runtime_sha256":FileAccess.get_sha256(OUTPUT+"greatsword_finisher.wav"),"audition":"three normal contacts then jump finisher; this is isolated audition, not live speaker approval"}
	FileAccess.open(PROOF+"audio_manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
	print("GREATSWORD_CONTACT_AUDIO: ",JSON.stringify(manifest))
	quit()
