import {expose, transfer} from 'comlink';
import {Creator} from './types';

const create: Creator = async (imageData, color) => {
    await polyfillTextEncoder();
    const { create } = await import('./wasm/pkg');
    const data = create(imageData, color);
    return transfer(data, [data.buffer]);
};

expose(create);

async function polyfillTextEncoder() {
    if (!self.TextEncoder || !self.TextDecoder) {
        const {TextEncoder, TextDecoder} = await import('text-encoding');
        self.TextEncoder = self.TextEncoder || TextEncoder;
        self.TextDecoder = self.TextDecoder || TextDecoder;
    }
}