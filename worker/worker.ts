import {expose, transfer} from 'comlink';
import {WorkerExport} from './types';

const wasmModule = import('./wasm/pkg');

const createPackage: WorkerExport = async options => {
    const result = (await wasmModule).create_package(options);
    return transfer(result, [result.buffer]);
};

expose(createPackage);