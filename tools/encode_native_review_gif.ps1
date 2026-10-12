param(
    [Parameter(Mandatory=$true)][string]$FramesPath,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [int]$Fps = 30,
    [int]$Every = 2
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class NativeReviewGif {
    static byte[] Pixels(Bitmap bitmap) {
        var area = new Rectangle(0,0,bitmap.Width,bitmap.Height);
        var locked = bitmap.LockBits(area,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
        var bytes = new byte[bitmap.Width*bitmap.Height*4];
        for (int y=0;y<bitmap.Height;y++)
            Marshal.Copy(IntPtr.Add(locked.Scan0,y*locked.Stride),bytes,y*bitmap.Width*4,bitmap.Width*4);
        bitmap.UnlockBits(locked);
        return bytes;
    }
    static int RGB(byte[] pixels,int offset) {
        return (pixels[offset+2]<<16)|(pixels[offset+1]<<8)|pixels[offset];
    }
    static void SkipBlocks(byte[] bytes,ref int offset) {
        int size;
        while ((size=bytes[offset++])!=0) offset+=size;
    }
    public static int Encode(string[] files,string output,int fps) {
        if (files.Length==0 || fps<1 || fps>100) throw new ArgumentException("Invalid frames or FPS");
        var histogram = new Dictionary<int,int>();
        for (int sample=0;sample<files.Length;sample+=3) {
            using (var bitmap=new Bitmap(files[sample])) {
                var pixels=Pixels(bitmap);
                for (int offset=0;offset<pixels.Length;offset+=4) {
                    int rgb=RGB(pixels,offset), count;
                    histogram.TryGetValue(rgb,out count);
                    histogram[rgb]=count+1;
                }
            }
        }
        var ordered=new List<KeyValuePair<int,int>>(histogram);
        ordered.Sort((a,b)=>b.Value.CompareTo(a.Value));
        var colors=new List<int>();
        for (int i=0;i<Math.Min(256,ordered.Count);i++) colors.Add(ordered[i].Key);
        var lookup=new Dictionary<int,byte>();
        for (int i=0;i<colors.Count;i++) lookup[colors[i]]=(byte)i;
        using (var writer=new BinaryWriter(File.Create(output))) {
            int width,height;
            using (var first=new Bitmap(files[0])) { width=first.Width; height=first.Height; }
            writer.Write(System.Text.Encoding.ASCII.GetBytes("GIF89a"));
            writer.Write((ushort)width); writer.Write((ushort)height);
            writer.Write((byte)0x70); writer.Write((byte)0); writer.Write((byte)0);
            writer.Write(new byte[]{0x21,0xff,0x0b});
            writer.Write(System.Text.Encoding.ASCII.GetBytes("NETSCAPE2.0"));
            writer.Write(new byte[]{3,1,0,0,0});
            for (int frame=0;frame<files.Length;frame++) {
                byte[] encoded;
                using (var source=new Bitmap(files[frame]))
                using (var indexed=new Bitmap(width,height,PixelFormat.Format8bppIndexed)) {
                    if (source.Width!=width || source.Height!=height) throw new InvalidDataException("Frame size changed");
                    var palette=indexed.Palette;
                    for (int i=0;i<256;i++) {
                        int rgb=colors[Math.Min(i,colors.Count-1)];
                        palette.Entries[i]=Color.FromArgb(255,(rgb>>16)&255,(rgb>>8)&255,rgb&255);
                    }
                    indexed.Palette=palette;
                    var pixels=Pixels(source);
                    var locked=indexed.LockBits(new Rectangle(0,0,width,height),ImageLockMode.WriteOnly,PixelFormat.Format8bppIndexed);
                    var row=new byte[width];
                    for (int y=0;y<height;y++) {
                        for (int x=0;x<width;x++) {
                            int rgb=RGB(pixels,(y*width+x)*4);
                            byte index;
                            if (!lookup.TryGetValue(rgb,out index)) {
                                int best=int.MaxValue;
                                index=0;
                                for (int i=0;i<colors.Count;i++) {
                                    int dr=((rgb>>16)&255)-((colors[i]>>16)&255);
                                    int dg=((rgb>>8)&255)-((colors[i]>>8)&255);
                                    int db=(rgb&255)-(colors[i]&255);
                                    int score=dr*dr+dg*dg+db*db;
                                    if (score<best) { best=score; index=(byte)i; }
                                }
                                lookup[rgb]=index;
                            }
                            row[x]=index;
                        }
                        Marshal.Copy(row,0,IntPtr.Add(locked.Scan0,y*locked.Stride),width);
                    }
                    indexed.UnlockBits(locked);
                    using (var memory=new MemoryStream()) {
                        indexed.Save(memory,ImageFormat.Gif);
                        encoded=memory.ToArray();
                    }
                }
                int bits=encoded[10]&7;
                int tableLength=(encoded[10]&0x80)!=0 ? 3*(1<<(bits+1)) : 0;
                int tableOffset=13,offset=13+tableLength;
                while (encoded[offset]==0x21) { offset+=2; SkipBlocks(encoded,ref offset); }
                if (encoded[offset]!=0x2c) throw new InvalidDataException("Missing GIF image block");
                int descriptor=offset, packed=encoded[offset+9];
                offset+=10;
                if ((packed&0x80)!=0) { bits=packed&7; tableLength=3*(1<<(bits+1)); tableOffset=offset; offset+=tableLength; }
                if (tableLength==0) throw new InvalidDataException("Missing GIF palette");
                int dataOffset=offset;
                offset++; SkipBlocks(encoded,ref offset);
                ushort delay=(ushort)(Math.Round((frame+1)*100.0/fps)-Math.Round(frame*100.0/fps));
                writer.Write(new byte[]{0x21,0xf9,4,4});
                writer.Write(delay); writer.Write((byte)0); writer.Write((byte)0);
                writer.Write(encoded,descriptor,9);
                writer.Write((byte)(0x80|(packed&0x40)|bits));
                writer.Write(encoded,tableOffset,tableLength);
                writer.Write(encoded,dataOffset,offset-dataOffset);
            }
            writer.Write((byte)0x3b);
        }
        using (var check=new Bitmap(output)) {
            int count=check.GetFrameCount(FrameDimension.Time);
            if (count!=files.Length) throw new InvalidDataException("Frame count differs");
            check.SelectActiveFrame(FrameDimension.Time,count-1);
            return count;
        }
    }
}
'@
$frames = @(Get-ChildItem -LiteralPath $FramesPath -Filter 'frame_*.png' -File | Sort-Object Name)
$selected = for ($index=0; $index -lt $frames.Count; $index+=$Every) { $frames[$index].FullName }
$resolvedOutput = [IO.Path]::GetFullPath($OutputPath)
$count = [NativeReviewGif]::Encode([string[]]$selected,$resolvedOutput,$Fps)
[pscustomobject]@{Output=$resolvedOutput;Frames=$count;FPS=$Fps;Bytes=(Get-Item -LiteralPath $resolvedOutput).Length} | ConvertTo-Json
