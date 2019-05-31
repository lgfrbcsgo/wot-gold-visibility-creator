import {wrap} from 'comlink';
import {ColorOptions, lazy, loadImageData, PackageCreator} from './common';

import forwardResource from './res/forward.png';
import deferredResource from './res/deferred.png';
import config from './res/config.json';

const setupWorker = lazy(() => wrap(new Worker('./worker', {type: 'module'})) as PackageCreator);
const loadForward = lazy(() => loadImageData(forwardResource));
const loadDeferred = lazy(() => loadImageData(deferredResource));

export async function run(color: ColorOptions): Promise<any> {
    const worker = setupWorker();
    return await worker({
        color,
        forward: {
            imageData: await loadForward(),
            path: config.paths.forward
        },
        deferred: {
            imageData: await loadDeferred(),
            path: config.paths.deferred
        }
    });
}
