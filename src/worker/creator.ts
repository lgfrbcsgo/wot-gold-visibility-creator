import {expose, transfer} from 'comlink';
import {Creator} from './types';
import {polyfillTextEncoder} from '../polyfills';

const create: Creator = async (imageData, color) => {
    await polyfillTextEncoder();
    const { create } = await import('./wasm/pkg');
    const data = create(imageData, color);
    return transfer(data, [data.buffer]);
};

expose(create);

