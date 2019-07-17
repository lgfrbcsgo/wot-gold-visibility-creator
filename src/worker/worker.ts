import {expose, transfer} from 'comlink';
import {polyfillTextEncoder} from '../polyfills';
import {Rgba} from '../types';
import {WorkerExports} from './types';

async function encodeTexture(imageData: ImageData, color: Rgba) {
    await polyfillTextEncoder();
    const {encode} = await import('./wasm/pkg');

    const data = encode(imageData, color);

    return transfer(data, [data.buffer]);
}

expose(<WorkerExports>{
    encodeTexture
});
