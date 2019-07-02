import {expose, transfer} from 'comlink';
import {Creator} from './types';

const create: Creator = async (imageData, color) => {
    const { create } = await import('./wasm/pkg');
    const data = create(imageData, color);
    return transfer(data, [data.buffer]);
};

expose(create);
