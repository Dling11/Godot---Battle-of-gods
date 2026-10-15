extends "res://tools/build_iron_reaper_audio.gd"

## Recorded material/air identity matched to the accepted scythe mix.
## Outputs belong only to the axe; other weapon recordings remain untouched.
const AXE_OUTPUT := "res://assets/audio/sfx/player/iron_beard/"
const AXE_SOURCE := "res://art_source/generated/characters/king/iron_beard_unified_2026_10_15/"
const AXE_REVIEW := "res://tmp/review/iron_beard_unified_2026_10_15/"

func _initialize() -> void:
	sample_rate = 44100
	DirAccess.make_dir_recursive_absolute(AXE_OUTPUT)
	var clips: Dictionary = {}
	for entry in [["chop","swish-7.wav",0.88,0.22],["rise","swish-9.wav",1.05,0.19],["push","swish-10.wav",0.85,0.21],["slam","swish-8.wav",0.70,0.25]]:
		clips[entry[0]] = normalize(_edit(_swish(entry[1]),entry[2],entry[3]))
	var spin := PackedFloat32Array()
	spin.resize(roundi(sample_rate*0.29))
	_mix_at(spin,normalize(_edit(_swish("swish-6.wav"),1.0,0.15)),0,0.65)
	_mix_at(spin,normalize(_edit(_swish("swish-9.wav"),1.2,0.15)),0.12,0.50)
	clips.spin = normalize(spin)
	var meat := decode("qubodupImpactMeat01.ogg")
	var other := decode("qubodupImpactMeat02.ogg")
	var wood := decode("qubodupImpactWood.ogg")
	var stone := decode("qubodupImpactStone.ogg")
	clips.contact_1 = normalize(_blend([meat,wood],[0.70,0.30]))
	clips.contact_2 = normalize(_blend([other,wood],[0.75,0.25]))
	clips.contact_3 = normalize(_blend([meat,other,wood],[0.35,0.35,0.30]))
	clips.slam_contact = normalize(_blend([other,wood,stone],[0.55,0.25,0.35]))
	var manifest := {"license":"CC0","sources":["artisticdude Swishes Sound Pack; retained iron_reaper_2026_10_14 archive","Iwan qubodup Gabovitch Impact; retained weapon_contact_2026_10_06 archive"],"processing":"offline recording trim/time-pitch resample, air doublet for spin, body/wood contacts and stone-supported slam; mono PCM16 44100Hz; normalized -4dBFS; no runtime DSP","clips":[]}
	for name_key: String in clips:
		var data: PackedFloat32Array = clips[name_key]
		write_wav(AXE_OUTPUT+name_key+".wav",data)
		manifest.clips.append({"file":name_key+".wav","seconds":float(data.size())/sample_rate,"sha256":FileAccess.get_sha256(AXE_OUTPUT+name_key+".wav")})
	FileAccess.open(AXE_SOURCE+"audio-manifest.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t")+"\n")
	var audition := PackedFloat32Array()
	audition.resize(sample_rate*4)
	for index in 5:
		_mix_at(audition,clips[["chop","rise","push","slam","spin"][index]],0.15+index*0.70,db_to_linear(-10))
		_mix_at(audition,clips.slam_contact if index==3 else clips["contact_%d"%(index%3+1)],0.18+index*0.70,db_to_linear(-4 if index==3 else -5))
	write_wav(AXE_REVIEW+"axe-audio-audition.wav",audition)
	print("AXE_UNIFIED_AUDIO clips=9; approved scythe recordings untouched")
	quit()
