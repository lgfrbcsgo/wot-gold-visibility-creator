import {loadImageData} from './util/util';
import {ColorOptions, WorkerOptions} from './util/types';

import forwardResourcePath from './res/forward.png';
import deferredResourcePath from './res/deferred.png';
import packagePaths from './res/paths.json';

export async function run(color: ColorOptions): Promise<any> {
    const bitmapForward = await loadImageData(forwardResourcePath);
    const bitmapDeferred = await loadImageData(deferredResourcePath);

    const options: WorkerOptions = {
        color,
        textureForward: {
            height: bitmapForward.height,
            width: bitmapForward.width,
            path: packagePaths.forward
        },
        textureDeferred: {
            height: bitmapDeferred.height,
            width: bitmapDeferred.width,
            path: packagePaths.deferred
        }
    };

    const worker = new Worker('./worker', { type: 'module' });

    const result = new Promise((resolve, reject) => {
        worker.addEventListener('error', ({ message }) =>  reject(message));
        worker.addEventListener('message', ({ data }) => resolve(data));
    });

    worker.postMessage(options);
    worker.postMessage(bitmapForward.data.buffer,[bitmapForward.data.buffer]);
    worker.postMessage(bitmapDeferred.data.buffer,[bitmapDeferred.data.buffer]);

    try {
        return await result;
    } finally {
        worker.terminate();
    }
}

