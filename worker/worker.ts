import {expose, transfer} from 'comlink';
import {WorkerExport} from './types';


const doCreatePackage = import('./wasm/pkg').then(({ create_package }) => create_package);


const createPackage: WorkerExport = async ({ r, g, b, alpha }, textureForward, textureDeferred) => {
    const packageData = (await doCreatePackage)(
        r, g, b, alpha,
        new Uint8Array(textureForward.imageData.data), textureForward.imageData.height, textureForward.imageData.width, textureForward.path,
        new Uint8Array(textureDeferred.imageData.data), textureDeferred.imageData.height, textureDeferred.imageData.width, textureDeferred.path
    );

    return transfer(packageData, [packageData.buffer]);
};


expose(createPackage);