(self.webpackJsonp=self.webpackJsonp||[]).push([[1],[,,,,,,,,,,,,,function(e,t,n){"use strict";n.r(t),function(e){n.d(t,"createModPackage",function(){return s});var a=n(16),r=n(14);const o=new Worker(e,{}),c=async function(e){const t=await async function(){const e=r.textures.map(async({src:e,packagePath:t})=>{const r=n(17)("./"+e),o={packagePath:t,imageData:await i(r)};return Object(a.a)(o,[o.imageData.data.buffer])});return await Promise.all(e)}();return await Object(a.b)(e)(t)}(o);async function s(e){await o;const t=await c;return await t.create(e)}async function i(e){const t=await async function(e){const t=new Image;t.src=e,t.decoding="async";const n=new Promise((e,n)=>{t.onload=(()=>e(t)),t.onerror=(()=>n())});t.decode&&await t.decode();return self.createImageBitmap?await self.createImageBitmap(await n):await n}(e),n=document.createElement("canvas");n.height=t.height,n.width=t.width;const a=n.getContext("2d");return a.drawImage(t,0,0),a.getImageData(0,0,t.width,t.height)}}.call(this,n(15))},function(e){e.exports={textures:[{src:"deferred.png",packagePath:"res/particles/content_deferred/PFX_textures/eff_tex.dds"},{src:"forward.png",packagePath:"res/particles/content_forward/PFX_textures/eff_tex.dds"}]}},function(e,t,n){e.exports=n.p+"2.65554bd67207cf9df3f9.worker.js"},function(e,t,n){"use strict";function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{},a=Object.keys(n);"function"==typeof Object.getOwnPropertySymbols&&(a=a.concat(Object.getOwnPropertySymbols(n).filter(function(e){return Object.getOwnPropertyDescriptor(n,e).enumerable}))),a.forEach(function(t){r(e,t,n[t])})}return e}function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}n.d(t,"b",function(){return u}),n.d(t,"a",function(){return d});const o=Symbol("Comlink.proxy"),c=Symbol("Comlink.endpoint"),s=new WeakSet,i=new Map([["proxy",{canHandle:e=>e&&e[o],serialize(e){const{port1:t,port2:n}=new MessageChannel;return function e(t,n=self){n.addEventListener("message",async r=>{if(!r||!r.data)return;const{id:c,type:i,path:u}=a({path:[]},r.data),f=(r.data.argumentList||[]).map(g);let p;try{const n=u.slice(0,-1).reduce((e,t)=>e[t],t),a=u.reduce((e,t)=>e[t],t);switch(i){case 0:p=await a;break;case 1:n[u.slice(-1)[0]]=g(r.data.value),p=!0;break;case 2:p=await a.apply(n,f);break;case 3:{const e=await new a(...f);p=function(e){return Object.assign(e,{[o]:!0})}(e)}break;case 4:{const{port1:n,port2:a}=new MessageChannel;e(t,a),p=d(n,[n])}break;default:console.warn("Unrecognized message",r.data)}}catch(e){p=e,s.add(e)}const[w,m]=l(p);n.postMessage(a({},w,{id:c}),m)});n.start&&n.start()}(e,t),[n,[n]]},deserialize:e=>(e.start(),u(e))}],["throw",{canHandle:e=>s.has(e),serialize(e){const t=e instanceof Error;let n=e;return t&&(n={isError:t,message:e.message,stack:e.stack}),[n,[]]},deserialize(e){if(e.isError)throw Object.assign(new Error,e);throw e}}]]);function u(e){return function e(t,n=[]){const a=new Proxy(new Function,{get(r,o){if("then"===o){if(0===n.length)return{then:()=>a};const e=w(t,{type:0,path:n.map(e=>e.toString())}).then(g);return e.then.bind(e)}return e(t,[...n,o])},set(e,a,r){const[o,c]=l(r);return w(t,{type:1,path:[...n,a].map(e=>e.toString()),value:o},c).then(g)},apply(a,r,o){const s=n[n.length-1];if(s===c)return w(t,{type:4}).then(g);if("bind"===s)return e(t,n.slice(0,-1));const[i,u]=f(o);return w(t,{type:2,path:n.map(e=>e.toString()),argumentList:i},u).then(g)},construct(e,a){const[r,o]=f(a);return w(t,{type:3,path:n.map(e=>e.toString()),argumentList:r},o).then(g)}});return a}(e)}function f(e){const t=e.map(l);return[t.map(e=>e[0]),(n=t.map(e=>e[1]),Array.prototype.concat.apply([],n))];var n}const p=new WeakMap;function d(e,t){return p.set(e,t),e}function l(e){for(const[t,n]of i)if(n.canHandle(e)){const[a,r]=n.serialize(e);return[{type:3,name:t,value:a},r]}return[{type:0,value:e},p.get(e)||[]]}function g(e){switch(e.type){case 3:return i.get(e.name).deserialize(e.value);case 0:return e.value}}function w(e,t,n){return new Promise(r=>{const o=new Array(4).fill(0).map(()=>Math.floor(Math.random()*Number.MAX_SAFE_INTEGER).toString(16)).join("-");e.addEventListener("message",function t(n){n.data&&n.data.id&&n.data.id===o&&(e.removeEventListener("message",t),r(n.data))}),e.start&&e.start(),e.postMessage(a({id:o},t),n)})}},function(e,t,n){var a={"./deferred.png":18,"./forward.png":19,"./package.config":14,"./package.config.json":14};function r(e){var t=o(e);return n(t)}function o(e){if(!n.o(a,e)){var t=new Error("Cannot find module '"+e+"'");throw t.code="MODULE_NOT_FOUND",t}return a[e]}r.keys=function(){return Object.keys(a)},r.resolve=o,e.exports=r,r.id=17},function(e,t,n){e.exports=n.p+"9593a0fa659ce650827e90313dc46b21.png"},function(e,t,n){e.exports=n.p+"d446dfd6135a0db6293e866208f16ef0.png"}]]);