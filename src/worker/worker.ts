import {expose, transfer, proxy} from 'comlink';
import {IWorkerInitializer} from "./interface";
import {IRgba} from "../common";

const setupWasmWorker: IWorkerInitializer = async config => {
    const { Worker } = await import('./wasm/pkg');
    class TransferringWorker extends Worker {
        create(color: IRgba) {
            const data = super.create(color);
            return transfer(data, [data.buffer]);
        }
    }
    return proxy(new TransferringWorker(config));
};

expose(setupWasmWorker);