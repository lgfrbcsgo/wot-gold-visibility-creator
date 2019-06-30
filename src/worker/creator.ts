import {expose, transfer, proxy} from 'comlink';
import {CreatorWorkerInitializer} from './types';
import {Rgba} from '../types';

const setupWasmWorker: CreatorWorkerInitializer = async config => {
    const { WasmCreatorWorker } = await import('./wasm/pkg');
    class TransferringCreatorWorker extends WasmCreatorWorker {
        create(color: Rgba) {
            const data = super.create(color);
            return transfer(data, [data.buffer]);
        }
    }
    // proxying return values leaks memory https://github.com/GoogleChromeLabs/comlink/issues/63
    // this is fine here since ideally this function should ever be called once
    return proxy(new TransferringCreatorWorker(config));
};

expose(setupWasmWorker);
