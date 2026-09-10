import sys
e = open(sys.argv[1],'rb').read()
print(f"Tong: {len(e)} byte = base 128 + {len(e)//128-1} extension\n")

v=(e[8]<<8)|e[9]
print(f"Vendor : {''.join(chr(((v>>s)&0x1F)+64) for s in (10,5,0))}")
print(f"Product: 0x{(e[11]<<8)|e[10]:04x}   Serial: 0x{int.from_bytes(e[12:16],'little'):08x}")
print(f"EDID   : v{e[18]}.{e[19]}   San xuat: tuan {e[16]}, nam {1990+e[17]}")
print(f"Kich thuoc: {e[21]}cm x {e[22]}cm")
print(f"Extension blocks: {e[126]}\n")

def dtd(d, tag):
    if d[0]==0 and d[1]==0:
        t=d[3]
        names={0xFF:'Serial',0xFE:'Text',0xFC:'Ten man hinh',0xFD:'Range limits'}
        txt=d[5:18].decode('ascii','replace').strip().strip('\n')
        print(f"  {tag}: [descriptor 0x{t:02x} {names.get(t,'?')}] {txt!r}")
        return
    px=((d[1]<<8)|d[0])*10000
    h=d[2]|((d[4]&0xF0)<<4); hb=d[3]|((d[4]&0x0F)<<8)
    vt=d[5]|((d[7]&0xF0)<<4); vb=d[6]|((d[7]&0x0F)<<8)
    tot=(h+hb)*(vt+vb)
    hz=px/tot if tot else 0
    print(f"  {tag}: {h}x{vt} @ {hz:.2f}Hz   pclk={px/1e6:.2f}MHz  htotal={h+hb} vtotal={vt+vb}")

print("=== Base block: 4 detailed timing descriptors ===")
for i in range(4):
    dtd(e[54+i*18:72+i*18], f"DTD{i}")

for b in range(1, len(e)//128):
    blk=e[b*128:(b+1)*128]
    tag=blk[0]
    kind={0x02:'CTA-861',0x70:'DisplayID',0xF0:'Block map'}.get(tag,f'0x{tag:02x}')
    print(f"\n=== Extension {b}: {kind} ===")
    if tag==0x02:
        dtd_off=blk[2]
        if dtd_off>=4:
            off=dtd_off
            while off+18<=127 and blk[off]|blk[off+1]:
                dtd(blk[off:off+18], f"  ext-DTD@{off}")
                off+=18
    elif tag==0x70:
        # DisplayID 2.0: quet cac type-7 timing block
        print(f"  version 0x{blk[1]:02x}, length {blk[2]}")
        off=5
        while off < 5+blk[2]-1:
            t,rev,ln = blk[off],blk[off+1],blk[off+2]
            if ln==0: break
            print(f"  - data block type 0x{t:02x} len {ln}")
            if t==0x22:  # Type VII timing - detailed (0x20 la Product Identification)
                for k in range(off+3, off+3+ln, 20):
                    d=blk[k:k+20]
                    if len(d)<20: break
                    # DisplayID 2.0: pixel clock tinh theo kHz, luu duoi dang value-1
                    px=int.from_bytes(d[0:3],'little')+1
                    hpix=(d[4]|(d[5]<<8))+1; hbl=(d[6]|(d[7]<<8))+1
                    vpix=(d[12]|(d[13]<<8))+1; vbl=(d[14]|(d[15]<<8))+1
                    tot=(hpix+hbl)*(vpix+vbl)
                    print(f"      {hpix}x{vpix} @ {px*1000/tot:.2f}Hz  pclk={px/1000:.3f}MHz")
            off += 3+ln
