const jimp = require('jimp')

main()

async function main() {
	let { bitmap: { data, width, height } } = await jimp.read('t06.png')
	//console.log(width,height)
	let colors={}
	for (let i=0;i<data.length;i+=4) {
		let r=data[i]
		let g=data[i+1]
		let b=data[i+2]
		if (r||g||b) {
			let hex=rgbToHex(r,g,b)
			let index=i/4
			let x=index%width
			let y=Math.floor(index/width)
			let o = colors[hex] = colors[hex]||{
				x1:x,
				y1:y,
				x2:x,
				y2:y,
				values:[],
			}
			o.x1=Math.min(o.x1,x)
			o.y1=Math.min(o.y1,y)
			o.x2=Math.max(o.x2,x)
			o.y2=Math.max(o.y2,y)
		}
	}
	let hexes=Object.keys(colors)
	//console.log(colors)
	for (let i=0;i<data.length;i+=4) {
		let r=data[i]
		let g=data[i+1]
		let b=data[i+2]
		let hex=rgbToHex(r,g,b)
		let index=i/4
		let x=index%width
		let y=Math.floor(index/width)
		for (let h of hexes) {
			let o=colors[h]
			//console.log(index,width,x,y)
			if (h===hex) {
				o.values.push(1)
			} else if (x>=o.x1&&x<=o.x2&&y>=o.y1&&y<=o.y2) {
				o.values.push(0)
			}
		}
	}
	for (let hex of hexes) {
		let nums=[]
		let o=colors[hex]
		while (o.values.length) {
			let _51=o.values.splice(0,51)
			let sum=_51.reduce((sum,v,i)=>sum+v*Math.pow(2,i),0)
			nums.push(sum.toString(36))
		}
		o.values=nums.join(',')
		console.log(JSON.stringify(o,undefined,'\t'))
	}
}

function rgbToHex(r,g,b) {
	let color=(r<<16)+(g<<8)+b
	return ('00000'+color.toString(16)).slice(-6)
}
