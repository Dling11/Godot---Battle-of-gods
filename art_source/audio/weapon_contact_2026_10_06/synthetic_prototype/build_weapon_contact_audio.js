// Original seeded contact SFX. Dry broadband crack + damped body, no pitched
// metallic ring or downloaded material. Reproducible PCM; no runtime synthesis.
const fs = require('fs');
const path = require('path');
const output = path.join(__dirname, '../assets/audio/sfx/player/weapon_contact');
const review = path.join(__dirname, '../art_source/review/combat/weapon_finalize_2026_10_06');
fs.mkdirSync(output, {recursive: true});
fs.mkdirSync(review, {recursive: true});
const rate = 44100;
const stats = [];
function wav(data) {
  const file = Buffer.alloc(44 + data.length * 2);
  file.write('RIFF'); file.writeUInt32LE(file.length-8,4); file.write('WAVEfmt ',8);
  file.writeUInt32LE(16,16); file.writeUInt16LE(1,20); file.writeUInt16LE(1,22);
  file.writeUInt32LE(rate,24); file.writeUInt32LE(rate*2,28);
  file.writeUInt16LE(2,32); file.writeUInt16LE(16,34); file.write('data',36);
  file.writeUInt32LE(data.length*2,40);
  data.forEach((value,index)=>file.writeInt16LE(Math.round(value*32767),44+index*2));
  return file;
}
const clips = [];
for (let variant=0; variant<3; variant++) {
  let seed=7106+variant*901, low=0, mid=0, dc=0, peak=0;
  const length=.18+variant*.015;
  const data=new Float64Array(Math.ceil(rate*length));
  for(let i=0;i<data.length;i++) {
    seed=(Math.imul(seed,1664525)+1013904223)>>>0;
    const noise=seed/2147483648-1, t=i/rate;
    low+=(noise-low)*.022; mid+=(noise-mid)*.28;
    const crack=(mid-low)*Math.exp(-75*t)*.85;
    const body=low*Math.exp(-22*t)*2.8;
    const thud=Math.sin(2*Math.PI*((100-variant*9)*t+1.1*(1-Math.exp(-25*t))))*Math.exp(-38*t)*.13;
    const scuff=(noise-mid)*Math.exp(-42*t)*.09;
    let value=(crack+body+thud+scuff)*Math.min(1,t/.0007)*Math.min(1,(length-t)/.022);
    dc+=(value-dc)*.004; value-=dc;
    data[i]=value; peak=Math.max(peak,Math.abs(value));
  }
  let energy=0;
  for(let i=0;i<data.length;i++){ data[i]=data[i]/peak*.63; energy+=data[i]*data[i]; }
  clips.push(data);
  const name=`contact_${variant+1}.wav`;
  fs.writeFileSync(path.join(output,name),wav(data));
  stats.push({name,duration:data.length/rate,peak_dbfs:20*Math.log10(.63),rms_dbfs:20*Math.log10(Math.sqrt(energy/data.length))});
}
// Audition the same core at the actual family pitches and volumes, with gaps.
for(const [family,pitch,db] of [['sword',1,-6],['axe',.82,-4],['dual',1.14,-8]]) {
  const data=new Float64Array(rate*2);
  clips.forEach((clip,index)=>{
    for(let i=0;i<clip.length/pitch;i++) {
      const sample=i*pitch, lo=Math.floor(sample), mix=sample-lo;
      data[Math.round(rate*(.15+index*.52))+i]=((clip[lo]||0)*(1-mix)+(clip[lo+1]||0)*mix)*Math.pow(10,db/20);
    }
  });
  fs.writeFileSync(path.join(review,`${family}_impacts.wav`),wav(data));
}
fs.writeFileSync(path.join(review,'audio_manifest.json'),JSON.stringify({rate,format:'mono PCM16',provenance:'original deterministic synthesis',clips:stats},null,2));
console.log(JSON.stringify(stats));
