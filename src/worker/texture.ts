import {expose, transfer} from 'comlink';
import {TextureCreator} from './types';
import {polyfillTextEncoder} from '../polyfills';

const createTexture: TextureCreator = async (imageData, color) => {
    await polyfillTextEncoder();
    const { create } = await import('./wasm/pkg');
    const data = create(color, new Uint8Array(imageData.data), imageData.height, imageData.width);
    return transfer(data, [data.buffer]);
};

expose(createTexture);
