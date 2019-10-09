-- title:  Todor
-- author: andraaspar
-- desc:   Creatures (C64) clone
-- script: moon
-- saveid: todor
moon=require('moon')
import is_object from moon
import floor, ceil, min, max, abs, random from math
import insert, remove from table
export todor,kapor,cam,slammed,kaporCaughtTime,gotLudmillaTime,startTime,btn4,btn5,btn6,btn7
export *
TILE_COUNT_X=30
TILE_COUNT_Y=17
CH_BASS=0
CH_HI=1
CH_DRUM=2
CH_SFX=3
GRAVITY=.1
SFX_SILENCE=-1
SFX_THROW=0
SFX_BOOM=1
SFX_JUMP=2
SFX_BLOW=3
SFX_HOLD=4
SFX_SPLASH=5
SFX_OHNO=6
SFX_KABOOM=7
SFX_HIT=8
SFX_COLLECT=9
SFX_COLLECT2=10
SFX_DRUM=11
SFX_HIGH=12
SFX_LOW=13
TRACK_DEATH=0
TRACK_1=1
TRACK_WIN=2
TILE_WATER=21
TILE_CAVE=32
TILE_LAVA=176
TILE_WATER_CAVE_MOD=80
HORIZON_COLOR=8
PMEM_START_POINT_X=0
PMEM_START_POINT_Y=1
frameTime=time!
msg=''
coverSkipped=false
sprites={}
decors={}
shots={}
enemyShots={}
flames={}
enemies={}
collectibles={}
turnTiles={}
ghostDownTiles={}
destructibleTiles={}
startPoints={}
startPointX=pmem(PMEM_START_POINT_X)
startPointY=pmem(PMEM_START_POINT_Y)
score=0
arrayToObject=(a)->
	result={}
	for i in *a
		result[i]=true
	result
wall=arrayToObject({2,17,53,54,55,64,69,72,91,96,97,98,119,130,131,132,134,147,149,195,196,209,211,224,225,226,227,241,242})
slopeUp=arrayToObject({1,20,48,90,99,133,144,146,193,208,211,240})
slopeDown=arrayToObject({3,22,49,92,100,135,145,148,192,210,214,243})
water=arrayToObject({TILE_WATER,5,6,20,21,22,22,36,37,38,39,40,88,104,120,136,144,145,160,161,TILE_LAVA,177})
cave=arrayToObject({TILE_CAVE,48,49,59,60,65,66,67,68,71,80,82,84,85,86,87,101,103,115,116,117,118,146,148,151,154,165,169,170,182,185,186})
destructible=arrayToObject({130,131,132})
lava=arrayToObject({TILE_LAVA,177,192,193})
waterLeftFrames={
	{5,0,0}
	{5,1,0}
	{6,1,0}
	{6,0,0}
}
waterfallLeftFrames={
	{5,0,3}
	{5,1,1}
	{6,1,1}
	{6,0,3}
}
waterfallTopLeftFrames={
	{4,0,0}
	{23,1,0}
	{7,1,0}
	{23,1,0}
}
waterfallBottomLeftFrames={
	{36,0,0}
	{37,1,0}
	{38,1,0}
	{37,1,0}
}
waterRightFrames={
	{6,0,0}
	{6,1,0}
	{5,1,0}
	{5,0,0}
}
waterfallRightFrames={
	{6,0,1}
	{6,1,3}
	{5,1,3}
	{5,0,1}
}
waterfallTopRightFrames={
	{7,0,0}
	{23,0,0}
	{4,1,0}
	{23,0,0}
}
waterfallBottomRightFrames={
	{38,0,0}
	{37,0,0}
	{36,1,0}
	{37,0,0}
}
seaweedFrames={
	{88,0,0}
	{104,0,0}
	{120,0,0}
	{88,1,0}
	{104,1,0}
	{120,1,0}
}
torchLightFrames={299,300}
torchLightFlipFrames={0,0,1,1}
flameStartFrames= {266,267,286,287,286,287,286,287,286,287,286,287,267,266}
flameMiddleFrames={  0,266,267,270,271,270,271,270,271,269,268,267,266}
flameEndFrames=   {  0,  0,266,269,282,283,282,283,282,283,269,266}
flameEndTopFrames={  0,  0,  0,  0,284,285,284,285,284,285}
flamePaletteIndexes={15,14,12,14}
blueFlamePaletteIndexes={15,13,10,13}
heartPaletteIndexes={1,6,12,15,12,6}
colorRoll={1,4,6,9,12,14,15,13,10,8,7,3,2,5,11,13,15,14,12,9,6,4}
colorRollStart={0,12,11,1,13,2,10,9,3,8,14,4,15,5,6}
mushroomCloudFrames={277,278,279,295,280,296,281,297}
popFrames={261,262,263,264,265}
defaultPalette={0x140c1c,0x442434,0x30346d,0x4e4a4f,0x854c30,0x346524,0xd04648,0x757161,0x597dce,0xd27d2c,0x8595a1,0x6daa2c,0xd2aa99,0x6dc2ca,0xdad45e,0xdeeed6}
grayscalePalette={0x000000,0x1e1e1e,0x373737,0x4b4b4b,0x565656,0x636363,0x717171,0x757575,0x7b7b7b,0x898989,0x929292,0xa0a0a0,0xb1b1b1,0xcdcdcd,0xe9e9e9,0xffffff}
cover={
	{
		x1: 37
		y1: 49
		x2: 98
		y2: 101
		values: "yyku8,e0m5k16o,m601zywhs0,gmnawxzmyp,6bj,13nhfk,1q5w14ao,5i02zkw4qo,22twv48ydc,18mbc,vkaau2o,2rrvtctreo,m672b1oidc,m63k9y43cv,ksb4nqgqgv,3i9z7if3,m5t1g0hgww,m672jxatc0,m672jdcdfh,m66mrstptr,jef9p1ibjz,4oeagkl4v,344zgcyyo,ksc07jamm8,oxr28yrkf,lh93lk4vb4,3xuf6e7,33es2qxts,jef6rjj56o,2fcnf52jgj,2rot9jg6ww,m65beyc8o0,jef6snp2pr,aiy3rojj,fy2hzqvtz4,8c3poaiakg,m672261igw,m5f0c44geb,ezqpr,1n81c0sf,5iypz42sqo,m672jw2kg0,m671kerif3,m5f0c4qr5r,8vn08v,e13wu1of,m672jxbhts,m672jw2kg0,m670kw7i7z,m32tonw3cv,zik0zj,1weekkh4w,1dvxwoc2kg,m66unsvaps,lh93ljwjcv,b8jj,hra0e8,e13wit4w,m671kerhmo,m4my49zbwg,e7,b8jg,4fssu8,esqcetc,0"
	}
	{
		x1: 6
		y1: 2
		x2: 208
		y2: 135
		values: "0,ksb4n6hjpc,1,0,0,lzyktbyrr4,3,0,0,m32twebrwg,3,0,0,m5f49vvxts,1,0,0,m60po9r94w,0,0,0,b31s4yfj0g,e,0,0,m672jx0a2o,7,0,0,m672jx5wcg,f,0,0,m672jx8phc,1,0,0,b33j9ymcqo,0,0,0,5jjrmzb6dc,0,0,0,cgbstct8g,0,0,0,345wr0af4,0,0,0,e0qldjao,0,0,0,vgbyyv0,0,0,mh34,1yjmrjy,0,0,b33l091slc,8qyg3j,0,0,gmnbvf2u4g,13c933,0,0,jqw6gfi03k,4u9kv,0,0,m4my8psqv4,e7,0,0,m5t1h4ftog,1r,0,0,m63ka83lds,f,0,0,m63ka0lwg0,1,0,0,b31s4zoh5s,0,0,0,1dsfmrxp14,0,0,0,689ugxxj3,0,0,gmnawxzmyo,1k0hl4s1r,0,0,ksb4n6hjpc,e04ea3un,0,0,lh93ljwj5s,3hagni7z,0,0,ltq32qm0w0,ukz8utb,0,0,ltq32qm0w0,3p6l3r3,0,0,ltq32qm0w0,fjd9fz,0,0,m32tomn56o,8lnev7,0,0,b1jeubbklc,22wydc,0,0,5irpf5nsao,7hp1c,0,0,1dj85kp8n4,18y68,74,0,cf4e4vmkg,gmnawyxclc,cg,0,346w9kbgg,4ulsom5bls,1k,0,s1q2e2v4,572s5smdxc,f,0,70b2s0lc,m32tomn56o,1,0,1r2rp05c,5irpf5nsao,0,0,vjdui2o,1doxcsey2o,0,0,7vkh14w,c9yx8agw0,0,0,1yr4glc,1idanqfi8,0,0,hma7sw,6krpil1c,0,0,4dbls0,1n6xdn9c,0,0,13bwg0,esqcetc,0,0,jny80,3gay3jw,0,0,b33ja3hxq8,4fti4j,0,0,8bbngi7d34,0,0,0,1dvxwr4utc,0,0,0,5fy8,4u6f4,0,0,19ts,9yw3k,0,0,9hc,jz3ls,0,0,5j4,22y9s0,0,0,16o,9hc,0,0,ow,1r9ff9c,0,0,nduiq35k0,3p6l3pc,0,0,2x8bc9m2o,1h9u1hc,0,0,d5jf18g0,2yjo2yo,0,0,1j8v5jpc,0,0,0,dt7sdz4,0,0,0,3hcekqg,0,0,0,2f38f,0,0,jef6qfnksg,2ghz,0,0,ltq32qm0w0,b33j9yof0j,3,0,m32tomn56o,45ntq8i2v4,0,0,5hzn7bzoxs,11eyfk4ips,0,0,1d3vox5vk0,9cqlw14oo,0,0,o5wqjqw3k,1k4fnc6su,16o,0,bfdi76y874,163bqi521,3k,0,30qlbgv0g,l1nveosm,o,0,b4ms5472f4,3i9z8wzl,4,0,8bpgo9dn9c,1r4zm3uo,1,0,1dzc8ntdds,vkht1xg,mh34,0,11ft0jdbsw,fs8whdu,8feo,0,b9cgjx9xq8,0,23uo,0,2rs3gqh5hc,0,iyo,0,1dw1sl5bsw,0,a68,0,ch1f3v668,0,1o0,0,8lnev4,g,o,0,22wydc,u,k,0,gmnaxzg45c,7,i,0,fxpbz21xxc,gmnawxzmyp,9,0,ab1bgeb8xs,b33j9ynrb4,p,0,2563im6y2o,b33j9ynrb4,0,0,1bcqpbvitc,0,0,0,ob65iodfk,0,0,0,c49q0lgqo,0,0,0,61p2regw0,0,0,0,30wiet43k,0,0,0,1iea6al8g,0,0,0,r753588w,0,0,0,64zgm58g,0,0,0,2mphemtc,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,36mp0ez17k,0,0,0,2i24hmzq4o,0,0,0,qplrn9hfo,0,0,0,a1hx2kqqk,0,3y283y8,0,0,0,2yjo2yo,0,0,0,qmx0qo,0,0,0,dbgidc,0,0,0,3bv4lc,0,0,0,1xx5og,0,0,0,hhaf4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,b33j9ynrb4,1,0,0,b2bh24zny8,0,0,0,2rdupktw5c,0,0,0,ojxugkxs0,0,0,0,cf8c73qio,0,0,0,1jonefqww,0,0,0,1k0hl42rk,0,0,0,s1yy1340,0,0,0,3i13ki68,0,0,0,7twjgu8,0,0,0,yyku80,0,0,0,22wydc,0,0,0"
	}
	{
		x1: 65
		y1: 4
		x2: 234
		y2: 132
		values: "0,0,0,e7,0,0,2sxs,0,0,4ekjy8,0,0,dx5ulxq8,0,0,awv1jdb0g0,6,0,0,2yo,0,0,4fi9kw,0,0,ry9rfzeo,0,0,ksb4n6hjpc,7,0,0,p34,0,0,hma7sw,0,0,30qlbgv0g,0,0,0,3j,0,0,8wvls0,0,0,oyem6hx4w,0,0,5hzn7bzoxs,1kw,0,0,4ftjog,0,0,68hssn0u8,0,0,rmfkrnk0,sg,0,gmnawxzmyo,27wr2n,0,0,9cqlw6k8w,0,0,3tvghkw,1idanqfwg,0,5ip2po95hc,b33jb2m4xs,am,0,348zli60s,20ecqo,0,61h8uoutc,2d18g95a8,0,1jwjivytc,ksb4p4epyw,ap,gmnawxzmyo,s27ycnjz,u1eyo,0,32hvaio0,s5o4m6ww,0,e0v171fk,4ulsp0wa9v,5c,lzyktbyrr4,gnte8okl6n,7ib67,0,3y73oqo,okszotz4,0,dmb1hu68,2flmtovw1s,o,ocxai5wxs,li0a8vrqym,y0q8,0,4u77c,wb8i3y6,0,dlbxlyps,dili3b7f9c,3,64zgm58g,2m8cth46ri,b6zk,0,lhmoxcobgm,1pjcg9y8,0,dlbo0f0g,bm3jsj76n3,3,0,1bcskgo20u,jqcw,0,58gbkzn5s0,1jfmmpuo,0,aej5n96dq8,j00a3usw0,f,0,noeaxcjsu,13ea8,0,1adps9ga2o,65667wog,0,2lwzek8su8,6b4ofob0g,1o,0,nhd8nnake,9d5hi,0,1bxtam56v4,ojyyvz94,0,1b5ad437cw,35skxj1a8,68,0,ds4c8d03em,yyl8h,0,1b5qdqzqps,5gfirrfwe,0,nkfaflds0,3tqmgps,16o,0,1nmkhtzy,dbgidc,0,lttlse0z5s,1dvxwqtywz,0,17u0xuzt34,2pzs,pa8,0,xv6m,7w4g7wg,0,33cvdvk0,0,0,gacw7gsq9s,6,0,0,5j4u,0,0,3gd4r9c,0,0,64zgm58g,0,0,0,s,0,0,26nsw,0,0,2mphemtc,0,0,0,c,0,1ds,mh34,0,zg24n4,1r4zlse8,0,2rodjjpdkw,1zmc6ww,8,6h9fjdiww,2u6p6g3jzs,mh34,0,1z0svfo,59eytj9d,0,5jiw7jz7k0,ddztb0,o,e4u2xpreo,11eyfp24n0,34dfk,zik0zk,2s5uuhe1l5,c9yx8g00,1dvxwqtyww,j2wubadr0g,6nqlvf,2fawcayg48,3itpin56o,9cr3rd6am,1vf9c,bs1iq3d5hc,amnoxs8w,59eyt9mo,1dvyyhaqyo,b0r9feul1c,zik108,2y0dk30opk,bfrlezpb7k,1dvxwt3cou,1vf9c,5xuyudquio,3hwngie8,3i9z7lkw,c1e983jk74,jklzfkuryp,6nq96v,awv1jdb0w,aejnyt17go,ax7v8qkww,18y68,bz3xiz7xs0,gmnawy1284,3i9z7if4,68xmsledc0,8h1g,pa8,5kbtuszz0g,5bs5g,1z141z4,0,25ubo1s,jef6qfnksg,0,shdduqbr4,0,mfi8,dv9g7d5qtc,68hphedms,z9odzb4,0,33t31smxs,572s5smjgg,0,lzyktego3k,1h9u1hd,27wykg,70jyf0u8,s0,5gh01iozk,0,17jmo,0,1s,3geoxz4,0,0,11igpjbzls,0,0,0,1eg,0,0,flv5s,0,0,d5jf162o,0,7w4g7wg,0,c,0,1,0,0,5zpc,0,0,13ydj40,0,0,cgzh6phq8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13ydj4,1kw,0,1k4fnc6ps,27wr28,0,0,0,0,0,d9jgjvoyyo,3cefseaga,0,cxm4hfrzls,7dh8k2dd1u,11x,erm082fm68,1uil7nefu2,qmwxu,0,es3npxsmbk,22twmyfu2,0,uk8yp2sxs,4stutar6fr,hf,erm082fm68,7e2cumw2i2,2ekh8q,0,es43vi5khs,6r77lm6cq,0,cxm4hfrzls,7dh8k295b6,11x,erm082fm68,8rxyfbwjop,1am3pg,0,0,0,0,0,15kk5rk,0,0,7dhb6rfsao,0,0,es3jlyh69s,xmy,0,0,2mhzplc,0,0,9z0osxxfy8,0,0,erpii1n4lc,xmy,0,0,2mhzpjk,0,0,7dhb6mfzls,0,0,erpii1n4lc,xmx"
	}
	{
		x1: 24
		y1: 53
		x2: 104
		y2: 118
		values: "6sntysxs,0,b280,5gfironi80,0,8qn7k0,0,70,tlgotmo,0,0,0,0,0,0,0,0,ltq32qm0w,0,4fi9kw,ltq32qm0w0,e7,1k4fice0w,0,2hwce,m672261i4g,1,1z141s0,m65jb25zb4,1kv,s27tnitc,m1bop0vxmo,aw3j,4unjtjbzls,0,cn3,689ll9ips,0,4zj0g,hy5dzrvnk0,7,7srm51c,30qlbgv0g,64v,1d7kxbeo0,g9e97xm1vk,329,akoslfy8,duvf3gbp4w,34f,1jw8jpj40,jef6qfnkso,zjsslj,li3coe62gw,1ds,59jeroow,5jiw2hj01s,23z0,17qxhq2dq8,lzyktbyrr4,6xne1zb,ong4eji0w,5li6,5j65ttmzum,m671kerhmo,8vc3yb,jqsofefhfk,ltq32qm1a7,e128to9b,ksb52put4w,mh33,b33j8upds0,jny8,lh93ufjjcw,m65bexpreo,zdk8hr,gmo6hegr9c,sf,aexmh70gsc,346w9kbgg,hpel4w,b301002mtc,5gfironj0f,e13wofeo,gmnawxzmyo,mh33,b33j130r28,0,4fthxc,m601zywhs0,3j,1r4zaio0,gmnawxzmyo,pa7,68hhppqm8,0,4zshs,m601zywhs0,1,hr4e80,gmnawxzmyo,73,1qw3yqyo,0,c8w"
	}
	{
		x1: 70
		y1: 58
		x2: 209
		y2: 130
		values: "0,0,rmfkrnk,0,0,jny8,18y68,aqmjsry9kw,c,e8,721892bk,1dxp1qh4ow,0,um38t1c,rmpkd1s,b33j9ynrb4,1k4fsh9dw,4dgcg,545jugd1c,jef7m2db7k,qo,22ucu5vn28,5i6fv63xts,32oqv118u8,309h98h,fs89yri,p0629nfnk,5ugmonywh,2htyo,1d6umyccc,koett7rojk,b3ft8vw1yv,49rs,c26cevuv4,chowp6qzgg,45ntq8hwqu,xsd30g,3m8goutc,629mnz6i2o,jef6qfq8uw,g7,48eir52ps0,1h06s1icjj,0,2ropfx6fb4,dbgidc,70jyf0u8,vk9ophc,p34,1nxkao,9zkow,0,ltq70vc7i8,35r,0,gsql7ln6kg,1,0,hcamf4,0,0,npd,0,jegxvf9c00,1,0,6krqrj7k,0,9cqlw14ao,hmwow,0,1jhqsjk,2rk,0,45ntq8kd8g,0,0,3u48efwu,0,1d3vox5vk,13bzls,0,b33jhqce0w,69s,0,ltq34yk3cw,0,gmnawxzmyo,1p5yo3yb,0,1s4i5s74,4u6f4,0,9cqlwks8w,e4,0,4oday0k80,0,9cqlw14ao,0,0,hra0hs,0,0,47pc,0,0,3y283yw,0,awv1jdb0g,thxc,0,5jjz1ci328,9s,0,17qqk2ksn4,0,0,tsn60o0,0,5db9wdz4sg,f0irw,0,46fywlu328,7,0,ca7t0wzk,13bwg,0,f0sn4,1k,0,28ywbqe6tc,0,0,3xzq7ls,0,2ltwwtxq80,2t1c,0,m32ugdijgg,3,0,1r3vo9a8,0,b33j9ynrb4,27lgxu,0,ltyuromsxs,73,0,m671kor30g,0,0,fs8qtj4,0,3wb34cgsg,10iq8,0,b1jiq5mxhc,1o,0,9g476eneo,0,b33j9ynrb4,ej8kf,0,33dasvhts,61g,0,dkclnikjy8,0,0,3ue5imf4,0,aqmjsry9kw,1x05j,0,qa3bib5s,7d,0,vklw4t1c,0,0,8vnh2w,0,8s2z4ovtog,1ekg,0,15ruvabk,8,0,s27zyrr4,0,gmnawxzmyo,zl,0,34amfnz6rk,0,0,0"
	}
	{
		x1: 64
		y1: 107
		x2: 130
		y2: 135
		values: "0,iyo,fjd9fk,c2ydayry8,1p5yhp8g,ksb4n6hk3g,iqewx,6fhb1ahhc,1y759ts,2rdupktwjq,f4npc,cdprr7xs,2ots233z7k,3ah5559yjj,gozhkg8uws,fs8scn3,5jjcjze540,8lugwe4hkw,ltrq9nzugv,jef7s62tf3,1cbtaa58ht,lzqonubrwg,m4rc7cn5kv,gmnaz5we0d,70jx62lm,m65bex7xts,m66hnfwooz,gdakb29r7f,7w4almm,b33j9ym000,m670by2k1s,m65bexr5z3,7w4g7wf,b33j9ynrb3,m672jxbcao,m672hpeupr,m5t1kgaz27,3i9z7if3,0"
	}
}
coverColors={4,8,15,12,14,11}
instanceOf=(klass,instance)->
	if klass==nil or instance==nil or not is_object(instance)
		return false
	if instance.__class==klass
		return true
	instanceOf(klass,instance.__class.__parent)
removeItem=(list,item)->
	[i for i in *list when i~=item]
round=(n)->
	if n>0 then floor(n+.5) else ceil(n-.5)
getFrameId=(sec,count,t=0)->
	floor((frameTime-t)/(sec*1000)%count)
getFrameIdLooped=(sec,count,t=0)->
	(frameTime-t)/(sec*1000)>=count
getFrameLooped=(sec,frames,t)->
	getFrameIdLooped(sec,#frames,t)
getFrame=(sec,frames,t,idOffset=0)->
	id=getFrameId(sec,#frames,t)
	r=frames[id+1]
	if type(r)=='number'
		-- msg..="\n#{r}"
		return r+idOffset
	else
		-- msg..="\n#{r[1]} #{r[2]} #{r[3]}"
		return r[1]+idOffset,r[2],r[3]
direction=(n)->
	if n==0
		return 0
	n/abs(n)
decrease=(n,maxAmount)->
	n-direction(n)*min(maxAmount,abs(n))
isWaterfall=(tile,x,y)->
	tileAbove=mget(x,y-1)
	tileBelow=mget(x,y+1)
	tile==5 and
		(tileAbove==4 or tileAbove==5 or
			tileBelow==5 or tileBelow==36) or
		tile==6 and 
			(tileAbove==6 or tileAbove==7 or
				tileBelow==6 or tileBelow==38)
isWater=(x,y)->
	tile=mget(x,y)
	if water[tile]
		if tile==5 or tile==6
			if isWaterfall(tile,x,y)
				return false
		return true
	false
isCave=(x,y)->
	tile=mget(x,y)
	if cave[tile]
		return true
	false
isCaveBelow=(x,y)->
	tile=mget(x,y)
	if wall[tile] or
			slopeUp[tile] or
			slopeDown[tile] or
			cave[tile] and
			tile!=65 and
			tile!=66
		return true
	false
getWaterMod=(x,y)->
	if isCaveBelow(x,y-1)
		return TILE_WATER_CAVE_MOD
	0
getWaterFallMod=(x,y,left,bottom)->
	if left
		x-=1
	else
		x+=1
	if bottom
		y-=1
	tile=mget(x,y)
	if wall[tile] or cave[tile]
		return TILE_WATER_CAVE_MOD
	0
remap=(tile,x,y)->
	switch tile
		when 5
			if isWaterfall(tile,x,y)
				return getFrame(.1,
					waterfallLeftFrames,
					0,
					getWaterFallMod(x,y,true,false))
			else
				return getFrame(.1,
					waterLeftFrames,
					0,
					getWaterMod(x,y))
		when 6
			if isWaterfall(tile,x,y)
				return getFrame(.1,
					waterfallRightFrames,
					0,
					getWaterFallMod(x,y,false,false))
			else
				return getFrame(.1,
					waterRightFrames,
					0,
					getWaterMod(x,y))
		when 4
			return getFrame(.1,
				waterfallTopLeftFrames,
				0,
				getWaterMod(x,y))
		when 7
			return getFrame(.1,
				waterfallTopRightFrames,
				0,
				getWaterMod(x,y))
		when 36
			return getFrame(.1,
				waterfallBottomLeftFrames,
				0,
				getWaterFallMod(x,y,true,true))
		when 38
			return getFrame(.1,
				waterfallBottomRightFrames,
				0,
				getWaterFallMod(x,y,false,true))
		when 88
			return getFrame(.5,
				seaweedFrames,
				0)
		when 104
			return getFrame(.5,
				seaweedFrames,
				1000)
		when 120
			return getFrame(.5,
				seaweedFrames,
				2000)
		when 97
			if startTime!=nil and not slammed
				return 32
		when 166
			if mget(x-1,y)==167
				return tile,1
		when 167
			if mget(x+1,y)==166
				return tile,1
		when 180
			if x==startPointX and y==startPointY
				return 181
		when 183
			if mget(x+1,y-1)==166
				return tile,1
	tile
setPaletteIndex=(i,v=i)->
	poke4(0x3FF0*2+i,v)
setBorderColorIndex=(v=0)->
	poke4(0x3FF8*2,v)
resetPaletteIndices=()->
	for i=0,15
		setPaletteIndex(i)
setPaletteColor=(i,rgb)->
	addr=0x3FC0+i*3
	poke(addr,(rgb&0xff0000)>>16)
	poke(addr+1,(rgb&0xff00)>>8)
	poke(addr+2,rgb&0xff)
killFlames=->
	for i,flame in ipairs(flames)
		flame\remove!
drawMountain=(x,y,w)->
	h=w/2
	textri(x-w/2,y,x,y-h,x+w/2,y,
		0,16,0,8.1,8,8.1)
drawHill=(x,y,w,h)->
	tri(x-w/2,y,x,y-h,x+w/2,y,HORIZON_COLOR)
drawHorizon=()->
	w=cam.width
	h=cam.height
	tx=cam\getTopLeftX!/(w*7)
	ty=cam\getTopLeftY!/(h*7)
	x=-w*tx
	y=h*.75-(h*.5*ty)
	circ(w*.4,h*.2,8,14)
	rect(0,y,w,h-y+1,HORIZON_COLOR)
	drawMountain(x+w*.1,y,w*.4,h*.3)
	drawMountain(x+w*.9,y,w*.6,h*.4)
	drawMountain(x+w*1.2,y,w*.8,h*.6)
	drawMountain(x+w*1.9,y,w*.5,h*.4)
	drawHill(x+w*.3,y,w*.2,h*.1)
	drawHill(x+w*.6,y,w*.4,h*.2)
	drawHill(x+w*1.6,y,w*.3,h*.15)
	drawHill(x+w*2,y,w*.15,h*.1)
perpProduct=(a,b)->
	a.x*b.y-a.y*b.x
segmentIntersectionT=(a,b)->
	v1=b\toVector!
	v2=a\toVector!
	v3=b.a\subtract(a.a)
	perpProduct(v3,v1)/perpProduct(v2,v1)
segmentHitsSegment=(a,b)->
	t1=segmentIntersectionT(a,b)
	if t1<=0 or t1>=1
		return false
	t2=segmentIntersectionT(b,a)
	t2>0 and t2<1
rectangleHitsRectangle=(a,b)->
	a.a.x<b.b.x and a.b.x>b.a.x and
		a.a.y<b.b.y and a.b.y>b.a.y
		
rectangleHitsSegment=(r,s)->
	a=r.a
	b=Vector(r.b.x,r.a.y)
	c=r.b
	d=Vector(r.a.x,r.b.y)
	rSegments={
		Segment(a,b),
		Segment(b,c),
		Segment(c,d),
		Segment(d,a)
	}
	for rs in *rSegments
		if segmentHitsSegment(s,rs)
			return true
	false
rectangleHitsTriangle=(r,t)->
	rectangleHitsSegment(r,
		Segment(t.a,t.b)) or
	rectangleHitsSegment(r,
		Segment(t.b,t.c)) or
	rectangleHitsSegment(r,
		Segment(t.c,t.a))
		
getTileRectangle=(tileX,tileY,tile)->
	switch tile
		when 96
			return Rectangle(
				Vector(tileX*8,tileY*8),
				Vector(tileX*8+8,tileY*8+2))
		when 132
			return Rectangle(
				Vector(tileX*8,tileY*8),
				Vector(tileX*8+8,tileY*8+2))
	Rectangle(
		Vector(tileX*8,tileY*8),
		Vector(tileX*8+8,tileY*8+8))
getTile=(x,y)->
	if x<0 or x>=cam.width or y>=cam.height
		return 17
	mget(x,y)
getTileCoord=(xOrY)->
	floor(xOrY/8)
getTileCenterCoord=(xOrY)->
	getTileCoord(xOrY)*8+4
getTileAtCoord=(x,y)->
	getTile(getTileCoord(x),getTileCoord(y))
xyHitsGhostDownTile=(x,y)->
	if ghostDownTiles[getTileCoord(x)..'-'..getTileCoord(y)]
		if abs(getTileCenterCoord(x)-x)<=1
			return true
	false
rectangleHitsWall=(r,all)->
	tileX1=floor(r.a.x/8)
	tileX2=floor(r.b.x/8)
	tileY1=floor(r.a.y/8)
	tileY2=floor(r.b.y/8)
	result={}
	finished=false
	for tileX=tileX1,tileX2
		for tileY=tileY1,tileY2
			tile=getTile(tileX,tileY)
			hit=false
			if wall[tile]
				hit=rectangleHitsRectangle(r,
					getTileRectangle(tileX,tileY,tile))
			else if slopeUp[tile]
				hit=rectangleHitsTriangle(r,
					Triangle(
						Vector(tileX*8,tileY*8+8),
						Vector(tileX*8+8,tileY*8),
						Vector(tileX*8+8,tileY*8+8)))
			else if slopeDown[tile]
				hit=rectangleHitsTriangle(r,
					Triangle(
						Vector(tileX*8,tileY*8),
						Vector(tileX*8+8,tileY*8+8),
						Vector(tileX*8,tileY*8+8)))
			if hit
				insert(result,Vector(tileX,tileY))
				if not all
					finished=true
					break
		if finished
			break
	if #result>0
		return result
	nil
rectangleHitsTurn=(r)->
	tileX1=floor(r.a.x/8)
	tileX2=floor(r.b.x/8)
	tileY1=floor(r.a.y/8)
	tileY2=floor(r.b.y/8)
	for tileX=tileX1,tileX2
		for tileY=tileY1,tileY2
			if turnTiles[tileX..'-'..tileY]
				if rectangleHitsRectangle(r,
					getTileRectangle(tileX,tileY))
					return true
	false
rectangleHitsEnemies=(r)->
	[enemy for enemy in *enemies when rectangleHitsRectangle(r,enemy\getRectangle!)]
rectangleSwims=(r,ratio)->
	tileX1=floor(r.a.x/8)
	tileX2=floor(r.b.x/8)
	tileY1=floor(r.a.y/8)
	tileY2=floor(r.b.y/8)
	ratioUnderwater=0
	for tileX=tileX1,tileX2
		for tileY=tileY1,tileY2
			if isWater(tileX,tileY)
				tileRectangle=getTileRectangle(tileX,tileY)
				hit=rectangleHitsRectangle(r,
					tileRectangle)
				if hit
					if ratio==nil
						return true
					else
						ratioUnderwater+=r\intersectionRatio(tileRectangle)
						if ratioUnderwater>=ratio
							return true
	false
fillMapGap=(x,y)->
	if lava[getTile(x,y-1)]
		mset(x,y,TILE_LAVA)
	else if isWater(x,y-1)
		mset(x,y,TILE_WATER)
	else if isCaveBelow(x,y-1)
		mset(x,y,TILE_CAVE)
	else
		mset(x,y,0)
addScore=(n)->
	if floor(score/25)<floor((score+n)/25)
		todor.hp+=1
		sfxCollectLife!
	else
		sfxCollectGem!
	score+=n
damageWalls=(wallsHit,damage)->
	if wallsHit
		for coords in *wallsHit
			tile=mget(coords.x,coords.y)
			if destructible[tile]
				hp=destructibleTiles[coords.x..'-'..coords.y]
				if hp!=nil and hp>0
					hp-=damage
					destructibleTiles[coords.x..'-'..coords.y]=hp
					flash=WallFlash!
					flash\moveToTile(coords.x,coords.y)
					sfxHit!
					if hp<=0
						mset(coords.x,coords.y,TILE_CAVE)
silence=(channel)->
	sfx(SFX_SILENCE,0,-1,channel)
sfxThrow=->
	sfx(SFX_THROW,6*12,-1,CH_SFX)
sfxBoomExplosion=->
	sfx(SFX_BOOM,0,-1,CH_DRUM,15,-1)
sfxBoomHit=->
	sfx(SFX_BOOM,0,-1,CH_DRUM)
sfxJump=->
	sfx(SFX_JUMP,3*12+2,-1,CH_SFX)
sfxBlow=->
	sfx(SFX_BLOW,3*12,-1,CH_SFX)
sfxHold=->
	sfx(SFX_HOLD,4*12+5,-1,CH_SFX)
sfxSplashBody=->
	sfx(SFX_SPLASH,7*12,-1,CH_DRUM)
sfxSplashBullet=->
	sfx(SFX_SPLASH,7*12+4,-1,CH_DRUM)
sfxOhnoEnemy=->
	sfx(SFX_OHNO,6*12,-1,CH_SFX)
sfxOhnoLudmilla=(tone)->
	sfx(SFX_OHNO,6*12+5+tone,-1,CH_SFX)
sfxSnap=->
	sfx(SFX_KABOOM,6*12,-1,CH_DRUM,10,3)
sfxKaboomExplosion=->
	sfx(SFX_KABOOM,0,-1,CH_DRUM,15,-1)
sfxZap=->
	sfx(SFX_KABOOM,4*12,-1,DRUM,10,-1)
sfxSlam=->
	sfx(SFX_KABOOM,0,-1,CH_DRUM,15,1)
sfxHit=->
	sfx(SFX_HIT,3*12,-1,CH_DRUM)
sfxCollectGem=->
	sfx(SFX_COLLECT,6*12,-1,CH_SFX)
sfxCollectLife=->
	sfx(SFX_COLLECT2,3*12,-1,CH_SFX)
rollColors=(start=0)->
	for i=1,14
		setPaletteIndex(i,getFrame(.1,colorRoll,colorRollStart[i]*100+start))
drawMap=->
	cls(13)
	drawHorizon!
	map(
		cam\getTileX!,
		cam\getTileY!,
		31,
		18,
		cam\getMapX!,
		cam\getMapY!,
		0,
		1,
		remap
	)
prepareCover=->
	local zeroOnes,n
	for i,o in ipairs(cover)
		zeroOnes={}
		for b36 in string.gmatch(o.values,"([^,]+)")
			n=tonumber(b36,36)
			for p=0,50
				insert(zeroOnes,if math.pow(2,p)&n>0 then 1 else 0)
		o.color=coverColors[i]
		o.values=zeroOnes
drawCover=->
	local i
	cls!
	circ(cam.width/3,cam.height/3,cam.height*.8,1)
	for o in *cover
		i=0
		for y=o.y1,o.y2
			for x=o.x1,o.x2
				i+=1
				if o.values[i]==1
					pix(x,y,o.color)
	print('Press            to start',8,8)
	drawFireButton(42,7)
drawFireButton=(x,y)->
	spr(331,x,y,0) -- Z
	spr(351,x+8,y,0) -- /
	spr(330,x+8*2,y,0) -- Y
	spr(351,x+8*3,y,0) -- /
	spr(329,x+8*4,y,0) -- A
drawAltButton=(x,y)->
	spr(333,x,y,0) -- X
	spr(351,x+8,y,0) -- /
	spr(332,x+8*2,y,0) -- B
drawResetButton=(x,y)->
	spr(335,x,y,0) -- A
	spr(351,x+8,y,0) -- /
	spr(334,x+8*2,y,0) -- X
updateSprites=->
	for i,sprite in ipairs(sprites)
		sprite\checkActive!
		if sprite.isActive
			if sprite.think
				sprite\think!
			if sprite\shouldRemove!
				sprite\remove!
			else
				sprite\move!
drawSprites=->
	for decor in *decors
		if decor.isActive
			decor\draw!
	for collectible in *collectibles
		if collectible.isActive
			collectible\draw!
	for enemy in *enemies
		if enemy.isActive
			enemy\draw!
	for enemyShot in *enemyShots
		enemyShot\draw!
	for shot in *shots
		shot\draw!
	for flame in *flames
		flame\draw!
	todor\draw!
setPalette=(palette)->
	for i=0,15
		setPaletteColor(i,palette[i+1])
handleInput=->
	btn4\check!
	btn5\check!
	btn6\check!
	btn7\check!
	if btn4.isOn and btn5.isOn and btn6.isOn and btn7.isOn
		exit()
	if not coverSkipped
		if btn4.released or btn5.released
			coverSkipped=true
	elseif startTime==nil
		if btn6.released
			pmem(PMEM_START_POINT_X,0)
			pmem(PMEM_START_POINT_Y,0)
			reset()
		if btn4.released or btn5.released
			start!
	else
		if todor.isDead or gotLudmillaTime!=nil
			if btn5.released
				reset()
main=->
	music!
	btn4=ButtonState(4)
	btn5=ButtonState(5)
	btn6=ButtonState(6)
	btn7=ButtonState(7)
	prepareCover!
	cam=Camera!
	todor=Todor!
	cam.follow=todor
	for y=0,cam.height*7
		for x=0,cam.width*7
			tile=mget(x,y)
			if destructible[tile]
				destructibleTiles[x..'-'..y]=3
			switch tile
				when 8
					fillMapGap(x,y)
					with Walker!
						\moveToTile(x,y)
						.spdX=-.5
				when 9
					fillMapGap(x,y)
					turnTiles[x..'-'..y]=true
				when 10
					fillMapGap(x,y)
					if todor.x==0
						todor\moveToTile(x,y)
				when 11
					fillMapGap(x,y)
					with Walker2!
						\moveToTile(x,y-1)
						.spdX=-.5
				when 12
					fillMapGap(x,y)
					with Flyer!
						\moveToTile(x,y)
						.spdX=-.5
				when 13
					fillMapGap(x,y)
					with Flyer!
						\moveToTile(x,y)
						.spdY=-.5
				when 14
					mset(x,y,TILE_WATER)
					with Swimmer!
						.swimFrames={402,403,404,403}
						\moveToTile(x,y)
						.spdX=-.5
				when 15
					mset(x,y,TILE_WATER)
					with Swimmer!
						\moveToTile(x,y)
						.spdY=-.5
				when 24
					fillMapGap(x,y)
					with Walker!
						\moveToTile(x,y)
				when 25
					fillMapGap(x,y)
					with Flyer2!
						\moveToTile(x,y)
						.spdX=-.5
				when 26
					fillMapGap(x,y)
					ghostDownTiles[x..'-'..y]=true
				when 27
					fillMapGap(x,y)
					with Ghost(x,y)
						.spdX=-.5
						.upStart=frameTime
				when 28
					fillMapGap(x,y)
					with WalkerActive!
						\moveToTile(x,y)
						.spdX=-.5
				when 29
					fillMapGap(x,y)
					if startPointX==0
						with KaporAbductsLudmilla!
							\moveToTile(x,y)
							.y-=4
					else
						slammed=true
				when 30
					fillMapGap(x,y)
					x-=1
					turnTiles[x..'-'..y]=true
				when 31
					fillMapGap(x,y)
					x+=1
					turnTiles[x..'-'..y]=true
				when 41
					fillMapGap(x,y)
					with Ghost(x,y)
						.spdX=.5
						.upStart=frameTime
				when 42
					fillMapGap(x,y)
					kapor=with KaporHoldsLudmilla!
						\moveToTile(x,y)
						.x-=4
						.y-=4
				when 43
					fillMapGap(x,y)
					hilda=with Hilda!
						\moveToTile(x,y)
						.y-=8
				when 44
					fillMapGap(x,y)
					with Fairy!
						\moveToTile(x,y)
						.spdX=-.5
				when 45
					fillMapGap(x,y)
					with Witch!
						\moveToTile(x,y)
						.spdX=-.5
				when 46
					fillMapGap(x,y)
					with GrassHead!
						\moveToTile(x,y)
						.spdX=-.5
				when 47
					fillMapGap(x,y)
					with GrassHead!
						\moveToTile(x,y)
				when 56
					fillMapGap(x,y)
					with Gem!
						\moveToTile(x,y)
				when 62
					fillMapGap(x,y)
					with Flyer2!
						\moveToTile(x,y)
						.spdX=.5
				when 63
					fillMapGap(x,y)
					with Spider!
						\moveToTile(x,y)
						.spdY=-.5
				when 73
					fillMapGap(x,y)
					with FatPotion!
						\moveToTile(x,y)
				when 74
					fillMapGap(x,y)
					with ThinPotion!
						\moveToTile(x,y)
				when 79
					fillMapGap(x,y)
					with Sarcophagus!
						\moveToTile(x,y)
				when 115
					with TorchLight!
						\moveToTile(x,y-1)
				when 180
					startPoints[x..'-'..y]=true
					if startPointX==x and startPointY==y
						todor\moveToTile(x,y)
	-- music(TRACK_1,0,0,true)
start=->
	startTime=frameTime
class ButtonState
	new:(num)=>
		@num=num
		@isOn=false
		@check!
	check:=>
		@wasOn=@isOn
		@isOn=btn(@num)
		@pressed=not @wasOn and @isOn
		@released=@wasOn and not @isOn
		@changed=@pressed or @released
class Vector
	new:(x=0,y=0)=>
		@x=x
		@y=y
	subtract:(o)=>
		Vector(@x-o.x,@y-o.y)
class Rectangle
	new:(a=Vector(),b=Vector())=>
		@a=a
		@b=b
	intersection:(r)=>
		Rectangle(
			Vector(max(@a.x,r.a.x),
				max(@a.y,r.a.y)),
			Vector(min(@b.x,r.b.x),
				min(@b.y,r.b.y)))
	area:=>
		a=@b.x-@a.x
		b=@b.y-@a.y
		a*b
	intersectionRatio:(r)=>
		@intersection(r)\area!/@area!
class Segment
	new:(a=Vector!,b=Vector!)=>
		@a=a
		@b=b
	toVector:=>
		@b\subtract(@a)
class Triangle
	new:(a=Vector(),b=Vector(),
		c=Vector())=>
		@a=a
		@b=b
		@c=c
class Camera
	new:=>
		@width=240
		@height=136
		@minX=@width/2
		@minY=@height/2
		@maxX=8*@width-@minX
		@maxY=8*@height-@minY
		@x=@minX
		@y=@minY
	update:=>
		if @follow
			@x=min(@maxX,
				max(@minX,
					@follow.x))
			@y=min(@maxY,
				max(@minY,
					@follow.y))
	getTopLeftX:=>
		round(@x-@width/2)
	getTopLeftY:=>
		round(@y-@height/2)
	getRectangle:(padding=0)=>
		tlx=@getTopLeftX!
		tly=@getTopLeftY!
		Rectangle(
			Vector(tlx-padding,tly-padding),
			Vector(tlx+@width+padding,tly+@height+padding))
	getTileX:=>
		floor(@getTopLeftX!/8)
	getTileY:=>
		floor(@getTopLeftY!/8)
	getMapX:=>
		-(@getTopLeftX!%8)
	getMapY:=>
		-(@getTopLeftY!%8)
class FloatingSprite
	new:=>
		@x=0
		@y=0
		@colorKey=0
		@isActive=true
		@layers=1
		insert(sprites,self)
	getTopLeftX:(layer)=>
		@x-@getWidth(layer)*@getScale(layer)/2
	getTopLeftY:(layer)=>
		@y-@getHeight(layer)*@getScale(layer)/2
	getCamX:(layer)=>
		@getTopLeftX(layer)
	getCamY:(layer)=>
		@getTopLeftY(layer)
	checkActive:=>
		return
	getWidth:=>8
	getHeight:=>8
	getScale:=>1
	getFlip:=>0
	getRotate:=>0
	draw:=>
		if @tweakPalette
			@tweakPalette!
		for layer=1,@layers
			spr(@getTileId(layer),@getCamX(layer),@getCamY(layer),
				@colorKey,@getScale(layer),@getFlip(layer),
				@getRotate(layer),
				ceil(@getWidth(layer)/8),
				ceil(@getHeight(layer)/8))
		if @untweakPalette
			@untweakPalette!
	shouldRemove:=>
		false
	remove:=>
		sprites=removeItem(sprites,self)
class Sprite extends FloatingSprite
	new:=>
		super!
		@spdX=0
		@spdY=0
		@onGround=false
	moveToTile:(x,y)=>
		@x=x*8+4
		@y=y*8+4
	getCamX:(layer)=>
		round(@getTopLeftX(layer)-cam\getTopLeftX!)
	getCamY:(layer)=>
		round(@getTopLeftY(layer)-cam\getTopLeftY!)
	getRectangle:=>
		Rectangle(
			Vector(@x-1,@y-1),
			Vector(@x+1,@y+1))
	checkActive:=>
		@isActive=rectangleHitsRectangle(
			@getRectangle!,
			cam\getRectangle(cam.width/2))
	applyGravity:=>
		@spdY+=GRAVITY
	canWalk:=>
		return not(rectangleHitsWall(@getRectangle(@x+@spdX,@y)) and
			rectangleHitsWall(@getRectangle(@x+@spdX,@y-abs(@spdX))) and
			rectangleHitsWall(@getRectangle(@x+@spdX,@y+abs(@spdX))))
	canMove:=>true
	walk:=>
		if @spdX~=0
			if @onGround and @canMove(@x+@spdX,@y+abs(@spdX))
				@x+=@spdX
				@y+=abs(@spdX)
			elseif @canMove(@x+@spdX,@y)
				@x+=@spdX
			elseif @canMove(@x+@spdX,@y-abs(@spdX))
				@x+=@spdX
				@y-=abs(@spdX)
		if @canMove(@x,@y+@spdY)
			@onGround=false
			@y+=@spdY
		else
			@onGround=@spdY>0
			if @onGround and @spdY>0
				while @canMove(@x,@y+GRAVITY)
					@y+=GRAVITY
				-- if @y%8>7
				-- 	tileBottom=@y-@y%8+8
				-- 	if @canMove(@x,tileBottom)
				-- 		@y=tileBottom
			@spdY=0
	swim:=>
		if @canMove(@x+@spdX,@y)
			@x+=@spdX
		else
			@spdX=0
		if @canMove(@x,@y+@spdY)
			@y+=@spdY
		else
			@spdY=0
class Decor extends Sprite
	new:=>
		super!
		insert(decors,self)
	move:=>
		return
	remove:=>
		decors=removeItem(decors,self)
		super!
class TorchLight extends Decor
	new:=>
		super!
		@start=floor(random(0,1000))
	getTileId:=>
		getFrame(.1,torchLightFrames,@start)
	getFlip:=>
		getFrame(.1,torchLightFlipFrames,@start)
	tweakPalette:=>
		setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@start))
	untweakPalette:=>
		setPaletteIndex(15)
class WallFlash extends Decor
	new:=>
		super!
		@start=frameTime
		@colorKey=1
	getTileId:=>0
	tweakPalette:=>
		setPaletteIndex(0,15)
	untweakPalette:=>
		setPaletteIndex(0)
	shouldRemove:=>
		frameTime-@start>50
class TodorShot extends Sprite
	new:()=>
		super!
		@startTime=frameTime
		@isFinished=false
		@damage=1
		insert(shots,self)
	checkActive:=>
		@isActive=true
	move:=>
		@x+=@spdX
		@y+=@spdY
		enemiesHit=rectangleHitsEnemies(@getRectangle!)
		if #enemiesHit>0
			for enemy in *enemiesHit
				if not enemy.isGhost
					@isFinished=true
					enemy.hp-=@damage
		wallsHit=rectangleHitsWall(@getRectangle!,true)
		if wallsHit
			@isFinished=true
			damageWalls(wallsHit,@damage)
		if rectangleSwims(@getRectangle!)
			@isFinished=true
			sfxSplashBullet!
		if @y>8*cam.height or @x<0 or @x>8*cam.width
			@isFinished=true
	getFlip:=>
		if @spdX>0
			return 0
		if @spdX<0
			return 1
	shouldRemove:=>
		@isFinished
	remove:=>
		shots=removeItem(shots,self)
		super!
	tweakPalette:=>
		setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@startTime))
	untweakPalette:=>
		setPaletteIndex(15)
class TodorShotNormal extends TodorShot
	getTileId:=>
		260
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-1,y-1),
			Vector(x+1,y+1))
	move:=>
		@applyGravity!
		super!
class TodorShotNoFall extends TodorShot
	new:=>
		super!
		@flyFrames={299,300}
		@flyFlipFrames={0,0,2,2}
	getTileId:=>
		getFrame(.1,@flyFrames,@startTime)
	getFlip:=>
		getFrame(.1,@flyFlipFrames,@startTime)
	getRotate:=>
		if @spdX<0
			return 1
		3
	getCamX:=>
		result=super!
		if @spdX<0
			return result+4
		return result-4
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-1,y-1),
			Vector(x+1,y+1))
	move:=>
		@spdY=0
		super!
class EnemyShot extends Sprite
	new:()=>
		super!
		@startTime=frameTime
		@isFinished=false
		insert(enemyShots,self)
	hitsTodor:=>
		if not todor.isDead
			rectangleHitsRectangle(@getRectangle!,todor\getRectangle!)
	shouldRemove:=>
		not @isActive or @isFinished
	remove:=>
		enemyShots=removeItem(enemyShots,self)
		super!
class Lightning extends EnemyShot
	new:=>
		super!
		@flyFrames={400,401}
		@startTime=frameTime
		@spdY=.5
	getTileId:=>
		getFrame(.1,@flyFrames,@startTime)
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+3))
	move:=>
		@swim!
	think:=>
		if @hitsTodor!
			@isFinished=true
			todor.hp-=1
			sfxSnap!
		else if rectangleHitsWall(@getRectangle!) or
				rectangleSwims(@getRectangle!)
			@isFinished=true
	tweakPalette:=>
		setPaletteIndex(15,getFrame(.1,flamePaletteIndexes))
	untweakPalette:=>
		setPaletteIndex(15)
class Curse extends Lightning
	new:=>
		super!
		@spdY=0
	getRotate:=>
		if @spdX<0
			return 1
		3
class Star extends EnemyShot
	new:=>
		super!
		@flipFrames={0,3}
		@startTime=frameTime
	getTileId:=>301
	getFlip:=>
		getFrame(.1,@flipFrames,@startTime)
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+3))
	move:=>
		@swim!
	think:=>
		if @hitsTodor!
			@isFinished=true
			todor.hp-=1
			sfxBoomHit!
		else if rectangleHitsWall(@getRectangle!) or
				rectangleSwims(@getRectangle!)
			@isFinished=true
	tweakPalette:=>
		setPaletteIndex(15,getFrame(.1,flamePaletteIndexes))
	untweakPalette:=>
		setPaletteIndex(15)
class KaporShot extends EnemyShot
	new:=>
		super!
		@flyFrames={299,300}
		@flyFlipFrames={0,0,2,2}
		@startTime=frameTime
	getTileId:=>
		getFrame(.1,@flyFrames,@startTime)
	getFlip:=>
		getFrame(.1,@flyFlipFrames,@startTime)
	getRotate:=>
		if @spdX<0
			return 1
		3
	getCamX:=>
		result=super!
		if @spdX<0
			return result+4
		return result-4
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-1,y-1),
			Vector(x+1,y+1))
	move:=>
		@swim!
	think:=>
		if @hitsTodor!
			@isFinished=true
			todor.hp-=1
			sfxSnap!
		else if rectangleHitsWall(@getRectangle!) or
				rectangleSwims(@getRectangle!)
			@isFinished=true
	tweakPalette:=>
		setPaletteIndex(15,getFrame(.1,blueFlamePaletteIndexes))
	untweakPalette:=>
		setPaletteIndex(15)
class Flame extends Sprite
	new:=>
		super!
		@startTime=frameTime
		@offsetX=0
		@offsetY=0
		insert(flames,self)
	getTileId:=>
		getFrame(.1,@frames,@startTime)
	getFlip:=>
		if @follow.facingRight
			return 0
		1
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-4,y-4),
			Vector(x+4,y+4))
	checkActive:=>
		@isActive=true
	move:=>
		if @follow~=nil
			@x=@follow.x
			if @follow.facingRight
				@x+=@offsetX
			else
				@x-=@offsetX
			@y=@follow.y+@offsetY
		if getFrame(.1,@frames,@startTime)>0
			enemiesHit=rectangleHitsEnemies(@getRectangle!)
			if #enemiesHit>0
				for enemy in *enemiesHit
					if not enemy.isGhost
						enemy.hp-=.1
			wallsHit=rectangleHitsWall(@getRectangle!,true)
			damageWalls(wallsHit,.1)
	shouldRemove:=>
		getFrameLooped(.1,@frames,@startTime)
	remove:=>
		flames=removeItem(flames,self)
		super!
	tweakPalette:=>
		setPaletteIndex(15,getFrame(.1,flamePaletteIndexes))
	untweakPalette:=>
		setPaletteIndex(15)
class Enemy extends Sprite
	new:=>
		super!
		@hp=0
		insert(enemies,self)
	canMove:=>true
	remove:=>
		enemies=removeItem(enemies,self)
		super!
	hitsTodor:=>
		if not todor.isDead
			rectangleHitsRectangle(@getRectangle!,todor\getRectangle!)
class Walker extends Enemy
	new:=>
		super!
		@walkFrames={289,290,289,291}
		@standFrame=288
		@deathFrames=mushroomCloudFrames
		@hp=3
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
		@flashColorIndex=6
	getTileId:=>
		if @deathTime==nil
			if @spdX~=0
				return getFrame(.1,@walkFrames)
			return @standFrame
		getFrame(.1,@deathFrames,@deathTime)
	getFlip:=>
		if @deathTime==nil
			if @spdX==0
				return getFrameId(1,2)
			if @spdX>0
				return 0
			if @spdX<0
				return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+4))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@applyGravity!
			@walk!
	think:=>
		if @deathTime==nil
			if @hitsTodor!
				@hp=0
				todor.hp-=1
			if @lastHp!=@hp
				sfxHit!
				@lastHp=@hp
				@flashStart=frameTime
				if @onGround
					@spdY=-1
					if @spdX==0
						if todor.x<@x
							@spdX=-.5
						else
							@spdX=.5
			if rectangleHitsTurn(@getRectangle!)
				@spdX*=-1
			if not @canWalk!
				@spdX*=-1
			if rectangleSwims(@getRectangle!)
				@hp=0
		if @hp<=0 and @deathTime==nil
			@deathTime=frameTime
			sfxBoomExplosion!
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(@flashColorIndex,15)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(@flashColorIndex)
		setPaletteIndex(15)
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
class WalkerActive extends Walker
	checkActive:=>
		@isActive=true
class GrassHead extends Walker
	new:=>
		super!
		@walkFrames={417,418,417,419}
		@standFrame=416
		@flashColorIndex=11
class Walker2 extends Enemy
	new:=>
		super!
		@walkFrames={337,338,337,339}
		@deathFrames=mushroomCloudFrames
		@hp=9
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
	getTileId:=>
		if @deathTime==nil
			if @spdX~=0
				return getFrame(.2,@walkFrames)
			return 336
		getFrame(.1,@deathFrames,@deathTime)
	getScale:=>3
	getFlip:=>
		if @deathTime==nil
			if @spdX==0
				return getFrameId(1,2)
			if @spdX>0
				return 0
			if @spdX<0
				return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-9,y-9),
			Vector(x+9,y+12))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@applyGravity!
			@walk!
	think:=>
		if @deathTime==nil
			if @hitsTodor!
				@hp=0
				todor.hp-=1
			if @lastHp!=@hp
				sfxHit!
				@lastHp=@hp
				@flashStart=frameTime
			if rectangleHitsTurn(@getRectangle!)
				@spdX*=-1
			if not @canWalk!
				@spdX*=-1
		if @hp<=0 and @deathTime==nil
			@deathTime=frameTime
			sfxKaboomExplosion!
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(6,15)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(6)
		setPaletteIndex(15)
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
class Flyer extends Enemy
	new:=>
		super!
		@flyFrames={305,306,305,307}
		@deathFrames=popFrames
		@hp=3
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
		@flashColorIndex=6
	getTileId:=>
		if @deathTime==nil
			if @spdX~=0 or @spdY~=0
				return getFrame(.2,@flyFrames)
			return 304
		getFrame(.1,@deathFrames,@deathTime)
	getFlip:=>
		if @deathTime==nil
			if @spdX==0 and @spdY==0
				return getFrameId(1,2)
			if @spdX>0
				return 0
			if @spdX<0
				return 1
		if todor.x<@x
			return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+3))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@swim!
	think:=>
		if @deathTime==nil
			if @hitsTodor!
				@hp=0
				todor.hp-=1
			if @lastHp!=@hp
				sfxOhnoEnemy!
				@lastHp=@hp
				@flashStart=frameTime
			if rectangleHitsTurn(@getRectangle!) or
					not @canMove(@x+@spdX,@y+@spdY) or
					rectangleSwims(@getRectangle(@x+@spdX,@y+@spdY))
				@spdX*=-1
				@spdY*=-1
		if @hp<=0 and @deathTime==nil
			@deathTime=frameTime
			sfxBoomExplosion!
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(@flashColorIndex,15)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(@flashColorIndex)
		setPaletteIndex(15)
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
class Spider extends Flyer
	new:=>
		super!
		@flyFrames={63,327}
		@flashColorIndex=2
class Flyer2 extends Enemy
	new:=>
		super!
		@flyFrames={385,384,385,386}
		@shootFrames={387,388}
		@deathFrames=popFrames
		@hp=3
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
		@shootStart=random(1,1000)
	getTileId:=>
		if @deathTime==nil
			if not getFrameLooped(.1,@shootFrames,@shootStart)
				return getFrame(.1,@shootFrames,@shootStart)
			return getFrame(.2,@flyFrames)
		getFrame(.1,@deathFrames,@deathTime)
	getFlip:=>
		if @deathTime==nil
			if @spdX==0 and @spdY==0
				return getFrameId(1,2)
			if @spdX>0
				return 0
			if @spdX<0
				return 1
		if todor.x<@x
			return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-4,y-2),
			Vector(x+4,y+2))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@swim!
	think:=>
		if @deathTime==nil
			if frameTime-@shootStart>2000
				@shootStart=frameTime
				lightning=Lightning!
				lightning.x=@x
				lightning.y=@y
			if @hitsTodor!
				@hp=0
				todor.hp-=1
			if @lastHp!=@hp
				sfxOhnoEnemy!
				@lastHp=@hp
				@flashStart=frameTime
			if rectangleHitsTurn(@getRectangle!) or
					not @canMove(@x+@spdX,@y+@spdY) or
					rectangleSwims(@getRectangle(@x+@spdX,@y+@spdY))
				@spdX*=-1
				@spdY*=-1
		if @hp<=0 and @deathTime==nil
			@deathTime=frameTime
			sfxBoomExplosion!
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(15,7)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(15)
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
class Fairy extends Enemy
	new:=>
		super!
		@flyFrames={340,341,342,341}
		@deathFrames=popFrames
		@hp=3
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
		@shootStart=random(1,1000)
		@shotConstructor=Star
	getTileId:=>
		if @deathTime==nil
			return getFrame(.1,@flyFrames)
		getFrame(.1,@deathFrames,@deathTime)
	getFlip:=>
		if @deathTime==nil
			if @spdX==0 and @spdY==0
				return getFrameId(1,2)
			if @spdX>0
				return 0
			if @spdX<0
				return 1
		if todor.x<@x
			return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+3))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@swim!
	think:=>
		if @deathTime==nil
			if frameTime-@shootStart>2000
				@shootStart=frameTime
				shot=@shotConstructor!
				shot.x=@x
				shot.y=@y
				shot.spdX=@spdX*2
			if @hitsTodor!
				@hp=0
				todor.hp-=1
			if @lastHp!=@hp
				sfxOhnoEnemy!
				@lastHp=@hp
				@flashStart=frameTime
			if rectangleHitsTurn(@getRectangle!) or
					not @canMove(@x+@spdX,@y+@spdY) or
					rectangleSwims(@getRectangle(@x+@spdX,@y+@spdY))
				@spdX*=-1
				@spdY*=-1
		if @hp<=0 and @deathTime==nil
			@deathTime=frameTime
			sfxBoomExplosion!
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(12,15)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(12)
		setPaletteIndex(15)
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
class Witch extends Fairy
	new:=>
		super!
		@flyFrames={433}
		@shotConstructor=Curse
class Ghost extends Enemy
	new:(x,y)=>
		super!
		@flyFrames={370,371,370,372}
		@upFrames={368,369,370}
		@downFrames={370,369,368,0,0,0,0,0,0,0,0,0,0}
		@lastHp=@hp
		@upStart=nil
		@downStart=nil
		@moveToTile(x,y)
		@startX=@x
		@startY=@y
		@isGhost=true
	getTileId:=>
		if @upStart!=nil
			return getFrame(.1,@upFrames,@upStart)
		if @downStart!=nil
			return getFrame(.1,@downFrames,@downStart)
		getFrame(.1,@flyFrames)
	getFlip:=>
		if @spdX<0
			return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-2,y-3),
			Vector(x+2,y+3))
	move:=>
		if @upStart==nil and @downStart==nil
			@swim!
	think:=>
		if @upStart!=nil
			if getFrameLooped(.1,@upFrames,@upStart)
				@upStart=nil
		else if @downStart!=nil
			if getFrameLooped(.1,@downFrames,@downStart)
				@downStart=nil
				@upStart=frameTime
				@x=@startX
				@y=@startY
		else
			if @hitsTodor!
				sfxZap!
				@downStart=frameTime
				todor.hp-=1
			else if xyHitsGhostDownTile(@x,@y)
				@downStart=frameTime
			else if rectangleHitsTurn(@getRectangle!)
				@spdX*=-1
				@spdY*=-1
class Swimmer extends Enemy
	new:=>
		super!
		@swimFrames={321,322,321,323}
		@deathFrames=popFrames
		@hp=3
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
	getTileId:=>
		if @deathTime==nil
			if @spdX~=0 or @spdY~=0
				return getFrame(.2,@swimFrames)
			return 15
		getFrame(.1,@deathFrames,@deathTime)
	getFlip:=>
		if @deathTime==nil
			if @spdX==0 and @spdY==0
				return getFrameId(1,2)
			if @spdX>0
				return 0
			if @spdX<0
				return 1
		if todor.x<@x
			return 1
		0
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+3))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@swim!
	think:=>
		if @deathTime==nil
			if @hitsTodor!
				@hp=0
				todor.hp-=1
			if @lastHp!=@hp
				@lastHp=@hp
				@flashStart=frameTime
			if rectangleHitsTurn(@getRectangle!) or
					not @canMove(@x+@spdX,@y+@spdY) or
					not rectangleSwims(@getRectangle(@x+@spdX,@y+@spdY),1)
				@spdX*=-1
				@spdY*=-1
		if @hp<=0 and @deathTime==nil
			@deathTime=frameTime
			sfxBoomExplosion!
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(12,15)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(12)
		setPaletteIndex(15)
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
class Collectible extends Sprite
	new:=>
		super!
		@collectedTime=nil
		insert(collectibles,self)
	remove:=>
		collectibles=removeItem(collectibles,self)
		super!
	hitsTodor:=>
		if not todor.isDead
			rectangleHitsRectangle(@getRectangle!,todor\getRectangle!)
	think:=>
		if @collectedTime==nil and @hitsTodor!
			@collectedTime=frameTime
			@onCollected!
	shouldRemove:=>
		@collectedTime~=nil
	getRectangle:=>
		Rectangle(
			Vector(@x-3,@y-3),
			Vector(@x+3,@y+3))
	move:=>
		return
class Gem extends Collectible
	new:=>
		super!
		@startRoll=random(0,999)
	getTileId:=>
		56
	onCollected:=>
		addScore(1)
	tweakPalette:=>
		rollColors(@startRoll)
		setPaletteIndex(15)
	untweakPalette:=>
		resetPaletteIndices!
class ThinPotion extends Collectible
	new:=>
		super!
		@startRoll=random(0,999)
	getTileId:=>
		74
	onCollected:=>
		todor.shotConstructor=TodorShotNoFall
class FatPotion extends Collectible
	new:=>
		super!
		@startRoll=random(0,999)
	getTileId:=>
		73
	onCollected:=>
		todor.isLavaProof=true
class Sarcophagus extends Decor
	new:=>
		super!
		@openedTime=nil
		@releasedTime=nil
	hitsTodor:=>
		if not todor.isDead
			rectangleHitsRectangle(@getRectangle!,todor\getRectangle!)
	getRectangle:=>
		Rectangle(
			Vector(@x-3,@y-4),
			Vector(@x+4,@y+4))
	think:=>
		if @openedTime==nil
			if @hitsTodor!
				@openedTime=frameTime
		else if @releasedTime==nil and @openedTime+1000<=frameTime
			@releasedTime=frameTime
			with Mummy!
				.x=@x
				.y=@y
				.spdX=if @x<todor.x then .5 else -.5
	getTileId:=>
		if @releasedTime==nil then 79 else 328
class Mummy extends Walker
	new:=>
		super!
		@walkFrames={312,313,312,311}
		@standFrame=314
		@deathFrames={315,316,317,318,319}
		@flashColorIndex=10
class KaporAbductsLudmilla extends Enemy
	new:=>
		super!
		@stealFrames={356,357,356,358}
		@ludmillaFrames={292,293}
		@ludmillaXFrames={0,2,0,-2}
		@layers=3
		@spdX=1
		@lastOhno=frameTime
	checkActive:=>
		true
	think:=>
		if @x<24*8+2*8
			if frameTime-@lastOhno>650
				@lastOhno=frameTime
				sfxOhnoLudmilla(floor((@lastOhno-startTime)/650))
		else if not slammed
			slammed=true
			sfxSlam!
		return
	move:=>
		@swim!
	shouldRemove:=>
		@x>cam.width*1.5
	getTileId:(layer)=>
		switch layer
			when 1
				return getFrame(.2,@stealFrames)
			when 2
				return getFrame(.2,@ludmillaFrames)
			when 3
				return 308
	getCamX:(layer)=>
		result=super(layer)
		switch layer
			when 2
				return result+getFrame(.2,@ludmillaXFrames)
			when 3
				return result-7+getFrame(.2,@ludmillaXFrames)
		result
	getCamY:(layer)=>
		result=super(layer)
		switch layer
			when 2
				return result-7-4
			when 3
				return result-7-4
		result
	getRotate:(layer)=>
		switch layer
			when 2
				return 3
			when 3
				return 3
		0
	getScale:(layer)=>
		switch layer
			when 1
				return 2
		1
class Ludmilla extends Enemy
	new:=>
		super!
		@layers=2
	getTileId:(layer)=>
		switch layer
			when 1
				if not @onGround
					return 258
				return 256
			when 2
				if not @onGround
					return 310
				return 308
	getFlip:=>
		if not @onGround
			return 0
		if todor.x<@x
			return 1
		0
	getCamY:(layer)=>
		result=super(layer)
		switch layer
			when 2
				return result-7
		return result
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+4))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if not @onGround
			@applyGravity!
			@walk!
	think:=>
		if gotLudmillaTime==nil and @hitsTodor!
			gotLudmillaTime=frameTime
			music(TRACK_WIN,0,0,false)
	shouldRemove:=>
		gotLudmillaTime!=nil
class KaporHoldsLudmilla extends Enemy
	new:=>
		super!
		@walkFrames={356,357,356,358}
		@ludmillaXFrames={0,2,0,-2}
		@deathFrames=mushroomCloudFrames
		@shootStart=frameTime
		@hp=30
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
		@ludmillaFrames={292,293}
		@layers=3
	think:=>
		if kaporCaughtTime==nil
			if @deathTime==nil
				if @spdX!=0 and frameTime-@shootStart>2000
					@shootStart=frameTime
					shot=KaporShot!
					shot.x=@x
					shot.y=@y
					shot.spdX=@spdX*2
				if @hitsTodor!
					@hp-=.1
					todor.hp-=.1
				if @lastHp!=@hp
					sfxHit!
					@lastHp=@hp
					@flashStart=frameTime
					if @onGround
						if @spdX==0
							if todor.x<@x
								@spdX=-1
							else
								@spdX=1
				if rectangleHitsTurn(@getRectangle!)
					@spdX*=-1
				if not @canWalk!
					@spdX*=-1
			if @hp<=0 and @deathTime==nil
				@deathTime=frameTime
				sfxKaboomExplosion!
				@releaseLudmilla!
		else
			@releaseLudmilla!
	releaseLudmilla:=>
		ludmilla=Ludmilla!
		ludmilla.x=@x
		ludmilla.y=@y-6
		ludmilla.spdX=1
		ludmilla.spdY=-2
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil
			@applyGravity!
			@walk!
	shouldRemove:=>
		kaporCaughtTime!=nil or @deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-6,y-6),
			Vector(x+6,y+8))
	getTileId:(layer)=>
		switch layer
			when 1
				if @deathTime==nil
					if @spdX!=0
						return getFrame(.2,@walkFrames)
					return 359
				return getFrame(.1,@deathFrames,@deathTime)
			when 2
				if @deathTime==nil
					return getFrame(.2,@ludmillaFrames)
				return 0
			when 3
				if @deathTime==nil
					return 308
				return 0
	getCamX:(layer)=>
		result=super(layer)
		dir=1
		if @spdX!=0
			dir=@spdX/abs(@spdX)
		switch layer
			when 2
				if @spdX!=0
					return result+getFrame(.2,@ludmillaXFrames)*dir
				return result-6*dir
			when 3
				if @spdX!=0
					return result-7*dir+getFrame(.2,@ludmillaXFrames)*dir
				return result-7*dir-6*dir
		result
	getCamY:(layer)=>
		result=super(layer)
		switch layer
			when 2
				return result-7-4
			when 3
				return result-7-4
		result
	getRotate:(layer)=>
		switch layer
			when 2
				if @spdX<0
					return 1
				return 3
			when 3
				if @spdX<0
					return 1
				return 3
		0
	getScale:(layer)=>
		switch layer
			when 1
				return 2
		1
	getFlip:(layer)=>
		switch layer
			when 1
				if @deathTime==nil
					if @spdX>0
						return 0
					if @spdX<0
						return 1
		0
	tweakPalette:=>
		if @deathTime==nil
			if frameTime-@flashStart<100
				setPaletteIndex(3,15)
		else
			setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
	untweakPalette:=>
		setPaletteIndex(3)
		setPaletteIndex(15)
class Hilda extends Enemy
	new:=>
		super!
		@walkFrames={353,354,353,355}
		@walkDecorFrames={309,294,309,310}
		@deathFrames=mushroomCloudFrames
		@kissFrames={374,375}
		@cheekPaletteIndexes={12,6}
		@hp=9
		@deathTime=nil
		@lastHp=@hp
		@flashStart=0
		@layers=3
	think:=>
		if kaporCaughtTime==nil
			if @deathTime==nil
				if @hitsTodor!
					@hp-=.1
					todor.hp-=.1
				if kapor.deathTime==nil
					if rectangleHitsRectangle(
							@getRectangle!,
							kapor\getRectangle!)
						kaporCaughtTime=frameTime
				if @lastHp!=@hp
					sfxOhnoEnemy!
					@lastHp=@hp
					@flashStart=frameTime
					if @onGround
						@spdY=-1
						if @spdX==0
							if todor.x<@x
								@spdX=-1
							else
								@spdX=1
				if rectangleHitsTurn(@getRectangle!)
					@spdX*=-1
				if not @canWalk!
					@spdX*=-1
			if @hp<=0 and @deathTime==nil
				@deathTime=frameTime
				sfxKaboomExplosion!
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @deathTime==nil and kaporCaughtTime==nil
			@applyGravity!
			@walk!
	shouldRemove:=>
		@deathTime!=nil and getFrameLooped(.1,@deathFrames,@deathTime)
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-9,y-9),
			Vector(x+9,y+12))
	getTileId:(layer)=>
		switch layer
			when 1
				if kaporCaughtTime==nil
					if @deathTime==nil
						if @spdX!=0
							return getFrame(.2,@walkFrames)
						return 352
					return getFrame(.1,@deathFrames,@deathTime)
				else
					t=frameTime-kaporCaughtTime
					if t<200
						return 373
					return getFrame(.5,@kissFrames,kaporCaughtTime+200)
			when 2
				if kaporCaughtTime==nil
					if @deathTime==nil
						if @spdX!=0
							return getFrame(.2,@walkDecorFrames)
						return 308
					return 0
				else
					t=frameTime-kaporCaughtTime
					if t<200
						return 0
					return 309
			when 3
				if kaporCaughtTime==nil
					return 0
				else
					return 389
	getCamX:(layer)=>
		result=super(layer)
		switch layer
			when 3
				if kaporCaughtTime!=nil
					t=frameTime-kaporCaughtTime
					if t<200
						return result+18
					return result+getFrameId(.5,2,kaporCaughtTime+200)*-3+18
		result
	getCamY:(layer)=>
		result=super(layer)
		switch layer
			when 2
				return result-7*3
			when 3
				if kaporCaughtTime!=nil
					t=frameTime-kaporCaughtTime
					if t<200
						return result+4
					return result
		result
	getScale:(layer)=>
		switch layer
			when 1
				return 3
			when 2
				return 3
			when 3
				return 2
	getFlip:(layer)=>
		switch layer
			when 1
				if kaporCaughtTime==nil
					if @deathTime==nil
						if @spdX>0
							return 0
						if @spdX<0
							return 1
			when 2
				if kaporCaughtTime==nil
					if @deathTime==nil
						if @spdX>0
							return 0
						if @spdX<0
							return 1
		0
	tweakPalette:=>
		if kaporCaughtTime==nil
			if @deathTime==nil
				if frameTime-@flashStart<100
					setPaletteIndex(3,15)
			else
				setPaletteIndex(15,getFrame(.1,flamePaletteIndexes,@deathTime))
		else
			setPaletteIndex(12,getFrame(.5,@cheekPaletteIndexes,kaporCaughtTime+200))
	untweakPalette:=>
		setPaletteIndex(3)
		setPaletteIndex(12)
		setPaletteIndex(15)
class Todor extends Sprite
	new:=>
		super!
		@swims=false
		@moveFrames={257,258,257,259}
		@swimFrames={274,275,276,275}
		@shootFrames={272,257}
		@deadFrames={292,293}
		@kissFrames={324,325}
		@holdColorFrames={6,4,1,4}
		@ludmillaKissFrames={324,326}
		@facingRight=true
		@blowFireTime=nil
		@hp=3
		@lastHp=@hp
		@flashStart=0
		@isDead=false
		@layers=3
		@holdStart=nil
		@shotConstructor=TodorShotNormal
		@isLavaProof=false
	getTileId:(layer)=>
		switch layer
			when 1
				if gotLudmillaTime==nil
					if @isDead
						return getFrame(.2,@deadFrames)
					if @swims
						return getFrame(.2,@swimFrames)
					if @blowFireTime~=nil
						return 273
					if @shootTime~=nil
						if getFrameLooped(.1,@shootFrames,@shootTime)
							@shootTime=nil
						else
							return getFrame(.1,@shootFrames,@shootTime)
					if not @onGround
						return 258
					if @spdX==0
						return 256
					else
						return getFrame(.1,@moveFrames)
				return getFrame(.5,@kissFrames,gotLudmillaTime)
			when 2
				if gotLudmillaTime==nil
					return 0
				return getFrame(.5,@ludmillaKissFrames,gotLudmillaTime)
			when 3
				if gotLudmillaTime==nil
					return 0
				return 309
	getFlip:(layer)=>
		switch layer
			when 1
				if gotLudmillaTime==nil
					if @isDead
						return getFrameId(1,2)
					if @shootTime~=nil or
						not @onGround or
						@blowFireTime~=nil
						if @facingRight
							return 0
						else
							return 1
					if @spdX==0
						return getFrameId(1,2)
					if @spdX>0
						return 0
					if @spdX<0
						return 1
				return 0
			when 2
				if gotLudmillaTime==nil
					return 0
				return 1-getFrameId(.5,2,gotLudmillaTime)
			when 3
				if gotLudmillaTime==nil
					return 0
				return 1
	getCamX:(layer)=>
		result=super(layer)
		switch layer
			when 2
				return result+8
			when 3
				if gotLudmillaTime==nil
					return result
				return result+8-getFrameId(.5,2,gotLudmillaTime)
		return result
	getCamY:(layer)=>
		result=super(layer)
		switch layer
			when 3
				return result-7
		return result
	getRectangle:(x=@x,y=@y)=>
		Rectangle(
			Vector(x-3,y-3),
			Vector(x+3,y+4))
	canMove:(x,y)=>
		not rectangleHitsWall(@getRectangle(x,y))
	move:=>
		if @isDead or gotLudmillaTime!=nil
			return
		if not @swims
			@applyGravity!
		if @blowFireTime~=nil
			if frameTime-@blowFireTime>.1*#flameStartFrames*1000 or
					@swims
				@blowFireTime=nil
				@onGround=false
		swims=rectangleSwims(@getRectangle!,.6)
		if not @swims and swims
			sfxSplashBody!
			killFlames!
		@swims=swims
		if @swims
			@swim!
		else
			@walk!
	think:=>
		if @isDead or gotLudmillaTime!=nil
			return
		tileX=getTileCoord(@x)
		tileY=getTileCoord(@y)
		if startPoints[tileX..'-'..tileY]
			if startPointX!=tileX or startPointY!=tileY
				startPointX=tileX
				startPointY=tileY
				pmem(PMEM_START_POINT_X,tileX)
				pmem(PMEM_START_POINT_Y,tileY)
		if @swims
			if btn(0)
				@spdY-=.1
			if btn(1)
				@spdY+=.1
			if not btn(0) and not btn(1)
				@spdY=decrease(@spdY,.1)
			if btn(2)
				@spdX-=.1
				@facingRight=false
			if btn(3)
				@spdX+=.1
				@facingRight=true
			if not btn(2) and not btn(3)
				@spdX=decrease(@spdX,.1)
			@spdX=min(1,max(-1,@spdX))
			@spdY=min(1,max(-1,@spdY))
			@holdStart=nil
			if lava[getTileAtCoord(@x,@y)] and not @isLavaProof
				sfxSplashBody!
				@hp-=.1
		else
			if btn(0)
				if @onGround
					@spdY=-2
					sfxJump!
			if btn(2)
				@spdX=-1
				@facingRight=false
			if btn(3)
				@spdX=1
				@facingRight=true
			if not btn(2) and not btn(3)
				@spdX=0
			if btn4.changed
				if @blowFireTime==nil
					if btn4.isOn
						@holdStart=frameTime
						sfxHold!
					else
						if @holdStart!=nil
							if frameTime-@holdStart<500
								spdMulti=if @facingRight then
									1 else -1
								with @shotConstructor!
									.x=@x
									.y=@y
									.spdX=@spdX+2*spdMulti
									.spdY=@spdY
								@shootTime=frameTime
								sfxThrow!
							else
								frames = {
									flameStartFrames
									flameMiddleFrames
									flameEndFrames
								}
								for i,f in ipairs(frames)
									with Flame!
										.frames=f
										.follow=todor
										.offsetX=8*i
								with Flame!
									.frames=flameEndTopFrames
									.follow=todor
									.offsetX=8*3
									.offsetY=-8
								@blowFireTime=frameTime
								sfxBlow!
							@holdStart=nil
		if @hp<@lastHp
			@flashStart=frameTime
		@lastHp=@hp
		if @hp<=0
			@isDead=true
			silence(CH_SFX)
			music(TRACK_DEATH,0,0,false)
			killFlames!
	tweakPalette:=>
		if frameTime-@flashStart<100
			setPaletteIndex(4,15)
		else if @holdStart!=nil and frameTime-@holdStart>500
			setPaletteIndex(4,getFrame(.1,@holdColorFrames,@holdStart+500))
	untweakPalette:=>
		setPaletteIndex(4)
TIC=->
	--msg..="\n\n\n\n#{tonumber('4l',36)}\n"
	frameTime=time!
	handleInput!
	if not coverSkipped
		drawCover!
	elseif startTime==nil
		cam\update!
		drawMap!
	else
		updateSprites!
		cam\update!
		drawMap!
		drawSprites!
		for i=1,ceil(todor.hp)
			setPaletteIndex(15,getFrame(.1,heartPaletteIndexes))
			spr(298,i*8,cam.height-16,0)
		setPaletteIndex(15)
		if todor.isDead or frameTime-todor.flashStart<100
			setBorderColorIndex(6)
		else
			setBorderColorIndex(0)
		scoreToPrint="#{score}"
		w=print(scoreToPrint,cam.width,cam.height,0,true,2)
		print(scoreToPrint,cam.width-w-8,cam.height-2*8,15,true,2)
	print(msg)
	msg=''
OVR=->
	setPalette(defaultPalette)
	if coverSkipped and startTime==nil
		rollColors!
		map(
			0,
			TILE_COUNT_Y*7,
			TILE_COUNT_X,
			TILE_COUNT_Y,
			0,
			0,
			0,
			1,
			nil
		)
		resetPaletteIndices!
		if startPointX==0 and startPointY==0
			print('Press it again to start',58,118)
		else
			print('Press it again to start here',44,113)
			print('or        to reset',74,123)
			drawResetButton(89,122)
	elseif todor.isDead
		rollColors!
		map(
			TILE_COUNT_X,
			TILE_COUNT_Y*7,
			TILE_COUNT_X,
			TILE_COUNT_Y,
			0,
			0,
			0,
			1,
			nil
		)
		resetPaletteIndices!
		print('Press        to try again',58,118)
		drawAltButton(92,117)
	elseif gotLudmillaTime!=nil
		rollColors!
		map(
			TILE_COUNT_X*2,
			TILE_COUNT_Y*7,
			TILE_COUNT_X,
			TILE_COUNT_Y,
			0,
			0,
			0,
			1,
			nil
		)
		resetPaletteIndices!
SCN=(line)->
	if line==0
		if coverSkipped and (startTime==nil or todor.isDead)
			setPalette(grayscalePalette)
		else
			setPalette(defaultPalette)
main!
