const cliProgress = require('cli-progress')
const axios = require('axios')

let obj = {
    current: 0,
    next: 0
}
let total = 0

// container
const multibar = new cliProgress.MultiBar({
    clearOnComplete: false,
    hideCursor: true,
    format: '{version} | {bar} {percentage}% | {value}/{total}'
}, cliProgress.Presets.shades_grey)

// bars
const b1 = multibar.create(0, 0)
const b2 = multibar.create(0, 0)

setInterval(async () => {
    var ret = ''
    try {
        ret = await axios.get('http://canary.jeromedecoster.net/')
        ret = ret.data.trim()
    } catch(err) {}
    
    if (ret.includes('1-0-0')) obj.current++
    else if  (ret.includes('1-1-0')) obj.next++

    total =  obj.current +  obj.next

    b1.update(obj.current, {version: '1-0-0'})
    b2.update(obj.next, {version: '1-1-0'})
    b1.setTotal(total)
    b2.setTotal(total)

}, 500)
