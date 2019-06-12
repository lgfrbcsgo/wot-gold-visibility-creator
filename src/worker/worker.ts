import {expose, transfer, proxy} from 'comlink';
import {CreatorWorkerInitializer} from './types';
import {Rgba} from '../types';

const setupWasmWorker: CreatorWorkerInitializer = async config => {
    const WasmCreatorWorker = await lazyLoadWorker();
    class TransferringCreatorWorker extends WasmCreatorWorker {
        create(color: Rgba) {
            const data = super.create(color);
            return transfer(data, [data.buffer]);
        }
    }
    return proxy(new TransferringCreatorWorker(config));
};

expose(setupWasmWorker);

async function lazyLoadWorker() {
    if (!self.TextEncoder || !self.TextDecoder) {
        // polyfill required by Edge
        Object.assign(self, await import('text-encoding'));
    }
    const { WasmCreatorWorker } = await import('./wasm/pkg');
    return WasmCreatorWorker;
}