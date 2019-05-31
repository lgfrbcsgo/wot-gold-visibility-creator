import {wrap} from 'comlink';
import {ColorOptions, lazy, loadImageData, PackageCreator} from './common';

import forwardResourcePath from './res/forward.png';
import deferredResourcePath from './res/deferred.png';
import packagePaths from './res/paths.json';

const setupWorker = lazy(() => wrap(new Worker('./worker', {type: 'module'})) as PackageCreator);
const loadForward = lazy(() => loadImageData(forwardResourcePath));
const loadDeferred = lazy(() => loadImageData(deferredResourcePath));

export async function run(color: ColorOptions): Promise<any> {
    const worker = setupWorker();
    return await worker({
        color,
        forward: {
            imageData: await loadForward(),
            path: packagePaths.forward
        },
        deferred: {
            imageData: await loadDeferred(),
            path: packagePaths.deferred
        }
    });
}
