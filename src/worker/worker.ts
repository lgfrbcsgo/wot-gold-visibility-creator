import {expose, transfer} from 'comlink';
import {polyfillTextEncoder} from '../polyfills';
import {Rgba} from '../types';
import {WorkerExports, ImageData} from './types';

async function encodeTexture(imageData: ImageData, color: Rgba) {
    await polyfillTextEncoder();
    const {encode} = await import('./wasm/pkg');

    const data = encode(imageData, color);

    return transfer(data, [data.buffer]);
}

async function decodeResource(data: Uint8Array): Promise<ImageData> {
    await polyfillTextEncoder();
    const {decode} = await import('./wasm/pkg');

    const rustImageData = decode(data);
    try {
        const imageData = {
            data: rustImageData.data,
            width: rustImageData.width,
            height: rustImageData.height
        };
        return transfer(imageData, [imageData.data.buffer]);
    } finally {
        rustImageData.free();
    }
}

expose(<WorkerExports>{
    encodeTexture,
    decodeResource
});
